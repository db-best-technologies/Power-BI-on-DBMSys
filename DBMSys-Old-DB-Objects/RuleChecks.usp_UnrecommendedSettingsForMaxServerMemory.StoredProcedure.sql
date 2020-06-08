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
/****** Object:  StoredProcedure [RuleChecks].[usp_UnrecommendedSettingsForMaxServerMemory]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [RuleChecks].[usp_UnrecommendedSettingsForMaxServerMemory]
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
		@FirstHourlyDataDate datetime2(3)

exec RuleChecks.usp_GetPerformanceCounterAggregatedResult @ClientID = @ClientID,
												@PRR_ID = @PRR_ID,
												@FromDate = @FromDate,
												@ToDate = @ToDate,
												@RTH_ID = @RTH_ID,
												@PlatformCategoryID = 1,
												@SystemID = 1,
												@CounterID = 1,
												@IncludeInstanceName = 0,
												@ResultFormat = 'int',
												@ReturnSQLOnly = 1,
												@SQL = @SQL output,
												@FirstRawDataDate = @FirstRawDataDate output,
												@FirstHourlyDataDate = @FirstHourlyDataDate output

set @SQL = 
';with ServerMemory as
		(' + replace(replace(replace(@SQL, '@PlatformCategoryID', '2'), '@SystemID', '4'), '@CounterID', '12') + '
		)
	, InstanceMemory as
		(' + replace(replace(replace(@SQL, '@PlatformCategoryID', '1'), '@SystemID', '1'), '@CounterID', '39') + '
		)
select @ClientID, @PRR_ID, ICF_MOB_ID, OSS_TotalPhysicalMemoryMB, ICF_Value, OtherInstanceCount, s.T_Value, i.T_Value
from Inventory.InstanceConfigurations
	inner join Inventory.InstanceConfigurationTypes on ICT_ID = ICF_ICT_ID
	inner join Inventory.MonitoredObjects d on ICF_MOB_ID = d.MOB_ID
	inner join Inventory.MonitoredObjects o on o.MOB_PLT_ID = 2
												and d.MOB_Name + ''\'' like o.MOB_Name + ''\%''
	inner join Inventory.OSServers on OSS_MOB_ID = o.MOB_ID
	outer apply (select COUNT(*) OtherInstanceCount
					from Inventory.MonitoredObjects oi
					where oi.MOB_PLT_ID = 1
						and oi.MOB_ID <> d.MOB_ID
						and oi.MOB_Name + ''\'' like o.MOB_Name + ''\%'') oi
	inner join ServerMemory s on s.T_MOB_ID = o.MOB_ID
	inner join InstanceMemory i on i.T_MOB_ID = d.MOB_ID
where ICT_Name = ''max server memory (MB)''
	and ICF_Value > OSS_TotalPhysicalMemoryMB'

exec sp_executesql @SQL,
						N'@ClientID int,
							@PRR_ID int,
							@FromDate date,
							@ToDate date,
							@FirstRawDataDate datetime2(3),
							@FirstHourlyDataDate datetime2(3)',
						@ClientID = @ClientID,
						@PRR_ID = @PRR_ID,
						@FromDate = @FromDate,
						@ToDate = @ToDate,
						@FirstRawDataDate = @FirstRawDataDate,
						@FirstHourlyDataDate = @FirstHourlyDataDate
GO
