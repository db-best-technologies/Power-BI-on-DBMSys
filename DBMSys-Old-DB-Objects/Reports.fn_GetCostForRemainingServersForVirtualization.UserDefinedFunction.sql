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
/****** Object:  UserDefinedFunction [Reports].[fn_GetCostForRemainingServersForVirtualization]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Reports].[fn_GetCostForRemainingServersForVirtualization](@SQLEdition varchar(100),
																@StandardCorePrice int,
																@EnterpriseCorePrice int,
																@OnPremServerYearlyOperationalCostUSD int,
																@StandardEditionCoreLicensesOwned int,
																@EnterpriseEditionCoreLicensesOwned int) returns table
as
	return (with Agg as
					(select isnull(SQLEdition, '[No/Free SQL]') SQLEdition,
							count(*) ServerCount,
							cast(sum(OPR_OriginalLicensingCoreCount) as int) CoreCount,
							PricePerCore,
							LicensesOwned,
							VirtualizationUsedLicenses
						from Consolidation.LoadBlocks
							inner join Consolidation.VW_OnPrem on OPR_Original_MOB_ID = LBL_MOB_ID
							cross join(select StandardCores - (StandardCores - StandardLicensesOwned) VirtualizationUsedStandardLicenses,
											EnterpriseCores - (EnterpriseCores - EnterpriseLicensesOwned) VirtualizationUsedEnterpriseLicenses
										from Reports.fn_GetCostForVirtualization(@StandardCorePrice, @EnterpriseCorePrice, @OnPremServerYearlyOperationalCostUSD,
																					@StandardEditionCoreLicensesOwned, @EnterpriseEditionCoreLicensesOwned) c

										) l
							outer apply (select *
											from (select cast('Standard' as varchar(100)) SQLEdition,
														@StandardCorePrice PricePerCore,
														@StandardEditionCoreLicensesOwned LicensesOwned,
														VirtualizationUsedStandardLicenses VirtualizationUsedLicenses
													union all
													select 'Enterprise' SQLEdition,
														@EnterpriseCorePrice PricePerCore,
														@EnterpriseEditionCoreLicensesOwned LicensesOwned,
														VirtualizationUsedEnterpriseLicenses VirtualizationUsedLicenses) e
											where SQLEdition = OPR_Edition) e
						where not exists (select *
											from Consolidation.ConsolidationBlocks_LoadBlocks
												inner join Consolidation.ConsolidationBlocks on CLB_ID = CBL_CLB_ID
											where CLB_HST_ID = 4
												and CLB_DLR_ID is null
												and CBL_DLR_ID is null
												and CBL_LBL_ID = LBL_ID)
							and exists (select *
											from Consolidation.ConsolidationBlocks_LoadBlocks
												inner join Consolidation.ConsolidationBlocks on CLB_ID = CBL_CLB_ID
											where CLB_HST_ID = 4
												and CLB_DLR_ID is null
												and CBL_DLR_ID is null)
						group by SQLEdition, PricePerCore, LicensesOwned, VirtualizationUsedLicenses
						)
			select SQLEdition,
				ServerCount,
				iif(PricePerCore > 0, CoreCount, 0) CoreCount,
				ServerCount*@OnPremServerYearlyOperationalCostUSD*3 OperationalCostFor3YearsUSD,
				isnull((CoreCount - (LicensesOwned - VirtualizationUsedLicenses))*PricePerCore, 0) LicensingPriceFor3YearsUSD,
				isnull(PricePerCore, 0) PricePerCore,
				isnull(LicensesOwned, 0) LicensesOwned,
				isnull(VirtualizationUsedLicenses, 0) VirtualizationUsedLicenses
			from Agg
			where SQLEdition = @SQLEdition
				or @SQLEdition is null
			)
GO
