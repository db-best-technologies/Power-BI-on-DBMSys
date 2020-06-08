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
/****** Object:  UserDefinedFunction [Reports].[fn_GetCostForRemainingServersForCloudServers]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Reports].[fn_GetCostForRemainingServersForCloudServers](@HST_ID int,
																@SQLEdition varchar(100),
																@StandardCorePrice int,
																@EnterpriseCorePrice int,
																@OnPremServerYearlyOperationalCostUSD int,
																@StandardEditionCoreLicensesOwned int,
																@EnterpriseEditionCoreLicensesOwned int,
																@StandardEditionCoreLicensesOwnedWithSA int,
																@EnterpriseEditionCoreLicensesOwnedWithSA int) returns table
as
	return (with Agg as
					(select isnull(SQLEdition, '[No/Free SQL]') SQLEdition,
							count(*) ServerCount,
							cast(sum(OPR_OriginalLicensingCoreCount) as int) CoreCount,
							PricePerCore,
							LicensesOwned,
							CloudUsedLicenses
						from Consolidation.LoadBlocks
							inner join Consolidation.VW_OnPrem on OPR_Original_MOB_ID = LBL_MOB_ID
							left join (select cast('Standard' as varchar(100)) SQLEdition,
											@StandardCorePrice PricePerCore,
											@StandardEditionCoreLicensesOwned LicensesOwned,
											@StandardEditionCoreLicensesOwnedWithSA SALicensesOwned
										union all
										select 'Enterprise' SQLEdition,
											@EnterpriseCorePrice PricePerCore,
											@EnterpriseEditionCoreLicensesOwned LicensesOwned,
											@EnterpriseEditionCoreLicensesOwnedWithSA SALicensesOwned) e on SQLEdition = OPR_Edition
							outer apply (select CoreCount - (CoreCount - SALicensesOwned) CloudUsedLicenses
								from Reports.fn_GetCostForCloudServers(@StandardCorePrice, @EnterpriseCorePrice, @StandardEditionCoreLicensesOwnedWithSA, @EnterpriseEditionCoreLicensesOwnedWithSA) c
								where HST_ID = @HST_ID
									and c.SQLEdition = e.SQLEdition
							) l
						where not exists (select *
											from Consolidation.ConsolidationBlocks_LoadBlocks
												inner join Consolidation.ConsolidationBlocks on CLB_ID = CBL_CLB_ID
											where CLB_HST_ID = @HST_ID
												and CLB_DLR_ID is null
												and CBL_DLR_ID is null
												and CBL_LBL_ID = LBL_ID)
							and exists (select *
											from Consolidation.ConsolidationBlocks_LoadBlocks
												inner join Consolidation.ConsolidationBlocks on CLB_ID = CBL_CLB_ID
											where CLB_HST_ID = @HST_ID
												and CLB_DLR_ID is null
												and CBL_DLR_ID is null)
						group by SQLEdition, PricePerCore, LicensesOwned, CloudUsedLicenses
						)
			select SQLEdition,
				ServerCount,
				iif(PricePerCore > 0, CoreCount, 0) CoreCount,
				ServerCount*@OnPremServerYearlyOperationalCostUSD*3 OperationalCostFor3YearsUSD,
				isnull((CoreCount - (ISNULL(LicensesOwned,0) - ISNULL(CloudUsedLicenses,0)))*PricePerCore, 0) LicensingPriceFor3YearsUSD,
				isnull(PricePerCore, 0) PricePerCore,
				isnull(LicensesOwned, 0) LicensesOwned,
				isnull(CloudUsedLicenses, 0) CloudUsedLicenses
			from Agg
			where SQLEdition = @SQLEdition
				or @SQLEdition is null
			)
GO
