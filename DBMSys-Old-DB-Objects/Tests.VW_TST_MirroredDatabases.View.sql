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
/****** Object:  View [Tests].[VW_TST_MirroredDatabases]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_MirroredDatabases]
as
select top 0 cast(null as nvarchar(128)) name,
			cast(null as uniqueidentifier) mirroring_guid,
			cast(null as tinyint) mirroring_state,
			cast(null as tinyint) mirroring_role,
			cast(null as tinyint) mirroring_safety_level,
			cast(null as nvarchar(128)) mirroring_partner_instance,
			cast(null as nvarchar(128)) mirroring_witness_name,
			cast(null as tinyint) mirroring_witness_state,
			cast(null as int) mirroring_connection_timeout,
			CAST(null as int) mirroring_redo_queue, 
			cast(null as nvarchar(60)) mirroring_redo_queue_type,
			cast(null as int) Metadata_TRH_ID,
			cast(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_MirroredDatabases]    Script Date: 6/8/2020 1:16:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_MirroredDatabases] on [Tests].[VW_TST_MirroredDatabases]
	instead of insert
as
set nocount on

merge Inventory.MirroredDatabases d
	using (select Metadata_ClientID, TRH_MOB_ID MOB_ID, IDB_ID, mirroring_guid, mirroring_state, mirroring_role, mirroring_safety_level, 
				mirroring_partner_instance, p.MOB_ID Partner_MOB_ID, mirroring_witness_name, w.MOB_ID Witness_MOB_ID, mirroring_witness_state,
				mirroring_connection_timeout, mirroring_redo_queue,
				case when mirroring_redo_queue_type = 'UNLIMITED' then 1 else 0 end IsRedoQueueUnlimited, TRH_StartDate, TRH_ID
			from inserted
				inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID
				inner join Inventory.InstanceDatabases on IDB_MOB_ID = TRH_MOB_ID
														and IDB_Name = name
				left join (Inventory.MonitoredObjects p
								inner join Inventory.DatabaseInstanceDetails pd on p.MOB_PLT_ID = 1
																					and p.MOB_Entity_ID = pd.DID_DFO_ID)
						on mirroring_partner_instance in (p.MOB_Name, pd.DID_Name)
				left join (Inventory.MonitoredObjects w
								inner join Inventory.DatabaseInstanceDetails wd on w.MOB_PLT_ID = 1
																					and w.MOB_Entity_ID = wd.DID_DFO_ID)
						on mirroring_partner_instance in (w.MOB_Name, wd.DID_Name)
			) s
		on MOB_ID = MRD_MOB_ID
			and IDB_ID = MRD_IDB_ID
	when matched then update set
							MRD_GUID = mirroring_guid,
							MRD_MST_ID = mirroring_state,
							MRD_MRL_ID = mirroring_role,
							MRD_MSL_ID = mirroring_safety_level,
							MRD_Partner_Name = mirroring_partner_instance,
							MRD_Partner_MOB_ID = Partner_MOB_ID,
							MRD_Witness_Name = mirroring_witness_name,
							MRD_Witness_MOB_ID = Witness_MOB_ID,
							MRD_MWS_ID = mirroring_witness_state,
							MRD_ConnectionTimeout = mirroring_connection_timeout,
							MRD_MaxRedoQueueSize = mirroring_redo_queue,
							MRD_IsRedoQueueUnlimited = IsRedoQueueUnlimited,
							MRD_LastSeenDate = TRH_StartDate,
							MRD_Last_TRH_ID = TRH_ID
	when not matched then insert(MRD_ClientID, MRD_MOB_ID, MRD_IDB_ID, MRD_GUID, MRD_MST_ID, MRD_MRL_ID, MRD_MSL_ID, MRD_Partner_Name, MRD_Partner_MOB_ID, MRD_Witness_Name,
									MRD_Witness_MOB_ID, MRD_MWS_ID, MRD_ConnectionTimeout, MRD_MaxRedoQueueSize, MRD_IsRedoQueueUnlimited, MRD_InsertDate, MRD_LastSeenDate,
									MRD_Last_TRH_ID)
							values(Metadata_ClientID, MOB_ID, IDB_ID, mirroring_guid, mirroring_state, mirroring_role, mirroring_safety_level, mirroring_partner_instance,
									Partner_MOB_ID, mirroring_witness_name, Witness_MOB_ID, mirroring_witness_state, mirroring_connection_timeout, mirroring_redo_queue,
									IsRedoQueueUnlimited, TRH_StartDate, TRH_StartDate, TRH_ID);
GO
