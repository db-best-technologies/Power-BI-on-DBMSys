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
/****** Object:  View [Tests].[VW_TST_SQLSharedClusterDrives]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_SQLSharedClusterDrives]
as
select top 0 CAST(null as NCHAR(1)) DriveName,
			CAST(null as nvarchar(128)) Metadata_Servername,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SQLSharedClusterDrives]    Script Date: 6/8/2020 1:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_SQLSharedClusterDrives] on [Tests].[VW_TST_SQLSharedClusterDrives]
	instead of insert
as
set nocount on

merge Inventory.InstanceClusterSharedDrives d
	using (select Metadata_ClientID, TRH_MOB_ID, DriveName, TRH_StartDate, TRH_ID
			from inserted
				inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID) s
		on TRH_MOB_ID = ICD_MOB_ID
			and DriveName = ICD_DriveName
	when matched then update set
							ICD_LastSeenDate = TRH_StartDate,
							ICD_Last_TRH_ID = TRH_ID
	when not matched then insert(ICD_ClientID, ICD_MOB_ID, ICD_DriveName, ICD_InsertDate, ICD_LastSeenDate, ICD_Last_TRH_ID)
							values(Metadata_ClientID, TRH_MOB_ID, DriveName, TRH_StartDate, TRH_StartDate, TRH_ID);
GO
