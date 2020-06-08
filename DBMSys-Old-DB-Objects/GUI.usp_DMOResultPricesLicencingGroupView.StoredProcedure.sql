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
/****** Object:  StoredProcedure [GUI].[usp_DMOResultPricesLicencingGroupView]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_DMOResultPricesLicencingGroupView]
		@Type INT						

AS

BEGIN
declare @DiskIOBufferPercentage int,
	@DiskSizeBufferPercentage int,
	@ZoneID tinyint,
	@Consolidation_HST_ID int,
	@OneToOne_HST_ID int
	,@CLV_ID INT,

	@StandardCorePrice int,
	@EnterpriseCorePrice int,
	@OnPremServerYearlyOperationalCostUSD int,
	@SQLStandardEditionCoreLicensesOwned int,
	@SQLEnterpriseEditionCoreLicensesOwned int,
	@SQLStandardEditionCoreLicensesOwnedWithSA int,
	@SQLEnterpriseEditionCoreLicensesOwnedWithSA int,
	@RedFlagHostBuffer decimal(10, 2),
	@RedFlagWorkLoadBuffer decimal(10, 2),
	@RedFlagLoadBufferMultiplier decimal(10, 2)


if OBJECT_ID('tempdb..#Payment') is not null
	drop table #Payment

if OBJECT_ID('tempdb..#MSCoreCountFactor') is not null
	drop table #MSCoreCountFactor
if OBJECT_ID('tempdb..#CoreInfo') is not null
	drop table #CoreInfo

create table #MSCoreCountFactor
	(CoreCount int null,
	CPUNamePattern varchar(100) collate database_default null,
	CPUNamePatternMinCoreCount int null,
	Factor decimal(10, 2))
insert into #MSCoreCountFactor
values(1, null, null, 4),
	(2, null, null, 2),
	(null, '%AMD% 31__%', 6, .75),
	(null, '%AMD% 32__%', 6, .75),
	(null, '%AMD% 33__%', 6, .75),
	(null, '%AMD% 41__%', 6, .75),
	(null, '%AMD% 42__%', 6, .75),
	(null, '%AMD% 43__%', 6, .75),
	(null, '%AMD% 61__%', 6, .75),
	(null, '%AMD% 62__%', 6, .75),
	(null, '%AMD% 63__%', 6, .75)

select @DiskIOBufferPercentage = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Disk IO Buffer Percentage'

select @DiskSizeBufferPercentage = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Disk Size Buffer Percentage'

select @ZoneID = CAST(SET_Value as tinyint)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Cloud Zone'

SELECT 
		@CLV_ID = HST_CLV_ID 
FROM	Consolidation.HostTypes 
WHERE	HST_ID = @Type

select @Consolidation_HST_ID = HST_ID 
from Consolidation.HostTypes
where HST_CLV_ID = @CLV_ID
	and HST_IsConsolidation = 1

select @OneToOne_HST_ID = HST_ID 
from Consolidation.HostTypes
where HST_CLV_ID = @CLV_ID
	and HST_IsConsolidation = 0

--***********************************************************************************************
--			GET SQL PRICE PER CORE
--***********************************************************************************************
select @StandardCorePrice = cast(IPR_Value as int)
from PresentationManagement.InputParameters
where IPR_PRN_ID = 1
	and IPR_Name = '$SQLStandardEditionCoreLicensePriceUSD'

select @EnterpriseCorePrice = cast(IPR_Value as int)
from PresentationManagement.InputParameters
where IPR_PRN_ID = 1
	and IPR_Name = '$SQLEnterpriseEditionCoreLicensePriceUSD'

select @OnPremServerYearlyOperationalCostUSD = cast(IPR_Value as int)
from PresentationManagement.InputParameters
where IPR_PRN_ID = 1
	and IPR_Name = '$OnPremServerYearlyOperationalCostUSD'

select @SQLStandardEditionCoreLicensesOwned = cast(IPR_Value as int)
from PresentationManagement.InputParameters
where IPR_PRN_ID = 1
	and IPR_Name = '$SQLStandardEditionCoreLicensesOwned'

select @SQLEnterpriseEditionCoreLicensesOwned = cast(IPR_Value as int)
from PresentationManagement.InputParameters
where IPR_PRN_ID = 1
	and IPR_Name = '$SQLEnterpriseEditionCoreLicensesOwned'

select @SQLStandardEditionCoreLicensesOwnedWithSA = cast(IPR_Value as int)
from PresentationManagement.InputParameters
where IPR_PRN_ID = 1
	and IPR_Name = '$SQLStandardEditionCoreLicensesOwnedWithSA'

select @SQLEnterpriseEditionCoreLicensesOwnedWithSA = cast(IPR_Value as int)
from PresentationManagement.InputParameters
where IPR_PRN_ID = 1
	and IPR_Name = '$SQLEnterpriseEditionCoreLicensesOwnedWithSA'
--***********************************************************************************************

END

;with CPUs as
		(select PRS_MOB_ID, max(PSN_Name) PSN_Name, sum(isnull(PRS_NumberOfCores, 1)) MachineCoreCount
			from Inventory.Processors
				inner join Inventory.ProcessorNames on PSN_ID = PRS_PSN_ID
			where exists (select * from Consolidation.ParticipatingDatabaseServers where PRS_MOB_ID = PDS_Server_MOB_ID)
			group by PRS_MOB_ID
		)
select 
		PRS_MOB_ID, MachineCoreCount, MachineCoreCount*coalesce(Factor, 1) LicensingCores
into #CoreInfo
from CPUs
	outer apply (select Factor Factor
					from #MSCoreCountFactor
					where MachineCoreCount = CoreCount
						or (PSN_Name like CPUNamePattern
							and MachineCoreCount >= CPUNamePatternMinCoreCount)
				) f

select *
into #Payment
from Consolidation.fn_Reports_BillableByUsageCostBreakdown(@CLV_ID,default)


IF exists (select * from Consolidation.HostTypes where HST_IsCloud = 1 and HST_IsPerSingleDatabase = 0 and HST_ID = @Type)
--@Type IN (3,5)
BEGIN
	select 
			CGR_NAME																	as [Group Name]
			,sum(SRV_CNT)																as [Servers (Count)]
			,sum(cast(iif(CMT_CoreCount < 4, 4, CMT_CoreCount) as int) * PricePerCore)	as [SQL Licensed price]
			,sum(CLB_BasePricePerMonthUSD*36)											as [Infrastructure price]
			,'Servers to be moved to Azure VMs'											as [Type]
			,CAST(1 as INT)																as TableId
			
					from Consolidation.ConsolidationBlocks
					join Consolidation.ConsolidationGroups on CLB_CGR_ID = CGR_ID
					cross apply (select COUNT(SGR_MOB_ID) as SRV_CNT from Consolidation.ServerGrouping where CGR_ID = SGR_CGR_ID)sg
						cross apply (select count(*) BlockMachines 
										from Consolidation.ConsolidationBlocks_LoadBlocks
										where CBL_CLB_ID = CLB_ID
											and CBL_DLR_ID is null) m
						inner join Consolidation.PossibleHosts on PSH_ID = CLB_PSH_ID
						inner join Consolidation.CloudMachineTypes on CMT_ID = PSH_CMT_ID
						left join Consolidation.CloudHostedApplicationEditions on CHE_ID = CLB_CHE_ID
						left join (select cast('Standard' as varchar(100)) SQLEdition,
										@StandardCorePrice PricePerCore,
										@SQLStandardEditionCoreLicensesOwnedWithSA LicensesOwnedWithSA
									union all
									select 'Enterprise' SQLEdition,
										@EnterpriseCorePrice PricePerCore,
										@SQLEnterpriseEditionCoreLicensesOwnedWithSA LicensesOwnedWithSA) e on SQLEdition = CHE_Name
					where CLB_HST_ID in (@Type)
						and CLB_DLR_ID is null
			group by CGR_NAME

select			
		CGR_NAME															as [Group Name]
		,count(*)															as [Servers (Count)]
		,cast(sum(OPR_OriginalLicensingCoreCount) as int) * PricePerCore	as [SQL Licensed price]
		,count(*)*@OnPremServerYearlyOperationalCostUSD*3					as [Infrastructure price]
		,'Servers to be remain on premises'									as [Type]
		,CAST(2 as INT)														as TableId
		from Consolidation.LoadBlocks
		join Consolidation.ConsolidationGroups on CGR_ID = LBL_CGR_ID
			inner join Consolidation.VW_OnPrem on OPR_Original_MOB_ID = LBL_MOB_ID
			left join (select cast('Standard' as varchar(100)) SQLEdition,
							@StandardCorePrice PricePerCore,
							@SQLStandardEditionCoreLicensesOwned LicensesOwned,
							@SQLStandardEditionCoreLicensesOwnedWithSA SALicensesOwned
						union all
						select 'Enterprise' SQLEdition,
							@EnterpriseCorePrice PricePerCore,
							@SQLEnterpriseEditionCoreLicensesOwned LicensesOwned,
							@SQLEnterpriseEditionCoreLicensesOwnedWithSA SALicensesOwned) e on SQLEdition = OPR_Edition
			outer apply (select CoreCount - (CoreCount - SALicensesOwned) CloudUsedLicenses
				from Reports.fn_GetCostForCloudServers(@StandardCorePrice, @EnterpriseCorePrice, @SQLStandardEditionCoreLicensesOwnedWithSA, @SQLEnterpriseEditionCoreLicensesOwnedWithSA) c
				where HST_ID = @Type
					and c.SQLEdition = e.SQLEdition
			) l
		where not exists (select *
							from Consolidation.ConsolidationBlocks_LoadBlocks
								inner join Consolidation.ConsolidationBlocks on CLB_ID = CBL_CLB_ID
							where CLB_HST_ID = @Type
								and CLB_DLR_ID is null
								and CBL_DLR_ID is null
								and CBL_LBL_ID = LBL_ID)
			and exists (select *
							from Consolidation.ConsolidationBlocks_LoadBlocks
								inner join Consolidation.ConsolidationBlocks on CLB_ID = CBL_CLB_ID
							where CLB_HST_ID = @Type
								and CLB_DLR_ID is null
								and CBL_DLR_ID is null)
		group by SQLEdition, PricePerCore, LicensesOwned, CloudUsedLicenses,CGR_Name

		exec Reports.usp_CloudBillableByUsageFactsTbl @Type
		
END

IF @Type = 10
BEGIN
	
	select @RedFlagHostBuffer = CAST(SET_Value as decimal(10, 2))
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Red Flag Host Buffer'

	select @RedFlagWorkLoadBuffer = CAST(SET_Value as decimal(10, 2))
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Red Flag Work Load Buffer'

	select @RedFlagLoadBufferMultiplier = 1 + @RedFlagWorkLoadBuffer/100.

	select 
			CGR_Name																				as [Group Name]
			, case when sum(TotalMonthlyPriceUSD) <> 0 then COUNT(DISTINCT SGR_MOB_ID) Else 0 end	as [Servers (Count)]
			, sum(TotalMonthlyPriceUSD)	* 36														as [Infrastructure price]
			, 'Databases moved to the cloud'														as [Type]
			,CAST(1 as INT)																			as TableId
	from	Consolidation.ConsolidationGroups
	inner join Consolidation.ServerGrouping on CGR_ID = SGR_CGR_ID
	
	outer apply (select count(*) CloudWorthyDatabases, isnull(cast(sum(SDC_MonthlyPrice) as decimal(15, 2)), 0) TotalMonthlyPriceUSD
					from Consolidation.SingleDatabaseCloudLocations
						inner join Consolidation.SingleDatabaseLoadBlocks on SDL_ID = SDC_SDL_ID
					where SDC_HST_ID = @Type
						and SGR_MOB_ID = SDL_MOB_ID) c
group by CGR_Name
order by  CGR_Name

	
	select 
			CGR_NAME											as [Group Name]
			,count(*)											as [Servers (Count)]
			,sum(ISNULL(OPR_OriginalLicensingCoreCount,0))*isnull(PricePerCore,0) 	as [SQL Licensed price]
			,count(*)*@OnPremServerYearlyOperationalCostUSD*3 	as [Infrastructure price]
			,'Servers to be remain on premises'					as [Type]
			,CAST(2 as INT)										as TableId
			
	from	Consolidation.VW_OnPrem
	join	Consolidation.ConsolidationGroups on CGR_ID = OPR_CGR_ID
		left join (select cast('Standard' as varchar(100)) SQLEdition,
						@StandardCorePrice PricePerCore,
						@SQLStandardEditionCoreLicensesOwned LicensesOwned
					union all
					select 'Enterprise' SQLEdition,
						@EnterpriseCorePrice PricePerCore,
						@SQLEnterpriseEditionCoreLicensesOwned LicensesOwned
						) e on SQLEdition = OPR_Edition
	where exists (select *
					from Inventory.InstanceDatabases
						inner join Consolidation.ParticipatingDatabaseServers on PDS_Database_MOB_ID = IDB_MOB_ID
					where not exists (select *
										from Consolidation.SingleDatabaseLoadBlocks
											inner join Consolidation.SingleDatabaseCloudLocations on SDC_SDL_ID = SDL_ID
										where SDL_IDB_ID = IDB_ID)
						and IDB_Name not in ('master', 'tempdb', 'model', 'msdb', 'distribution')
					)
		and exists (select *
					from Consolidation.SingleDatabaseLoadBlocks
						inner join Consolidation.SingleDatabaseCloudLocations on SDC_SDL_ID = SDL_ID)
	group by CGR_NAME, PricePerCore, LicensesOwned


	select cast('Standard' as varchar(100)) SQLEdition,
		@StandardCorePrice PricePerCore,
		@SQLStandardEditionCoreLicensesOwned LicensesOwned
	union all
	select 'Enterprise' SQLEdition,
		@EnterpriseCorePrice PricePerCore,
		@SQLEnterpriseEditionCoreLicensesOwned LicensesOwned

	
END


IF @Type = 2
BEGIN
	
	select 
		CGR_Name											as [Group Name]
		,count(distinct OPR_Original_MOB_ID)				as [Servers (Count)]
		,sum(PricePerCore * OPR_NewLicensingCoreCount)		as [SQL Licensed price]
		,count(*)*@OnPremServerYearlyOperationalCostUSD*3	as [Infrastructure price]
		,CAST(1 as INT)										as TableId
	from Consolidation.VW_OnPrem
	join Consolidation.ConsolidationGroups on CGR_ID = OPR_CGR_ID
		left join (select cast('Standard' as varchar(100)) SQLEdition,
						@StandardCorePrice PricePerCore,
						@SQLStandardEditionCoreLicensesOwned LicensesOwned
					union all
					select 'Enterprise' SQLEdition,
						@EnterpriseCorePrice PricePerCore,
						@SQLEnterpriseEditionCoreLicensesOwned LicensesOwned
					) e on SQLEdition =  OPR_Edition

	where OPR_New_MOB_ID = OPR_Original_MOB_ID
		and exists (select *
						from Consolidation.VW_OnPrem o2
						where o2.OPR_New_MOB_ID <> o2.OPR_Original_MOB_ID)
	group by CGR_NAME

	select cast('Standard' as varchar(100)) SQLEdition,
		@StandardCorePrice PricePerCore,
		@SQLStandardEditionCoreLicensesOwned LicensesOwned
	union all
	select 'Enterprise' SQLEdition,
		@EnterpriseCorePrice PricePerCore,
		@SQLEnterpriseEditionCoreLicensesOwned LicensesOwned

END

IF @Type = 4
BEGIN

	;with CoreCalc as
					(select CGR_NAME
					,sum(iif(LBL_CHA_ID = 1 and CHE_Name = 'Standard', iif(CBL_VirtualCoreCount < 4, 4, CBL_VirtualCoreCount), 0)) StandardVirtualCores,
							sum(iif(LBL_CHA_ID = 1 and CHE_Name = 'Enterprise', iif(CBL_VirtualCoreCount < 4, 4, CBL_VirtualCoreCount), 0)) EnterpriseVirtualCores,
							PhysicalCores,
							count(*) VMs
						from Consolidation.ConsolidationBlocks_LoadBlocks
							inner join Consolidation.LoadBlocks on LBL_ID = CBL_LBL_ID
							join Consolidation.consolidationGroups on  CGR_ID = LBL_CGR_ID
							left join Consolidation.CloudHostedApplicationEditions on CHE_ID = LBL_CHE_ID
							cross apply (select top 1 CPF_CPUCount/CPUStretchRatio PhysicalCores
											from Consolidation.CPUFactoring
													cross join (select cast(SET_Value as int) CPUStretchRatio
																	from Management.Settings
																	where SET_Module = 'Consolidation'
																		and SET_Key = 'Virtualization - CPU Core Stretch Ratio') s
											where CPF_VES_ID is not null) c
						where CBL_HST_ID = 4
						group by CBL_CLB_ID, PhysicalCores,CGR_NAME
					)
				, AddingPriceFactor as
					(select *, iif(StandardVirtualCores*@StandardCorePrice + EnterpriseVirtualCores*@EnterpriseCorePrice > PhysicalCores*@EnterpriseCorePrice, 1, 0) IsHost
						from CoreCalc
					)

				, EditionCores as
					(select CGR_NAME,count(*) Hosts,
							sum(VMs) VMs,
							sum(iif(IsHost = 0, StandardVirtualCores, 0)) StandardCores,
							sum(iif(IsHost = 0, EnterpriseVirtualCores, PhysicalCores)) EnterpriseCores
						from AddingPriceFactor
						group by CGR_NAME
					)
			select 
					CGR_NAME																	as [Group Name]						
					,vms																		as [Servers (Count)]
					,StandardCores*@StandardCorePrice + EnterpriseCores*@EnterpriseCorePrice 	as [SQL Licensed price]
					,CAST(1 as INT)																as TableId
					,'Servers to virtualized SQL licensing'										as [Type]
			from	EditionCores																
			where	Hosts > 0


		;with Agg as
					(select OPR_CGR_ID as CGRID,
							count(*) ServerCount,
							cast(sum(OPR_OriginalLicensingCoreCount) as int) CoreCount,
							PricePerCore,
							LicensesOwned,
							VirtualizationUsedLicenses
						from Consolidation.LoadBlocks
							inner join Consolidation.VW_OnPrem on OPR_Original_MOB_ID = LBL_MOB_ID
							cross join(select StandardCores - (StandardCores - StandardLicensesOwned) VirtualizationUsedStandardLicenses,
											EnterpriseCores - (EnterpriseCores - EnterpriseLicensesOwned) VirtualizationUsedEnterpriseLicenses
										from Reports.fn_GetCostForVirtualization(@StandardCorePrice, @EnterpriseCorePrice, @OnPremServerYearlyOperationalCostUSD,
																					@SQLStandardEditionCoreLicensesOwned, @SQLEnterpriseEditionCoreLicensesOwned) c

										) l
							outer apply (select *
											from (select cast('Standard' as varchar(100)) SQLEdition,
														@StandardCorePrice PricePerCore,
														@SQLStandardEditionCoreLicensesOwned LicensesOwned,
														VirtualizationUsedStandardLicenses VirtualizationUsedLicenses
													union all
													select 'Enterprise' SQLEdition,
														@EnterpriseCorePrice PricePerCore,
														@SQLEnterpriseEditionCoreLicensesOwned LicensesOwned,
														VirtualizationUsedEnterpriseLicenses VirtualizationUsedLicenses) e
											where SQLEdition = OPR_Edition) e
						where not exists (select *
											from Consolidation.ConsolidationBlocks_LoadBlocks
												inner join Consolidation.ConsolidationBlocks on CLB_ID = CBL_CLB_ID
											where CLB_HST_ID = 4
												and CLB_DLR_ID is null
												and CBL_DLR_ID is null
												and CBL_LBL_ID = LBL_ID)
							and exists (select *
											from Consolidation.ConsolidationBlocks_LoadBlocks
												inner join Consolidation.ConsolidationBlocks on CLB_ID = CBL_CLB_ID
											where CLB_HST_ID = 4
												and CLB_DLR_ID is null
												and CBL_DLR_ID is null)
						group by PricePerCore, LicensesOwned, VirtualizationUsedLicenses,OPR_CGR_ID
						)
			select CGR_Name																					as [Group Name]
				,SUM(ServerCount)																			as [Servers (Count)]
				,SUM(isnull((CoreCount - (LicensesOwned - VirtualizationUsedLicenses))*PricePerCore, 0))	as [SQL Licensed price]
				,SUM(ServerCount*@OnPremServerYearlyOperationalCostUSD*3) 									as [Infrastructure price]
				,CAST(2 as INT)																				as TableId
				,'Servers that cannot be virtualized'														as [Type]
			from Agg																						
			join Consolidation.ConsolidationGroups on CGR_ID = CGRID										
			group by CGR_Name
				
	
		create table #VirtualOnPrem
		(
			Edition				NVARCHAR(100)
			,Lic_core			NVARCHAR(30)
			,Lic_owned			NVARCHAR(30)
			,Lic_Purch			NVARCHAR(30)
			,lic_purch_price	NVARCHAR(30)
			,Oper_Cost			NVARCHAR(30)
		)
		insert into #VirtualOnPrem(lic_purch_price)
		exec Reports.usp_FinancialAnalysisVirtualizationOperationalCost

	
		update #VirtualOnPrem set Edition = 'Virtualization hosts operational cost'

		select 
				'Virtualization hosts operational cost'																	as [Fact]
				,REPLACE(REPLACE(REPLACE(REPLACE(lic_purch_price,'$',''),',',''),')',''),'(','')		as [AmountToPay]
		from	#VirtualOnPrem


		select cast('Standard' as varchar(100)) SQLEdition,
		@StandardCorePrice PricePerCore,
		@SQLStandardEditionCoreLicensesOwned LicensesOwned
	union all
	select 'Enterprise' SQLEdition,
		@EnterpriseCorePrice PricePerCore,
		@SQLEnterpriseEditionCoreLicensesOwned LicensesOwned

END
GO
