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
/****** Object:  StoredProcedure [Reports].[usp_FinancialAnalysisScenarioSummaryTable]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_FinancialAnalysisScenarioSummaryTable]
--declare
	@ShowHSTType bit = 0
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

;with CurrentStateScenario as
		(select 1 ScenarioOrder,
				'Current state' Scenario,
				sum(LicensingPriceFor3YearsUSD) [SQL licenses],
				sum(OperationalCostFor3YearsUSD) [HW/Operational cost]
				,0 as HST_ID
			from Reports.fn_GetCostForCurrentServerState(@StandardCorePrice, @EnterpriseCorePrice, @OnPremServerYearlyOperationalCostUSD, @SQLStandardEditionCoreLicensesOwned, @SQLEnterpriseEditionCoreLicensesOwned)
		)
	,RemainingServers as 
	(
		select 
				r.*
				,ht.HST_ID
		from	Consolidation.HostTypes ht
		cross apply Reports.fn_GetCostForRemainingServersForCloudServers(HST_ID, NULL, @StandardCorePrice, @EnterpriseCorePrice, @OnPremServerYearlyOperationalCostUSD,
																									@SQLStandardEditionCoreLicensesOwned, @SQLEnterpriseEditionCoreLicensesOwned,
																									@SQLStandardEditionCoreLicensesOwnedWithSA, @SQLEnterpriseEditionCoreLicensesOwnedWithSA) r
		WHERE HST_IsCloud = 1 and HST_IsPerSingleDatabase = 0
	)
	, CloudScenarios as
		(			
		select ht.HST_ID ScenarioOrder,
				
				HST_ReportName as Scenario,
				sum(isnull(c.LicensingPriceFor3YearsUSD, 0)) + sum(isnull(r.LicensingPriceFor3YearsUSD, 0)) [SQL licenses],
				sum(isnull(c.OperationalCostFor3YearsUSD, 0)) + sum(isnull(r.OperationalCostFor3YearsUSD, 0)) + isnull(Price, 0) [HW/Operational cost]
				,ht.HST_ID
			from RemainingServers r
			full join Reports.fn_GetCostForCloudServers(@StandardCorePrice, @EnterpriseCorePrice, @SQLStandardEditionCoreLicensesOwnedWithSA, @SQLEnterpriseEditionCoreLicensesOwnedWithSA) c on r.SQLEdition = c.SQLEdition and r.HST_ID = c.HST_ID
			join Consolidation.HostTypes ht on isnull(c.HST_ID,r.HST_ID) = ht.HST_ID
			cross apply (select sum(Price) Price
					from (
							select iif(min(isnull(AmountToPay, -1)) = -1, 0, sum(ISNULL(AmountToPay,0))*36) Price
								from Consolidation.fn_Reports_BillableByUsageCostBreakdown(ht.HST_CLV_ID,ht.HST_ID)
								where StorageRedundancyLevelRank = 1
								group by ItemType

					) b1 ) b
			
			group by HST_ReportName,ht.HST_ID, Price
		)
	, VirtualizationScenario as
		(select 10 ScenarioOrder,
				'Virtualize on premises' Scenario,
				isnull(StandardLicensingPriceFor3YearsUSD, 0) + isnull(EnterpriseLicensingPriceFor3YearsUSD, 0) + isnull(r.LicensingPriceFor3YearsUSD, 0) [SQL licenses],
				v.OperationalCostFor3YearsUSD + isnull(r.OperationalCostFor3YearsUSD, 0) [HW/Operational cost]
				,4 as HST_ID
			from Reports.fn_GetCostForVirtualization(@StandardCorePrice, @EnterpriseCorePrice, @OnPremServerYearlyOperationalCostUSD, @SQLStandardEditionCoreLicensesOwned, @SQLEnterpriseEditionCoreLicensesOwned) v
				cross join (select sum(LicensingPriceFor3YearsUSD) LicensingPriceFor3YearsUSD,
									sum(OperationalCostFor3YearsUSD) OperationalCostFor3YearsUSD
								from Reports.fn_GetCostForRemainingServersForVirtualization(null, @StandardCorePrice, @EnterpriseCorePrice, @OnPremServerYearlyOperationalCostUSD,
																								@SQLStandardEditionCoreLicensesOwned, @SQLEnterpriseEditionCoreLicensesOwned)
							) r
		)
	, OnPremConsolidationScenario as
		(select 11 ScenarioOrder,
				'Consolidate on premises' Scenario,
				sum(LicensingPriceFor3YearsUSD) [SQL licenses],
				sum(OperationalCostFor3YearsUSD) [HW/Operational cost]
				,2 as HST_ID
			from Reports.fn_GetCostForOnPremConsolidation(@StandardCorePrice, @EnterpriseCorePrice, @OnPremServerYearlyOperationalCostUSD,
															@SQLStandardEditionCoreLicensesOwned, @SQLEnterpriseEditionCoreLicensesOwned)
			having sum(OperationalCostFor3YearsUSD) is not null
		)
	, CloudPaaSScenario as
		(select 12 ScenarioOrder,
				'Move existing database to Azure SQL Databases' Scenario,
				sum(LicensingPriceFor3YearsUSD) [SQL licenses],
				sum(OperationalCostFor3YearsUSD) + PriceFor3YearsUSD [HW/Operational cost]
				,10 as HST_ID
			from Reports.fn_GetCostForCloudDatabases()
				cross join Reports.fn_GetCostForRemainingServersForCloudDatabases(@StandardCorePrice, @EnterpriseCorePrice, @OnPremServerYearlyOperationalCostUSD,
																					@SQLStandardEditionCoreLicensesOwned, @SQLEnterpriseEditionCoreLicensesOwned)
			group by PriceFor3YearsUSD
		)
	, Scenarios as
		(select *
			from CurrentStateScenario
			union all
			select *
			from CloudScenarios
			union all
			select *
			from VirtualizationScenario
			union all
			select *
			from OnPremConsolidationScenario
			union all
			select *
			from CloudPaaSScenario
		)

select * into #Scenarios from Scenarios

if @ShowHSTType = 1
	select Scenario,
		format([SQL licenses], 'C') [SQL licenses],
		format([HW/Operational cost], 'C') [HW/Operational cost],
		format([SQL licenses] + [HW/Operational cost], 'C') [Total spend]
		--,
		,HST_ID
	from #Scenarios
	order by ScenarioOrder
else
	select Scenario,
		format([SQL licenses], 'C') [SQL licenses],
		format([HW/Operational cost], 'C') [HW/Operational cost],
		format([SQL licenses] + [HW/Operational cost], 'C') [Total spend]
		--,
	from #Scenarios
	order by ScenarioOrder
GO
