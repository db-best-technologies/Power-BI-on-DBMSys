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
/****** Object:  View [Tests].[VW_TST_ServerRoles]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_ServerRoles]
as
select top 0 CAST(null as int) ID,
			CAST(null as varchar(500)) Name,
			CAST(null as int) ParentID,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_ServerRoles]    Script Date: 6/8/2020 1:16:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_ServerRoles] on [Tests].[VW_TST_ServerRoles]
	instead of insert
as
set nocount on

merge Inventory.ServerRoleTypes d
	using (select ID, Name, ParentID
			from inserted) s
		on ID = SRT_ID
	when not matched then insert(SRT_ID, SRT_Name, SRT_Parent_SRT_ID)
							values(ID, Name, ParentID);

merge Inventory.ServerRoles
	using (select Metadata_ClientID, TRH_MOB_ID, SRT_ID, TRH_StartDate, TRH_ID
			from inserted
				inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID
				inner join Inventory.ServerRoleTypes on ID = SRT_ID) s
		on TRH_MOB_ID = SRL_MOB_ID
			and SRT_ID = SRL_SRT_ID
	when matched then update set
							SRL_LastSeenDate = TRH_StartDate,
							SRL_Last_TRH_ID = TRH_ID
	when not matched then insert(SRL_ClientID, SRL_MOB_ID, SRL_SRT_ID, SRL_InsertDate, SRL_LastSeenDate, SRL_Last_TRH_ID)
							values(Metadata_ClientID, TRH_MOB_ID, SRT_ID, TRH_StartDate, TRH_StartDate, TRH_ID);
GO
