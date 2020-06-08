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
/****** Object:  View [Tests].[VW_TST_OperatingSystemServices]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_OperatingSystemServices]
as
select top 0 CAST(null as nvarchar(1000)) Caption,
			CAST(null as nvarchar(1000)) [Description],
			CAST(null as nvarchar(1000)) Name,
			CAST(null as varchar(4000)) PathName,
			CAST(null as varchar(200)) ServiceType,
			CAST(null as varchar(300)) StartMode,
			CAST(null as varchar(300)) StartName,
			CAST(null as varchar(100)) [State],
			CAST(null as varchar(100)) [Status],
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_OperatingSystemServices]    Script Date: 6/8/2020 1:16:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_OperatingSystemServices] on [Tests].[VW_TST_OperatingSystemServices]
	instead of insert
as
set nocount on

Merge Inventory.ServiceDescriptions d
	using (select distinct [Description]
			from inserted
			where [Description] is not null) s
		on hashbytes('MD5',left(CONVERT(varchar(max),[Description],0),(8000))) = SCD_HashedDescription
			and [Description] = SCD_Description
	when not matched then insert(SCD_Description)
							values([Description]);

Merge Inventory.ServiceDisplayNames d
	using (select distinct Caption
			from inserted
			where Caption is not null) s
		on hashbytes('MD5',left(CONVERT([nvarchar](max),Caption,(0)),(8000))) = SDN_NameHashed
	when not matched then insert(SDN_Name)
							values(Caption);

Merge Inventory.ServiceLoginNames d
	using (select distinct StartName
			from inserted
			where StartName is not null) s
		on StartName = SLN_Name
	when not matched then insert(SLN_Name)
							values(StartName);

Merge Inventory.ServiceNames d
	using (select distinct Name
			from inserted
			where Name is not null) s
		on SNM_NameHashed = hashbytes('MD5',left(CONVERT([nvarchar](max),[Name],(0)),(8000)))
	when not matched then insert(SNM_Name)
							values(Name);

Merge Inventory.ServicePaths d
	using (select distinct PathName
			from inserted
			where PathName is not null) s
		on SPT_NameHashed =  hashbytes('MD5',left(CONVERT([varchar](max),[PathName],(0)),(8000)))
	when not matched then insert(SPT_Name)
							values(PathName);
	
Merge Inventory.ServiceStartModes d
	using (select distinct StartMode
			from inserted
			where StartMode is not null) s
		on StartMode = SSM_Name
	when not matched then insert(SSM_Name)
							values(StartMode);

Merge Inventory.ServiceStates d
	using (select distinct [State]
			from inserted
			where [State] is not null) s
		on [State] = SST_Name
	when not matched then insert(SST_Name)
							values([State]);
	
Merge Inventory.ServiceStatuses d
	using (select distinct [Status]
			from inserted
			where [Status] is not null) s
		on [Status] = STT_Name
	when not matched then insert(STT_Name)
							values([Status]);
	
Merge Inventory.ServiceTypes d
	using (select distinct ServiceType
			from inserted
			where ServiceType is not null) s
		on ServiceType = STP_Name
	when not matched then insert(STP_Name)
							values(ServiceType);

merge Inventory.OperatingSystemServices d
	using (select Metadata_ClientID, TRH_MOB_ID, SNM_ID, SDN_ID, SCD_ID, SPT_ID, STP_ID, SSM_ID, SST_ID, STT_ID, SLN_ID,
									TRH_StartDate, TRH_ID
				from inserted
					inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID
					left join Inventory.ServiceDescriptions on hashbytes('MD5',left(CONVERT(varchar(max),[Description],0),(8000))) = SCD_HashedDescription
																and [Description] = SCD_Description
					inner join Inventory.ServiceDisplayNames on hashbytes('MD5',left(CONVERT([nvarchar](max),Caption,(0)),(8000))) = SDN_NameHashed
					left join Inventory.ServiceLoginNames on SLN_Name = StartName
					inner join Inventory.ServiceNames on SNM_NameHashed = hashbytes('MD5',left(CONVERT([nvarchar](max),[Name],(0)),(8000)))
					left join Inventory.ServicePaths on SPT_NameHashed = hashbytes('MD5',left(CONVERT([varchar](max),[PathName],(0)),(8000)))
					inner join Inventory.ServiceStartModes on SSM_Name = StartMode
					inner join Inventory.ServiceStates on SST_Name = [State]
					inner join Inventory.ServiceStatuses on STT_Name = [Status]
					inner join Inventory.ServiceTypes on STP_Name = ServiceType) s
		on OSR_MOB_ID = TRH_MOB_ID
			and OSR_SNM_ID = SNM_ID
	when matched then update set
						OSR_SDN_ID = SDN_ID,
						OSR_SCD_ID = SCD_ID,
						OSR_SPT_ID = SPT_ID,
						OSR_STP_ID = STP_ID,
						OSR_SSM_ID = SSM_ID,
						OSR_SST_ID = SST_ID,
						OSR_STT_ID = STT_ID,
						OSR_SLN_ID = SLN_ID,
						OSR_LastSeenDate = TRH_StartDate,
						OSR_Last_TRH_ID = TRH_ID
	when not matched then insert(OSR_ClientID, OSR_MOB_ID, OSR_SNM_ID, OSR_SDN_ID, OSR_SCD_ID, OSR_SPT_ID, OSR_STP_ID, OSR_SSM_ID, OSR_SST_ID,
									OSR_STT_ID, OSR_SLN_ID, OSR_InsertDate, OSR_LastSeenDate, OSR_Last_TRH_ID)
							values(Metadata_ClientID, TRH_MOB_ID, SNM_ID, SDN_ID, SCD_ID, SPT_ID, STP_ID, SSM_ID, SST_ID, STT_ID, SLN_ID,
									TRH_StartDate, TRH_StartDate, TRH_ID);
GO
