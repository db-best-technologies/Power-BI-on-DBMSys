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
/****** Object:  View [Tests].[VW_TST_InstanceConfigurations]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_InstanceConfigurations]
as
select top 0 CAST(null as nvarchar(255)) name,
			CAST(null as sql_variant) run_value,
			CAST(null as bit) is_advanced,
			CAST(null as sql_variant) config_value,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_InstanceConfigurations]    Script Date: 6/8/2020 1:16:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_InstanceConfigurations] on [Tests].[VW_TST_InstanceConfigurations]
	instead of insert
as
set nocount on

merge Inventory.InstanceConfigurationTypes d
	using (select distinct name, is_advanced
			from inserted) s
		on name = ICT_Name
	when matched and is_advanced <> ICT_IsAdvanced then update set
													ICT_IsAdvanced = is_advanced
	when not matched then insert(ICT_Name, ICT_IsAdvanced)
							values(name, is_advanced);

merge Inventory.InstanceConfigurations d
	using (select Metadata_ClientID, TRH_MOB_ID MOB_ID, ICT_ID, run_value, config_value
			from inserted
				inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID
				inner join Inventory.InstanceConfigurationTypes on name = ICT_Name) s
		on MOB_ID = ICF_MOB_ID
			and ICT_ID = ICF_ICT_ID
	when matched and ICF_Value <> run_value
						or ICF_ConfiguredValue <> config_value
						or ICF_Value is null and run_value is not null
						or ICF_ConfiguredValue is null and config_value is not null
							then update set
										ICF_Value = run_value,
										ICF_ConfiguredValue = config_value
	when not matched then insert(ICF_ClientID, ICF_MOB_ID, ICF_ICT_ID, ICF_Value, ICF_ConfiguredValue)
							values(Metadata_ClientID, MOB_ID, ICT_ID, run_value, config_value);
GO
