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
/****** Object:  View [Tests].[VW_TST_Processors]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_Processors]
as
select top 0 cast(null as tinyint) Architecture,
			cast(null as tinyint) Availability,
			cast(null as nvarchar(250)) Caption,
			cast(null as tinyint) CpuStatus,
			cast(null as int) CurrentClockSpeed,
			cast(null as int) CurrentVoltage,
			cast(null as tinyint) DataWidth,
			cast(null as varchar(20)) DeviceID,
			cast(null as int) L2CacheSize,
			cast(null as int) L3CacheSize,
			cast(null as nvarchar(250)) Manufacturer,
			cast(null as int) MaxClockSpeed,
			cast(null as nvarchar(250)) Name,
			cast(null as int) NumberOfCores,
			cast(null as int) NumberOfLogicalProcessors,
			cast(null as varchar(100)) [Status],
			cast(null as int) Metadata_TRH_ID,
			cast(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_Processors]    Script Date: 6/8/2020 1:16:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_Processors] on [Tests].[VW_TST_Processors]
	instead of insert
as
merge Inventory.ProcessorCaptions d
	using (select distinct Caption
			from inserted
			where Caption is not null) s
	on Caption = PCA_Caption
	when not matched then insert(PCA_Caption)
							values(Caption);

merge Inventory.ProcessorManufacturers d
	using (select distinct Manufacturer
			from inserted
			where Manufacturer is not null) s
	on Manufacturer = PMN_Name
	when not matched then insert(PMN_Name)
							values(Manufacturer);

merge Inventory.ProcessorNames d
	using (select distinct Name
			from inserted
			where Name is not null) s
	on Name = PSN_Name
	when not matched then insert(PSN_Name)
							values(Name);

merge Inventory.ProcessorOperationalStatuses d
	using (select distinct [Status]
			from inserted
			where [Status] is not null) s
	on [Status] = POS_Name
	when not matched then insert(POS_Name)
							values([Status]);

merge Inventory.Processors d
	using (select Metadata_ClientID, TRH_MOB_ID, Architecture, Availability, PCA_ID, CpuStatus, CurrentClockSpeed,
				CurrentVoltage, DataWidth, DeviceID, L2CacheSize, L3CacheSize, PMN_ID, MaxClockSpeed, PSN_ID, NumberOfCores, NumberOfLogicalProcessors,
				POS_ID, TRH_ID, TRH_StartDate
			from inserted
				inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID
				left join Inventory.ProcessorCaptions on PCA_Caption = Caption
				left join Inventory.ProcessorManufacturers on PMN_Name = Manufacturer
				left join Inventory.ProcessorNames on PSN_Name = Name
				left join Inventory.ProcessorOperationalStatuses on POS_Name = [Status]
			) s
		on TRH_MOB_ID = PRS_MOB_ID
			and DeviceID = PRS_DeviceID
	when matched then update set
							PRS_PAC_ID = Architecture,
							PRS_PAV_ID = Availability,
							PRS_PCA_ID = PCA_ID,
							PRS_PCS_ID = CpuStatus,
							PRS_CurrentClockSpeed = CurrentClockSpeed,
							PRS_CurrentVoltage = CurrentVoltage,
							PRS_DataWidth = DataWidth,
							PRS_L2CacheSize = L2CacheSize,
							PRS_L3CacheSize = L3CacheSize,
							PRS_PMN_ID = PMN_ID,
							PRS_MaxClockSpeed = MaxClockSpeed,
							PRS_PSN_ID = PSN_ID,
							PRS_NumberOfCores = NumberOfCores,
							PRS_NumberOfLogicalProcessors = NumberOfLogicalProcessors,
							PRS_POS_ID = POS_ID,
							PRS_LastSeenDate = TRH_StartDate,
							PRS_Last_TRH_ID = TRH_ID
	when not matched then insert(PRS_ClientID, PRS_MOB_ID, PRS_PAC_ID, PRS_PAV_ID, PRS_PCA_ID, PRS_PCS_ID, PRS_CurrentClockSpeed, PRS_CurrentVoltage,
									PRS_DataWidth, PRS_DeviceID, PRS_L2CacheSize, PRS_L3CacheSize, PRS_PMN_ID, PRS_MaxClockSpeed, PRS_PSN_ID, PRS_NumberOfCores,
									PRS_NumberOfLogicalProcessors, PRS_POS_ID, PRS_InsertDate, PRS_LastSeenDate, PRS_Last_TRH_ID)
						values(Metadata_ClientID, TRH_MOB_ID, Architecture, Availability, PCA_ID, CpuStatus, CurrentClockSpeed, CurrentVoltage,
									DataWidth, DeviceID, L2CacheSize, L3CacheSize, PMN_ID, MaxClockSpeed, PSN_ID, NumberOfCores,
									NumberOfLogicalProcessors, POS_ID, TRH_StartDate, TRH_StartDate, TRH_ID);
GO
