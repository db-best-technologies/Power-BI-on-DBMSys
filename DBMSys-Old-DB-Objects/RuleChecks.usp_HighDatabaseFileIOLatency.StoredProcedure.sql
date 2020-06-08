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
/****** Object:  StoredProcedure [RuleChecks].[usp_HighDatabaseFileIOLatency]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_HighDatabaseFileIOLatency]
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
';with Latency as
		(' + replace(@SQL, '@CounterID', '88') + '
		)
	, ReadIOPS as
		(' + replace(@SQL1, '@CounterID', '80') + '
		)
	, WriteIOPS as
		(' + replace(@SQL1, '@CounterID', '83') + '
		)
	, TransferIOPS as
		(' + replace(@SQL1, '@CounterID', '86') + '
		)
select @ClientID, @PRR_ID, l.T_MOB_ID, IDB_ID, IDB_Name, DBF_ID, DBF_Name, DFT_Name, DSK_ID, DSK_Path, l.T_Value, r.T_Value, w.T_Value, f.T_Value
from Latency l
	inner join Inventory.InstanceDatabases on IDB_MOB_ID = l.T_MOB_ID
												and IDB_Name = SUBSTRING(T_InstanceName, 2, CHARINDEX('')'', l.T_InstanceName, 1) - 2)
	inner join Inventory.DatabaseFiles on DBF_MOB_ID = l.T_MOB_ID
											and DBF_IDB_ID = IDB_ID
											and DBF_FileName = SUBSTRING(T_InstanceName, CHARINDEX('')'', l.T_InstanceName, 1) + 2, 1000)
	inner join Inventory.DatabaseFileTypes on DFT_ID = DBF_DFT_ID
	inner join Inventory.Disks on DSK_ID = DBF_DSK_ID
	left join ReadIOPS r on r.T_MOB_ID = l.T_MOB_ID
								and r.T_InstanceName = l.T_InstanceName
	left join WriteIOPS w on w.T_MOB_ID = l.T_MOB_ID
								and w.T_InstanceName = l.T_InstanceName
	left join TransferIOPS f on f.T_MOB_ID = l.T_MOB_ID
								and f.T_InstanceName = l.T_InstanceName'

exec sp_executesql @SQL,
						N'@ClientID int,
							@PRR_ID int,
							@PlatformCategoryID tinyint,
							@SystemID int,
							@FromDate date,
							@ToDate date,
							@FirstRawDataDate datetime2(3),
							@FirstHourlyDataDate datetime2(3),
							@LowerValue decimal(18, 5),
							@UpperValue decimal(18, 5)',
						@ClientID = @ClientID,
						@PRR_ID = @PRR_ID,
						@PlatformCategoryID = 1,
						@SystemID = 3,
						@FromDate = @FromDate,
						@ToDate = @ToDate,
						@FirstRawDataDate = @FirstRawDataDate,
						@FirstHourlyDataDate = @FirstHourlyDataDate,
						@LowerValue = @LowerValue,
						@UpperValue = @UpperValue
GO
