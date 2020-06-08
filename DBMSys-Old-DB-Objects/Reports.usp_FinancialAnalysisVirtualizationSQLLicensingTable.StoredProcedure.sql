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
/****** Object:  StoredProcedure [Reports].[usp_FinancialAnalysisVirtualizationSQLLicensingTable]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_FinancialAnalysisVirtualizationSQLLicensingTable]
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

select isnull(SQLEdition, '[Total]') [SQL edition],
	iif(SQLEdition is not null, format(sum(CoreCount), '##,##0'), '') [Licensed cores],
	iif(SQLEdition is not null, format(sum(LicensesOwned), '##,##0'), '') [Licenses owned],
	iif(SQLEdition is not null, format(sum(CoreCount - LicensesOwned), '##,##0'), '') [Licenses to be purchased],
	format(sum(LicensingPriceFor3YearsUSD), 'C') [Licenses to be purchased price]
from Reports.fn_GetCostForVirtualization(@StandardCorePrice, @EnterpriseCorePrice, @OnPremServerYearlyOperationalCostUSD, @SQLStandardEditionCoreLicensesOwned, @SQLEnterpriseEditionCoreLicensesOwned) v
	cross apply (select 'Standard' SQLEdition,
						StandardCores CoreCount,
						StandardLicensesOwned LicensesOwned,
						StandardLicensingPriceFor3YearsUSD LicensingPriceFor3YearsUSD
					union all
					select 'Enterprise' SQLEdition,
						EnterpriseCores CoreCount,
						EnterpriseLicensesOwned LicensesOwned,
						EnterpriseLicensingPriceFor3YearsUSD LicensingPriceFor3YearsUSD
					) e
group by SQLEdition with rollup
order by isnull(SQLEdition, 'z')
GO
