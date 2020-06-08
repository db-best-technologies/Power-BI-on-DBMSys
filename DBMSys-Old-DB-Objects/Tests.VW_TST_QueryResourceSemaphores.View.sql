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
/****** Object:  View [Tests].[VW_TST_QueryResourceSemaphores]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_QueryResourceSemaphores]
as
select top 0 CAST(null as int) pool_id,
			CAST(null as smallint) resource_semaphore_id,
			CAST(null as bigint) target_memory_kb,
			CAST(null as bigint) max_target_memory_kb,
			CAST(null as bigint) total_memory_kb,
			CAST(null as bigint) available_memory_kb,
			CAST(null as bigint) granted_memory_kb,
			CAST(null as bigint) used_memory_kb,
			CAST(null as int) grantee_count,
			CAST(null as int) waiter_count,
			CAST(null as bigint) timeout_error_count,
			CAST(null as bigint) forced_grant_count,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_QueryResourceSemaphores]    Script Date: 6/8/2020 1:16:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_QueryResourceSemaphores] on [Tests].[VW_TST_QueryResourceSemaphores]
	instead of insert
as
set nocount on

merge Inventory.QueryResourceSemaphores d
	using (select pool_id, resource_semaphore_id, target_memory_kb, max_target_memory_kb, total_memory_kb, available_memory_kb, granted_memory_kb, used_memory_kb, grantee_count,
				waiter_count, timeout_error_count, forced_grant_count, TRH_ID, TRH_MOB_ID, Metadata_ClientID, TRH_StartDate
			from inserted
				inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID) s
		on TRH_MOB_ID = QRS_MOB_ID
			and (QRS_PoolID = pool_id
					or (QRS_PoolID is null
							and pool_id is null)
				)
			and QRS_ResourceSemaphoreID = resource_semaphore_id
	when matched then update set
							QRS_TargetMemoryKB = target_memory_kb,
							QRS_MaxTargetMemoryKB = max_target_memory_kb,
							QRS_TotalMemoryKB = total_memory_kb,
							QRS_AvailableMemoryKB = available_memory_kb,
							QRS_GrantedMemoryKB = granted_memory_kb,
							QRS_UsedMemoryKB = used_memory_kb,
							QRS_GranteeCount = grantee_count,
							QRS_WaiterCount = waiter_count,
							QRS_TimeoutErrorCount = timeout_error_count,
							QRS_ForcedGrantCount = forced_grant_count,
							QRS_LastSeenDate = TRH_StartDate,
							QRS_Last_TRH_ID = TRH_ID
	when not matched then insert(QRS_ClientID, QRS_MOB_ID, QRS_PoolID, QRS_ResourceSemaphoreID, QRS_TargetMemoryKB, QRS_MaxTargetMemoryKB, QRS_TotalMemoryKB, QRS_AvailableMemoryKB,
									QRS_GrantedMemoryKB, QRS_UsedMemoryKB, QRS_GranteeCount, QRS_WaiterCount, QRS_TimeoutErrorCount, QRS_ForcedGrantCount, QRS_InsertDate,
									QRS_LastSeenDate, QRS_Last_TRH_ID)
							values(Metadata_ClientID, TRH_MOB_ID, pool_id, resource_semaphore_id, target_memory_kb, max_target_memory_kb, total_memory_kb, available_memory_kb,
									granted_memory_kb, used_memory_kb, grantee_count, waiter_count, timeout_error_count, forced_grant_count, TRH_StartDate, TRH_StartDate,
									TRH_ID);
GO
