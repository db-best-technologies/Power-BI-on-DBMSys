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
/****** Object:  StoredProcedure [Reports].[usp_ConsolidationFacts]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_ConsolidationFacts]
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

;with Facts as
		(select case when c.SQLEdition in ('Standard', 'Enterprise')
						then concat('Consolidation can cut down SQL Enterprise edition cores by ', 100 - sum(c.CoreCount)*100/isnull(nullif(sum(o.CoreCount), 0), 1) , '%, from ', format(sum(o.CoreCount), '##,##0'),
									' to ', format(sum(c.CoreCount), '##,##0'), ')')
					when c.SQLEdition is null
						then concat(100 - sum(c.ServerCount)*100/isnull(nullif(sum(o.CoreCount), 0), 1), '% of the serves (', format(sum(c.ServerCount), '##,##0'), ' out of ',
								format(sum(o.ServerCount), '##,##0'), ') can be consolidated into other servers and then decommissioned')
				end Fact,
				sum(o.CoreCount) - sum(c.CoreCount) ReducedCores
			from Reports.fn_GetCostForOnPremConsolidation(@StandardCorePrice, @EnterpriseCorePrice, @OnPremServerYearlyOperationalCostUSD,
															@SQLStandardEditionCoreLicensesOwned, @SQLEnterpriseEditionCoreLicensesOwned) c
				inner join Reports.fn_GetCostForCurrentServerState(@StandardCorePrice, @EnterpriseCorePrice, @OnPremServerYearlyOperationalCostUSD,
																		@SQLStandardEditionCoreLicensesOwned, @SQLEnterpriseEditionCoreLicensesOwned) o on c.SQLEdition = o.SQLEdition
			group by c.SQLEdition
			with rollup
		)
select Fact
from Facts
where Fact is not null
	and ReducedCores > 0
order by Fact
GO
