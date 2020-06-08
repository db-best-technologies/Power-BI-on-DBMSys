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
/****** Object:  View [Tests].[VW_TST_InstanceAudits]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_InstanceAudits]
as
select top 0 CAST(null as nvarchar(128)) name,
			CAST(null as datetime) create_date,
			CAST(null as datetime) modify_date,
			CAST(null as nvarchar(60)) type_desc,
			CAST(null as nvarchar(60)) on_failure_desc,
			CAST(null as bit) is_state_enabled,
			CAST(null as int) queue_delay,
			CAST(null as datetime2) status_time,
			CAST(null as nvarchar(256)) status_desc,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_InstanceAudits]    Script Date: 6/8/2020 1:16:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_InstanceAudits] on [Tests].[VW_TST_InstanceAudits]
	instead of insert
as
set nocount on

merge Inventory.InstanceAuditTypes d
	using (select distinct type_desc
			from inserted
			where type_desc is not null) s
		on type_desc = IAT_Name
	when not matched then insert(IAT_Name)
							values(type_desc);

merge Inventory.InstanceAuditOnFailureActionTypes d
	using (select distinct on_failure_desc
			from inserted
			where on_failure_desc is not null) s
		on on_failure_desc = IAF_Name
	when not matched then insert(IAF_Name)
							values(on_failure_desc);

merge Inventory.InstanceAuditStatuses d
	using (select distinct status_desc
			from inserted
			where status_desc is not null) s
		on status_desc = IAS_Name
	when not matched then insert(IAS_Name)
							values(status_desc);

merge Inventory.InstanceAudits
	using (select name, create_date, modify_date, IAT_ID, IAF_ID, is_state_enabled, queue_delay, status_time, IAS_ID, Metadata_ClientID,
					TRH_ID, TRH_MOB_ID, TRH_StartDate
			from inserted
				inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID
				inner join Inventory.InstanceAuditTypes on type_desc = IAT_Name
				left join Inventory.InstanceAuditOnFailureActionTypes on on_failure_desc = IAF_Name
				left join Inventory.InstanceAuditStatuses on status_desc = IAS_Name
			) s
		on IAU_MOB_ID = TRH_MOB_ID
			and IAU_Name = name
	when matched then update set
							IAU_CreateDate = create_date,
							IAU_ModifyDate = modify_date,
							IAU_IAT_ID = IAT_ID,
							IAU_IAF_ID = IAF_ID,
							IAU_IsEnabled = is_state_enabled,
							IAU_QueueDelay = queue_delay,
							IAU_LastStatusUpdateDate = status_time,
							IAU_IAS_ID = IAS_ID,
							IAU_LastSeenDate = TRH_StartDate,
							IAU_Last_TRH_ID = TRH_ID
	when not matched then insert(IAU_ClientID, IAU_MOB_ID, IAU_Name, IAU_CreateDate, IAU_ModifyDate, IAU_IAT_ID, IAU_IAF_ID, IAU_IsEnabled, IAU_QueueDelay,
									IAU_LastStatusUpdateDate, IAU_IAS_ID, IAU_InsertDate, IAU_LastSeenDate, IAU_Last_TRH_ID)
						values(Metadata_ClientID, TRH_MOB_ID, name, create_date, modify_date, IAT_ID, IAF_ID, is_state_enabled, queue_delay, status_time, IAS_ID,
								TRH_StartDate, TRH_StartDate, TRH_ID);
GO
