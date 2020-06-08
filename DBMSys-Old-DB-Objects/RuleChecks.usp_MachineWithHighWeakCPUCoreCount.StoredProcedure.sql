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
/****** Object:  StoredProcedure [RuleChecks].[usp_MachineWithHighWeakCPUCoreCount]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_MachineWithHighWeakCPUCoreCount]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

declare @LowerValue int,
	@UpperValue int
select @LowerValue = RTH_LowerValue,
	@UpperValue = RTH_UpperValue
from BusinessLogic.RuleThresholds
where RTH_ID = @RTH_ID

select @ClientID, @PRR_ID, MOB_ID, ProcessorID, ProcessorName, Cores, PhysicalSockets
from Inventory.MonitoredObjects
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = MOB_ID
	inner join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
	cross apply RuleChecks.fn_GetNumberOfCores(MOB_ID)
	left join ExternalData.CPUBenchmark on replace(CPB_Name , '[Quad CPU] Quad-Core', 'Quad-Core') =
		replace(replace(replace(replace(replace(replace(ltrim(rtrim(replace(replace(replace(replace(replace(replace(ProcessorName, '(R)', ''), '(TM)', ''), 'CPU ', ''), '  ', ' ^'), '^ ', ''), '^', ''))), ' 0 ', ''),
		' Processor ', ' '), 'Dual Core', '[Dual CPU]'), 'Dual-Core', '[Dual CPU]'), '0@', '0 @'), ' MP ', ' ')
where PLT_PLC_ID = 1
	and (CPB_Mark < @UpperValue
				or @UpperValue is null)
			and (CPB_Mark > @LowerValue
				or @LowerValue is null)
GO
