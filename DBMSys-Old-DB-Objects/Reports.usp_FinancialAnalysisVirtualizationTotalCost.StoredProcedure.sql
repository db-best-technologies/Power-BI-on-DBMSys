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
/****** Object:  StoredProcedure [Reports].[usp_FinancialAnalysisVirtualizationTotalCost]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_FinancialAnalysisVirtualizationTotalCost]
as
set nocount on

declare @StandardCorePrice int,
		@EnterpriseCorePrice int,
		@OnPremServerYearlyOperationalCostUSD int,
		@SQLStandardEditionCoreLicensesOwned int,
		@SQLEnterpriseEditionCoreLicensesOwned int

select @StandardCorePrice = CAST(SET_Value AS INT)
FROM	Management.Settings
WHERE	SET_Key ='SQLStandardEditionCoreLicensePriceUSD'

select @EnterpriseCorePrice = CAST(SET_Value AS INT)
FROM	Management.Settings
WHERE	SET_Key ='SQLEnterpriseEditionCoreLicensePriceUSD'

select @OnPremServerYearlyOperationalCostUSD = CAST(SET_Value AS INT)
FROM	Management.Settings
WHERE	SET_Key ='OnPremServerYearlyOperationalCostUSD'

select @SQLStandardEditionCoreLicensesOwned = CAST(SET_Value AS INT)
FROM	Management.Settings
WHERE	SET_Key ='SQLStandardEditionCoreLicensesOwned'

select @SQLEnterpriseEditionCoreLicensesOwned = CAST(SET_Value AS INT)
FROM	Management.Settings
WHERE	SET_Key ='SQLEnterpriseEditionCoreLicensesOwned'

select format(v.OperationalCostFor3YearsUSD + StandardLicensingPriceFor3YearsUSD + EnterpriseLicensingPriceFor3YearsUSD
				+ isnull(sum(LicensingPriceFor3YearsUSD), 0) + isnull(sum(r.OperationalCostFor3YearsUSD), 0), 'C') Value
from Reports.fn_GetCostForVirtualization(@StandardCorePrice, @EnterpriseCorePrice, @OnPremServerYearlyOperationalCostUSD, @SQLStandardEditionCoreLicensesOwned, @SQLEnterpriseEditionCoreLicensesOwned) v
	outer apply Reports.fn_GetCostForRemainingServersForVirtualization(null, @StandardCorePrice, @EnterpriseCorePrice, @OnPremServerYearlyOperationalCostUSD,
															@SQLStandardEditionCoreLicensesOwned, @SQLEnterpriseEditionCoreLicensesOwned) r
group by v.OperationalCostFor3YearsUSD, StandardLicensingPriceFor3YearsUSD, EnterpriseLicensingPriceFor3YearsUSD
GO
