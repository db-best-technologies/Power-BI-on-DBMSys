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
/****** Object:  View [Tests].[VW_TST_InstalledPatches]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_InstalledPatches]
as
select top 0 CAST(null as varchar(1000)) Caption,
			CAST(null as varchar(100)) [Description],
			CAST(null as varchar(200)) HotFixID,
			CAST(null as varchar(10)) InstalledOn,
			CAST(null as varchar(200)) ServicePackInEffect,
			CAST(null as varchar(100)) [Status],
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_InstalledPatches]    Script Date: 6/8/2020 1:16:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_InstalledPatches] on [Tests].[VW_TST_InstalledPatches]
	instead of insert
as
set nocount on

merge Inventory.PatchCategories d
	using (select distinct [Description]
			from inserted
			where [Description] is not null) s
		on [Description] = PCT_Name
	when not matched then insert(PCT_Name)
							values([Description]);

merge Inventory.PatchTypes d
	using (select distinct nullif(rtrim(ServicePackInEffect), '') ServicePackInEffect, HotFixID, PCT_ID, Caption
			from inserted
				inner join Inventory.PatchCategories on [Description] = PCT_Name
			) s
		on HotFixID = PTY_HotFixID
			and (ServicePackInEffect = PTY_ServicePackInEffect
				or (ServicePackInEffect is null
					and PTY_ServicePackInEffect is null)
				)
	when not matched then insert(PTY_ServicePackInEffect, PTY_HotFixID, PTY_PCT_ID, PTY_Link)
							values(ServicePackInEffect, HotFixID, PCT_ID, Caption);

merge Inventory.PatchStatuses d
	using (select distinct [Status]
			from inserted
			where [Status] is not null) s
		on [Status] = PST_Name
	when not matched then insert(PST_Name)
							values([Status]); 

merge Inventory.InstalledPatches d
	using (select Metadata_ClientID, TRH_MOB_ID, PTY_ID, cast(nullif(InstalledOn, '') as date) InstalledOn, PST_ID, TRH_StartDate, TRH_ID
			from inserted
				inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID
				inner join Inventory.PatchTypes on HotFixID = PTY_HotFixID
														and (nullif(rtrim(ServicePackInEffect), '') = PTY_ServicePackInEffect
															or (nullif(rtrim(ServicePackInEffect), '') is null
																and PTY_ServicePackInEffect is null)
															)
				left join Inventory.PatchStatuses on [Status] = PST_Name
			) s
		on ISP_MOB_ID = TRH_MOB_ID
			and ISP_PTY_ID = PTY_ID
	when matched then update set
							ISP_InstalledDate = InstalledOn,
							ISP_PST_ID = PST_ID,
							ISP_LastSeenDate = TRH_StartDate,
							ISP_Last_TRH_ID = TRH_ID
	when not matched then insert (ISP_ClientID, ISP_MOB_ID, ISP_PTY_ID, ISP_InstalledDate, ISP_PST_ID, ISP_InsertDate, ISP_LastSeenDate, ISP_Last_TRH_ID)
							values(Metadata_ClientID, TRH_MOB_ID, PTY_ID, InstalledOn, PST_ID, TRH_StartDate, TRH_StartDate, TRH_ID);
GO
