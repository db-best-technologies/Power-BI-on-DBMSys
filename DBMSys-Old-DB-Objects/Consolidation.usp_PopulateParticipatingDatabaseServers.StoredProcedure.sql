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
/****** Object:  StoredProcedure [Consolidation].[usp_PopulateParticipatingDatabaseServers]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Consolidation].[usp_PopulateParticipatingDatabaseServers]
as
if object_id('tempdb..#Servers') is not null
	drop table #Servers

declare @ConsiderClusterVirtualServerAsHost bit,
		@ConsiderServersWithoutADatabaseInstance bit,
		@IncludeAvailabilityGroupSecondaries bit,
		@StartDate datetime2(3),
		@EndDate datetime2(3)

truncate table Consolidation.ParticipatingDatabaseServers
truncate table Consolidation.ClusterNodesMapping
truncate table Consolidation.ParticipatingServersPrimaryHistory

select @ConsiderClusterVirtualServerAsHost = cast(SET_Value as bit)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Consider Cluster Virtual Server As Host'

select @ConsiderServersWithoutADatabaseInstance = cast(SET_Value as bit)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Consider servers without a database instance'

select @IncludeAvailabilityGroupSecondaries = cast(SET_Value as bit)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Include Availability Group Secondaries'

select @StartDate = min(CRS_DateTime),
	@EndDate = max(CRS_DateTime)
from PerformanceData.CounterResults

select d.MOB_ID + 0 DB_MOB_ID, PCR_Parent_MOB_ID OS_MOB_ID, OSS_IsClusterNode, OSS_IsVirtualServer
into #Servers
from Inventory.MonitoredObjects d
	inner join Management.PlatformTypes dp on dp.PLT_ID = d.MOB_PLT_ID
	cross join (select 1 IsClusterNode
					union all select 0 IsClusterNode) c
	cross apply (select top 1 PCR_Parent_MOB_ID, OSS_IsClusterNode, OSS_IsVirtualServer
					from Inventory.ParentChildRelationships
						inner join Inventory.MonitoredObjects o on o.MOB_ID = PCR_Parent_MOB_ID
						inner join Management.PlatformTypes op on op.PLT_ID = o.MOB_PLT_ID
						inner join Inventory.OSServers on OSS_MOB_ID = o.MOB_ID
					where PCR_Child_MOB_ID = d.MOB_ID
						and PCR_IsCurrentParent = 1
						and op.PLT_PLC_ID = 2
						and o.MOB_OOS_ID in (0, 1)
						and OSS_IsClusterNode = IsClusterNode
						and o.MOB_VER_ID is not null
					order by PCR_LastSeenDate desc) p
where dp.PLT_PLC_ID = 1
	and d.MOB_OOS_ID = 1
	and d.MOB_VER_ID is not null
	and not exists (select *
						from Consolidation.RemovedFromAssessment
						where RFA_MOB_ID = PCR_Parent_MOB_ID)

insert into #Servers
select distinct null DB_MOB_ID, MOB_ID OS_MOB_ID, isnull(OSS_IsClusterNode, 0), OSS_IsVirtualServer
from Inventory.MonitoredObjects o
	inner join Inventory.OSServers on OSS_MOB_ID = MOB_ID
	inner join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
where PLT_PLC_ID = 2
	and MOB_OOS_ID = 1
	and MOB_VER_ID is not null
	and @ConsiderServersWithoutADatabaseInstance = 1
	and not exists (select *
						from Inventory.ParentChildRelationships
						where PCR_Parent_MOB_ID = o.MOB_ID
							and exists (select *
											from #Servers
											where DB_MOB_ID = PCR_Child_MOB_ID)
						)
	and not exists (select *
					from #Servers
					where OS_MOB_ID = MOB_ID)
	and not exists (select *
						from Consolidation.RemovedFromAssessment
						where RFA_MOB_ID = MOB_ID)

if @ConsiderClusterVirtualServerAsHost = 1
	insert into Consolidation.ParticipatingDatabaseServers
	select DB_MOB_ID, OS_MOB_ID
	from #Servers
	where OSS_IsClusterNode = 0
else
begin
	insert into Consolidation.ClusterNodesMapping
	select OS_MOB_ID, Node_MOB_ID
	from #Servers vs
		inner join Inventory.MonitoredObjects on MOB_ID = OS_MOB_ID
		cross apply (select top 1 nd.OS_MOB_ID Node_MOB_ID
						from #Servers nd
						where nd.DB_MOB_ID = vs.DB_MOB_ID
							and nd.OSS_IsClusterNode = 1) p
	where OSS_IsVirtualServer = 1

	insert into Consolidation.ParticipatingDatabaseServers
	select DB_MOB_ID, OS_MOB_ID
	from #Servers
	where OSS_IsVirtualServer = 0
end

if @IncludeAvailabilityGroupSecondaries = 0
begin
	delete Consolidation.ParticipatingDatabaseServers
	where PDS_Database_MOB_ID in (select AGR_MOB_ID
									from Inventory.AvailabilityGroupReplicas
									where AGR_AGO_ID = 2
										and exists (select *
														from Inventory.AvailabilityGroupReplicatedDatabases
														where AGD_GroupID = AGR_GroupID)
								)
		and not PDS_Database_MOB_ID in (select AGR_MOB_ID
									from Inventory.AvailabilityGroupReplicas
									where AGR_AGO_ID = 1
										and exists (select *
														from Inventory.AvailabilityGroupReplicatedDatabases
														where AGD_GroupID = AGR_GroupID)
								)

	insert into Consolidation.ParticipatingServersPrimaryHistory
	select PDS_Server_MOB_ID, PDS_Database_MOB_ID, PCR_Parent_MOB_ID, a.AGS_MOB_ID, iif(a.AGS_DateRecorded < @StartDate, @StartDate, a.AGS_DateRecorded), isnull(b.AGS_DateRecorded, @EndDate)
	from Consolidation.ParticipatingDatabaseServers
		inner join Inventory.AvailabilityGroupReplicas on AGR_MOB_ID = PDS_Database_MOB_ID
		inner join Activity.AvailabilityGroupRoleSwitches a on a.AGS_GroupID = AGR_GroupID
		cross apply (select top 1 PCR_Parent_MOB_ID
						from Inventory.ParentChildRelationships
						where PCR_Child_MOB_ID = a.AGS_MOB_ID
							and PCR_IsCurrentParent = 1) p
		outer apply (select top 1 b.AGS_DateRecorded
						from Activity.AvailabilityGroupRoleSwitches b
						where b.AGS_GroupID = a.AGS_GroupID
							and b.AGS_DateRecorded > a.AGS_DateRecorded
						order by b.AGS_DateRecorded) b
	where exists (select *
					from Inventory.AvailabilityGroupReplicatedDatabases
					where AGD_GroupID = AGR_GroupID)

	insert into Consolidation.ParticipatingServersPrimaryHistory
	select MOB_ID, PCR_Parent_MOB_ID, PPH_Database_MOB_ID, Primary_Database_MOB_ID, @StartDate, PPH_StartDate
	from (select distinct PPH_Server_MOB_ID MOB_ID, PPH_Database_MOB_ID
			from Consolidation.ParticipatingServersPrimaryHistory) s
		cross apply (select top 1 PPH_StartDate, PPH_Primary_Server_MOB_ID, PPH_Primary_Database_MOB_ID
						from Consolidation.ParticipatingServersPrimaryHistory
						where PPH_Server_MOB_ID = MOB_ID
						order by PPH_StartDate
					) d
		cross apply (select top 1 Primary_Database_MOB_ID
						from Consolidation.ParticipatingDatabaseServers
							inner join Inventory.AvailabilityGroupReplicas a on AGR_MOB_ID = PDS_Database_MOB_ID
							cross apply (select top 1 b.AGR_MOB_ID Primary_Database_MOB_ID
											from Inventory.AvailabilityGroupReplicas b
											where b.AGR_GroupID = a.AGR_GroupID
												and b.AGR_MOB_ID <> PPH_Primary_Database_MOB_ID
											order by b.AGR_AGA_ID desc
												) b
						where PDS_Server_MOB_ID = MOB_ID
							and AGR_AGO_ID = 1) a
			cross apply (select top 1 PCR_Parent_MOB_ID
							from Inventory.ParentChildRelationships
							where PCR_Child_MOB_ID = a.Primary_Database_MOB_ID
								and PCR_IsCurrentParent = 1) p								
	where PPH_StartDate > @StartDate
end

update Consolidation.ParticipatingDatabaseServers
set PDS_Database_MOB_ID = (select MOB_ID
							from Inventory.MonitoredObjects d
							where d.MOB_Name + ':' like o.MOB_Name + ':%'
								and exists (select *
												from Management.PlatformTypes
												where PLT_ID = d.MOB_PLT_ID
													and PLT_PLC_ID = 1)
							)
from Consolidation.ParticipatingDatabaseServers p
	inner join Inventory.MonitoredObjects o on o.MOB_ID = PDS_Server_MOB_ID
where PDS_Database_MOB_ID is null
	and o.MOB_PLT_ID <> 2
	and exists (select *
					from Inventory.MonitoredObjects
					where MOB_ID = PDS_Server_MOB_ID
						and MOB_PLT_ID <> 2)

delete Consolidation.ParticipatingDatabaseServers
where exists (select *
				from Consolidation.Exceptions
				where EXP_EXT_ID = 1
					and EXP_MOB_ID in (PDS_Server_MOB_ID, PDS_Database_MOB_ID))

insert into Consolidation.ParticipatingServersPrimaryHistory
select PDS_Server_MOB_ID, PDS_Database_MOB_ID, PDS_Server_MOB_ID, PDS_Database_MOB_ID, @StartDate, @EndDate
from Consolidation.ParticipatingDatabaseServers
where not exists (select *
					from Consolidation.ParticipatingServersPrimaryHistory
					where PDS_Server_MOB_ID = PPH_Server_MOB_ID)
GO
