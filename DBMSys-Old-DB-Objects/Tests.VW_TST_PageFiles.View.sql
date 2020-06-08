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
/****** Object:  View [Tests].[VW_TST_PageFiles]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_PageFiles]
as
select top 0 CAST(null as int) AllocatedBaseSize,
			CAST(null as int) CurrentUsage,
			CAST(null as varchar(1000)) Name,
			CAST(null as int) PeakUsage,
			CAST(null as varchar(100)) [Status],
			CAST(null as bit) TempPageFile,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_PageFiles]    Script Date: 6/8/2020 1:16:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_PageFiles] on [Tests].[VW_TST_PageFiles]
	instead of insert
as
set nocount on

merge Inventory.PageFiles d
	using (select AllocatedBaseSize, CurrentUsage, Name, PeakUsage, PFS_ID, isnull(TempPageFile, 0) TempPageFile,
				TRH_MOB_ID, Metadata_TRH_ID, Metadata_ClientID, TRH_StartDate, DSK_ID
			from inserted
				inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID
				left join Inventory.PageFileStatuses on [Status] = PFS_Name
				cross apply (select top 1 DSK_ID
								from Inventory.Disks
								where DSK_MOB_ID = TRH_MOB_ID
									and Name like DSK_Path + '%'
								order by len(DSK_Path) desc) k) s
		on TRH_MOB_ID = PGF_MOB_ID
			and hashbytes('MD5',left(CONVERT([varchar](max),[Name],(0)),(8000))) = PGF_LocationHashed
	when matched then update set
							PGF_Location = Name,
							PGF_DSK_ID = DSK_ID,
							PGF_AllocatedBaseSizeMB = AllocatedBaseSize,
							PGF_CurrentUsageMB = CurrentUsage,
							PGF_PFS_ID = PFS_ID,
							PGF_IsTempFile = TempPageFile,
							PGF_LastSeenDate = TRH_StartDate,
							PGF_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(PGF_ClientID, PGF_MOB_ID, PGF_Location, PGF_DSK_ID, PGF_AllocatedBaseSizeMB, PGF_CurrentUsageMB,
									PGF_PFS_ID, PGF_IsTempFile, PGF_InsertDate, PGF_LastSeenDate, PGF_Last_TRH_ID)
							values(Metadata_ClientID, TRH_MOB_ID, Name, DSK_ID, AllocatedBaseSize, CurrentUsage, PFS_ID,
									TempPageFile, TRH_StartDate, TRH_StartDate, Metadata_TRH_ID);
GO
