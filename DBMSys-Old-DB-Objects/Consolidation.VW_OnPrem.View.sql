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
/****** Object:  View [Consolidation].[VW_OnPrem]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Consolidation].[VW_OnPrem]
as
with MSCoreCountFactor as
		(select CoreCount, CPUNamePattern, CPUNamePatternMinCoreCount, Factor
			from (values(1, null, null, 4),
						(2, null, null, 2),
						(null, '%AMD% 31__%', 6, .75),
						(null, '%AMD% 32__%', 6, .75),
						(null, '%AMD% 33__%', 6, .75),
						(null, '%AMD% 41__%', 6, .75),
						(null, '%AMD% 42__%', 6, .75),
						(null, '%AMD% 43__%', 6, .75),
						(null, '%AMD% 61__%', 6, .75),
						(null, '%AMD% 62__%', 6, .75),
						(null, '%AMD% 63__%', 6, .75)) t(CoreCount, CPUNamePattern, CPUNamePatternMinCoreCount, Factor)
		)
	, CPUs as
		(select PRS_MOB_ID, max(PSN_Name) PSN_Name, sum(isnull(PRS_NumberOfCores, 1)) MachineCoreCount
			from Inventory.Processors
				inner join Inventory.ProcessorNames on PSN_ID = PRS_PSN_ID
			where exists (select * from Consolidation.ParticipatingDatabaseServers where PRS_MOB_ID = PDS_Server_MOB_ID)
			group by PRS_MOB_ID
		)
	, CoreInfo as
		(select PRS_MOB_ID, MachineCoreCount, MachineCoreCount*coalesce(Factor, 1) LicensingCores
			from CPUs
				outer apply (select Factor Factor
								from MSCoreCountFactor
								where MachineCoreCount = CoreCount
									or (PSN_Name like CPUNamePattern collate database_default
										and MachineCoreCount >= CPUNamePatternMinCoreCount)
							) f
		)
	, Combinations as -- ConsolidationCombinations
		(select LBL_CGR_ID, PSH_MOB_ID, LBL_MOB_ID, LBL_ID SourceMachineID, PSH_PricePerMonthUSD Price,
				CLB_OST_ID, CLB_CHA_ID, CLB_ID, CLB_CHE_ID
			from Consolidation.ConsolidationBlocks
				inner join Consolidation.ConsolidationBlocks_LoadBlocks on CBL_CLB_ID = CLB_ID
				inner join Consolidation.PossibleHosts on PSH_ID = CLB_PSH_ID
				inner join Consolidation.LoadBlocks on LBL_ID = CBL_LBL_ID
				inner join Consolidation.HostTypes on HST_ID = PSH_HST_ID
			where CLB_DLR_ID is null
				and CBL_DLR_ID is null
				and HST_NumberOfInstancesPerHost = 1
		)
	, OnPrem as
		(select LBL_CGR_ID OPR_CGR_ID, PSH_MOB_ID OPR_New_MOB_ID, LBL_MOB_ID OPR_Original_MOB_ID, Price OPR_PRICE, CLB_OST_ID OPR_OST_ID, CLB_CHA_ID OPR_CHA_ID, 0 OPR_RedFlagged, CHE_Name OPR_Edition
			from Combinations
				left join Consolidation.CloudHostedApplicationEditions on CHE_ID = CLB_CHE_ID
			union all
			select LBL_CGR_ID OPR_CGR_ID, PSH_MOB_ID ORP_New_MOB_ID, LBL_MOB_ID ORP_Original_MOB_ID, PSH_PricePerMonthUSD ORP_Price, LBL_OST_ID OPR_OST_ID, LBL_CHA_ID OPR_CHA_ID, 1 OPR_RedFlagged, CHE_Name OPR_Edition
			from Consolidation.LoadBlocks
				inner join Consolidation.PossibleHosts on PSH_MOB_ID = LBL_MOB_ID
				inner join Inventory.MonitoredObjects on MOB_ID = PSH_MOB_ID
				left join Consolidation.CloudHostedApplicationEditions on CHE_ID = LBL_CHE_ID
			where not exists (select *
								from Combinations
								where LBL_ID = SourceMachineID)
				and exists (select *
								from Consolidation.ServerPossibleHostTypes
								where SHT_MOB_ID = LBL_MOB_ID
									and SHT_HST_ID in (1, 2))
			union all
			select LBL_CGR_ID, LBL_MOB_ID, LBL_MOB_ID, null, LBL_OST_ID, LBL_CHA_ID, 1 RedFlagged, CHE_Name Edition
			from Consolidation.LoadBlocks
				left join Consolidation.CloudHostedApplicationEditions on CHE_ID = LBL_CHE_ID
			where not exists (select *
								from Combinations
								where LBL_ID = SourceMachineID)
				and not exists (select *
								from Consolidation.ServerPossibleHostTypes
								where SHT_MOB_ID = LBL_MOB_ID
									and SHT_HST_ID in (1, 2))
		)
select p.*, o.MachineCoreCount OPR_OriginalCoreCount, o.LicensingCores OPR_OriginalLicensingCoreCount,
	n.MachineCoreCount OPR_NewCoreCount, n.LicensingCores OPR_NewLicensingCoreCount
from OnPrem p
	inner join CoreInfo o on o.PRS_MOB_ID = OPR_Original_MOB_ID
	inner join CoreInfo n on n.PRS_MOB_ID = OPR_Original_MOB_ID
GO
