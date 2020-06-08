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
/****** Object:  StoredProcedure [RuleChecks].[usp_HighNumberOfBlockingEvents]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_HighNumberOfBlockingEvents]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

declare @LowerValue decimal(18, 5),
		@UpperValue decimal(18, 5)

select @LowerValue = RTH_LowerValue,
	@UpperValue = RTH_UpperValue
from BusinessLogic.RuleThresholds
where RTH_ID = @RTH_ID

select @ClientID, @PRR_ID, MOB_ID, WaitingTasks, WaitingTime
from Inventory.MonitoredObjects
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = MOB_ID
	inner join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
	cross apply (select sum(case when CIN_Name = 'Waiting Tasks' then CRS_Value else 0 end) WaitingTasks,
						sum(case when CIN_Name = 'Wait Time (Sec)' then CRS_Value else 0 end) WaitingTime
					from PerformanceData.CounterResults
						inner join PerformanceData.CounterInstances on CIN_ID = CRS_InstanceID
						inner join PerformanceData.VW_Counters on SystemID = CRS_SystemID
																and CounterID = CRS_CounterID
					where CRS_MOB_ID = MOB_ID
						and CRS_DateTime between @FromDate and @ToDate
						and SystemID = 5
						and CounterName like 'LCK%') r
where PLT_PLC_ID = 1
	and (WaitingTasks >= @LowerValue
		or @LowerValue is null)
	and (WaitingTasks <= @UpperValue
		or @UpperValue is null)
GO
