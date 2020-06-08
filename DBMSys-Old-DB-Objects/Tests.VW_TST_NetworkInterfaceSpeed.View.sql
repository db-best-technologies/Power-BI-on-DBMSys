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
/****** Object:  View [Tests].[VW_TST_NetworkInterfaceSpeed]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_NetworkInterfaceSpeed]
as
select top 0 CAST(null as bit) Active,
			CAST(null as varchar(200)) InstanceName,
			CAST(null as bigint) NdisLinkSpeed,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_VW_TST_NetworkInterfaceSpeed]    Script Date: 6/8/2020 1:16:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_VW_TST_NetworkInterfaceSpeed] on [Tests].[VW_TST_NetworkInterfaceSpeed]
	instead of insert
as
set nocount on

;with NewRecords as
		(select TRH_MOB_ID, NIT_ID, Active, NdisLinkSpeed
			from inserted
				inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID
				inner join Inventory.NetworkInterfaceTypes on NIT_Name = InstanceName
		)
update Inventory.NetworkInterfaces
set NIN_IsActive = Active,
	NIN_LinkSpeed = NdisLinkSpeed
from NewRecords
where NIN_MOB_ID = TRH_MOB_ID
	and NIN_NIT_ID = NIT_ID
GO
