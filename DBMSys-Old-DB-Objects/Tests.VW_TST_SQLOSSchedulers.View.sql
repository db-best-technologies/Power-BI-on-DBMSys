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
/****** Object:  View [Tests].[VW_TST_SQLOSSchedulers]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_SQLOSSchedulers]
as
select top 0 cast(null as int) parent_node_id,
			CAST(null as int) scheduler_id,
			CAST(null as int) cpu_id,
			CAST(null as nvarchar(60)) [status],
			CAST(null as bit) is_online,
			CAST(null as bit) is_idle,
			CAST(null as int) preemptive_switches_count,
			CAST(null as int) context_switches_count,
			CAST(null as int) idle_switches_count,
			CAST(null as int) current_tasks_count,
			CAST(null as int) runnable_tasks_count,
			CAST(null as int) current_workers_count,
			CAST(null as int) active_workers_count,
			CAST(null as bigint) work_queue_count,
			CAST(null as int) pending_disk_io_count,
			CAST(null as int) load_factor,
			CAST(null as bit) failed_to_create_worker,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SQLOSSchedulers]    Script Date: 6/8/2020 1:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_SQLOSSchedulers] on [Tests].[VW_TST_SQLOSSchedulers]
	instead of insert
as
set nocount on

merge Inventory.SchedulerStatuses d
	using (select distinct [status]
			from inserted
			where [status] is not null) s
		on [status] = SDS_Name
	when not matched then insert(SDS_Name)
							values([status]);

merge Inventory.SQLOSSchedulers
	using (select Metadata_ClientID, Metadata_TRH_ID, TRH_MOB_ID, parent_node_id, scheduler_id, cpu_id, SDS_ID, is_online, is_idle, TRH_StartDate
				from inserted
					inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID
					inner join Inventory.SchedulerStatuses on [status] = SDS_Name) s
		on SOS_MOB_ID = TRH_MOB_ID
			and SOS_SchedulerID = scheduler_id
	when matched then update set
							SOS_ParentNodeID = parent_node_id,
							SOS_ProcessorID = cpu_id,
							SOS_SDS_ID = SDS_ID,
							SOS_IsOnline = is_online,
							SOS_IsIdle = is_idle,
							SOS_LastSeenDate = TRH_StartDate,
							SOS_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(SOS_ClientID, SOS_MOB_ID, SOS_SchedulerID, SOS_ParentNodeID, SOS_ProcessorID, SOS_SDS_ID, SOS_IsOnline, SOS_IsIdle, SOS_InsertDate,
									SOS_LastSeenDate, SOS_Last_TRH_ID)
							values(Metadata_ClientID, TRH_MOB_ID, scheduler_id, parent_node_id, cpu_id, SDS_ID, is_online, is_idle, TRH_StartDate, TRH_StartDate,
									Metadata_TRH_ID);

insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Instance, Value, Metadata_TRH_ID, Metadata_ClientID)
select 'SQLOS Schedulers', GNC_CounterName,
		'Scheduler #' + CAST(scheduler_id as varchar(10)) Instance,
		case GNC_CounterName
			when 'Active Workers Count' then active_workers_count
			when 'Context Switches Count' then context_switches_count
			when 'Current Tasks Count' then current_tasks_count
			when 'Current Workers Count' then current_workers_count
			when 'Failed To Create Worker' then failed_to_create_worker
			when 'Idle Switches Count' then idle_switches_count
			when 'Pending Disk IO Count' then pending_disk_io_count
			when 'Preemptive Switches Count' then preemptive_switches_count
			when 'Runnable Tasks Count' then runnable_tasks_count
			when 'Work Queue Count' then work_queue_count
		end Value, Metadata_TRH_ID, Metadata_ClientID
from inserted
	cross join (select GNC_CounterName, GNC_CSY_ID, GNC_ID
				from PerformanceData.GeneralCounters
				where GNC_CategoryName = 'SQLOS Schedulers') g
GO
