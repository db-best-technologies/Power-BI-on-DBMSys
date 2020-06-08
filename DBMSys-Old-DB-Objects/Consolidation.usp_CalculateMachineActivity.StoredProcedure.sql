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
/****** Object:  StoredProcedure [Consolidation].[usp_CalculateMachineActivity]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Consolidation].[usp_CalculateMachineActivity]
AS
BEGIN
	set nocount on
	if object_id('tempdb..#Counters') is not null
		drop table #Counters
	if object_id('tempdb..#MissingData') is not null
		drop table #MissingData

	create table #Counters
	(
		UCI_PLT_ID			int,
		UCI_SystemID		int,
		UCI_CounterID		int,
		UCI_DivideBy		decimal(18, 5),
		UCI_ConstantValue	decimal(18, 5),
		UCI_InstanceName	varchar(900)
	)

	truncate table Consolidation.MachineActivity

	-- For Unified counters groups
	truncate table #Counters
	INSERT INTO #Counters(UCI_PLT_ID, UCI_SystemID, UCI_CounterID, UCI_DivideBy, UCI_ConstantValue)
	select UCI_PLT_ID, UCI_SystemID, UCI_CounterID, ISNULL(UCI_DivideBy, 1) AS UCI_DivideBy, UCI_ConstantValue
	from PerformanceData.UnifiedCounterImplementations
	where UCI_UFT_ID IN (6, 7)	-- Counter_ID in 21, 23, Counter Type in ('Reads/sec', 'Writes/sec')
		and exists (select *
			from Management.PlatformTypes
			where PLT_ID = UCI_PLT_ID
				and PLT_PLC_ID = 2)

	insert into Consolidation.MachineActivity
	select PDS_Server_MOB_ID, case when sum(IsActive)*100/count(IsActive) > 90 then 100 else sum(IsActive)*100/count(IsActive) end PercentActive
	from (select distinct PDS_Server_MOB_ID
			from Consolidation.ParticipatingDatabaseServers) s
		cross apply (select PPH_Primary_Server_MOB_ID V_MOB_ID, PPH_StartDate, PPH_EndDate
						from Consolidation.ParticipatingServersPrimaryHistory
						where PPH_Server_MOB_ID = PDS_Server_MOB_ID
						union all
						select CNM_VirtualServer_MOB_ID V_MOB_ID, PPH_StartDate, PPH_EndDate
						from Consolidation.ClusterNodesMapping
							inner join Consolidation.ParticipatingServersPrimaryHistory on PPH_Server_MOB_ID = CNM_ClusterNode_MOB_ID
						where CNM_ClusterNode_MOB_ID = PDS_Server_MOB_ID) c
		inner join Inventory.MonitoredObjects on MOB_ID = V_MOB_ID
		cross apply (select case when sum(CRS_Value) > 16 then 1 else 0 end IsActive
						from Inventory.Disks
							inner join #Counters on UCI_PLT_ID = MOB_PLT_ID
							inner join PerformanceData.CounterInstances on CIN_Name = DSK_InstanceName
							inner join PerformanceData.CounterResults on CRS_MOB_ID = DSK_MOB_ID
						where DSK_MOB_ID = V_MOB_ID	
							and (exists (select *
											from Inventory.DatabaseFiles
											where DBF_DSK_ID = DSK_ID)
									or PDS_Server_MOB_ID in (select PDS_Server_MOB_ID from Consolidation.ParticipatingDatabaseServers where PDS_Database_MOB_ID is null)
								)
							and CRS_SystemID = UCI_SystemID
							and CRS_CounterID = UCI_CounterID
							and CRS_InstanceID = CIN_ID
							and CRS_DateTime >= PPH_StartDate
							and CRS_DateTime < PPH_EndDate
						group by dateadd(hour, datepart(hour, CRS_DateTime)/6, cast(cast(CRS_DateTime as date) as datetime))
					) d
	group by PDS_Server_MOB_ID

	insert into Consolidation.MachineActivity(MAC_MOB_ID, MAC_PercentActive)
	select SGR_MOB_ID, 100
	from Consolidation.ServerGrouping
	where not exists (select *
						from Consolidation.MachineActivity
						where MAC_MOB_ID = SGR_MOB_ID)
END
GO
