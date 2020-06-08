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
/****** Object:  View [Tests].[VW_TST_SolarisProcessors]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_SolarisProcessors]
as
select top 0 CAST(null as varchar(200)) Column1, -- cpu{Logical Cores}: {Processor Name}
			CAST(null as int) Column2, -- Physical Cores
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SolarisProcessors]    Script Date: 6/8/2020 1:16:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_SolarisProcessors] on [Tests].[VW_TST_SolarisProcessors]
	instead of insert
as
set nocount on

merge Inventory.ProcessorNames d
	using (select ltrim(rtrim(substring(Column1, charindex(':', Column1, 1) + 1, 1000))) Name
			from inserted
		) s
	on PSN_Name = Name
	when not matched then insert(PSN_Name)
						values(Name);

merge Inventory.Processors d
	using (select Metadata_ClientID, TRH_MOB_ID, concat('CPU', Num) DeviceID, PSN_ID,
				(cast(ltrim(replace(left(Column1, charindex(':', Column1, 1) - 1), 'cpu', '')) as int) + 1)/Column2 NumberOfCores, TRH_ID
			from inserted
				inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID
				inner join Inventory.ProcessorNames on PSN_Name = ltrim(rtrim(substring(Column1, charindex(':', Column1, 1) + 1, 1000)))
				inner join Infra.Numbers on Num <= Column2
		) s
	on TRH_MOB_ID = PRS_MOB_ID
		and DeviceID = PRS_DeviceID
	when matched then update
					set PRS_PSN_ID = PSN_ID,
						PRS_NumberOfCores = NumberOfCores,
						PRS_InsertDate = getdate(),
						PRS_LastSeenDate = getdate(),
						PRS_Last_TRH_ID = TRH_ID
	when not matched then insert(PRS_ClientID, PRS_MOB_ID, PRS_DeviceID, PRS_PSN_ID, PRS_NumberOfCores, PRS_InsertDate, PRS_LastSeenDate, PRS_Last_TRH_ID)
						values(Metadata_ClientID, TRH_MOB_ID, DeviceID, PSN_ID, NumberOfCores, getdate(), getdate(), TRH_ID);
GO
