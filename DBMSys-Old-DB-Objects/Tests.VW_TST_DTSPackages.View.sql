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
/****** Object:  View [Tests].[VW_TST_DTSPackages]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_DTSPackages]
as
SELECT TOP 0 CAST(null as nvarchar(128)) PackageName,
			CAST(null as datetime) CreateDate,
			CAST(null as bit) IsPartOfAnActiveJob,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_DTSPackages]    Script Date: 6/8/2020 1:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_DTSPackages] on [Tests].[VW_TST_DTSPackages]
	instead of insert
as
set nocount on

merge Inventory.DTSPackages d
	using (select PackageName, CreateDate, IsPartOfAnActiveJob, TRH_MOB_ID, TRH_StartDate, Metadata_TRH_ID, Metadata_ClientID
			from inserted
				inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID) s
		on DTP_MOB_ID = TRH_MOB_ID
			and DTP_Name = PackageName collate database_default
	when matched then update set
							DTP_Name = PackageName,
							DTP_CreateDate = CreateDate,
							DTP_IsPartOfAnActiveJob = IsPartOfAnActiveJob,
							DTP_LastSeenDate = TRH_StartDate,
							DTP_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(DTP_ClientID, DTP_MOB_ID, DTP_Name, DTP_CreateDate, DTP_IsPartOfAnActiveJob, DTP_InsertDate, DTP_LastSeenDate, DTP_Last_TRH_ID)
							values(Metadata_ClientID, TRH_MOB_ID, PackageName, CreateDate, IsPartOfAnActiveJob, TRH_StartDate, TRH_StartDate, Metadata_TRH_ID);
GO
