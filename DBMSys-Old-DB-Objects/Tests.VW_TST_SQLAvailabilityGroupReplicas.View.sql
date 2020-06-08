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
/****** Object:  View [Tests].[VW_TST_SQLAvailabilityGroupReplicas]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_SQLAvailabilityGroupReplicas]
as
select top 0 cast(null as uniqueidentifier) group_id, 
			cast(null as nvarchar(128)) name,
			cast(null as int) failure_condition_level,
			cast(null as int) health_check_timeout,
			cast(null as tinyint) automated_backup_preference,
			cast(null as nvarchar(60)) automated_backup_preference_desc,
			cast(null as uniqueidentifier) replica_id,
			cast(null as nvarchar(256)) replica_server_name,
			cast(null as nvarchar(256)) endpoint_url,
			cast(null as tinyint) availability_mode,
			cast(null as nvarchar(60)) availability_mode_desc,
			cast(null as tinyint) failover_mode,
			cast(null as nvarchar(60)) failover_mode_desc,
			cast(null as tinyint) primary_role_allow_connections,
			cast(null as nvarchar(60)) primary_role_allow_connections_desc,
			cast(null as tinyint) secondary_role_allow_connections,
			cast(null as nvarchar(60)) secondary_role_allow_connections_desc,
			cast(null as datetime) create_date,
			cast(null as int) Metadata_TRH_ID,
			cast(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SQLAvailabilityGroupReplicas]    Script Date: 6/8/2020 1:16:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_SQLAvailabilityGroupReplicas] on [Tests].[VW_TST_SQLAvailabilityGroupReplicas]
	instead of insert
as
set nocount on

merge Inventory.AvailabilityGroupBackupPreferences d
	using (select distinct automated_backup_preference, automated_backup_preference_desc
			from inserted) s
		on automated_backup_preference = AGB_ID
	when not matched then insert(AGB_ID, AGB_Name)
							values(automated_backup_preference, automated_backup_preference_desc);

merge Inventory.AvailabilityGroupAvailabilityModes d
	using (select distinct availability_mode, availability_mode_desc
			from inserted) s
		on availability_mode = AGA_ID
	when not matched then insert(AGA_ID, AGA_Name)
							values(availability_mode, availability_mode_desc);

merge Inventory.AvailabilityGroupFailoverModes d
	using (select distinct failover_mode, failover_mode_desc
			from inserted) s
		on failover_mode = AGF_ID
	when not matched then insert(AGF_ID, AGF_Name)
							values(failover_mode, failover_mode_desc);

merge Inventory.AvailabilityGroupConnectionAllowance d
	using (select primary_role_allow_connections allow_connections, primary_role_allow_connections_desc allow_connections_desc
			from inserted
			union
			select secondary_role_allow_connections allow_connections, secondary_role_allow_connections_desc allow_connections_desc
			from inserted) s
		on allow_connections = AGN_ID
	when not matched then insert(AGN_ID, AGN_Name)
							values(allow_connections, allow_connections_desc);

merge Inventory.AvailabilityGroupReplicas d
	using (select group_id, name, failure_condition_level, health_check_timeout, automated_backup_preference, replica_id, MOB_ID, endpoint_url, availability_mode,
					failover_mode, primary_role_allow_connections, secondary_role_allow_connections, create_date, TRH_ID, Metadata_ClientID, TRH_StartDate
			from inserted
					cross apply (select top 1 MOB_ID
									from Inventory.MonitoredObjects
											inner join Inventory.DatabaseInstanceDetails on DID_DFO_ID = MOB_Entity_ID
											inner join Management.DefinedObjects on DFO_ID = DID_DFO_ID
																					and DFO_PLT_ID = MOB_PLT_ID
									where replica_server_name in (MOB_Name, DID_Name)
									order by iif(replica_server_name = MOB_Name, 0, 1)) o
					inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID) s
		on group_id = AGR_GroupID
			and replica_id = AGR_ReplicaID
	when matched then update set
							AGR_Name = name,
							AGR_AGL_ID = failure_condition_level,
							AGR_HealthCheckTimeout = health_check_timeout,
							AGR_AGB_ID = automated_backup_preference,
							AGR_EndpointURL = endpoint_url,
							AGR_AGA_ID = availability_mode,
							AGR_AGF_ID = failover_mode,
							AGR_Primary_AGN_ID = primary_role_allow_connections,
							AGR_Secondary_AGN_ID = secondary_role_allow_connections,
							AGR_CreateDate = create_date,
							AGR_LastSeenDate = TRH_StartDate,
							AGR_Last_TRH_ID = TRH_ID,
							AGR_IsDeleted = 0

	when not matched then insert(AGR_ClientID, AGR_GroupID, AGR_Name, AGR_AGL_ID, AGR_HealthCheckTimeout, AGR_AGB_ID, AGR_ReplicaID, AGR_MOB_ID, AGR_EndpointURL, AGR_AGA_ID,
								AGR_AGF_ID, AGR_Primary_AGN_ID, AGR_Secondary_AGN_ID, AGR_CreateDate, AGR_InsertDate, AGR_LastSeenDate, AGR_Last_TRH_ID)
						values(Metadata_ClientID, group_id, name, failure_condition_level, health_check_timeout, automated_backup_preference, replica_id, MOB_ID, endpoint_url, availability_mode,
								failover_mode, primary_role_allow_connections, secondary_role_allow_connections, create_date, TRH_StartDate, TRH_StartDate, TRH_ID);

	DECLARE 
			@TRHID		INT
			,@MOBID		INT

	SELECT 
			@TRHID	= TRH_ID
			,@MOBID = TRH_MOB_ID 
	FROM	inserted i 
	JOIN	Collect.TestRunHistory ON Metadata_TRH_ID = TRH_ID 

	UPDATE	Inventory.AvailabilityGroupReplicas
	SET		AGR_IsDeleted = 1
	WHERE	AGR_MOB_ID = @MOBID
			AND NOT EXISTS (SELECT * FROM inserted i WHERE group_id = AGR_GroupID and replica_id = AGR_ReplicaID)
			AND AGR_IsDeleted = 0
			AND EXISTS (SELECT * FROM Collect.GetLastTestTRHID(@TRHID,10)f WHERE f.RN>2 AND AGR_Last_TRH_ID = TRHID)
GO
