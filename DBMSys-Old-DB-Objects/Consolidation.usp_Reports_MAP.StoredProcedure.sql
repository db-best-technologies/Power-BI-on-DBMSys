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
/****** Object:  StoredProcedure [Consolidation].[usp_Reports_MAP]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Consolidation].[usp_Reports_MAP]
as
if object_id('tempdb..#Processors') is not null
	drop table #Processors
if object_id('tempdb..#Databases') is not null
	drop table #Databases

declare @ConsiderServersWithoutADatabaseInstance bit,
	@ConsiderClusterVirtualServerAsHost bit,
	@ShowOnlyConsolidationParticipants bit,
	@FromDate datetime2(3),
	@ToDate datetime2(3),
	@Collector_PGN_ID int

if exists (select * from Consolidation.ParticipatingDatabaseServers)
	set @ShowOnlyConsolidationParticipants = 1
else
	set @ShowOnlyConsolidationParticipants = 0

select @ConsiderServersWithoutADatabaseInstance = cast(SET_Value as bit)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Consider servers without a database instance'

select @ConsiderClusterVirtualServerAsHost = cast(SET_Value as bit)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Consider Cluster Virtual Server As Host'

select @FromDate = min(CRS_DateTime),
	@ToDate = max(CRS_DateTime)
from PerformanceData.CounterResults

select CR_MOB_ID PRS_MOB_ID, RawCPUName ProcessorName, CPUCount Processors, NumberOfCores CoreCount, NumberOfLogicalCores LogicalProcessors,
	LicensedCores, SingleCPUScore CPUScore
into #Processors
from Consolidation.fn_CPUAnalysis()

select 'Server level' [Report]
;with ServerList as
		(select MOB_ID S_MOB_ID
			from Inventory.MonitoredObjects o
					inner join Inventory.OSServers on OSS_MOB_ID = MOB_ID
			where exists (select *
							from Management.PlatformTypes
							where PLT_ID = MOB_PLT_ID
								and PLT_PLC_ID = 2)
				and MOB_OOS_ID = 1
				and (exists (select *
								from Inventory.ParentChildRelationships
									inner join Inventory.MonitoredObjects d on d.MOB_ID = PCR_Child_MOB_ID
									inner join Management.PlatformTypes on d.MOB_PLT_ID = PLT_ID
								where PCR_Parent_MOB_ID = o.MOB_ID
									and PLT_PLC_ID = 1
									and d.MOB_OOS_ID = 1)
					or
						(@ConsiderServersWithoutADatabaseInstance = 1
						and exists (select *
										from Management.DefinedObjects
										where DFO_PLT_ID = MOB_PLT_ID
											and DFO_Name = MOB_Name)
						)
					)
				and ((@ConsiderClusterVirtualServerAsHost = 0
						and OSS_IsVirtualServer = 0)
					or (@ConsiderClusterVirtualServerAsHost = 1
						and (OSS_IsClusterNode = 0
								or OSS_IsClusterNode is null)
							)
					)
		)
	, Processors as
		(select *
			from #Processors
		)
	, Disks as
		(select DSK_MOB_ID, DSK_Path, cast(DSK_TotalSpaceMB/1024 as varchar(20)) TotalSizeGB, FreeSpaceGB
			from Inventory.Disks
				outer apply (select top 1 cast(cast(CRS_Value as int)/1024 as varchar(20)) FreeSpaceGB
								from PerformanceData.CounterResults
									left join PerformanceData.CounterInstances on CIN_ID = CRS_InstanceID
								where CRS_MOB_ID = DSK_MOB_ID
										and CIN_Name = DSK_Path
										and CRS_SystemID = 4
										and CRS_CounterID = 27
										and CRS_DateTime between @FromDate and @ToDate
								order by CRS_DateTime desc) r
			where DSK_Path like '%:%'
		)
select CGR_Name ServerGroup, s.MOB_Name ComputerName,
	isnull('Microsoft SQL Server ' + d.EDT_Name, 'No SQL Server data available') SQLServerProductName,
	isnull('SQL ' + left(d.VER_Name, charindex(' -', d.VER_Name + ' -', 1) - 1), 'N/A') SQLServerVersion,
	isnull(d.PRL_Name, 'N/A') SQLServerServicePack,
	isnull(d.EDT_Name, 'N/A') SQLServerEdition,
	case when DID_IsClustered = 1 then 'Yes' when DID_IsClustered = 0 then 'No' else 'N/A' end IsClustered,
	case DID_IsClustered when 1 then s.MOB_Name else '' end SQLServerClusterNetworkName,
	isnull(ServiceStatus, 'N/A') SQLServiceState,
	isnull(StartingMode, 'N/A') SQLServiceStartMode,
	isnull(alias + ' (' + cast(OSS_Language as varchar(10)) + ')', 'N/A') [Language],
	'"' + coalesce(se.EDT_Name, 'N/A') + '"' OperatingSystem,
	isnull(sp.PRL_Name, 'N/A') OperatingSystemServicePack,
	isnull(cast(case when se.EDT_Name is not null then isnull(OSS_Architecture, 32) end as char(2)) + '-bit', 'N/A') OSArchitectureType,
	Processors NumberOfProcessors, CoreCount NumberOfTotalCores, isnull(LogicalProcessors, CoreCount) NumberOfLogicalProcessors, LicensedCores, ProcessorName CPU, CPUScore,
	isnull(cast(OSS_TotalPhysicalMemoryMB as varchar(100)), 'N/A') SystemMemoryMB,
	'"' + isnull(stuff(replace((select char(13)+char(10) + DSK_Path
						from Disks
						where DSK_MOB_ID = s.MOB_ID
						order by DSK_Path
						for xml path('')), '&#x0D;', char(13)), 1, 2, ''), 'N/A') + '"' LogicalDiskDriveName,
	'"' + isnull(stuff(replace((select char(13)+char(10) + TotalSizeGB
						from Disks
						where DSK_MOB_ID = s.MOB_ID
						order by DSK_Path
						for xml path('')), '&#x0D;', char(13)), 1, 2, ''), 'N/A') + '"' LogicalDiskSizeGB,
	'"' + isnull(stuff(replace((select char(13)+char(10) + FreeSpaceGB
						from Disks
						where DSK_MOB_ID = s.MOB_ID
						order by DSK_Path
						for xml path('')), '&#x0D;', char(13)), 1, 2, ''), 'N/A') + '"' LogicalDiskFreeSpaceGB,
	case when OSS_IsVirtualServer = 1 then 'Virtual' else 'Physical' end MachineType,
	'"' + coalesce(MMN_Name, 'N/A') + '"' MachineManufacturer,
	isnull(MMD_Name, 'N/A') MachineModel, isnull(convert(char(10), OSS_InstallDate, 101), 'N/A') OSInstallationDate
from Inventory.OSServers
	inner join Inventory.MonitoredObjects s on OSS_MOB_ID = s.MOB_ID
	left join Consolidation.ServerGrouping on SGR_MOB_ID = MOB_ID
	left join Consolidation.ConsolidationGroups on CGR_ID = SGR_CGR_ID
	outer apply (select top 1 DID_InstanceName, DID_IsClustered, EDT_Name, VER_Name, PRL_Name
					from Inventory.ParentChildRelationships
						inner join Inventory.MonitoredObjects d on d.MOB_ID = PCR_Child_MOB_ID
						inner join Inventory.DatabaseInstanceDetails on d.MOB_Entity_ID = DID_DFO_ID
						inner join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
																and PLT_PLC_ID = 1
						inner join Inventory.Versions dv on d.MOB_VER_ID = dv.VER_ID
						inner join Inventory.ProductLevels dp on DID_PRL_ID = dp.PRL_ID
						inner join Inventory.Editions de on DID_EDT_ID = de.EDT_ID
					where d.MOB_OOS_ID = 1
						and PCR_Parent_MOB_ID = s.MOB_ID
					order by case when EDT_Name like '%Enterprise%' then 1 else 2 end) d
	outer apply (select sum(Processors) Processors, sum(CoreCount) CoreCount, sum(LogicalProcessors) LogicalProcessors, sum(LicensedCores) LicensedCores, sum(CPUScore) CPUScore
					from Processors
					where PRS_MOB_ID = s.MOB_ID) prs
	outer apply (select top 1 ProcessorName
					from Processors
					where PRS_MOB_ID = s.MOB_ID
					order by CPUScore desc) prs1
	left join Inventory.Versions sv on s.MOB_VER_ID = sv.VER_ID
	left join Inventory.Editions se on s.MOB_Engine_EDT_ID = se.EDT_ID
	left join Inventory.ProductLevels sp on OSS_PRL_ID = sp.PRL_ID
	left join sys.syslanguages on OSS_Language = lcid
	left join Inventory.MachineManufacturers on MMN_ID = OSS_MMN_ID
	left join inventory.MachineManufacturerModels on MMD_ID = OSS_MMD_ID
	outer apply (select SSM_Name StartingMode, SST_Name ServiceStatus
					from Inventory.OperatingSystemServices
						left join Inventory.ServiceNames on SNM_ID = OSR_SNM_ID
						left join Inventory.ServiceStartModes on SSM_ID = OSR_SSM_ID
						left join Inventory.ServiceStates on SST_ID = OSR_SST_ID
						left join Inventory.SQLComponentTypes on LEFT(SNM_Name + '$', CHARINDEX('$', SNM_Name + '$', 1) - 1) like SMT_ServiceName
					where SMT_DisplayName = 'Database Engine'
							and OSR_MOB_ID = s.MOB_ID
							and (SUBSTRING(SNM_Name, CHARINDEX('$', SNM_Name + '$', 1) + 1, 100) = DID_InstanceName
									or SUBSTRING(SNM_Name, CHARINDEX('$', SNM_Name + '$', 1) + 1, 100) = '' and DID_InstanceName is null)
					) osr
where exists (select *
				from ServerList
				where s.MOB_ID = S_MOB_ID)
	and (@ShowOnlyConsolidationParticipants = 0
			or CGR_Name is not null)
order by 1, 2

select 'Instance level' [Report]
;with Processors as
		(select *
			from #Processors
		)
	, Disks as
		(select DSK_MOB_ID, DSK_Path, cast(DSK_TotalSpaceMB/1024 as varchar(20)) TotalSizeGB, FreeSpaceGB
			from Inventory.Disks
				outer apply (select top 1 cast(cast(CRS_Value as int)/1024 as varchar(20)) FreeSpaceGB
								from PerformanceData.CounterResults with (forceseek)
									left join PerformanceData.CounterInstances on CIN_ID = CRS_InstanceID
								where CRS_MOB_ID = DSK_MOB_ID
										and CIN_Name = DSK_Path
										and CRS_SystemID = 4
										and CRS_CounterID = 27
										and CRS_DateTime between @FromDate and @ToDate
								order by CRS_DateTime desc) r
			where DSK_Path like '%:%'
		)
select CGR_Name ServerGroup, s.MOB_Name ComputerName, isnull(DID_InstanceName, '') InstanceName, 
	isnull('Microsoft SQL Server ' + de.EDT_Name, 'No SQL Server data available') SQLServerProductName,
	isnull('SQL ' + left(dv.VER_Name, charindex(' -', dv.VER_Name + ' -', 1) - 1), 'N/A') SQLServerVersion,
	isnull(dp.PRL_Name, 'N/A') SQLServerServicePack,
	isnull(de.EDT_Name, 'N/A') SQLServerEdition,
	case when DID_IsClustered = 1 then 'Yes' when DID_IsClustered = 0 then 'No' else 'N/A' end IsClustered,
	case DID_IsClustered when 1 then s.MOB_Name else '' end SQLServerClusterNetworkName,
	isnull(ServiceStatus, 'N/A') SQLServiceState,
	isnull(StartingMode, 'N/A') SQLServiceStartMode,
	isnull(alias + ' (' + cast(OSS_Language as varchar(10)) + ')', 'N/A') [Language],
	'"' + coalesce(se.EDT_Name, 'N/A') + '"' OperatingSystem,
	isnull(sp.PRL_Name, 'N/A') OperatingSystemServicePack,
	isnull(cast(case when se.EDT_Name is not null then isnull(OSS_Architecture, 32) end as char(2)) + '-bit', 'N/A') OSArchitectureType,
	Processors NumberOfProcessors, CoreCount NumberOfTotalCores, isnull(LogicalProcessors, CoreCount) NumberOfLogicalProcessors, ProcessorName CPU, CPUScore,
	isnull(cast(OSS_TotalPhysicalMemoryMB as varchar(100)), 'N/A') SystemMemoryMB,
	'"' + isnull(stuff(replace((select char(13)+char(10) + DSK_Path
						from Disks
						where DSK_MOB_ID = s.MOB_ID
						order by DSK_Path
						for xml path('')), '&#x0D;', char(13)), 1, 2, ''), 'N/A') + '"' LogicalDiskDriveName,
	'"' + isnull(stuff(replace((select char(13)+char(10) + TotalSizeGB
						from Disks
						where DSK_MOB_ID = s.MOB_ID
						order by DSK_Path
						for xml path('')), '&#x0D;', char(13)), 1, 2, ''), 'N/A') + '"' LogicalDiskSizeGB,
	'"' + isnull(stuff(replace((select char(13)+char(10) + FreeSpaceGB
						from Disks
						where DSK_MOB_ID = s.MOB_ID
						order by DSK_Path
						for xml path('')), '&#x0D;', char(13)), 1, 2, ''), 'N/A') + '"' LogicalDiskFreeSpaceGB,
	case when OSS_IsVirtualServer = 1 then 'Virtual' else 'Physical' end MachineType,
	'"' + coalesce(MMN_Name, 'N/A') + '"' MachineManufacturer,
	isnull(MMD_Name, 'N/A') MachineModel,
	DatabaseCount, isnull(convert(char(10), OSS_InstallDate, 101), 'N/A') OSInstallationDate
from Inventory.OSServers
	inner join Inventory.MonitoredObjects s on OSS_MOB_ID = s.MOB_ID
	left join Consolidation.ServerGrouping on SGR_MOB_ID = MOB_ID
												or exists (select *
															from Consolidation.ClusterNodesMapping
															where SGR_MOB_ID = CNM_ClusterNode_MOB_ID
																and MOB_ID = CNM_VirtualServer_MOB_ID)
	left join Consolidation.ConsolidationGroups on CGR_ID = SGR_CGR_ID
	outer apply (select distinct MOB_ID, DID_InstanceName, DID_IsClustered, DID_PRL_ID, DID_EDT_ID, MOB_VER_ID, MOB_OOS_ID
					from Inventory.DatabaseInstanceDetails
						inner join Inventory.MonitoredObjects d on d.MOB_Entity_ID = DID_DFO_ID
						inner join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
																and PLT_PLC_ID = 1
					where d.MOB_OOS_ID = 1
						and DID_OSS_ID = OSS_ID) d
	outer apply (select case when d.MOB_ID is not null then COUNT(*) end DatabaseCount
					from Inventory.InstanceDatabases
					where IDB_MOB_ID = d.MOB_ID
						and IDB_Name not in ('master', 'msdb', 'model', 'tempdb', 'distribution')
				) dbs
	outer apply (select sum(cast(Processors as int)) Processors, sum(cast(CoreCount as int)) CoreCount, sum(cast(LogicalProcessors as int)) LogicalProcessors, sum(CPUScore) CPUScore
					from Processors
					where PRS_MOB_ID = s.MOB_ID) prs
	outer apply (select top 1 ProcessorName
					from Processors
					where PRS_MOB_ID = s.MOB_ID
					order by CPUScore desc) prs1
	left join Inventory.Versions dv on d.MOB_VER_ID = dv.VER_ID
	left join Inventory.ProductLevels dp on DID_PRL_ID = dp.PRL_ID
	left join Inventory.Editions de on DID_EDT_ID = de.EDT_ID
	left join Inventory.Versions sv on s.MOB_VER_ID = sv.VER_ID
	left join Inventory.Editions se on s.MOB_Engine_EDT_ID = se.EDT_ID
	left join Inventory.ProductLevels sp on OSS_PRL_ID = sp.PRL_ID
	left join sys.syslanguages on OSS_Language = lcid
	left join Inventory.MachineManufacturers on MMN_ID = OSS_MMN_ID
	left join inventory.MachineManufacturerModels on MMD_ID = OSS_MMD_ID
	outer apply (select SSM_Name StartingMode, SST_Name ServiceStatus
					from Inventory.OperatingSystemServices
						left join Inventory.ServiceNames on SNM_ID = OSR_SNM_ID
						left join Inventory.ServiceStartModes on SSM_ID = OSR_SSM_ID
						left join Inventory.ServiceStates on SST_ID = OSR_SST_ID
						left join Inventory.SQLComponentTypes on LEFT(SNM_Name + '$', CHARINDEX('$', SNM_Name + '$', 1) - 1) like SMT_ServiceName
					where SMT_DisplayName = 'Database Engine'
							and OSR_MOB_ID = s.MOB_ID
							and (SUBSTRING(SNM_Name, CHARINDEX('$', SNM_Name + '$', 1) + 1, 100) = DID_InstanceName
									or SUBSTRING(SNM_Name, CHARINDEX('$', SNM_Name + '$', 1) + 1, 100) = '' and DID_InstanceName is null)
					) osr
where s.MOB_OOS_ID = 1
	and d.MOB_OOS_ID = 1
	and (@ShowOnlyConsolidationParticipants = 0
		or CGR_Name is not null)
order by 1, 2, 3

select DID_Name ServerName, IDB_Name DatabaseName, VER_Name SQLVersion, MOB_ID, CIN_ID, IDB_ID
into #Databases
from Inventory.InstanceDatabases
	inner join Inventory.MonitoredObjects on MOB_ID = IDB_MOB_ID
	inner join Inventory.DatabaseInstanceDetails on DID_DFO_ID = MOB_Entity_ID
	inner join Inventory.Versions on VER_ID = MOB_VER_ID
	inner join Inventory.DatabaseFiles on DBF_IDB_ID = IDB_ID
	inner join PerformanceData.CounterInstances on CIN_Name = DBF_FileName
where MOB_OOS_ID = 1
	and MOB_PLT_ID = 1
	and DBF_DFT_ID <> 1
	and (@ShowOnlyConsolidationParticipants = 0
			or exists (select * from Consolidation.ParticipatingDatabaseServers where PDS_Database_MOB_ID = MOB_ID))

select @Collector_PGN_ID = PGN_ID
from Activity.ProgramNames
where PGN_Name = 'DBBest Collector'

select 'Database sizes' [Report]
select left(ServerName, charindex('\', ServerName + '\', 1) - 1) ServerName, ServerName InstanceName, DatabaseName, SQLVersion, sum(SizeMB) SizeMB,
	case when DatabaseName in ('master', 'tempdb', 'model', 'msdb') then 'System database'
			when Connections = 0 then 'No'
			else 'Yes'
		end IsActive
from #Databases
	outer apply (select top 1 cast(CRS_Value as bigint) SizeMB
				from PerformanceData.CounterResults with (forceseek)
				where CRS_MOB_ID = MOB_ID
					and CRS_SystemID = 3
					and CRS_CounterID = 41
					and CRS_InstanceID = CIN_ID
				order by CRS_DateTime desc) r
	outer apply (select count(*) Connections
					from Inventory.ApplicationConnections with (forceseek)
				where ACN_MOB_ID = MOB_ID
						and IDB_ID  = ACN_IDB_ID
						and (ACN_PGN_ID <> @Collector_PGN_ID or ACN_PGN_ID is null)
						) a
group by ServerName, DatabaseName, SQLVersion, case when DatabaseName in ('master', 'tempdb', 'model', 'msdb') then 'System database'
													when Connections = 0 then 'No'
													else 'Yes'
												end
order by ServerName, DatabaseName
GO
