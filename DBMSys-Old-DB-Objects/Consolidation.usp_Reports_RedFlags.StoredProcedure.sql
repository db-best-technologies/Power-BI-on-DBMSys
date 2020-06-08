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
/****** Object:  StoredProcedure [Consolidation].[usp_Reports_RedFlags]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Consolidation].[usp_Reports_RedFlags]
as
select 'By Resource Type'
select distinct CGR_Name [Server Group Name], MOB_Name [Object], PLT_Name [Platform],
	PCG_Name [Resource], RFR_DaysSampled [Days Sampled], RFR_PercentOverThreshold [Percent Over Threshold],
	RFR_HoursWithMoreThanThan30PercentRecurrence [Hours With More Than 30% Recurrence]
from Consolidation.RedFlagsByResourceType
	inner join Consolidation.ParticipatingDatabaseServers on RFR_MOB_ID in (PDS_Server_MOB_ID, PDS_Database_MOB_ID)
	inner join Consolidation.ServerGrouping on SGR_MOB_ID = PDS_Server_MOB_ID
	inner join Consolidation.ConsolidationGroups on CGR_ID = SGR_CGR_ID
	inner join Inventory.MonitoredObjects on MOB_ID = RFR_MOB_ID
	inner join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
	inner join PerformanceData.PerformanceCounterGroups on PCG_ID = RFR_PCG_ID
order by [Server Group Name], [Object], [Platform], [Resource]

select 'SQL Memory Detailed'
select CGR_Name [Server Group Name], d.MOB_Name [Object], RFR_DaysSampled [Days Sampled], RFR_PercentOverThreshold [Percent Over Threshold],
	RFR_HoursWithMoreThanThan30PercentRecurrence [Hours With More Than 30% Recurrence],
	case when cast(ICF_Value as bigint) > OSS_TotalPhysicalMemoryMB
		then OSS_TotalPhysicalMemoryMB
		else cast(ICF_Value as bigint)
	end [Assigned Memory MB],
	[Actual Percentage of Assigned Memory Available On Average],
	case when cast(ICF_Value as bigint) = 2147483647
			then 'N'
			else 'Y'
		end [Is Max Memory Configured]
from Consolidation.RedFlagsByResourceType
	inner join Consolidation.ParticipatingDatabaseServers on RFR_MOB_ID = PDS_Database_MOB_ID
	inner join Consolidation.ServerGrouping on SGR_MOB_ID = PDS_Server_MOB_ID
	inner join Consolidation.ConsolidationGroups on CGR_ID = SGR_CGR_ID
	inner join Inventory.MonitoredObjects d on d.MOB_ID = RFR_MOB_ID
	inner join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
	inner join PerformanceData.PerformanceCounterGroups on PCG_ID = RFR_PCG_ID
	inner join Inventory.MonitoredObjects s on s.MOB_ID = PDS_Server_MOB_ID
	left join (Inventory.InstanceConfigurations 
				inner join Inventory.InstanceConfigurationTypes on ICT_ID = ICF_ICT_ID)
		on ICF_MOB_ID = RFR_MOB_ID
			and ICT_Name = 'max server memory (MB)'
	left join Inventory.OSServers on OSS_MOB_ID = s.MOB_ID
	outer apply (select cast(cast(AVG(CRS_Value)/1024 as int)*100/case when cast(ICF_Value as bigint) > OSS_TotalPhysicalMemoryMB
																then OSS_TotalPhysicalMemoryMB
																else cast(ICF_Value as bigint)
															end as varchar(10)) + '%' [Actual Percentage of Assigned Memory Available On Average]
					from PerformanceData.CounterResults
					where CRS_MOB_ID = RFR_MOB_ID
						and CRS_SystemID = 1
						and CRS_CounterID = 39
				) v
where PLT_Name = 'Microsoft SQL Server'
	and PCG_Name = 'Memory'
order by [Server Group Name], [Object]

select 'By Counter'
select CGR_Name [Server Group Name], MOB_Name [Object], PLT_Name [Platform], PCG_Name [Resource], CategoryName [Counter Category], CounterName [Counter], isnull(CIN_Name, '') Instance,
		RFC_DiffSign + ' ' + CAST(RFC_Value as varchar(100)) [Threshold Rule], RFC_MinValue [Min.], RFC_AvgValue [Avg.], RFC_MaxValue [Max.], RFC_SamplesCollected [Samples Collected],
		RFC_DaysSampled [Days Sampled], RFC_PercentOverThreshold [Percent Over Threshold],
		RFC_HoursWithMoreThanThan30PercentRecurrence [Hours With More Than 30% Recurrence]
from Consolidation.RedFlagsOverThresholdCounters c
	inner join Consolidation.ParticipatingDatabaseServers on RFC_MOB_ID in (PDS_Server_MOB_ID, PDS_Database_MOB_ID)
	inner join Consolidation.ServerGrouping on SGR_MOB_ID = PDS_Server_MOB_ID
	inner join Consolidation.ConsolidationGroups on CGR_ID = SGR_CGR_ID
	inner join Inventory.MonitoredObjects on MOB_ID = RFC_MOB_ID
	inner join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
	inner join PerformanceData.PerformanceCounterGroups on PCG_ID = RFC_PCG_ID
	inner join PerformanceData.VW_Counters v on SystemID = RFC_CSY_ID
													and CounterID = RFC_CounterID
	left join PerformanceData.CounterInstances on CIN_ID = RFC_CounterInstanceID
order by [Server Group Name], [Object], [Platform], [Resource], [Counter Category], [Counter]
GO
