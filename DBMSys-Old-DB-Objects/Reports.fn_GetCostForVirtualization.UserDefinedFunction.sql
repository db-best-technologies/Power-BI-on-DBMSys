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
/****** Object:  UserDefinedFunction [Reports].[fn_GetCostForVirtualization]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [Reports].[fn_GetCostForVirtualization](@StandardCorePrice int,
														@EnterpriseCorePrice int,
														@OnPremServerYearlyOperationalCostUSD int,
														@StandardEditionCoreLicensesOwned int,
														@EnterpriseEditionCoreLicensesOwned int) returns table
as
return (with CoreCalc as
					(select sum(iif(LBL_CHA_ID = 1 and CHE_Name = 'Standard', iif(CBL_VirtualCoreCount < 4, 4, CBL_VirtualCoreCount), 0)) StandardVirtualCores,
							sum(iif(LBL_CHA_ID = 1 and CHE_Name = 'Enterprise', iif(CBL_VirtualCoreCount < 4, 4, CBL_VirtualCoreCount), 0)) EnterpriseVirtualCores,
							PhysicalCores,
							count(*) VMs
						from Consolidation.ConsolidationBlocks_LoadBlocks
							inner join Consolidation.LoadBlocks on LBL_ID = CBL_LBL_ID
							left join Consolidation.CloudHostedApplicationEditions on CHE_ID = LBL_CHE_ID
							cross apply (select top 1 CPF_CPUCount/CPUStretchRatio PhysicalCores
											from Consolidation.CPUFactoring
													cross join (select cast(SET_Value as int) CPUStretchRatio
																	from Management.Settings
																	where SET_Module = 'Consolidation'
																		and SET_Key = 'Virtualization - CPU Core Stretch Ratio') s
											where CPF_VES_ID is not null) c
						where CBL_HST_ID = 4
						group by CBL_CLB_ID, PhysicalCores
					)
				, AddingPriceFactor as
					(select *, iif(StandardVirtualCores*@StandardCorePrice + EnterpriseVirtualCores*@EnterpriseCorePrice > PhysicalCores*@EnterpriseCorePrice, 1, 0) IsHost
						from CoreCalc
					)
				, EditionCores as
					(select count(*) Hosts,
							sum(VMs) VMs,
							sum(iif(IsHost = 0, StandardVirtualCores, 0)) StandardCores,
							sum(iif(IsHost = 0, EnterpriseVirtualCores, PhysicalCores)) EnterpriseCores
						from AddingPriceFactor
					)
			select Hosts,
				VMs,
				StandardCores,
				@StandardEditionCoreLicensesOwned StandardLicensesOwned,
				EnterpriseCores,
				@EnterpriseEditionCoreLicensesOwned EnterpriseLicensesOwned,
				(StandardCores-@StandardEditionCoreLicensesOwned)*@StandardCorePrice StandardLicensingPriceFor3YearsUSD,
				(EnterpriseCores-@EnterpriseEditionCoreLicensesOwned)*@EnterpriseCorePrice EnterpriseLicensingPriceFor3YearsUSD,
				Hosts*@OnPremServerYearlyOperationalCostUSD*3 OperationalCostFor3YearsUSD
			from EditionCores
			where Hosts > 0
		)
GO
