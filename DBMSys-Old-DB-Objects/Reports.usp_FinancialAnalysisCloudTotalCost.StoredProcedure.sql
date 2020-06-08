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
/****** Object:  StoredProcedure [Reports].[usp_FinancialAnalysisCloudTotalCost]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_FinancialAnalysisCloudTotalCost]
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

;with BillableByUsageItems as
		(select iif(min(isnull(AmountToPay, -1)) = -1, 0, sum(AmountToPay)*36) Price
			from Consolidation.fn_Reports_BillableByUsageCostBreakdown(1,@HST_ID)
			where StorageRedundancyLevelRank = 1
			group by ItemType
		)
select format(isnull(c.LicensingPriceFor3YearsUSD, 0) + isnull(r.LicensingPriceFor3YearsUSD, 0)
	+ isnull(c.OperationalCostFor3YearsUSD, 0) + isnull(r.OperationalCostFor3YearsUSD, 0) + isnull(Price, 0), 'C') Value
from (select sum(LicensingPriceFor3YearsUSD) LicensingPriceFor3YearsUSD,
								sum(OperationalCostFor3YearsUSD) OperationalCostFor3YearsUSD
			from Reports.fn_GetCostForCloudServers(@StandardCorePrice, @EnterpriseCorePrice, @SQLStandardEditionCoreLicensesOwnedWithSA, @SQLEnterpriseEditionCoreLicensesOwnedWithSA) c
			where HST_ID = @HST_ID
	) c
	outer apply (select sum(LicensingPriceFor3YearsUSD) LicensingPriceFor3YearsUSD,
								sum(OperationalCostFor3YearsUSD) OperationalCostFor3YearsUSD
							from Reports.fn_GetCostForRemainingServersForCloudServers(@HST_ID, null, @StandardCorePrice, @EnterpriseCorePrice, @OnPremServerYearlyOperationalCostUSD,
																						@SQLStandardEditionCoreLicensesOwned, @SQLEnterpriseEditionCoreLicensesOwned,
																						@SQLStandardEditionCoreLicensesOwnedWithSA, @SQLEnterpriseEditionCoreLicensesOwnedWithSA)
						) r
	cross join (select sum(Price) Price
					from BillableByUsageItems) b
where c.LicensingPriceFor3YearsUSD is not null
GO
