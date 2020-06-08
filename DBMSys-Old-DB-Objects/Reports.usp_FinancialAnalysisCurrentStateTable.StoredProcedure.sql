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
/****** Object:  StoredProcedure [Reports].[usp_FinancialAnalysisCurrentStateTable]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_FinancialAnalysisCurrentStateTable]
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

;with Scenario as
		(select isnull(replace(replace(SQLEdition, '[', ''), ']', ''), '[Total]') [SQL edition],
				CoreCount [Licensed cores],
				case SQLEdition
							when 'Standard' then @SQLStandardEditionCoreLicensesOwned
							when 'Enterprise' then @SQLEnterpriseEditionCoreLicensesOwned
							else 0
						end [Licensed owned],
				PricePerCore,
				OperationalCostFor3YearsUSD [HW/Operational Costs]
			from Reports.fn_GetCostForCurrentServerState(@StandardCorePrice, @EnterpriseCorePrice, @OnPremServerYearlyOperationalCostUSD,
															@SQLStandardEditionCoreLicensesOwned, @SQLEnterpriseEditionCoreLicensesOwned)
		)
select isnull([SQL edition], '[Total]') [SQL edition],
	iif(PricePerCore > 0, format(sum([Licensed cores]), '##,##0'), '') [Licensed cores],
	iif(PricePerCore > 0, format(sum([Licensed owned]), '##,##0'), '') [Licensed owned],
	iif(PricePerCore > 0, format(sum([Licensed cores] - [Licensed owned]), '##,##0'), '') [Licenses to be purchased],
	iif([SQL edition] <> 'No/Free SQL' or [SQL edition] is null, format(sum(([Licensed cores] - [Licensed owned])*PricePerCore), 'C'), '') [Licenses to be purchased price],
	format(sum([HW/Operational Costs]), 'C') [HW/Operational Costs]
from Scenario
group by PricePerCore, [SQL edition] with rollup
having grouping(PricePerCore) = grouping([SQL edition])
order by PricePerCore desc
GO
