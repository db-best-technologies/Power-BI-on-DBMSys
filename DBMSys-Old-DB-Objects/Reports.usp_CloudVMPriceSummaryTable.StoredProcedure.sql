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
/****** Object:  StoredProcedure [Reports].[usp_CloudVMPriceSummaryTable]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_CloudVMPriceSummaryTable]
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

select iif(HST_ID = 3, 'With consolidation', 'Without consolidation (1:1)') [Method],
	concat(format(sum(OperationalCostFor3YearsUSD), 'C'), ' (', format(sum(OperationalCostFor3YearsUSD)/36, 'C'), ' per month)') [VM price],
	[SQL licensing],
	format(sum(ServerCount), '##,##0') [Cloud machines],
	concat(format(OldServerCount, '##,##0'), ' (', format(OldServerCount - sum(MigratedServerCount), '##,##0'), ' not considered)') [Current server count]
from Reports.fn_GetCostForCloudServers(@StandardCorePrice, @EnterpriseCorePrice, @SQLStandardEditionCoreLicensesOwnedWithSA, @SQLEnterpriseEditionCoreLicensesOwnedWithSA) c
	cross join (select sum(ServerCount) OldServerCount
					from Reports.fn_GetCostForCurrentServerState(@StandardCorePrice, @EnterpriseCorePrice, @OnPremServerYearlyOperationalCostUSD,
																		@SQLStandardEditionCoreLicensesOwned, @SQLEnterpriseEditionCoreLicensesOwned) c
					) o
	cross apply (select stuff(replace(
						(select concat(char(13), char(10), isnull(SQLEdition, 'Total'), ': ',
										iif(SQLEdition is null, '', concat(format(sum(CoreCount), '##,##0'), ' cores, ')), format(sum(LicensingPriceFor3YearsUSD), 'C'))
							from Reports.fn_GetCostForCloudServers(@StandardCorePrice, @EnterpriseCorePrice, @SQLStandardEditionCoreLicensesOwnedWithSA, @SQLEnterpriseEditionCoreLicensesOwnedWithSA) c1
							where c1.HST_ID = c.HST_ID
								and SQLEdition in ('Standard', 'Enterprise')
							group by SQLEdition
							with rollup
							order by isnull(SQLEdition, 'Total')
							for xml path('')
						), '&#x0D;', char(13)), 1, 2, '') [SQL licensing]
				) l
group by iif(HST_ID = 3, 'With consolidation', 'Without consolidation (1:1)'), HST_ID, OldServerCount, [SQL licensing]
order by HST_ID desc
GO
