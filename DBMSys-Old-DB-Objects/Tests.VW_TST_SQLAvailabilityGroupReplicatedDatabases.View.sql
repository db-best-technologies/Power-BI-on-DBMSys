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
/****** Object:  View [Tests].[VW_TST_SQLAvailabilityGroupReplicatedDatabases]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_SQLAvailabilityGroupReplicatedDatabases]
as
select top 0 CAST(null as uniqueidentifier) group_id,
			CAST(null as uniqueidentifier) replica_id,
			CAST(null as nvarchar(128)) database_name,
			CAST(null as nvarchar(60)) synchronization_state_desc,
			CAST(null as bit) is_commit_participant,
			CAST(null as nvarchar(60)) synchronization_health_desc,
			CAST(null as nvarchar(60)) database_state_desc,
			CAST(null as bit) is_suspended,
			CAST(null as nvarchar(60)) suspend_reason_desc,
			CAST(null as bit) is_failover_ready,
			CAST(null as bit) is_pending_secondary_suspend,
			CAST(null as bit) is_database_joined,
			CAST(null as int) SecondsSinceLastSendTime,
			CAST(null as int) SecondsSinceLastReceiveTime,
			CAST(null as int) SecondsSinceLastHardenTime,
			CAST(null as int) SecondsSinceLastRedoTime,
			CAST(null as int) SecondsSinceLastCommitTime,
			CAST(null as bigint) log_send_queue_size,
			CAST(null as bigint) log_send_rate,
			CAST(null as bigint) redo_queue_size,
			CAST(null as bigint) redo_rate,
			CAST(null as bigint) filestream_send_rate,
			CAST(null as bigint) low_water_mark_for_ghosts,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SQLAvailabilityGroupReplicatedDatabases]    Script Date: 6/8/2020 1:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_SQLAvailabilityGroupReplicatedDatabases] on [Tests].[VW_TST_SQLAvailabilityGroupReplicatedDatabases]
	instead of insert
as
set nocount on
declare @MOB_ID int,
		@StartDate datetime2(3)
select top 1 @MOB_ID = TRH_MOB_ID,
			@StartDate = TRH_StartDate
from inserted
	inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID

merge Inventory.InstanceDatabases s
	using (select database_name, Metadata_TRH_ID, Metadata_ClientID
			from inserted) d
		on IDB_MOB_ID = @MOB_ID
			and IDB_Name = database_name
	when not matched then insert(IDB_ClientID, IDB_MOB_ID, IDB_Name, IDB_InsertDate, IDB_LastSeenDate, IDB_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, database_name, @StartDate, @StartDate, Metadata_TRH_ID);

merge Inventory.AvailabilityGroupSynchronizationStates d
	using (select distinct synchronization_state_desc
			from inserted
			where synchronization_state_desc is not null) s
		on synchronization_state_desc = ASS_Name
	when not matched then insert(ASS_Name)
							values(synchronization_state_desc);

merge Inventory.AvailabilityGroupSynchronizationHealthStatuses d
	using (select distinct synchronization_health_desc
			from inserted
			where synchronization_health_desc is not null) s
		on synchronization_health_desc = ASH_Name
	when not matched then insert(ASH_Name)
							values(synchronization_health_desc);

merge Inventory.InstanceDatabaseStates d
	using (select distinct database_state_desc
			from inserted
			where database_state_desc is not null) s
		on database_state_desc = IDS_Name
	when not matched then insert(IDS_Name)
							values(database_state_desc);

merge Inventory.AvailabilityGroupSuspensionReasons d
	using (select distinct suspend_reason_desc
			from inserted
			where suspend_reason_desc is not null) s
		on suspend_reason_desc = ASR_Name
	when not matched then insert(ASR_Name)
							values(suspend_reason_desc);

merge Inventory.AvailabilityGroupReplicatedDatabases d
	using (select group_id, replica_id, IDB_ID, ASS_ID, is_commit_participant, ASH_ID, IDS_ID, is_suspended, ASR_ID, is_failover_ready, is_pending_secondary_suspend, is_database_joined,
					Metadata_TRH_ID, Metadata_ClientID
			from inserted
				inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
												and IDB_Name = database_name
				inner join Inventory.AvailabilityGroupSynchronizationStates on synchronization_state_desc = ASS_Name
				inner join Inventory.AvailabilityGroupSynchronizationHealthStatuses on synchronization_health_desc = ASH_Name
				inner join Inventory.InstanceDatabaseStates on database_state_desc = IDS_Name
				left join Inventory.AvailabilityGroupSuspensionReasons on suspend_reason_desc = ASR_Name) s
		on AGD_MOB_ID = @MOB_ID
			and AGD_GroupID = group_id
			and AGD_ReplicaID = replica_id
			and AGD_IDB_ID = IDB_ID
	when matched then update set
							AGD_ASS_ID = ASS_ID,
							AGD_IsCommitParticipant = is_commit_participant,
							AGD_ASH_ID = ASH_ID,
							AGD_IDS_ID = IDS_ID,
							AGD_IsSuspended = is_suspended,
							AGD_ASR_ID = ASR_ID,
							AGD_IsFailoverReady = is_failover_ready,
							AGD_IsPendingSecondarySuspend = is_pending_secondary_suspend,
							AGD_IsDatabaseJoined = is_database_joined,
							AGD_LastSeenDate = @StartDate,
							AGD_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(AGD_ClientID, AGD_MOB_ID, AGD_GroupID, AGD_ReplicaID, AGD_IDB_ID, AGD_ASS_ID, AGD_IsCommitParticipant, AGD_ASH_ID, AGD_IDS_ID, AGD_IsSuspended, AGD_ASR_ID,
								AGD_IsFailoverReady, AGD_IsPendingSecondarySuspend, AGD_IsDatabaseJoined ,AGD_InsertDate, AGD_LastSeenDate, AGD_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, group_id, replica_id, IDB_ID, ASS_ID, is_commit_participant, ASH_ID, IDS_ID, is_suspended, ASR_ID, is_failover_ready,
									is_pending_secondary_suspend, is_database_joined, @StartDate, @StartDate, Metadata_TRH_ID);

;with NewRecords as
		(select AGR_Name + '\' + database_name InstanceName, database_name, Metadata_TRH_ID, Metadata_ClientID, SecondsSinceLastSendTime, SecondsSinceLastReceiveTime, SecondsSinceLastHardenTime,
				SecondsSinceLastRedoTime, SecondsSinceLastCommitTime, log_send_queue_size, log_send_rate, redo_queue_size, redo_rate, filestream_send_rate, low_water_mark_for_ghosts
			from inserted
				inner join Inventory.AvailabilityGroupReplicas on AGR_GroupID = group_id
		)
	, ReplicadDatabasesStats as
		(select 'Filestream Send Rate' CounterName, InstanceName, filestream_send_rate Value, Metadata_TRH_ID, Metadata_ClientID, database_name
			from NewRecords
			where filestream_send_rate is not null
			union all
			select 'Log Send Queue Size' CounterName, InstanceName, log_send_queue_size Value, Metadata_TRH_ID, Metadata_ClientID, database_name
			from NewRecords
			where log_send_queue_size is not null
			union all
			select 'Log Send Rate' CounterName, InstanceName, log_send_rate Value, Metadata_TRH_ID, Metadata_ClientID, database_name
			from NewRecords
			where log_send_rate is not null
			union all
			select 'Low Water Mark For Ghosts' CounterName, InstanceName, low_water_mark_for_ghosts Value, Metadata_TRH_ID, Metadata_ClientID, database_name
			from NewRecords
			where low_water_mark_for_ghosts is not null
			union all
			select 'Redo Queue Size' CounterName, InstanceName, redo_queue_size Value, Metadata_TRH_ID, Metadata_ClientID, database_name
			from NewRecords
			where redo_queue_size is not null
			union all
			select 'Redo Rate' CounterName, InstanceName, redo_rate Value, Metadata_TRH_ID, Metadata_ClientID, database_name
			from NewRecords
			where redo_rate is not null
			union all
			select 'Seconds Since Last Commit Time' CounterName, InstanceName, SecondsSinceLastCommitTime Value, Metadata_TRH_ID, Metadata_ClientID, database_name
			from NewRecords
			where SecondsSinceLastCommitTime is not null
			union all
			select 'Seconds Since Last Harden Time' CounterName, InstanceName, SecondsSinceLastHardenTime Value, Metadata_TRH_ID, Metadata_ClientID, database_name
			from NewRecords
			where SecondsSinceLastHardenTime is not null
			union all
			select 'Seconds Since Last Receive Time' CounterName, InstanceName, SecondsSinceLastReceiveTime Value, Metadata_TRH_ID, Metadata_ClientID, database_name
			from NewRecords
			where SecondsSinceLastReceiveTime is not null
			union all
			select 'Seconds Since Last Redo Time' CounterName, InstanceName, SecondsSinceLastRedoTime Value, Metadata_TRH_ID, Metadata_ClientID, database_name
			from NewRecords
			where SecondsSinceLastRedoTime is not null
			union all
			select 'Seconds Since Last Send Time' CounterName, InstanceName, SecondsSinceLastSendTime Value, Metadata_TRH_ID, Metadata_ClientID, database_name
			from NewRecords
			where SecondsSinceLastSendTime is not null
		)
insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Instance, Value, Metadata_TRH_ID, Metadata_ClientID, DatabaseName)
select 'Availability Group Replicated Database Health', CounterName, InstanceName, Value, Metadata_TRH_ID, Metadata_ClientID, database_name
from ReplicadDatabasesStats
GO
