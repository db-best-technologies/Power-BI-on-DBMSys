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
/****** Object:  View [Tests].[VW_TST_SolarisBase]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_SolarisBase]
as
select top 0 CAST(null as nvarchar(128)) Column1, --Server name
			CAST(null as decimal(15, 5)) Column4, --Version
			CAST(null as varchar(100)) Column5,	--Platform
			CAST(null as varchar(200)) Column6,	--Machine model
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SolarisBase]    Script Date: 6/8/2020 1:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_SolarisBase] on [Tests].[VW_TST_SolarisBase]
	instead of insert
as
set nocount on

declare @MOB_ID int

select @MOB_ID = TRH_MOB_ID
from Collect.TestRunHistory
	inner join inserted on Metadata_TRH_ID = TRH_ID
	
merge Inventory.Versions d
	using (select MOB_PLT_ID, cast(Column4 as varchar(100)) VerName, Column4 VerNumber
			from inserted
				inner join Inventory.MonitoredObjects on MOB_ID = @MOB_ID
		) s
	on MOB_PLT_ID = VER_PLT_ID
		and VerNumber = VER_Number
	when not matched then insert(VER_PLT_ID, VER_Name, VER_Full, VER_Number)
						values(MOB_PLT_ID, VerName, VerName, VerNumber);

merge Inventory.Editions d
	using (select MOB_PLT_ID, Column5 Edition
			from inserted
				inner join Inventory.MonitoredObjects on MOB_ID = @MOB_ID
		) s
	on MOB_PLT_ID = EDT_PLT_ID
		and Edition = EDT_Name
	when not matched then insert(EDT_PLT_ID, EDT_Name)
						values(MOB_PLT_ID, Edition);

merge Inventory.MachineManufacturerModels d
	using (select ltrim(rtrim(replace(Column6, '^', ' '))) MachineModel
			from inserted
		) s
	on MachineModel = MMD_Name
	when not matched then insert(MMD_Name)
						values(MachineModel);

update Inventory.MonitoredObjects
set MOB_VER_ID = VER_ID,
	MOB_Engine_EDT_ID = EDT_ID
from inserted
	inner join Inventory.Versions on VER_Number = Column4
	inner join Inventory.Editions on EDT_Name = Column5
where MOB_ID = @MOB_ID
	and MOB_PLT_ID = VER_PLT_ID
	and MOB_PLT_ID = EDT_PLT_ID

merge Inventory.OSServers d
using (select Metadata_ClientID, MOB_PLT_ID, Column1, case Column5 when 'X86' then 32 else 64 end Architecture, MMD_ID
		from inserted
			inner join Inventory.MonitoredObjects on MOB_ID = @MOB_ID
			inner join Inventory.MachineManufacturerModels on MMD_Name = ltrim(rtrim(replace(Column6, '^', ' ')))
		) s
		on OSS_MOB_ID = @MOB_ID
	when matched then update set
						OSS_Architecture = Architecture,
						OSS_MMD_ID = MMD_ID
	when not matched then insert(OSS_ClientID, OSS_PLT_ID, OSS_Name, OSS_IsVirtualServer, OSS_Architecture, OSS_MOB_ID, OSS_MMD_ID)
						values(Metadata_ClientID, MOB_PLT_ID, Column1, 0, Architecture, @MOB_ID, MMD_ID);
GO
