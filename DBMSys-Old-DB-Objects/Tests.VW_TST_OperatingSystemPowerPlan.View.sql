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
/****** Object:  View [Tests].[VW_TST_OperatingSystemPowerPlan]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_OperatingSystemPowerPlan]
as
select top 0 CAST(null as varchar(300)) ElementName,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_OperatingSystemPowerPlan]    Script Date: 6/8/2020 1:16:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_OperatingSystemPowerPlan] on [Tests].[VW_TST_OperatingSystemPowerPlan]
	instead of insert
as
set nocount on

Merge Inventory.PowerPlanTypes d
	using (select distinct ElementName
			from inserted) s
		on ElementName = PPT_Name
	when not matched then insert(PPT_Name)
							values(ElementName);

;with NewValues as
	(select MOB_ID, PPT_ID
		from inserted
			inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID
			inner join Inventory.MonitoredObjects on TRH_MOB_ID = MOB_ID
			inner join Inventory.PowerPlanTypes on ElementName = PPT_Name)
update Inventory.OSServers
set OSS_PPT_ID = PPT_ID
from NewValues
where OSS_MOB_ID = MOB_ID
	and (OSS_PPT_ID is null
			or OSS_PPT_ID <> PPT_ID)
GO
