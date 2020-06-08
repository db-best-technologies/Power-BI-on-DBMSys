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
/****** Object:  StoredProcedure [Reports].[usp_FinancialAnalysisCloudRemainingOnPremisesTable]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_FinancialAnalysisCloudRemainingOnPremisesTable]
	@HST_ID int
as
set nocount on

declare @StandardCorePrice int,
		@EnterpriseCorePrice int,
		@OnPremServerYearlyOperationalCostUSD int,
		@SQLStandardEditionCoreLicensesOwned int,
		@SQLEnterpriseEditionCoreLicensesOwned int,
		@SQLStandardEditionCoreLicensesOwnedWithSA int,
		@SQLEnterpriseEditionCoreLicensesOwnedWithSA int

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

select @SQLStandardEditionCoreLicensesOwnedWithSA = CAST(SET_Value AS INT)
FROM	Management.Settings
WHERE	SET_Key ='SQLStandardEditionCoreLicensesOwnedWithSA'

select @SQLEnterpriseEditionCoreLicensesOwnedWithSA = CAST(SET_Value AS INT)
FROM	Management.Settings
WHERE	SET_Key ='SQLEnterpriseEditionCoreLicensesOwnedWithSA'

select isnull(replace(replace(SQLEdition, '[', ''), ']', ''), '[Total]') [SQL edition],
	iif(PricePerCore > 0, format(sum(CoreCount), '##,##0'), '') [Licensed cores],
	iif(PricePerCore > 0, format(sum(LicensesOwned - CloudUsedLicenses), '##,##0'), '') [Licenses owned],
	iif(PricePerCore > 0, format(sum(CoreCount - (LicensesOwned - CloudUsedLicenses)), '##,##0'), '') [Licenses to be purchased],
	iif(SQLEdition <> '[No/Free SQL]' or SQLEdition is null, format(sum(LicensingPriceFor3YearsUSD), 'C'), '') [Licenses to be purchased price],
	format(sum(OperationalCostFor3YearsUSD), 'C') [HW/Operational cost]
from Reports.fn_GetCostForRemainingServersForCloudServers(@HST_ID, null, @StandardCorePrice, @EnterpriseCorePrice, @OnPremServerYearlyOperationalCostUSD,
															@SQLStandardEditionCoreLicensesOwned, @SQLEnterpriseEditionCoreLicensesOwned,
															@SQLStandardEditionCoreLicensesOwnedWithSA, @SQLEnterpriseEditionCoreLicensesOwnedWithSA)
group by SQLEdition, PricePerCore with rollup
having grouping(SQLEdition) = grouping(PricePerCore)
order by PricePerCore desc
GO
