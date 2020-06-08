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
/****** Object:  View [Tests].[VW_TST_SQLAvailabilityGroupClusterMembers]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_SQLAvailabilityGroupClusterMembers]
as
select top 0 cast(null as nvarchar(256)) cluster_name,
			cast(null as nvarchar(256)) member_name,
			cast(null as tinyint) member_state,
			cast(null as int) Metadata_TRH_ID,
			cast(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SQLAvailabilityGroupClusterMembers]    Script Date: 6/8/2020 1:16:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_SQLAvailabilityGroupClusterMembers] on [Tests].[VW_TST_SQLAvailabilityGroupClusterMembers]
	instead of insert
as
set nocount on
declare @StartDate datetime2(3),
		@OOS_ID tinyint

select @OOS_ID = CAST(SET_Value as tinyint)
from Management.Settings
where SET_Module = 'Tests'
	and SET_Key = 'Availability Group New Machine Operational Status'

select @StartDate = TRH_StartDate
from inserted
	inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID

merge Inventory.AvailabilityGroupsClusters d
	using (select distinct cluster_name, Metadata_TRH_ID, Metadata_ClientID
			from inserted) s
		on cluster_name = AGC_Name
	when matched then update set
							AGC_LastSeenDate = @StartDate,
							AGC_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(AGC_ClientID, AGC_Name, AGC_InsertDate, AGC_LastSeenDate, AGC_Last_TRH_ID)
							values(Metadata_ClientID, cluster_name, @StartDate, @StartDate, Metadata_TRH_ID);

--merge Inventory.OSServers d
--	using (select Metadata_ClientID, 2 PLT_ID, member_name,
--					0 IsVirtualServer, 0 IsClusterNode
--			from inserted) s
--				on PLT_ID = OSS_PLT_ID
--					and member_name = OSS_Name
--			when matched then update set
--					OSS_IsVirtualServer = IsVirtualServer,
--					OSS_IsClusterNode = IsClusterNode
--			when not matched then insert(OSS_ClientID, OSS_PLT_ID, OSS_Name, OSS_IsVirtualServer, OSS_IsClusterNode)
--									values(Metadata_ClientID, PLT_ID, member_name, IsVirtualServer, IsClusterNode);

--merge Inventory.MonitoredObjects d
--	using (select Metadata_ClientID, OSS_ID Entity_ID, member_name,
--					@OOS_ID OOS_ID
--			from inserted
--				inner join Inventory.OSServers on OSS_Name = member_name) s
--		on MOB_PLT_ID = 2
--			and MOB_Name = member_name
--	when matched and MOB_OOS_ID in (0, 4) and OOS_ID = 1 then update set
--					MOB_OOS_ID = OOS_ID
--	when not matched then insert (MOB_ClientID, MOB_PLT_ID, MOB_Entity_ID, MOB_Name, MOB_OOS_ID)
--							values(Metadata_ClientID, 2, Entity_ID, member_name, OOS_ID);

merge Inventory.AvailabilityGroupsClusterMembers d
	using (select AGC_ID, MOB_ID, member_state IsOnline, Metadata_TRH_ID, Metadata_ClientID
			from inserted
				inner join Inventory.AvailabilityGroupsClusters on cluster_name = AGC_Name
				inner join Inventory.MonitoredObjects on MOB_PLT_Id = 2
														and MOB_Name = member_name) s
		on AGM_AGC_ID = AGC_ID
			and AGM_MOB_ID = MOB_ID
	when matched then update set
					AGM_IsOnline = IsOnline,
					AGM_LastSeenDate = @StartDate,
					AGM_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(AGM_ClientID, AGM_AGC_ID, AGM_MOB_ID, AGM_IsOnline, AGM_InsertDate, AGM_LastSeenDate, AGM_Last_TRH_ID)
							values(Metadata_ClientID, AGC_ID, MOB_ID, IsOnline, @StartDate, @StartDate, Metadata_TRH_ID);
GO
