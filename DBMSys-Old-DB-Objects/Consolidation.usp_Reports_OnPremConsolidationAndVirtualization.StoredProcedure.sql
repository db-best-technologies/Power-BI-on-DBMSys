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
/****** Object:  StoredProcedure [Consolidation].[usp_Reports_OnPremConsolidationAndVirtualization]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Consolidation].[usp_Reports_OnPremConsolidationAndVirtualization]
as
declare @DiskIOBufferPercentage int,
		@CPUStretchingRatio decimal(10, 2),
		@RedFlagLoadBuffer decimal(10, 2),
		@ExcludeCurrentlyVirtualized bit

if OBJECT_ID('tempdb..#MSCoreCountFactor') is not null
	drop table #MSCoreCountFactor
if OBJECT_ID('tempdb..#ConsideredForVirtualization') is not null
	drop table #ConsideredForVirtualization

create table #MSCoreCountFactor
	(CoreCount int null,
	CPUNamePattern varchar(100) collate database_default null,
	CPUNamePatternMinCoreCount int null,
	Factor decimal(10, 2))
insert into #MSCoreCountFactor
values(1, null, null, 4),
	(2, null, null, 2),
	(null, '%AMD% 31__%', 6, .75),
	(null, '%AMD% 32__%', 6, .75),
	(null, '%AMD% 33__%', 6, .75),
	(null, '%AMD% 41__%', 6, .75),
	(null, '%AMD% 42__%', 6, .75),
	(null, '%AMD% 43__%', 6, .75),
	(null, '%AMD% 61__%', 6, .75),
	(null, '%AMD% 62__%', 6, .75),
	(null, '%AMD% 63__%', 6, .75)

select @DiskIOBufferPercentage = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Disk IO Buffer Percentage'

select @CPUStretchingRatio = CAST(SET_Value as decimal(10, 2))
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Virtualization - CPU Core Stretch Ratio'

select @RedFlagLoadBuffer = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Red Flag Work Load Buffer'

declare @RedFlagLoadBufferMultiplier decimal(10, 2) = 1 + @RedFlagLoadBuffer/100.

select @DiskIOBufferPercentage = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Disk IO Buffer Percentage'

select @CPUStretchingRatio = CAST(SET_Value as decimal(10, 2))
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Virtualization - CPU Core Stretch Ratio'

select @RedFlagLoadBuffer = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Red Flag Work Load Buffer'

select @ExcludeCurrentlyVirtualized = CAST(SET_Value as bit)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Virtualization - Exclude Currently Virtualized'

select MOB_ID, CGR_Name ServerGroup, MOB_Name ServerName, isnull(IDB_Name, '') DatabaseName,
	case when EXP_ID is null and IsConsidered = 1 then 'Yes' else 'No' end [CanBeVirtualized?],
	coalesce(EXP_Reason, case when IsConsidered = 0 then 'Machine is already virtual' end, '') Reason,
	isnull(CHE_Name, '') SQLEdition, Cores, Cores*isnull(Factor, 1) LicensedCores
into #ConsideredForVirtualization
from (select distinct PDS_Server_MOB_ID
		from Consolidation.ParticipatingDatabaseServers) o
	inner join Inventory.MonitoredObjects om on MOB_ID = PDS_Server_MOB_ID
	inner join Consolidation.ServerGrouping on SGR_MOB_ID = MOB_ID
	inner join Consolidation.ConsolidationGroups on CGR_ID = SGR_CGR_ID
	inner join Consolidation.LoadBlocks on LBL_MOB_ID = PDS_Server_MOB_ID
	cross apply (select OSS_ID, case when @ExcludeCurrentlyVirtualized = 1 and MMD_Name like '%Virtual%' then 0 else 1 end IsConsidered
					from Inventory.MonitoredObjects
						inner join Inventory.OSServers on MOB_ID = OSS_MOB_ID
						left join Inventory.MachineManufacturerModels on MMD_ID = OSS_MMD_ID
					where MOB_ID = PDS_Server_MOB_ID) v
	left join Consolidation.CloudHostedApplicationEditions on CHE_ID = LBL_CHE_ID
	cross apply (select sum(isnull(PRS_NumberOfCores, 1)) Cores,
						max(PSN_Name) ProcessorName
					from Inventory.Processors
						inner join Inventory.ProcessorNames on PSN_ID = PRS_PSN_ID
					where PRS_MOB_ID = PDS_Server_MOB_ID) c
	left join #MSCoreCountFactor on (ProcessorName like CPUNamePattern collate database_default
										and Cores >= CPUNamePatternMinCoreCount)
									or Cores = CoreCount
	left join Consolidation.PerDatabaseRatios on PDR_MOB_ID = MOB_ID
	left join Inventory.InstanceDatabases on IDB_ID = PDR_IDB_ID
	left join Consolidation.Exceptions on EXP_EXT_ID = 2
											and EXP_MOB_ID = MOB_ID
											and (EXP_IDB_ID = PDR_IDB_ID
													or (EXP_IDB_ID is null
														and PDR_IDB_ID is null)
												)
where exists (select *
				from Consolidation.ServerPossibleHostTypes
				where SHT_MOB_ID = MOB_ID
					and SHT_HST_ID = 4)

select 'Summary' [Description]

;with cold as 
(
	SELECT	DISTINCT 
			OSS_MOB_ID
			,SGR_CGR_ID as OPR_CGR_ID
			,IIF(OSS_IsVirtualServer = 1,1,IIF(MMD_Name LIKE '%Virtual%',1,0)) AS OldIsVirtual
			,IIF(OSS_IsVirtualServer = 1,0,IIF(MMD_Name LIKE '%Virtual%',0,1)) AS OldIsPhysical
	FROM	Consolidation.ServerGrouping
	JOIN	Inventory.OSServers ON OSS_MOB_ID = SGR_MOB_ID
	JOIN	Inventory.MachineManufacturerModels ON MMD_ID = OSS_MMD_ID
)
,cnew  as 
(
	SELECT	DISTINCT 
			OSS_MOB_ID
			,OPR_CGR_ID
			,IIF(OSS_IsVirtualServer = 1,1,IIF(MMD_Name LIKE '%Virtual%',1,0)) AS NewIsVirtual
			,IIF(OSS_IsVirtualServer = 1,0,IIF(MMD_Name LIKE '%Virtual%',0,1)) AS NewIsPhysical
	FROM	Consolidation.VW_OnPrem
	JOIN	Inventory.OSServers ON OSS_MOB_ID = OPR_New_MOB_ID
	JOIN	Inventory.MachineManufacturerModels ON MMD_ID = OSS_MMD_ID
)
, vexcluded as 
(
	SELECT 
			SGR_CGR_ID
			,COUNT(*) as Excl_cnt
	FROM	#ConsideredForVirtualization
	JOIN	Consolidation.ServerGrouping ON MOB_ID = SGR_MOB_ID	
	WHERE	UPPER([CanBeVirtualized?]) = 'NO'
	GROUP BY SGR_CGR_ID

)
, v_newPhys as
(
	SELECT 
			CLB_CGR_ID
			,COUNT(*) as NewVmCnt
			,COUNT(DISTINCT CLB_PSH_ID) AS NewPhCnt
	FROM	Consolidation.ConsolidationBlocks
	
	where	CLB_HST_ID = 4
	GROUP BY CLB_CGR_ID
)
select 
		CGR_Name as ServerGroup
		,OldIsPhysical
		,OldIsVirtual
		,SUM(NewIsPhysical)	 as NewIsPhysical
		,SUM(NewIsVirtual)	 as NewIsVirtual
		,OldIsVirtual + OldIsPhysical - ( SUM(NewIsVirtual) + SUM(NewIsPhysical) ) AS Decommissioned
		,'Consolidation' AS Operation
from	cnew
JOIN	Consolidation.ConsolidationGroups ON cnew.OPR_CGR_ID = CGR_ID
CROSS APPLY (
				SELECT 
						SUM(OldIsVirtual)	as OldIsVirtual
						,SUM(OldIsPhysical) as OldIsPhysical
				FROM	cold
				WHERE	cnew.OPR_CGR_ID = cold.OPR_CGR_ID
			)o
GROUP BY OldIsVirtual
		,OldIsPhysical
		,CGR_Name
UNION ALL
select 
		CGR_Name as ServerGroup
		,SUM(OldIsPhysical)
		,SUM(OldIsVirtual)
		,Excl_cnt + NewPhCnt as NewIsPhysical
		,NewVmCnt 	 as NewIsVirtual
		,SUM(OldIsPhysical) + SUM(OldIsVirtual) - (Excl_cnt + NewPhCnt + NewVmCnt) AS Decommissioned
		,'Virtualization' Operation
from	cold
JOIN	Consolidation.ConsolidationGroups ON OPR_CGR_ID = CGR_ID
CROSS APPLY (
				SELECT 
						NewVmCnt
						,NewPhCnt
				FROM	v_newPhys
				WHERE	CLB_CGR_ID = CGR_ID
			)nph
CROSS APPLY (
				SELECT 
						Excl_cnt
				FROM	vexcluded
				WHERE	SGR_CGR_ID = CGR_ID
			)nex
GROUP BY CGR_Name
		,Excl_cnt
		,NewVmCnt
		,NewPhCnt
			
select 'Consolidation - Licensing Info'
select CGR_Name ServerGroup, OPR_Edition SQLEdition, OldServerCount, NewServerCount, CurrentCores, NewCores, CurrentLicensingCores, NewLicensingCores
from (select OPR_CGR_ID, OPR_Edition, sum(OPR_NewCoreCount) NewCores, sum(OPR_NewLicensingCoreCount) NewLicensingCores
		from (select distinct OPR_CGR_ID, OPR_New_MOB_ID, OPR_Edition, OPR_NewCoreCount, OPR_NewLicensingCoreCount
				from Consolidation.VW_OnPrem) p
		group by OPR_CGR_ID, OPR_Edition) n
	inner join (select OPR_CGR_ID Current_CGR_ID, OPR_Edition CurrentEdition, sum(OPR_OriginalCoreCount) CurrentCores, sum(OPR_OriginalLicensingCoreCount) CurrentLicensingCores,
						count(*) OldServerCount, count(distinct OPR_New_MOB_ID) NewServerCount
					from Consolidation.VW_OnPrem p
					group by OPR_CGR_ID, OPR_Edition) c
					 on c.Current_CGR_ID = OPR_CGR_ID
							and c.CurrentEdition = OPR_Edition
	inner join Consolidation.ConsolidationGroups on CGR_ID = OPR_CGR_ID
order by ServerGroup

select 'Details'
select CGR_Name ServerGroup, MOB_Name ServerName, cast('' as nvarchar(255)) MoveTo,
	cast('' as nvarchar(255)) Method, WMC_Comments Comment
from Consolidation.WeakMachines
	inner join Consolidation.ServerGrouping on SGR_MOB_ID = WMC_MOB_ID
	inner join Consolidation.ConsolidationGroups on CGR_ID = SGR_CGR_ID
	inner join Inventory.MonitoredObjects on MOB_ID = WMC_MOB_ID
union
select distinct CGR_Name ServerGroup, s.MOB_Name ServerName,
	case when PSH_MOB_ID <> LBL_MOB_ID
				or PSH_MOB_ID is null
		then isnull(d.MOB_Name, concat('ESX #', CLB_ID))
		else ''
	end MoveTo,
	case when PSH_MOB_ID is null then 'Virtualize' when d.MOB_ID <> s.MOB_ID then 'Consolidate' else '' end Operation,
	isnull(Comment, '') + iif(Comment is not null and LBL_CHE_ID < CLB_CHE_ID, ', ', '') + iif(LBL_CHE_ID < CLB_CHE_ID, 'Edition upgrade (' + se.CHE_Name + ' --> ' + de.CHE_Name + ')', '') Comment
from Consolidation.LoadBlocks
	inner join Inventory.MonitoredObjects s on s.MOB_ID = LBL_MOB_ID
	inner join Consolidation.ConsolidationBlocks_LoadBlocks on CBL_LBL_ID = LBL_ID
	inner join Consolidation.ConsolidationBlocks on CLB_ID = CBL_CLB_ID
	inner join Consolidation.PossibleHosts on PSH_ID = CLB_PSH_ID
	inner join Consolidation.ConsolidationGroups on CGR_ID = CLB_CGR_ID
	left join Consolidation.CloudHostedApplicationEditions se on se.CHE_ID = LBL_CHE_ID
	left join Consolidation.CloudHostedApplicationEditions de on de.CHE_ID = CLB_CHE_ID
	left join Inventory.MonitoredObjects d on d.MOB_ID = PSH_MOB_ID
	outer apply (select stuff((select distinct ', ' + stuff(concat(case when PCG_Name = 'CPU' then concat(', ', AddAction,  ' ', AddCores, ' Cores') end,
												case when PCG_Name = 'Memory' then concat(', ', AddAction,  ' ', AddMemory, ' MB of RAM') end
												), 1, 2, '')
							from Consolidation.RedFlagsByResourceType r
								inner join PerformanceData.PerformanceCounterGroups on r.RFR_PCG_ID = PCG_ID
								left join Consolidation.ParticipatingDatabaseServers p on p.PDS_Database_MOB_ID = r.RFR_MOB_ID
								inner join Consolidation.CPUInfo on CPI_MOB_ID = isnull(PDS_Server_MOB_ID, r.RFR_MOB_ID)
								inner join Consolidation.MemoryInfo on MMI_MOB_ID = isnull(PDS_Server_MOB_ID, r.RFR_MOB_ID)
								cross apply (select (cast(ceiling(MMI_TotalMemoryMB*(@RedFlagLoadBufferMultiplier-1)) as int) + 1023)/1024*1024 AddMemory,
													CPI_CPUCount*(@RedFlagLoadBufferMultiplier-1) AddCores) c
								cross apply (select case when PSH_MOB_ID <> LBL_MOB_ID or PSH_MOB_ID is null then 'Assumed a load of an extra' else 'Add' end AddAction) a
							where isnull(PDS_Server_MOB_ID, r.RFR_MOB_ID) = s.MOB_ID
								and PCG_Name in ('Memory', 'CPU')
								and not exists (select *
									from Consolidation.WeakMachines
									where WMC_MOB_ID = isnull(PDS_Server_MOB_ID, r.RFR_MOB_ID)
										and ((PCG_Name = 'Memory'
												and WMC_IsShortOnMemory = 1)
											or (PCG_Name = 'CPU'
												and WMC_IsShortOnCPU = 1
												)
											)
									)	
							for xml path('')
							), 1, 2, '') Comment
				) r
where CLB_HST_ID in (1, 2, 4)
	and CLB_DLR_ID is null
	and CBL_DLR_ID is null
order by ServerGroup, ServerName

select 'Consolidation conflicts'
select *
from Consolidation.fn_ConsolidationConflicts(null)

select 'Considered for Virtualization'
select ServerGroup, ServerName, DatabaseName,
	[CanBeVirtualized?],
	Reason, SQLEdition, Cores, LicensedCores
from #ConsideredForVirtualization
order by ServerGroup, ServerName

select 'Virtualization Buckets'
select VBC_SizeRank BucketID, VBC_FromNumberOfCores FromNumberOfCores, VBC_ToNumberOfCores ToNumberOfCores,
	VBC_FromMemoryMB FromMemoryMB, VBC_ToMemoryMB ToMemoryMB, Machines
from Consolidation.VirtualizationBuckets
	cross apply (select COUNT(*) Machines
					from Consolidation.LoadBlocks
					where LBL_VBC_ID = VBC_ID) m
order by VBC_SizeRank

select 'Virtualization - Licensing Info'
select CGR_Name ServerGroup, CLB_ID ESX_ID, count(*) VMs, --sum(CBL_VirtualCoreCount) VirtualCores,
	sum(case when CHE_Name = 'Developer' then CBL_VirtualCoreCount else 0 end) DeveloperCores,
	sum(case when CHE_Name = 'Standard' then CBL_VirtualCoreCount else 0 end) StandardCores,
	sum(case when CHE_Name = 'Enterprise' then CBL_VirtualCoreCount else 0 end) EnterpriseCores,
	sum(case when CHE_Name = 'Developer' then LicensedCores else 0 end) DeveloperLicensedCores,
	sum(case when CHE_Name = 'Standard' then LicensedCores else 0 end) StandardLicensedCores,
	sum(case when CHE_Name = 'Enterprise' then LicensedCores else 0 end) EnterpriseLicensedCores,
	cast(PSH_CoreCount/@CPUStretchingRatio as int) PhysicalCores
from Consolidation.ConsolidationBlocks_LoadBlocks
	inner join Consolidation.LoadBlocks on LBL_ID = CBL_LBL_ID
	left join Consolidation.CloudHostedApplicationEditions on CHE_ID = LBL_CHE_ID
	inner join Consolidation.ConsolidationBlocks on CBL_CLB_ID = CLB_ID
	inner join Consolidation.PossibleHosts on PSH_ID = CLB_PSH_ID
	inner join Consolidation.ConsolidationGroups on CGR_ID = CLB_CGR_ID
	cross apply (select case when CBL_VirtualCoreCount < 4 then 4 else CBL_VirtualCoreCount end LicensedCores) l
where CLB_HST_ID = 4
group by CGR_Name, CLB_ID, cast(PSH_CoreCount/@CPUStretchingRatio as int)
order by ServerGroup, CLB_ID

select 'Virtualization - VM assignment'
select CGR_Name ServerGroup, CLB_ID ESX_ID, isnull(CHE_Name, '') SQLEdition, isnull(cast(VBC_SizeRank as varchar(10)), '') BucketID, MOB_Name SourceMachineName, ISNULL(IDB_Name, '') DatabaseName, CBL_VirtualCoreCount VirtualCoreCount, CBL_BufferedMemoryMB
 MemoryMB,
	isnull(cast(DSI_DataFilesMB as varchar(100)), '') CurrentDataFileSizeMB,
	isnull(cast(DSI_DataFilesMBIn3Years as varchar(100)), '') EstimatedDataFilesMBIn3Years,
	isnull(cast(DSI_LogFilesMB as varchar(100)), '') LogFilesSizeMB,
	isnull(cast(DSI_TempdbMB as varchar(100)), '') TempdbSizeMB,
	isnull(cast(LBL_DiskSize - DSI_DataFilesMB - DSI_LogFilesMB - DSI_TempdbMB as varchar(100)), '') OtherDataSizeMB,
	LBL_DiskSize TotalSizeMB,
	isnull(cast(ceiling(DII_DataFileTransfers + DII_DataFileTransfers*(@DiskIOBufferPercentage/100.)) as varchar(100)), '') DataFileIOPS,
	isnull(cast(ceiling(DII_LogFileTransfers + DII_LogFileTransfers*(@DiskIOBufferPercentage/100.)) as varchar(100)), '') LogFileIOPS,
	isnull(cast(ceiling(DII_TempdbTransfers + DII_TempdbTransfers*(@DiskIOBufferPercentage/100.)) as varchar(100)), '') TempdbIOPS,
	isnull(cast(ceiling((DII_TotalTransfers + DII_TotalTransfers*(@DiskIOBufferPercentage/100. ))*ISNULL(PDR_IOphRatio, 1)) as varchar(100)), '') TotalIOPS
from Consolidation.ConsolidationBlocks
	inner join Consolidation.ConsolidationBlocks_LoadBlocks on CBL_CLB_ID = CLB_ID
	inner join Consolidation.LoadBlocks on LBL_ID = CBL_LBL_ID
	left join Consolidation.CloudHostedApplicationEditions on CHE_ID = LBL_CHE_ID
	inner join Inventory.MonitoredObjects m on m.MOB_ID = LBL_MOB_ID
	inner join Consolidation.DiskIOInfo f on DII_MOB_ID = m.MOB_ID
	inner join Consolidation.DiskInfo on DSI_MOB_ID = LBL_MOB_ID
											and (DSI_IDB_ID = LBL_IDB_ID
													or (DSI_IDB_ID is null
															and LBL_IDB_ID is null
														)
												)
	left join Consolidation.PerDatabaseRatios on PDR_MOB_ID = LBL_MOB_ID
											and (PDR_IDB_ID = LBL_IDB_ID
													or (PDR_IDB_ID is null
															and LBL_IDB_ID is null
														)
												)
	inner join Consolidation.ConsolidationGroups on CGR_ID = CLB_CGR_ID
	left join Inventory.InstanceDatabases on IDB_ID = LBL_IDB_ID
	left join Consolidation.VirtualizationBuckets on VBC_ID = LBL_VBC_ID
where  CLB_HST_ID = 4
order by ServerGroup, ESX_ID, SourceMachineName
GO
