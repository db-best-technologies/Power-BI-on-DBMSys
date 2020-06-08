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
/****** Object:  StoredProcedure [Reports].[usp_VirtualizationFacts]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_VirtualizationFacts]
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

;with Virtualized as
		(select o.SQLEdition, sum(o.ServerCount) over() OldServerCount, o.CoreCount OldCoreCount, Hosts, VMs,
			isnull(case o.SQLEdition
							when 'Enterprise' then EnterpriseCores
							when 'Standard' then StandardCores
						else 0
					end , 0) + isnull(r.CoreCount, 0) NewCoreCount
			from Reports.fn_GetCostForCurrentServerState(@StandardCorePrice, @EnterpriseCorePrice, @OnPremServerYearlyOperationalCostUSD,
															@SQLStandardEditionCoreLicensesOwned, @SQLEnterpriseEditionCoreLicensesOwned) o
				cross join Reports.fn_GetCostForVirtualization(@StandardCorePrice, @EnterpriseCorePrice, @OnPremServerYearlyOperationalCostUSD,
																	@SQLStandardEditionCoreLicensesOwned, @SQLEnterpriseEditionCoreLicensesOwned) v
				outer apply Reports.fn_GetCostForRemainingServersForVirtualization(o.SQLEdition, @StandardCorePrice, @EnterpriseCorePrice, @OnPremServerYearlyOperationalCostUSD,
																						@SQLStandardEditionCoreLicensesOwned, @SQLEnterpriseEditionCoreLicensesOwned) r
		)
	, Facts as
		(select top 1 concat(VMs*100/isnull(nullif(OldServerCount, 0), 1) , '% (', format(VMs, '##,##0'), ') of the servers can be virtualized into ', Hosts, ' hosts') Fact, 1 Rnk
			from Virtualized
			union all
			select concat('Virtualization can ', iif(NewCoreCount < OldCoreCount, 'cut down', 'increase'), ' SQL ', SQLEdition, ' edition cores by ', cast(abs(100 - NewCoreCount*100/isnull(nullif(OldServerCount, 0), 1)) as int), '%, from ',
							format(OldCoreCount, '##,##0'), ' to ', format(NewCoreCount, '##,##0')) Fact, 2 Rnk
			from Virtualized
			where SQLEdition in ('Standard', 'Enterprise')
		)
select Fact
from Facts
order by Rnk
GO
