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
/****** Object:  StoredProcedure [Consolidation].[usp_DiscoverCollectionExceptions]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Consolidation].[usp_DiscoverCollectionExceptions]
	@CompensateWithCapacityForMissingPerformance bit = 0,
	@ReturnResults bit = 1
as
if object_id('tempdb..#serverleveldata') is not null
	drop table #ServerLevelData
if object_id('tempdb..#DatabaseLevelData') is not null
	drop table #DatabaseLevelData
if object_id('tempdb..#Participatingservers') is not null
	drop table #ParticipatingServers
if object_id('tempdb..#Files') is not null
	drop table #Files
if object_id('tempdb..#Processors') is not null
	drop table #Processors
if object_id('tempdb..#Disks') is not null
	drop table #Disks

update d
set d.DBF_DSK_ID = DSK_ID
from Inventory.DatabaseFiles d
	inner join Consolidation.ParticipatingDatabaseServers on PDS_Database_MOB_ID = DBF_MOB_ID
	inner join Inventory.Disks on DSK_MOB_ID = PDS_Server_MOB_ID
								and DBF_FileName like DSK_Path + '%'
where DBF_DSK_ID is null

select o.MOB_ID Server_MOB_ID, d.MOB_ID Database_MOB_ID
into #ParticipatingServers
from Inventory.MonitoredObjects o
	inner join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
	left join Inventory.ParentChildRelationships on PCR_Parent_MOB_ID = o.MOB_ID
	left join Inventory.MonitoredObjects d on d.MOB_ID = PCR_Child_MOB_ID
											and d.MOB_OOS_ID = 1
where PLT_PLC_ID = 2
	and o.MOB_OOS_ID = 1

select distinct MOB_ID, MOB_Name,
				nullif(stuff(
						iif (MOB_ID is null , ', No WMI data', '')
						+ iif (OSS_ID is null , ', No OS data', '')
						+ iif (PRS_ID is null , ', No Processor data', '')
						+ iif (DSK_ID is null , ', No Disk data', '')
						--+ iif (NIN_ID is null , ', No Network interface data', '')
						+ iif (CPUPerfData < 100 , ', No CPU performance data', '')
						+ iif (DiskPerfData < 100 , ', No Disk performance data', '')
						+ iif (NetPerfData < 100 , ', No Network performance data', '')
						+ iif (MemPerfData < 100 , ', No Memory performance data', '')
						, 1, 2, ''), '')  MissingData,
						iif (MOB_ID is null , 1, 0)
						| iif (OSS_ID is null , 1, 0)
						| iif (PRS_ID is null , 1, 0)
						| iif (DSK_ID is null , 1, 0)
						--+ iif (NIN_ID is null , ', No Network interface data', '')
						| iif (CPUPerfData < 100 , 2, 0)
						| iif (DiskPerfData < 100 , 2, 0)
						| iif (NetPerfData < 100 , 2, 0)
						| iif (MemPerfData < 100 , 2, 0) MissingDataTypes
into #ServerLevelData
from (select distinct Server_MOB_ID from #ParticipatingServers) srv
	inner join Inventory.MonitoredObjects on mob_id = Server_MOB_ID
	outer apply (select top 1 PRS_ID
					from Inventory.Processors
					where PRS_MOB_ID = MOB_ID) p
	outer apply (select top 1 DSK_ID
					from Inventory.Disks
					where DSK_MOB_ID = MOB_ID) d
	--outer apply (select top 1 NIN_ID, NIN_LinkSpeed
	--				from Inventory.NetworkInterfaces
	--				where NIN_MOB_ID = MOB_ID) n
	outer apply (select top 1 OSS_ID
					from Inventory.OSServers
					where (/*OSS_ID = MOB_Entity_ID
							or */OSS_MOB_ID = MOB_ID)
						and OSS_TotalPhysicalMemoryMB is not null) o
	outer apply (select DID_ID, d.MOB_ID D_MOB_ID
					from Inventory.DatabaseInstanceDetails
						inner join Inventory.MonitoredObjects d on d.MOB_PLT_ID = 1
																	and d.MOB_Entity_ID = DID_DFO_ID
					where DID_OSS_ID = OSS_ID
						and d.MOB_OOS_ID = 1) db
	outer apply (select count(*) NetPerfData
					from PerformanceData.UnifiedCounterImplementations
						inner join PerformanceData.CounterResults on UCI_SystemID = CRS_SystemID
																and UCI_CounterID = CRS_CounterID
					where CRS_MOB_ID = MOB_ID
						and UCI_PLT_ID = MOB_PLT_ID
						and UCI_UFT_ID in (12, 13)) npd
	outer apply (select count(*) CPUPerfData
					from PerformanceData.UnifiedCounterImplementations
						inner join PerformanceData.CounterResults on UCI_SystemID = CRS_SystemID
																and UCI_CounterID = CRS_CounterID
					where CRS_MOB_ID = MOB_ID
						and UCI_PLT_ID = MOB_PLT_ID
						and UCI_UFT_ID = 1) cpd
	outer apply (select count(*) DiskPerfData
					from PerformanceData.UnifiedCounterImplementations
						inner join PerformanceData.CounterResults on UCI_SystemID = CRS_SystemID
																and UCI_CounterID = CRS_CounterID
					where CRS_MOB_ID = MOB_ID
						and UCI_PLT_ID = MOB_PLT_ID
						and UCI_UFT_ID in (6, 7)) dpd
	outer apply (select count(*) MemPerfData
					from PerformanceData.UnifiedCounterImplementations
						inner join PerformanceData.CounterResults on UCI_SystemID = CRS_SystemID
																and UCI_CounterID = CRS_CounterID
					where CRS_MOB_ID = MOB_ID
						and UCI_PLT_ID = MOB_PLT_ID
						and UCI_UFT_ID = 2) mpd

select distinct PRS_ClientID, MOB_ID PRS_MOB_ID, PRS_PAC_ID, PRS_PAV_ID, PRS_PCA_ID, PRS_PCS_ID, PRS_CurrentClockSpeed, PRS_CurrentVoltage, PRS_DataWidth, PRS_DeviceID, PRS_L2CacheSize,
	PRS_L3CacheSize, PRS_PMN_ID, PRS_MaxClockSpeed, PRS_PSN_ID, PRS_NumberOfCores, PRS_NumberOfLogicalProcessors, PRS_POS_ID, getdate() PRS_InsertDate, getdate() PRS_LastSeenDate, 0 PRS_Last_TRH_ID
into #Processors
from #ServerLevelData
	cross apply (select top 1 PCR_Child_MOB_ID
					from Inventory.ParentChildRelationships
					where MOB_ID = PCR_Parent_MOB_ID
						and PCR_IsCurrentParent = 1
					order by PCR_LastSeenDate desc
					) p1
	cross apply (select top 1 p2.PCR_Parent_MOB_ID
					from Inventory.ParentChildRelationships p2
					where p2.PCR_Child_MOB_ID = p1.PCR_Child_MOB_ID
							and p2.PCR_Parent_MOB_ID <> MOB_ID
							and p2.PCR_IsCurrentParent = 1
					order by p2.PCR_LastSeenDate desc) p2
	inner join Inventory.Processors on PRS_MOB_ID = p2.PCR_Parent_MOB_ID
where MissingData like '%No Processor data%'

merge Inventory.Processors d
	using #Processors s
		on d.PRS_MOB_ID = s.PRS_MOB_ID
		and d.PRS_DeviceID = s.PRS_DeviceID
	when not matched then insert(PRS_ClientID, PRS_MOB_ID, PRS_PAC_ID, PRS_PAV_ID, PRS_PCA_ID, PRS_PCS_ID, PRS_CurrentClockSpeed, PRS_CurrentVoltage, PRS_DataWidth, PRS_DeviceID, PRS_L2CacheSize, PRS_L3CacheSize,
									PRS_PMN_ID, PRS_MaxClockSpeed, PRS_PSN_ID, PRS_NumberOfCores, PRS_NumberOfLogicalProcessors, PRS_POS_ID, PRS_InsertDate, PRS_LastSeenDate, PRS_Last_TRH_ID)
							values(s.PRS_ClientID, s.PRS_MOB_ID, s.PRS_PAC_ID, s.PRS_PAV_ID, s.PRS_PCA_ID, s.PRS_PCS_ID, s.PRS_CurrentClockSpeed, s.PRS_CurrentVoltage, s.PRS_DataWidth, s.PRS_DeviceID,
									s.PRS_L2CacheSize, s.PRS_L3CacheSize, s.PRS_PMN_ID, s.PRS_MaxClockSpeed, s.PRS_PSN_ID, s.PRS_NumberOfCores, s.PRS_NumberOfLogicalProcessors, s.PRS_POS_ID, s.PRS_InsertDate,
									s.PRS_LastSeenDate, s.PRS_Last_TRH_ID);

delete #ServerLevelData
where MissingData like '%No Processor data%'
	and exists (select *
					from #Processors
					where PRS_MOB_ID = MOB_ID)

select distinct DSK_ClientID, MOB_ID DSK_MOB_ID, DSK_FST_ID, DSK_IsClusteredResource, DSK_Path, DSK_TotalSpaceMB, DSK_BlockSize, DSK_IsCompressed,
	DSK_SerialNumber, getdate() DSK_InsertDate, getdate() DSK_LastSeenDate, 0 DSK_Last_TRH_ID, DSK_InstanceName, p1.PCR_Child_MOB_ID
into #Disks
from #ServerLevelData
	cross apply (select top 1 PCR_Child_MOB_ID
					from Inventory.ParentChildRelationships
					where MOB_ID = PCR_Parent_MOB_ID
						and PCR_IsCurrentParent = 1
					order by PCR_LastSeenDate desc
					) p1
	cross apply (select top 1 p2.PCR_Parent_MOB_ID
					from Inventory.ParentChildRelationships p2
					where p2.PCR_Child_MOB_ID = p1.PCR_Child_MOB_ID
							and p2.PCR_Parent_MOB_ID <> MOB_ID
							and p2.PCR_IsCurrentParent = 1
					order by p2.PCR_LastSeenDate desc) p2
	inner join Inventory.DatabaseFiles on DBF_MOB_ID = p1.PCR_Child_MOB_ID
	inner join Inventory.Disks on DSK_MOB_ID = p2.PCR_Parent_MOB_ID
									and DSK_Letter = left(DBF_FileName, 1)
where MissingData like '%No Disk data%'

merge Inventory.Disks d
	using #Disks s
		on d.DSK_MOB_ID = s.DSK_MOB_ID
			and d.DSK_Path = s.DSK_Path
	when not matched then insert(DSK_ClientID, DSK_MOB_ID, DSK_FST_ID, DSK_IsClusteredResource, DSK_Path, DSK_TotalSpaceMB, DSK_BlockSize, DSK_IsCompressed, DSK_SerialNumber, DSK_InsertDate,
									DSK_LastSeenDate, DSK_Last_TRH_ID, DSK_InstanceName)
							values(s.DSK_ClientID, s.DSK_MOB_ID, s.DSK_FST_ID, s.DSK_IsClusteredResource, s.DSK_Path, s.DSK_TotalSpaceMB, s.DSK_BlockSize, s.DSK_IsCompressed, s.DSK_SerialNumber, s.DSK_InsertDate,
									s.DSK_LastSeenDate, s.DSK_Last_TRH_ID, s.DSK_InstanceName);

update dbf
set DBF_DSK_ID = DSK_ID
from Inventory.DatabaseFiles dbf
	cross apply (select top 1 DSK_ID
					from #Disks d
						inner join Inventory.Disks d1 on d1.DSK_MOB_ID = d.DSK_MOB_ID
														and d1.DSK_Path = d.DSK_Path
					where PCR_Child_MOB_ID = DBF_MOB_ID
						and DBF_FileName like d.DSK_Path + '%'
					order by len(d.DSK_Path) desc) d
where DBF_DSK_ID is null

delete #ServerLevelData
where MissingData like '%No Disk data%'
	and exists (select *
					from #Disks
					where DSK_MOB_ID = MOB_ID)

insert into Inventory.NetworkInterfaces(NIN_ClientID, NIN_MOB_ID, NIN_Index, NIN_NIT_ID, NIN_InsertDate, NIN_LastSeenDate, NIN_Last_TRH_ID, NIN_LinkSpeed)
select NIN_ClientID, MOB_ID NIN_MOB_ID, NIN_Index, NIN_NIT_ID, getdate() NIN_InsertDate, getdate() NIN_LastSeenDate, 0 NIN_Last_TRH_ID, NIN_LinkSpeed
from #ServerLevelData
	cross apply (select top 1 *,
		iif(exists(select *
											from Inventory.Processors a
											where a.PRS_MOB_ID = MOB_ID
												and exists (select *
																from Inventory.Processors b
																where b.PRS_MOB_ID = NIN_MOB_ID
																	and b.PRS_PSN_ID = a.PRS_PSN_ID)
										), 0, 1) aa
					from Inventory.NetworkInterfaces
					where NIN_LinkSpeed is not null
					order by iif(exists(select *
											from Inventory.Processors a
											where a.PRS_MOB_ID = MOB_ID
												and exists (select *
																from Inventory.Processors b
																where b.PRS_MOB_ID = NIN_MOB_ID
																	and b.PRS_PSN_ID = a.PRS_PSN_ID)
										), 0, 1), iif(NIN_LinkSpeed is null, 99999999999, NIN_LinkSpeed)
				) t	
where MissingData like '%No Network interface data%'

delete #ServerLevelData
where MissingData like '%No Network interface data%'
	and exists (select *
					from Inventory.NetworkInterfaces
					where NIN_MOB_ID = MOB_ID)

select Database_MOB_ID, Server_MOB_ID, MOB_Name,
			nullif(stuff(
						iif(MOB_Engine_EDT_ID is null, ', No Edition data', '')
						+ iif(IOPerfData < 100, ', No SQL files IO performance data', '')
						+ iif(DBFiles = 0, 'No database files', '')
					, 1, 2, ''), '') MissingData
into #DatabaseLevelData
from #ParticipatingServers
	inner join Inventory.MonitoredObjects on MOB_ID = Database_MOB_ID
	outer apply (select count(*) IOPerfData
					from PerformanceData.CounterResults
					where CRS_MOB_ID = MOB_ID
						and CRS_SystemID = 3
						and CRS_CounterID = 120) dpd
	outer apply (select count(*) DBFiles
					from Inventory.DatabaseFiles
					where DBF_MOB_ID = MOB_ID) dbf

;with Input as
		(select Database_MOB_ID DB_MOB_ID
			from #DatabaseLevelData
			where MissingData like '%No database files%')
select distinct DB_MOB_ID, CIN_Name
into #Files
from Input
	inner join PerformanceData.CounterResults with (forceseek) on CRS_MOB_ID = DB_MOB_ID
	inner join PerformanceData.CounterInstances on CIN_ID = CRS_InstanceID
where CRS_SystemID = 3
	and CRS_CounterID = 120
	and CIN_Name <> '_Total'

insert into Inventory.DatabaseFiles(DBF_ClientID, DBF_MOB_ID, DBF_IDB_ID, DBF_Name, DBF_FileName, DBF_DSK_ID, DBF_DFT_ID, DBF_InsertDate, DBF_LastSeenDate, DBF_Last_TRH_ID)
select IDB_ClientID, IDB_MOB_ID, IDB_ID, concat(IDB_Name, '_', row_number() over (partition by IDB_Name order by CIN_Name)), substring(CIN_Name, charindex(')', CIN_Name, 1) + 2, 1000) FName, DSK_ID,
	case when CIN_Name like '%ldf' then 1 else 0 end FileType, sysdatetime(), sysdatetime(), 0
from #Files
	inner join Inventory.InstanceDatabases on IDB_MOB_ID = DB_MOB_ID
											and CIN_Name like '(' + IDB_Name + ')%'
	inner join #ParticipatingServers on Database_MOB_ID = DB_MOB_ID
	outer apply (select top 1 DSK_ID, DSK_Path
					from Inventory.Disks
					where DSK_MOB_ID = Server_MOB_ID
						and CIN_Name like '%' + DSK_Path + '%'
					order by len(DSK_Path) desc) d

delete #DatabaseLevelData
where MissingData like '%No database files%'
	and exists (select *
					from Inventory.DatabaseFiles
					where DBF_MOB_ID = Database_MOB_ID)

delete Consolidation.Exceptions
where EXP_EXT_ID = 1


if @CompensateWithCapacityForMissingPerformance = 1
	delete #ServerLevelData
	where MissingDataTypes & 2 = 2
		and MissingDataTypes & 1 = 0

insert into Consolidation.Exceptions
select distinct 1, MOB_ID, null, stuff(isnull(', ' + MissingData, '') + isnull(', ' + DBMissingData, ''), 1, 2, ''), null
from #ServerLevelData
	outer apply (select top 1 MissingData DBMissingData
					from #DatabaseLevelData d
					where MOB_ID = Server_MOB_ID
						and d.MissingData is not null) d
where MissingData is not null
	or DBMissingData is not null

if @ReturnResults = 1
	select MOB_ID, MOB_Name MonitoredObjectName, EXP_Reason Reason
	from Consolidation.Exceptions
		inner join Inventory.MonitoredObjects on MOB_ID = EXP_MOB_ID
	where EXP_EXT_ID = 1
	order by Reason
GO
