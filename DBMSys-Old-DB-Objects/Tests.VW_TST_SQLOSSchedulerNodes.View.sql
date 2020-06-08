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
/****** Object:  View [Tests].[VW_TST_SQLOSSchedulerNodes]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_SQLOSSchedulerNodes]
as
select top 0 CAST(null as smallint) node_id,
			CAST(null as nvarchar(256)) node_state_desc,
			CAST(null as smallint) memory_node_id,
			CAST(null as bigint) cpu_affinity_mask,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SQLOSSchedulerNodes]    Script Date: 6/8/2020 1:16:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_SQLOSSchedulerNodes] on [Tests].[VW_TST_SQLOSSchedulerNodes]
	instead of insert
as
set nocount on

merge Inventory.SchedulerNodeStatuses d
	using (select distinct node_state_desc
			from inserted
			where node_state_desc is not null) s
		on node_state_desc = SNS_Name
	when not matched then insert(SNS_Name)
							values(node_state_desc);

merge Inventory.SQLOSSchedulerNodes d
	using (select Metadata_ClientID, TRH_MOB_ID, node_id, SNS_ID, memory_node_id, cpu_affinity_mask, TRH_StartDate, Metadata_TRH_ID
			from inserted
				inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID
				inner join Inventory.SchedulerNodeStatuses on node_state_desc = SNS_Name) s
		on SON_MOB_ID = TRH_MOB_ID
			and SON_NodeID = node_id
	when matched then update set
							SON_SNS_ID = SNS_ID,
							SON_MemoryNodeID = memory_node_id,
							SON_CpuAffinityMask = cpu_affinity_mask,
							SON_LastSeenDate = TRH_StartDate,
							SON_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(SON_ClientID, SON_MOB_ID, SON_NodeID, SON_SNS_ID, SON_MemoryNodeID, SON_CpuAffinityMask, SON_InsertDate, SON_LastSeenDate, SON_Last_TRH_ID)
							values(Metadata_ClientID, TRH_MOB_ID, node_id, SNS_ID, memory_node_id, cpu_affinity_mask, TRH_StartDate, TRH_StartDate, Metadata_TRH_ID);
GO
