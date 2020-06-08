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
/****** Object:  StoredProcedure [Reports].[usp_Consolidation_Servers]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_Consolidation_Servers]
as
if OBJECT_ID('tempdb..#AggregatedResults') is not null
	drop table #AggregatedResults

if OBJECT_ID('tempdb..#ServerOverview') is not null
	drop table #ServerOverview

;with Parents as
	(select MOB_ID
		from Inventory.MonitoredObjects
				inner join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
				inner join Inventory.OSServers on MOB_ID = OSS_MOB_ID
		where PLT_PLC_ID = 1
	)
	, Children as
		(select PCR_Parent_MOB_ID Parent_MOB_ID, PCR_Child_MOB_ID MOB_ID
			from Inventory.ParentChildRelationships
				inner join Parents on MOB_ID = PCR_Parent_MOB_ID
			where PCR_IsCurrentParent = 1
		)
	, Counters as
		(select MOB_ID Parent_MOB_ID, MOB_ID, 4 SystemID, 1 CounterID, CIN_ID InstanceID, cast(null as varchar(900)) InstanceName --CPU usage
			from Parents
				inner join PerformanceData.CounterInstances on CIN_Name = '_Total'
			union all
			select MOB_ID Parent_MOB_ID, MOB_ID, 4 SystemID, 12 CounterID, cast(null as int) InstanceID, cast(null as varchar(900)) InstanceName --Available MBytes
			from Parents
			union all
			select Parent_MOB_ID, MOB_ID, 1 SystemID, CounterID, cast(null as int) InstanceID, cast(null as varchar(900)) InstanceName --PLE
			from Children
				cross join (values(3),
								(39)) c(CounterID)
			union all
			select Parent_MOB_ID, MOB_ID, 3 SystemID, 92 CounterID, CIN_ID InstanceID, CIN_Name InstanceName
			from Children
				inner join PerformanceData.CounterInstances on CIN_Name = '_Total'
			union all
			select DSK_MOB_ID Parent_MOB_ID, MOB_ID, 4 SystemID, CounterID, CIN_ID InstanceID, DSK_Path InstanceName --Disk counters
			from Inventory.Disks
				inner join Parents on DSK_MOB_ID = MOB_ID
				inner join PerformanceData.CounterInstances on DSK_Path = CIN_Name
				cross join (values(16),
								(22)) c(CounterID)
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
				MIN(case when ButtomResults > ResultCount/20 and TopResults > ResultCount/20
						then CRS_Value
						else null
					end) CalcMinValue,
				AVG(case when ButtomResults > ResultCount/20 and TopResults > ResultCount/20
						then CRS_Value
						else null
					end) CalcAvgValue,
				MAX(case when ButtomResults > ResultCount/20 and TopResults > ResultCount/20
						then CRS_Value
						else null
					end) CalcMaxValue,
				MAX(CRS_Value) MaxValue,
				STDEV(CRS_Value) STDEVValue
			from CounterResults
			group by Parent_MOB_ID, CRS_MOB_ID, CRS_SystemID, CRS_CounterID, InstanceName
		)
select *
into #AggregatedResults
from AggregatedResults

select MOB_ID ServerID, OSS_Name ServerName, OSS_TotalPhysicalMemoryMB TotalPhysicalMemoryMB, OSS_Architecture Architecture,
		CPB_Name CPUType, PRS_NumberOfCores NumberOfCores, PRS_NumberOfCores*CPB_Mark TotalCPUMark,
		cast(CPU.CalcMaxValue as int) CPUUsagePercent,
		cast(Mem.CalcAvgValue + Mem.STDEVValue/2 + (ServerMemory - TotalClerkMemory) as int) AvailableMemoryMB,
		isnull(STUFF((select ',' + c.MOB_Name
						from #AggregatedResults PLE
							inner join Inventory.MonitoredObjects c on c.MOB_ID = PLE.CRS_MOB_ID
						where PLE.Parent_MOB_ID = p.MOB_ID
							and PLE.CRS_SystemID = 1
							and PLE.CRS_CounterID = 3
							and (PLE.CalcMinValue < 1000)), 1, 1, ''), '<NONE>') HostedSQLInstancesWithMemoryPressure,
		isnull(STUFF((select ',' + DSK.InstanceName + ' (Sec/Transfer = ' + CAST(CAST(DSK.CalcMaxValue as decimal(18, 3)) as nvarchar(100)) + ')'
						from #AggregatedResults DSK
						where DSK.CRS_MOB_ID = p.MOB_ID
							and DSK.CRS_SystemID = 4
							and DSK.CRS_CounterID = 16
							and DSK.CalcMaxValue > 0.02), 1, 1, ''), '<NONE>') DisksWithLatencyIssues,
		MaxIOPsOverAllDisks, IOPsOverAllDisks
into #ServerOverview
from Inventory.OSServers
	inner join Inventory.MonitoredObjects p on MOB_ID = OSS_MOB_ID
	inner join Inventory.Processors on PRS_MOB_ID = MOB_ID
	inner join Inventory.ProcessorNames on PSN_ID = PRS_PSN_ID
	inner join ExternalData.CPUBenchmark on CPB_Name = replace(replace(replace(PSN_Name, '(R)', ''), '(TM)', ''), ' CPU ', ' ')
	left join #AggregatedResults CPU on CPU.Parent_MOB_ID = MOB_ID
										and CPU.CRS_SystemID = 4
										and CPU.CRS_CounterID = 1
	left join #AggregatedResults Mem on Mem.Parent_MOB_ID = MOB_ID
										and Mem.CRS_SystemID = 4
										and Mem.CRS_CounterID = 12
	outer apply (select SUM(SM.CalcAvgValue + SM.STDEVValue/2)/1024 ServerMemory
					from #AggregatedResults SM
					where SM.Parent_MOB_ID = MOB_ID
							and SM.CRS_SystemID = 1
							and SM.CRS_CounterID = 39) sm
	outer apply (select SUM(TC.CalcAvgValue + TC.STDEVValue/2) TotalClerkMemory
					from #AggregatedResults TC
					where TC.Parent_MOB_ID = MOB_ID
							and TC.CRS_SystemID = 3
							and TC.CRS_CounterID = 92) tc
	outer apply (select CAST(SUM(MAXIO.MaxValue) as int) MaxIOPsOverAllDisks
					from #AggregatedResults MAXIO
					where MAXIO.CRS_MOB_ID = MOB_ID
							and MAXIO.CRS_SystemID = 4
							and MAXIO.CRS_CounterID = 22) MaxIO
	outer apply (select CAST(SUM(AVGIO.CalcMaxValue) as int) IOPsOverAllDisks
					from #AggregatedResults AVGIO
					where AVGIO.CRS_MOB_ID = MOB_ID
							and AVGIO.CRS_SystemID = 4
							and AVGIO.CRS_CounterID = 22) AvgIO

select *, CPUUsagePercent*TotalCPUMark/100 CPUCalculatedMark
from #ServerOverview
GO
