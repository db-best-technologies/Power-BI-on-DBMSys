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
/****** Object:  StoredProcedure [Reports].[usp_Consolidation_Disks]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_Consolidation_Disks]
as
if OBJECT_ID('tempdb..#AggregatedResults') is not null
	drop table #AggregatedResults

;with Parents as
	(select MOB_ID
		from Inventory.MonitoredObjects
				inner join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
				inner join Inventory.OSServers on MOB_ID = OSS_MOB_ID
		where PLT_PLC_ID = 1
	)
	, Counters as
		(select DSK_MOB_ID Parent_MOB_ID, MOB_ID, 4 SystemID, 22 CounterID, CIN_ID InstanceID, DSK_Path InstanceName --Disk counters
			from Inventory.Disks
				inner join Parents on DSK_MOB_ID = MOB_ID
				inner join PerformanceData.CounterInstances on DSK_Path = CIN_Name
			where exists (select *
							from Inventory.DatabaseFiles
							where DBF_DSK_ID = DSK_ID)
		)
	, CounterResults as
		(select Parent_MOB_ID, CRS_MOB_ID, CRS_SystemID, CRS_CounterID, InstanceName, COUNT(*) over(partition by CRS_MOB_ID, CRS_SystemID, CRS_CounterID, InstanceName) ResultCount,
					ROW_NUMBER() over (partition by CRS_MOB_ID, CRS_SystemID, CRS_CounterID, InstanceName order by CRS_Value asc) ButtomResults,
					ROW_NUMBER() over (partition by CRS_MOB_ID, CRS_SystemID, CRS_CounterID, InstanceName order by CRS_Value desc) TopResults,
					CRS_Value, CRS_DateTime
			from Counters
				inner join PerformanceData.CounterResults on CRS_MOB_ID = MOB_ID
															and CRS_SystemID = SystemID
															and CRS_CounterID = CounterID
															and (CRS_InstanceID = InstanceID
																	or (CRS_InstanceID is null
																		and InstanceID is null)
																)
		)
	, AggregatedResults as
		(select Parent_MOB_ID, CRS_MOB_ID, CRS_SystemID, CRS_CounterID, InstanceName,
				MAX(case when ButtomResults > ResultCount/20 and TopResults > ResultCount/20
										then CRS_Value
										else null
									end) CalcMaxValue,
				MAX(CRS_Value) MaxValue
			from CounterResults
			group by Parent_MOB_ID, CRS_MOB_ID, CRS_SystemID, CRS_CounterID, InstanceName
		)
select *
into #AggregatedResults
from AggregatedResults

select MOB_ID ServerID, OSS_Name ServerName, InsTanceName DiskName, cast(CalcMaxValue as int) IOPs, cast(MaxValue as int) MaxIOps
from Inventory.OSServers
	inner join Inventory.MonitoredObjects p on MOB_ID = OSS_MOB_ID
	inner join #AggregatedResults on MOB_ID = CRS_MOB_ID
where CRS_SystemID = 4
	and CRS_CounterID = 22
order by ServerID
GO
