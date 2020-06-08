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
/****** Object:  StoredProcedure [GUI].[usp_DMOResultPricesLicencingDetailsView]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_DMOResultPricesLicencingDetailsView]
--declare 
		@Type INT		= 10				
		,@TableId INT	= 0
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

if OBJECT_ID('tempdb..#MainResult') is not null
	drop table #MainResult

if OBJECT_ID('tempdb..#MSCoreCountFactor') is not null
	drop table #MSCoreCountFactor
if OBJECT_ID('tempdb..#CoreInfo') is not null
	drop table #CoreInfo
if OBJECT_ID('tempdb..#RedFlags') is not null
	drop table #RedFlags

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


select 
		MOB_ID as RF_MOBID
		, PCG_Name
		, RFR_PercentOverThreshold
		, PCG_Name + ' ' + cast(RFR_PercentOverThreshold as NVARCHAR(10)) + '%' as Res
		, PDS_Database_MOB_ID
INTO	#RedFlags
from Consolidation.RedFlagsByResourceType
	inner join Consolidation.ParticipatingDatabaseServers on RFR_MOB_ID in (PDS_Server_MOB_ID, PDS_Database_MOB_ID)
	inner join Consolidation.ServerGrouping on SGR_MOB_ID = PDS_Server_MOB_ID
	inner join Consolidation.ConsolidationGroups on CGR_ID = SGR_CGR_ID
	inner join Inventory.MonitoredObjects on MOB_ID = RFR_MOB_ID
	inner join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
	inner join PerformanceData.PerformanceCounterGroups on PCG_ID = RFR_PCG_ID
order by 1

;with dbl1 as 
(
	select 
			RF_MOBID	AS SRVMOBID
			,PCG_Name	AS PCGNAME
	from	#RedFlags
	group by RF_MOBID,PCG_Name
	having	COUNT(DISTINCT PDS_Database_MOB_ID)>1

)
, dbl2 as 
(
	SELECT 
			RF_MOBID
			, PCG_Name
			, RFR_PercentOverThreshold
			, Res
			, PDS_Database_MOB_ID
			, MOB_Name
	FROM	#RedFlags rf
	JOIN	Inventory.MonitoredObjects ON PDS_Database_MOB_ID = MOB_ID
	WHERE	EXISTS (SELECT * FROM dbl1 WHERE RF_MOBID = SRVMOBID AND PCG_Name = PCGNAME)
)
UPDATE	rf --#RedFlags
SET		Res += ' (' + MOB_NAME + ')'
FROM	#RedFlags rf
JOIN	dbl2 ON rf.PDS_Database_MOB_ID = dbl2.PDS_Database_MOB_ID 

create table #MainResult
(
	[Server]					NVARCHAR(255)
	,[Group]					NVARCHAR(255)
	,[Cores(count)]				INT
	,[Cloud Machine]			NVARCHAR(255)
	,[Infrastructure Price]		FLOAT
	,[SQL License Price]		FLOAT
	,[Type]						NVARCHAR(50)
	,[Red flag buffering]		NVARCHAR(max)
	,[Edition]					NVARCHAR(32)
	,[TableId]					SMALLINT
	
)

IF exists (select * from Consolidation.HostTypes where HST_IsCloud = 1 and HST_IsPerSingleDatabase = 0 and HST_ID = @Type)
--@Type IN (3,5)
BEGIN
	
	
	IF @TableId = 0 or @TableId = 1
	INSERT into #MainResult
	select 
			MOB_NAME																			as [Server]
			,CGR_NAME																			as [Group]
			,cast(iif(CMT_CoreCount < 4, 4, CMT_CoreCount) / BlockMachines as int)				as [Cores(count)]
			,CMT_NAME																			as [Cloud Machine]
			,CLB_BasePricePerMonthUSD * 36 / BlockMachines										as [Infrastructure Price]
			,ISNULL(PricePerCore,0) * iif(CMT_CoreCount < 4, 4, CMT_CoreCount) / BlockMachines	as [SQL License Price]
			,'Servers to be moved to Azure VMs'													as [Type]
			,isnull(stuff((
				SELECT N';' + Res
				from	#RedFlags
				where	MOB_ID = RF_MOBID
			  FOR XML PATH(''), TYPE).value('.', 'nvarchar(4000)'),1,1,N''),N'') 				as [Red flag buffering]
			  ,SQLEdition
			  ,@TableId
	from	Consolidation.ConsolidationBlocks
	cross apply (select count(*) BlockMachines
					from Consolidation.ConsolidationBlocks_LoadBlocks
					where CBL_CLB_ID = CLB_ID
						and CBL_DLR_ID is null) m
	join Consolidation.ConsolidationBlocks_LoadBlocks on CBL_CLB_ID = CLB_ID and CBL_DLR_ID is null
	join Consolidation.LoadBlocks on CBL_LBL_ID = LBL_ID
	join Inventory.MonitoredObjects on LBL_MOB_ID = MOB_ID
	join Consolidation.ConsolidationGroups on CLB_CGR_ID = CGR_ID
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

	IF @TableId = 0 or @TableId = 2
	INSERT into #MainResult
	select 
		MOB_NAME													as [Server]
		,CGR_NAME													as [Group]
		,cast(OPR_OriginalLicensingCoreCount as int)				as [Cores(count)]
		,''															as [Cloud Machine]
		,@OnPremServerYearlyOperationalCostUSD*3					as [Infrastructure Price]
		,OPR_OriginalLicensingCoreCount * ISNULL(PricePerCore,0)	as [SQL License Price]
		,'Servers to be remain on premises'							as [Type]
		,isnull(stuff((
				SELECT N';' + Res
				from	#RedFlags
				where	MOB_ID = RF_MOBID
			  FOR XML PATH(''), TYPE).value('.', 'nvarchar(4000)'),1,1,N''),N'') 		as [Red flag buffering]
		,SQLEdition
		,@TableId														
	from Consolidation.LoadBlocks
		inner join Consolidation.VW_OnPrem on OPR_Original_MOB_ID = LBL_MOB_ID
		join Inventory.MonitoredObjects on LBL_MOB_ID = MOB_ID
		join Consolidation.ConsolidationGroups on CGR_ID = LBL_CGR_ID
		left join (select cast('Standard' as varchar(100)) SQLEdition,
						@StandardCorePrice PricePerCore,
						@SQLStandardEditionCoreLicensesOwned LicensesOwned,
						@SQLStandardEditionCoreLicensesOwnedWithSA SALicensesOwned
					union all
					select 'Enterprise' SQLEdition,
						@EnterpriseCorePrice PricePerCore,
						@SQLEnterpriseEditionCoreLicensesOwned LicensesOwned,
						@SQLEnterpriseEditionCoreLicensesOwnedWithSA SALicensesOwned) e on SQLEdition = OPR_Edition
		outer apply (select CoreCount - (CoreCount - SALicensesOwned) CloudUsedLicenses,CoreCount
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
	
	select 
			* 
	from	#MainResult

	exec Reports.usp_CloudBillableByUsageFactsTbl @Type

	select cast('Standard' as varchar(100)) SQLEdition,
			
			@StandardCorePrice PricePerCore,
			case when @TableId = 0 THEN @SQLStandardEditionCoreLicensesOwned
				 when @TableId = 1 then @SQLStandardEditionCoreLicensesOwnedWithSA 
				 else @SQLStandardEditionCoreLicensesOwned - @SQLStandardEditionCoreLicensesOwnedWithSA end LicensesOwnedWithSA
	where exists (
					/*select 
							*
					from	Consolidation.ConsolidationBlocks 
					join	Consolidation.CloudHostedApplicationEditions on CHE_ID = CLB_CHE_ID
					where CLB_HST_ID = @Type and CHE_Name = cast('Standard' as varchar(100))*/
					select * from #MainResult where TableId = @TableId and Edition = 'Standard'
				)
			
		union all
	select 'Enterprise' SQLEdition,
		@EnterpriseCorePrice PricePerCore,
		case when @TableId = 0 then @SQLEnterpriseEditionCoreLicensesOwned
			 when @TableId = 1 then @SQLEnterpriseEditionCoreLicensesOwnedWithSA 
			 else @SQLEnterpriseEditionCoreLicensesOwned - @SQLEnterpriseEditionCoreLicensesOwnedWithSA end LicensesOwnedWithSA
	where exists (
					select * from #MainResult where TableId = @TableId and Edition = 'Enterprise'
					/*select 
							*
					from	Consolidation.ConsolidationBlocks 
					join	Consolidation.CloudHostedApplicationEditions on CHE_ID = CLB_CHE_ID
					where CLB_HST_ID = @Type and CHE_Name = cast('Enterprise' as varchar(100))
					*/
				)


END



IF @Type = 10
BEGIN

	IF @TableId = 0 or @TableId = 1
	select 
			o.MOB_Name + ' - ' + dbi.MOB_Name + ' - ' + IDB_Name		as [Server]
			, CGR_Name													as [Group]
												
			, CMG_Name + ' - ' + CMT_Name								as [Cloud Machine]
			, cast(SDC_MonthlyPrice as decimal(15, 2))*36				as [Infrastructure Price]--[SQL License Price]
			,'Databases moved to the cloud'								as [Type]							
			,isnull(stuff((														
				SELECT N';' + Res
				from	#RedFlags
				where	o.MOB_ID = RF_MOBID
			  FOR XML PATH(''), TYPE).value('.', 'nvarchar(4000)'),1,1,N''),N'') 		as [Red flag buffering]
			
	from	Consolidation.SingleDatabaseCloudLocations
	inner join Consolidation.SingleDatabaseLoadBlocks on SDL_ID = SDC_SDL_ID
	inner join Inventory.MonitoredObjects o on o.MOB_ID = SDL_MOB_ID
	inner join Consolidation.CloudMachineTypes on CMT_ID = SDC_CMT_ID
	inner join Consolidation.CloudMachineCategories on CMG_ID = CMT_CMG_ID
	inner join Consolidation.ServerGrouping on SGR_MOB_ID = SDL_MOB_ID
	inner join Consolidation.ConsolidationGroups on CGR_ID = SGR_CGR_ID
	inner join Inventory.InstanceDatabases on SDL_IDB_ID = IDB_ID
	inner join Inventory.MonitoredObjects dbi on IDB_MOB_ID = dbi.MOB_ID
	where SDC_HST_ID = @Type
	order by CGR_Name, o.MOB_Name

	IF @TableId = 0 or @TableId = 2
	select 
			MOB_Name														as [Server]						
			,CGR_NAME														as [Group]
																				
			,count(*)														as [Cores(count)]			
			,sum(OPR_OriginalLicensingCoreCount)*isnull(PricePerCore,0) 	as [SQL License Price]
			,count(*)*@OnPremServerYearlyOperationalCostUSD*3 				as [Infrastructure Price]		
			,'Servers to be remain on premises'								as [Type]
			,isnull(stuff((
				SELECT N';' + Res
				from	#RedFlags
				where	MOB_ID = RF_MOBID
			  FOR XML PATH(''), TYPE).value('.', 'nvarchar(4000)'),1,1,N''),N'') 		as [Red flag buffering]
	from	Consolidation.VW_OnPrem
	join	Consolidation.ConsolidationGroups on CGR_ID = OPR_CGR_ID
	join	Inventory.MonitoredObjects on OPR_Original_MOB_ID = MOB_ID
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
	group by MOB_NAME,CGR_NAME, PricePerCore, LicensesOwned,MOB_ID

	
	select cast('Standard' as varchar(100)) SQLEdition,
			
			@StandardCorePrice PricePerCore,
			@SQLStandardEditionCoreLicensesOwned as LicensesOwnedWithSA
	where exists (
					select 
							*
					from	Consolidation.VW_OnPrem
					where	OPR_Edition = cast('Standard' as varchar(100))
					)
		union all
	select 'Enterprise' SQLEdition,
		@EnterpriseCorePrice PricePerCore,
		@SQLEnterpriseEditionCoreLicensesOwned as LicensesOwnedWithSA
	where exists (
					select 
							*
					from	Consolidation.VW_OnPrem
					where	OPR_Edition = cast('Enterprise' as varchar(100))
				)

END

IF @Type = 2
BEGIN

	IF @TableId = 0 or @TableId = 1
	select 
		MOB_NAME												as [Server]
		,CGR_Name												as [Group]
		,cast(OPR_NewLicensingCoreCount as int)					as [Cores(count)]
		,@OnPremServerYearlyOperationalCostUSD*3				as [Infrastructure Price]
		,ISNULL(PricePerCore,0) * OPR_NewLicensingCoreCount		as [SQL License Price]
		,isnull(stuff((
				SELECT N';' + Res
				from	#RedFlags
				where	MOB_ID = RF_MOBID
			  FOR XML PATH(''), TYPE).value('.', 'nvarchar(4000)'),1,1,N''),N'') 		as [Red flag buffering]
		
	from Consolidation.VW_OnPrem
	join Inventory.MonitoredObjects on OPR_Original_MOB_ID = MOB_ID
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

	select cast('Standard' as varchar(100)) SQLEdition,
			
			@StandardCorePrice PricePerCore,
			case when @TableId = 0 THEN @SQLStandardEditionCoreLicensesOwned
				 when @TableId = 1 then @SQLStandardEditionCoreLicensesOwnedWithSA 
				 else @SQLStandardEditionCoreLicensesOwned - @SQLStandardEditionCoreLicensesOwnedWithSA end LicensesOwnedWithSA
	where exists (
					select 
							*
					from	Consolidation.VW_OnPrem
					where	OPR_Edition = cast('Standard' as varchar(100))
					)
		union all
	select 'Enterprise' SQLEdition,
		@EnterpriseCorePrice PricePerCore,
		case when @TableId = 0 then @SQLEnterpriseEditionCoreLicensesOwned
			 when @TableId = 1 then @SQLEnterpriseEditionCoreLicensesOwnedWithSA 
			 else @SQLEnterpriseEditionCoreLicensesOwned - @SQLEnterpriseEditionCoreLicensesOwnedWithSA end LicensesOwnedWithSA
	where exists (
					select 
							*
					from	Consolidation.VW_OnPrem
					where	OPR_Edition = cast('Enterprise' as varchar(100))
	)


END

IF @Type = 4
BEGIN
	
	IF @TableId = 0 or @TableId = 1
	BEGIN
	
if OBJECT_ID('tempdb..#Res') is not null
	drop table #Res


;with CoreCalc as
					(select CGR_NAME,CGR_ID,
					sum(iif(LBL_CHA_ID = 1 and CHE_Name = 'Standard', iif(CBL_VirtualCoreCount < 4, 4, CBL_VirtualCoreCount), 0)) StandardVirtualCores,
							sum(iif(LBL_CHA_ID = 1 and CHE_Name = 'Enterprise', iif(CBL_VirtualCoreCount < 4, 4, CBL_VirtualCoreCount), 0)) EnterpriseVirtualCores,
							PhysicalCores,
							count(*) VMs
							,VES_ServerType + '(Processor: ' +  VES_CPUName + ', Number of CPU Socket: ' + cast(VES_NumberOfCPUSockets as nvarchar(4)) + ', Memory, Mb: ' + cast(VES_MemoryMB as nvarchar(10)) + ')' as ToSrv
							from Consolidation.ConsolidationBlocks_LoadBlocks
							inner join Consolidation.LoadBlocks on LBL_ID = CBL_LBL_ID
							join Consolidation.consolidationGroups on  CGR_ID = LBL_CGR_ID
							left join Consolidation.CloudHostedApplicationEditions on CHE_ID = LBL_CHE_ID
							join Consolidation.ConsolidationBlocks on CBL_CLB_ID = CLB_ID
							join Consolidation.PossibleHosts on CLB_PSH_ID = PSH_ID
							join Consolidation.VirtualizationESXServers on VES_ID = PSH_VES_ID
							cross apply (select top 1 CPF_CPUCount/CPUStretchRatio PhysicalCores
											from Consolidation.CPUFactoring
													cross join (select cast(SET_Value as int) CPUStretchRatio
																	from Management.Settings
																	where SET_Module = 'Consolidation'
																		and SET_Key = 'Virtualization - CPU Core Stretch Ratio') s
											where CPF_VES_ID is not null) c
						where CBL_HST_ID = 4
						group by CBL_CLB_ID, PhysicalCores,CGR_NAME,CGR_ID,VES_ServerType + '(Processor: ' +  VES_CPUName + ', Number of CPU Socket: ' + cast(VES_NumberOfCPUSockets as nvarchar(4)) + ', Memory, Mb: ' + cast(VES_MemoryMB as nvarchar(10)) + ')' 
					)
				, AddingPriceFactor as
					(select *, iif(StandardVirtualCores*@StandardCorePrice + EnterpriseVirtualCores*@EnterpriseCorePrice > PhysicalCores*@EnterpriseCorePrice, 1, 0) IsHost
						from CoreCalc
					)

				, EditionCores as
					(select CGR_NAME,count(*) Hosts,CGR_ID,
							sum(VMs) VMs,
							sum(iif(IsHost = 0, StandardVirtualCores, 0)) StandardCores,
							sum(iif(IsHost = 0, EnterpriseVirtualCores, PhysicalCores)) EnterpriseCores
							,tosrv
						from AddingPriceFactor
						group by CGR_NAME,CGR_ID,ToSrv
					)
			select 
					MOB_Name																	as [Server]
					,CGR_NAME																	as [Group]						
					,CBL_VirtualCoreCount														as [Cores(Count)]
					,ToSrv																		as [Move to Server]
					,StandardCores*@StandardCorePrice + EnterpriseCores*@EnterpriseCorePrice 	as [SQL License Price]
					,CAST(1 as INT)																as TableId
					,'Servers to virtualized SQL licensing'										as [Type]
					,isnull(stuff((
						SELECT N';' + Res
						from	#RedFlags
						where	MOB_ID = RF_MOBID
					  FOR XML PATH(''), TYPE).value('.', 'nvarchar(4000)'),1,1,N''),N'') 		as [Red flag buffering]
					,DENSE_RANK() over (partition by CGR_ID order by MOB_ID)					as NN
			INTO	#res
			from	EditionCores
			join	Consolidation.ServerGrouping on CGR_ID = SGR_CGR_ID
			join	Inventory.MonitoredObjects on SGR_MOB_ID = MOB_ID	
			join	Consolidation.LoadBlocks on LBL_MOB_ID = MOB_ID
			join	Consolidation.ConsolidationBlocks_LoadBlocks on CBL_LBL_ID = LBL_ID and CBL_HST_ID = 4
			where	Hosts > 0


			update #res set [SQL License price] = 0 where NN <> 1
	
			select 
					[Server]
					,[Group]					
					,[Cores(Count)]
					,[Move to Server]
					,[SQL License price]
					,TableId
					,[Type]
					,[Red flag buffering]
			from	#res

	
;with Agg as
					(select OPR_CGR_ID as CGRID,
							count(*) ServerCount,
							cast(sum(OPR_OriginalLicensingCoreCount) as int) CoreCount,
							PricePerCore,
							LicensesOwned,
							VirtualizationUsedLicenses
							,MOB_ID,MOB_Name
						from Consolidation.LoadBlocks
						join Inventory.MonitoredObjects on LBL_MOB_ID = MOB_ID
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
						group by PricePerCore, LicensesOwned, VirtualizationUsedLicenses,OPR_CGR_ID,MOB_ID,MOB_Name
						)
			select 
					MOB_Name																					as [Server]
					,CGR_Name																					as [Group]					
					,SUM(CoreCount - (LicensesOwned - VirtualizationUsedLicenses))								as [Cores(Count)]
					,SUM(isnull((CoreCount - (LicensesOwned - VirtualizationUsedLicenses))*PricePerCore, 0))	as [SQL License Price]
					,SUM(ServerCount*@OnPremServerYearlyOperationalCostUSD*3) 									as [Infrastructure price]
					,CAST(2 as INT)																				as TableId
					,'Servers that cannot be virtualized'														as [Type]
					,isnull(stuff((
						SELECT N';' + Res
						from	#RedFlags
						where	MOB_ID = RF_MOBID
					  FOR XML PATH(''), TYPE).value('.', 'nvarchar(4000)'),1,1,N''),N'') 						as [Red flag buffering]
			from Agg																						
			join Consolidation.ConsolidationGroups on CGR_ID = CGRID										
			group by CGR_Name,MOB_Name,MOB_ID

		END	
		

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
				'Virtualization hosts operational cost'												as [Fact]
				,REPLACE(REPLACE(REPLACE(REPLACE(lic_purch_price,'$',''),',',''),')',''),'(','')	as [AmountToPay]
		from	#VirtualOnPrem


		select cast('Standard' as varchar(100)) SQLEdition,
			
			@StandardCorePrice PricePerCore,
			@SQLStandardEditionCoreLicensesOwned LicensesOwnedWithSA
		union all
		select 'Enterprise' SQLEdition,
			@EnterpriseCorePrice PricePerCore,
			@SQLEnterpriseEditionCoreLicensesOwned LicensesOwnedWithSA
END
GO
