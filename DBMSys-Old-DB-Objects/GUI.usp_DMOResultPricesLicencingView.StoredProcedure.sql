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
/****** Object:  StoredProcedure [GUI].[usp_DMOResultPricesLicencingView]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_DMOResultPricesLicencingView] --3
--declare 
		@Type int --= 3

AS
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

IF @Type = 0
BEGIN
	
	if OBJECT_ID('tempdb..#Summary') is not null
		drop table #Summary

	create table #Summary
	(
		Edition				NVARCHAR(100)
		,Lic_core			NVARCHAR(30)
		,Lic_owned			NVARCHAR(30)
		,Lic_Purch			NVARCHAR(30)
		,lic_purch_price	NVARCHAR(30)
		,Oper_Cost			NVARCHAR(30)
	)

	insert into #Summary
	exec Reports.usp_FinancialAnalysisCurrentStateTable

	update #Summary set lic_purch_price = REPLACE(REPLACE(REPLACE(REPLACE(IIF(left(lic_purch_price,1) = '(','-' + lic_purch_price,lic_purch_price),'$',''),',',''),')',''),'(','')

	delete from #Summary where Edition = '[Total]'
	

	select 
			Edition												as [SQL edition]
			,Lic_core											as [Licensed cores]
			,Lic_owned											as [Licensed owned]
			,Lic_Purch											as [Licenses to be purchased]
			,REPLACE(REPLACE(lic_purch_price,'$',''),',','')	as [Licenses to be purchased price]
			,REPLACE(REPLACE(Oper_Cost,'$',''),',','')			as [HW/Operational Costs]
			,1													as [TableId]
	from	#Summary

END

IF exists (select * from Consolidation.HostTypes where HST_IsCloud = 1 and HST_IsPerSingleDatabase = 0 and HST_ID = @Type)
--@Type IN (3,5)
BEGIN
	
	if OBJECT_ID('tempdb..#AzureConsolidation') is not null
		drop table #AzureConsolidation

	create table #AzureConsolidation
	(
		Edition				NVARCHAR(100)
		,Lic_core			NVARCHAR(30)
		,Lic_owned			NVARCHAR(30)
		,Lic_Purch			NVARCHAR(30)
		,lic_purch_price	NVARCHAR(30)
		,Oper_Cost			NVARCHAR(30)
		,[Type]				NVARCHAR(100)
	)

	insert into #AzureConsolidation(Edition,Lic_core,Lic_owned,Lic_Purch,lic_purch_price,Oper_Cost)
	exec Reports.usp_FinancialAnalysisCloudVMsTable @type

	update #AzureConsolidation set lic_purch_price = REPLACE(REPLACE(REPLACE(REPLACE(IIF(left(lic_purch_price,1) = '(','-' + lic_purch_price,lic_purch_price),'$',''),',',''),')',''),'(','')

	update #AzureConsolidation set [Type] = 'Servers to be moved to Cloud VMs'

	delete from #AzureConsolidation where Edition = '[Total]'
	delete from #AzureConsolidation where Edition = 'No/Free SQL'
	--select * from #AzureConsolidation

	select 
			Edition												as [SQL edition]
			,Lic_core											as [Licensed cores]
			,Lic_owned											as [Licensed owned]
			,Lic_Purch											as [Licenses to be purchased]
			,REPLACE(REPLACE(lic_purch_price,'$',''),',','')	as [Licenses to be purchased price]
			,REPLACE(REPLACE(Oper_Cost,'$',''),',','')			as [HW/Operational Costs]
			,[Type]
			,CAST(1 as INT)										as TableId
	from	#AzureConsolidation

	delete from #AzureConsolidation

	insert into #AzureConsolidation(Edition,Lic_core,Lic_owned,Lic_Purch,lic_purch_price,Oper_Cost)
	exec Reports.usp_FinancialAnalysisCloudRemainingOnPremisesTable @type
	
	delete from #AzureConsolidation where Edition = '[Total]'
	delete from #AzureConsolidation where Edition = 'No/Free SQL'
	--select * from #AzureConsolidation

	
	update #AzureConsolidation set [Type] = 'Servers to be remain on premises'

	update #AzureConsolidation set lic_purch_price = REPLACE(REPLACE(REPLACE(REPLACE(IIF(left(lic_purch_price,1) = '(','-' + lic_purch_price,lic_purch_price),'$',''),',',''),')',''),'(','')

	select 
			Edition												as [SQL edition]
			,Lic_core											as [Licensed cores]
			,Lic_owned											as [Licensed owned]
			,Lic_Purch											as [Licenses to be purchased]
			,REPLACE(REPLACE(lic_purch_price,'$',''),',','')	as [Licenses to be purchased price]
			,REPLACE(REPLACE(Oper_Cost,'$',''),',','')			as [HW/Operational Costs]
			,[Type]
			,CAST(2 as INT)										as TableId
	from	#AzureConsolidation

	select cast('Standard' as varchar(100)) SQLEdition,
			
			@StandardCorePrice PricePerCore,
			@SQLStandardEditionCoreLicensesOwnedWithSA LicensesOwnedWithSA
		union all
		select 'Enterprise' SQLEdition,
			@EnterpriseCorePrice PricePerCore,
			@SQLEnterpriseEditionCoreLicensesOwnedWithSA LicensesOwnedWithSA
	

END

IF @Type = 4
BEGIN
	
	if OBJECT_ID('tempdb..#VirtualOnPrem') is not null
		drop table #VirtualOnPrem

	create table #VirtualOnPrem
	(
		Edition				NVARCHAR(100)
		,Lic_core			NVARCHAR(30)
		,Lic_owned			NVARCHAR(30)
		,Lic_Purch			NVARCHAR(30)
		,lic_purch_price	NVARCHAR(30)
		,Oper_Cost			NVARCHAR(30)
	)

	insert into #VirtualOnPrem(Edition,Lic_core,Lic_owned,Lic_Purch,lic_purch_price)
	exec Reports.usp_FinancialAnalysisVirtualizationSQLLicensingTable

	update #VirtualOnPrem set lic_purch_price = REPLACE(REPLACE(REPLACE(REPLACE(IIF(left(lic_purch_price,1) = '(','-' + lic_purch_price,lic_purch_price),'$',''),',',''),')',''),'(','')

	delete from #VirtualOnPrem where Edition = '[Total]'

	select 
			Edition																				as [SQL edition]
			,Lic_core																			as [Licensed cores]
			,Lic_owned																			as [Licensed owned]
			,Lic_Purch																			as [Licenses to be purchased]
			,REPLACE(REPLACE(REPLACE(REPLACE(lic_purch_price,'$',''),',',''),')',''),'(','')	as [Licenses to be purchased price]
			,'Servers to virtualized SQL licensing'												as [Type]
			,CAST(1 as INT)																		as TableId
	from	#VirtualOnPrem

	delete from #VirtualOnPrem

	delete from #VirtualOnPrem
	
	insert into #VirtualOnPrem
	exec Reports.usp_FinancialAnalysisCannotBeVirtualizedTable

	delete from #VirtualOnPrem where Edition = '[Total]'

	select 
			Edition												as [SQL edition]
			,Lic_core											as [Licensed cores]
			,Lic_owned											as [Licensed owned]
			,Lic_Purch											as [Licenses to be purchased]
			,REPLACE(REPLACE(lic_purch_price,'$',''),',','')	as [Licenses to be purchased price]
			,REPLACE(REPLACE(Oper_Cost,'$',''),',','')			as [HW/Operational Costs]
			,'Servers that cannot be virtualized'				as [Type]
			,CAST(2 as INT)										as TableId
	from	#VirtualOnPrem

END

IF @Type = 10
BEGIN
	
	if OBJECT_ID('tempdb..#AzurePaaS') is not null
		drop table #AzurePaaS

	create table #AzurePaaS
	(
		Edition				NVARCHAR(100)
		,Lic_core			NVARCHAR(30)
		,Lic_owned			NVARCHAR(30)
		,Lic_Purch			NVARCHAR(30)
		,lic_purch_price	NVARCHAR(30)
		,Oper_Cost			NVARCHAR(30)
	)

	insert into #AzurePaaS
	exec Reports.usp_FinancialAnalysisCloudPaaSRemainingOnPremisesTable

	delete from #AzurePaaS where Edition = '[Total]'

	update #AzurePaaS set lic_purch_price = REPLACE(REPLACE(REPLACE(REPLACE(IIF(left(lic_purch_price,1) = '(','-' + lic_purch_price,lic_purch_price),'$',''),',',''),')',''),'(','')

	select 
			Edition												as [SQL edition]
			,Lic_core											as [Licensed cores]
			,Lic_owned											as [Licensed owned]
			,Lic_Purch											as [Licenses to be purchased]
			,REPLACE(REPLACE(lic_purch_price,'$',''),',','')	as [Licenses to be purchased price]
			,REPLACE(REPLACE(Oper_Cost,'$',''),',','')			as [HW/Operational Costs]
			,CAST(2 as INT)										as TableId
	from	#AzurePaaS

END

IF @Type = 2
BEGIN
	if OBJECT_ID('tempdb..#OnPrem') is not null
		drop table #OnPrem

	create table #OnPrem
	(
		Edition				NVARCHAR(100)
		,Lic_core			NVARCHAR(30)
		,Lic_owned			NVARCHAR(30)
		,Lic_Purch			NVARCHAR(30)
		,lic_purch_price	NVARCHAR(30)
		,Oper_Cost			NVARCHAR(30)
	)

	insert into #OnPrem
	exec Reports.usp_FinancialAnalysisOnPremConsolidationTable

	delete from #OnPrem where Edition = '[Total]'

	update #OnPrem set lic_purch_price = REPLACE(REPLACE(REPLACE(REPLACE(IIF(left(lic_purch_price,1) = '(','-' + lic_purch_price,lic_purch_price),'$',''),',',''),')',''),'(','')

	select 
			Edition												as [SQL edition]
			,Lic_core											as [Licensed cores]
			,Lic_owned											as [Licensed owned]
			,Lic_Purch											as [Licenses to be purchased]
			,REPLACE(REPLACE(lic_purch_price,'$',''),',','')	as [Licenses to be purchased price]
			,REPLACE(REPLACE(Oper_Cost,'$',''),',','')			as [HW/Operational Costs]
			,CAST(1 as INT)										as TableId
	from	#OnPrem
END
GO
