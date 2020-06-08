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
/****** Object:  StoredProcedure [RuleChecks].[usp_GetPerformanceCounterAggregatedResult]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_GetPerformanceCounterAggregatedResult]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int,
	@PlatformCategoryID tinyint,
	@SystemID int,
	@CounterID int,
	@InstanceName varchar(900) = null,
	@IncludeInstanceName bit,
	@ResultFormat varchar(50),
	@UseRawData bit = 1,
	@UseHourlyDate bit = 1,
	@UseDailyData bit = 0,
	@ReturnSQLOnly bit = 0,
	@SQL nvarchar(max) = null output,
	@FirstRawDataDate datetime2(3) = null output,
	@FirstHourlyDataDate datetime2(3) = null output,
	@LowerValue decimal(18, 5) = null output,
	@UpperValue decimal(18, 5) = null output
as
set nocount on
set transaction isolation level read uncommitted
declare @ValueAggregationString nvarchar(max),
		@Percentile tinyint,
		@IsLowerBetter bit
		
select @LowerValue = RTH_LowerValue,
	@UpperValue = RTH_UpperValue,
	@IsLowerBetter = RTH_IsLowerBetter
from BusinessLogic.RuleThresholds
where RTH_ID = @RTH_ID

select @FirstRawDataDate = MIN(CRS_DateTime)
from PerformanceData.CounterResults

select @FirstHourlyDataDate = MIN(CRS_DateTime)
from PerformanceData.CounterResults_Hourly

select @ValueAggregationString = replace(replace(replace(VAT_Syntax,
										'$PEAK$', case when @IsLowerBetter = 0 then 'MIN'
														else 'MAX'
													end),
										'$PERCENTILE$', isnull(cast(PKN_PercentileIfNeeded/100. as nvarchar(10)), '')),
										'$ORDER$', case when @IsLowerBetter = 0 then 'DESC'
														else 'ASC'
													end)
from BusinessLogic.PackageRunRules
	inner join BusinessLogic.PackageRuns on PKN_ID = PRR_PKN_ID
	inner join BusinessLogic.ValueAggregationTypes on VAT_ID = PKN_VAT_ID
where PRR_ID = @PRR_ID

set @SQL =
'select @ClientID ClientID, @PRR_ID T_PRR_ID, MOB_ID T_MOB_ID, r.*
from Inventory.MonitoredObjects
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = MOB_ID
	inner join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
	cross apply (select top 1 ' + case @IncludeInstanceName
										when 1 then 'max(CIN_Name) T_InstanceName, '
										else ''
									end
								+ 'cast(' + @ValueAggregationString + ' as ' + @ResultFormat + ') T_Value
					from (select cast(null as varchar(900)) CRS_InstanceID, cast(null as decimal(18, 5)) CRS_Value, 1 IsDummy' + CHAR(13)+CHAR(10)
							+ case when @UseRawData = 1
									then 'union all
											select CRS_InstanceID, CRS_Value, 0 IsDummy
											from PerformanceData.CounterResults with (forceseek)
											where CRS_MOB_ID = MOB_ID
												and CRS_DateTime between @FromDate and @ToDate
												and CRS_SystemID = @SystemID
												and CRS_CounterID = @CounterID' + CHAR(13)+CHAR(10)
									else ''
								end
							+ case when @UseHourlyDate = 1
									then 'union all
											select CRS_InstanceID, CRS_AvgValue, 0 IsDummy
											from PerformanceData.CounterResults_Hourly with (forceseek)
											where CRS_MOB_ID = MOB_ID
												and CRS_DateTime between @FromDate and @ToDate
												' + case when @UseRawData = 1
														then 'and CRS_DateTime < @FirstRawDataDate' + CHAR(13)+CHAR(10)
														else ''
													end
												+ 'and CRS_SystemID = @SystemID
												and CRS_CounterID = @CounterID' + CHAR(13)+CHAR(10)
									else ''
								end
							+ case when @UseDailyData = 1
									then 'union all
											select CRS_InstanceID, CRS_AvgValue, 0 IsDummy
											from PerformanceData.CounterResults_Daily with (forceseek)
											where CRS_MOB_ID = MOB_ID
												and CRS_DateTime between @FromDate and @ToDate
												' + case when @UseRawData = 1
														then 'and CRS_DateTime < @FirstRawDataDate' + CHAR(13)+CHAR(10)
														else ''
													end
												+ case when @UseHourlyDate = 1
														then 'and CRS_DateTime < @FirstHourlyDataDate' + CHAR(13)+CHAR(10)
														else ''
													end
												+ 'and CRS_SystemID = @SystemID
												and CRS_CounterID = @CounterID'
									else ''
								end
							+ ') r
						left join PerformanceData.CounterInstances on CIN_ID = CRS_InstanceID
					where IsDummy = 0
						' + case when @InstanceName is not null
								then 'and CIN_Name = @InstanceName'
								else ''
							end
					+ ') r
where PLT_PLC_ID = @PlatformCategoryID'
		+ case when @LowerValue is not null
				then ' and T_Value >= @LowerValue'
				else ''
			end
		+ case when @UpperValue is not null
				then ' and T_Value <= @UpperValue'
				else ''
			end

if @ReturnSQLOnly = 0
	exec sp_executesql @SQL,
						N'@ClientID int,
							@PRR_ID int,
							@PlatformCategoryID tinyint,
							@FromDate date,
							@ToDate date,
							@FirstRawDataDate datetime2(3),
							@FirstHourlyDataDate datetime2(3),
							@SystemID int,
							@CounterID int,
							@InstanceName varchar(900),
							@LowerValue decimal(18, 5),
							@UpperValue decimal(18, 5)',
						@ClientID = @ClientID,
						@PRR_ID = @PRR_ID,
						@PlatformCategoryID = @PlatformCategoryID,
						@FromDate = @FromDate,
						@ToDate = @ToDate,
						@FirstRawDataDate = @FirstRawDataDate,
						@FirstHourlyDataDate = @FirstHourlyDataDate,
						@SystemID = @SystemID,
						@CounterID = @CounterID,
						@InstanceName = @InstanceName,
						@LowerValue = @LowerValue,
						@UpperValue = @UpperValue
GO
