/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2016 (13.0.1601)
    Source Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2016
    Target Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Target Database Engine Type : Standalone SQL Server
*/
USE [DBMSYS_CityofTucson_City_of_Tucson]
GO
/****** Object:  StoredProcedure [RuleChecks].[usp_ReplicationLatency]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_ReplicationLatency]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted
declare @SQL nvarchar(max),
		@SQL1 nvarchar(max),
		@FirstRawDataDate datetime2(3),
		@FirstHourlyDataDate datetime2(3),
		@LowerValue decimal(18, 5),
		@UpperValue decimal(18, 5)

exec RuleChecks.usp_GetPerformanceCounterAggregatedResult @ClientID = @ClientID,
												@PRR_ID = @PRR_ID,
												@FromDate = @FromDate,
												@ToDate = @ToDate,
												@RTH_ID = @RTH_ID,
												@PlatformCategoryID = 1,
												@SystemID = 1,
												@CounterID = 1,
												@IncludeInstanceName = 1,
												@ResultFormat = 'int',
												@ReturnSQLOnly = 1,
												@SQL = @SQL output,
												@FirstRawDataDate = @FirstRawDataDate output,
												@FirstHourlyDataDate = @FirstHourlyDataDate output,
												@LowerValue = @LowerValue output,
												@UpperValue = @UpperValue output

exec RuleChecks.usp_GetPerformanceCounterAggregatedResult @ClientID = @ClientID,
												@PRR_ID = @PRR_ID,
												@FromDate = @FromDate,
												@ToDate = @ToDate,
												@RTH_ID = null,
												@PlatformCategoryID = 1,
												@SystemID = 1,
												@CounterID = 1,
												@IncludeInstanceName = 1,
												@ResultFormat = 'int',
												@ReturnSQLOnly = 1,
												@SQL = @SQL1 output,
												@FirstRawDataDate = @FirstRawDataDate output,
												@FirstHourlyDataDate = @FirstHourlyDataDate output,
												@LowerValue = @LowerValue output,
												@UpperValue = @UpperValue output
set @SQL =
';with TotalLatency as
		(' + replace(@SQL, '@CounterID', '173') + '
		)
	, DistLatency as
		(' + replace(@SQL1, '@CounterID', '171') + '
		)
	, SubLatency as
		(' + replace(@SQL1, '@CounterID', '172') + '
		)
select @ClientID, @PRR_ID, TRB_MOB_ID, IDB_ID, IDB_Name, TRP_ID, TRP_Name, TRB_Subscriber_MOB_ID, TRB_SubscriberServerName, TRB_Subscriber_IDB_ID,
	TRB_SubscriberDatabaseName, d.T_Value DistLatency, s.T_Value SubLatency, t.T_Value TotalLatency
from TotalLatency t
	inner join DistLatency d on t.T_MOB_ID = d.T_MOB_ID
									and t.T_InstanceName like d.T_InstanceName + '', To%''
	inner join SubLatency s on t.T_MOB_ID = s.T_MOB_ID
									and t.T_InstanceName = s.T_InstanceName
	cross apply (select parsename(InstName, 4) Publication,
						parsename(InstName, 1) Subscriber,
						parsename(InstName, 2) SubscriberDB
					from (select replace(replace(replace(replace(replace(t.T_InstanceName, '', '', ''.''), ''('', ''.''), '')'', ''''), ''Publication: '', ''''), ''To DB: '', '''') InstName) t
				) i
	inner join Inventory.TransactionalReplicationPublications on TRP_MOB_ID = t.T_MOB_ID
																	and TRP_Name = Publication
	inner join Inventory.InstanceDatabases on IDB_ID = TRP_IDB_ID
	inner join Inventory.TransactionalReplicationSubscriptions on TRB_TRP_ID = TRP_ID
																and TRB_SubscriberServerName = Subscriber
																and TRB_SubscriberDatabaseName = SubscriberDB'

exec sp_executesql @SQL,
						N'@ClientID int,
							@PRR_ID int,
							@PlatformCategoryID tinyint,
							@FromDate date,
							@ToDate date,
							@FirstRawDataDate datetime2(3),
							@FirstHourlyDataDate datetime2(3),
							@SystemID int,
							@LowerValue decimal(18, 5),
							@UpperValue decimal(18, 5)',
						@ClientID = @ClientID,
						@PRR_ID = @PRR_ID,
						@PlatformCategoryID = 1,
						@FromDate = @FromDate,
						@ToDate = @ToDate,
						@FirstRawDataDate = @FirstRawDataDate,
						@FirstHourlyDataDate = @FirstHourlyDataDate,
						@SystemID = 3,
						@LowerValue = @LowerValue,
						@UpperValue = @UpperValue
GO
