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
/****** Object:  View [Tests].[VW_TST_WindowsVolumes]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_WindowsVolumes]
as
select top 0 CAST(null as int) [BlockSize],
			CAST(null as bigint) Capacity,
			CAST(null as bit) Compressed,
			CAST(null as nvarchar(260)) Caption,
			CAST(null as varchar(50)) FileSystem,
			CAST(null as bigint) SerialNumber,
			CAST(null as bigint) Size,
			CAST(null as nvarchar(128)) Metadata_Servername,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_WindowsVolumes]    Script Date: 6/8/2020 1:16:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_WindowsVolumes] on [Tests].[VW_TST_WindowsVolumes]
	instead of insert
as
set nocount on

merge Inventory.Disks d
	using (select Metadata_ClientID, OS.MOB_ID, [BlockSize], case when Caption like '%\' then left(Caption, len(Caption) - 1) else Caption end Caption,
					isnull(Capacity, Size)/1024/1024 TotalSizeMB, Compressed, FST_ID, SerialNumber,
					case when ICD_ID is not null then 1 else 0 end IsClusteredResource, TRH_StartDate, TRH_ID
			from inserted
				inner join Inventory.MonitoredObjects OS on MOB_PLT_ID = 2
														and Metadata_Servername = OS.MOB_Name
				inner join Inventory.OSServers N on MOB_ID = OSS_MOB_ID--OS.MOB_Entity_ID = OSS_ID
				inner join Inventory.FileSystems on FileSystem = FST_Name
				inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID
				outer apply (select top 1 ICD_ID
								from Inventory.DatabaseInstanceDetails D
										inner join Inventory.MonitoredObjects DB on DB.MOB_PLT_ID = 1
																				and DB.MOB_Entity_ID = D.DID_DFO_ID
										inner join Inventory.InstanceClusterSharedDrives ICD on DB.MOB_ID = ICD.ICD_MOB_ID
																								and left(Caption, 1) = ICD.ICD_DriveName
								where D.DID_OSS_ID = OSS_ID) ICD
				) s
		on MOB_ID = DSK_MOB_ID
			and Caption = DSK_Path
	when matched then update set DSK_FST_ID = FST_ID,
								DSK_IsClusteredResource = IsClusteredResource,
								DSK_TotalSpaceMB = TotalSizeMB,
								DSK_BlockSize = [BlockSize],
								DSK_IsCompressed = Compressed,
								DSK_SerialNumber = SerialNumber,
								DSK_LastSeenDate = TRH_StartDate,
								DSK_Last_TRH_ID = TRH_ID
	when not matched then insert(DSK_ClientID, DSK_MOB_ID, DSK_FST_ID, DSK_IsClusteredResource, DSK_Path, DSK_InstanceName, DSK_TotalSpaceMB,
									DSK_BlockSize, DSK_IsCompressed, DSK_SerialNumber, DSK_InsertDate, DSK_LastSeenDate, DSK_Last_TRH_ID)
							values(Metadata_ClientID, MOB_ID, FST_ID, IsClusteredResource, Caption, Caption, TotalSizeMB, [BlockSize], Compressed, SerialNumber,
									TRH_StartDate, TRH_StartDate, TRH_ID);
GO
