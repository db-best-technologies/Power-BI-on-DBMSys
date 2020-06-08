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
/****** Object:  StoredProcedure [Consolidation].[usp_UpdateAWSRDSPricing]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Consolidation].[usp_UpdateAWSRDSPricing]
--DECLARE
	@XML_RDSPricing		xml = null,
	@ReturnResults bit = 1
AS
BEGIN

	set nocount on

	declare @PricingDBName nvarchar(128),
			@CLV_ID tinyint = 3,
			@ErrorMessage nvarchar(2000)

	if object_id('tempdb..#RDS') is not null
		drop table #RDS
	create table #RDS
		(LeaseContractLength varchar(200),
		PurchaseOption varchar(200),
		DatabaseEngine varchar(200),
		Location varchar(200),
		InstanceType varchar(200),
		InstanceFamily varchar(200),
		MemoryMB int,
		DatabaseEdition varchar(200),
		UpfrontPrice decimal(15, 3),
		MonthlyPrice decimal(15, 3),
		HourlyPrice decimal(15, 3),
		EffectiveHourlyPrice decimal(15, 3),
		ToLocationType varchar(250),
		usageType NVARCHAR(255),
		PhysicalProcessor	nvarchar(255),
		vCPU					INT,
		CPUStrenght			FLOAT,
		NetworkDSpeed		INT,
		NetworkUSpeed		INT
		)

	if object_id('tempdb..#OutboundNetworking') is not null
		drop table #OutboundNetworking
	create table #OutboundNetworking
		(Location varchar(200),
		EndingRange int,
		PricePerUnit decimal(15, 3))

	if object_id('tempdb..#Storage') is not null
		drop table #Storage
	create table #Storage
		(Location varchar(200),
		DeploymentOption varchar(200),
		PricePerUnit decimal(15, 3))

	IF OBJECT_ID('tempdb..#RDSPricing') IS NOT NULL
		DROP TABLE #RDSPricing

	CREATE TABLE #RDSPricing
	(
		SKU						nvarchar(255) NULL,
		OfferTermCode			nvarchar(255) NULL,
		EndingRange				nvarchar(255) NULL,
		Unit					nvarchar(255) NULL,
		PricePerUnit			float NULL,
		LeaseContractLength		nvarchar(255) NULL,
		PurchaseOption			nvarchar(255) NULL,
		[Product Family]		nvarchar(255) NULL,
		serviceCode				nvarchar(255) NULL,
		[Location]				nvarchar(255) NULL,
		[Instance Type]			nvarchar(255) NULL,
		[Instance Family]		nvarchar(255) NULL,
		Memory					nvarchar(255) NULL,
		[Database Engine]		nvarchar(255) NULL,
		[Database Edition]		nvarchar(255) NULL,
		[License Model]			nvarchar(255) NULL,
		[Transfer Type]			nvarchar(255) NULL,
		[From Location]			nvarchar(255) NULL,
		[To Location Type]		nvarchar(255) NULL,
		[usageType]				nvarchar(255) NULL,
		[Physical Processor]	nvarchar(255),
		vCPU					INT,
		CPUStrenght			FLOAT NULL,
		NetworkDSpeed		INT NULL,
		NetworkUSpeed		INT NULL

		

	)

	IF @XML_RDSPricing IS NOT NULL
	BEGIN
		INSERT INTO #RDSPricing
		(
			SKU, 
			OfferTermCode, 
			EndingRange, Unit, PricePerUnit, 
			LeaseContractLength, PurchaseOption, 
			[Product Family], serviceCode, [Location], 
			[Instance Type], 
			[Instance Family], 
			Memory, 
			[Database Engine], [Database Edition], [License Model], 
			[Transfer Type], [From Location], 
			[To Location Type], 
			usageType,
			[Physical Processor],
			vCPU			,	
			CPUStrenght		,
			NetworkDSpeed	,
			NetworkUSpeed	
		) --, 
			
		SELECT 
			R.value('@sku[1]', 'nvarchar(255)') AS SKU,
			R.value('@offertermcode[1]', 'nvarchar(255)') AS OfferTermCode,
			R.value('@endingrange[1]', 'nvarchar(255)') AS EndingRange,
			R.value('@unit[1]', 'nvarchar(255)') AS Unit,
			R.value('@priceperunit[1]', 'float') AS PricePerUnit,
			R.value('@leasecontractlength[1]', 'nvarchar(255)') AS LeaseContractLength,
			R.value('@purchaseoption[1]', 'nvarchar(255)') AS PurchaseOption,
			R.value('@product_family[1]', 'nvarchar(255)') AS [Product Family],
			R.value('@servicecode[1]', 'nvarchar(255)') AS serviceCode,
			R.value('@location[1]', 'nvarchar(255)') AS [Location],
			R.value('@instance_type[1]', 'nvarchar(255)') AS [Instance Type],
			R.value('@instance_family[1]', 'nvarchar(255)') AS [Instance Family],
			R.value('@memory[1]', 'nvarchar(255)') AS Memory,
			R.value('@database_engine[1]', 'nvarchar(255)') AS [Database Engine],
			R.value('@database_edition[1]', 'nvarchar(255)') AS [Database Edition],
			R.value('@license_model[1]', 'nvarchar(255)') AS [License Model],
			R.value('@transfer_type[1]', 'nvarchar(255)') AS [Transfer Type],
			R.value('@from_location[1]', 'nvarchar(255)') AS [From Location],
			R.value('@to_location_type[1]', 'nvarchar(255)') AS [To Location Type],
			R.value('@usagetype[1]', 'nvarchar(255)') AS usageType,
			R.value('@Physical_Processor[1]', 'nvarchar(255)') AS Physical_Processor,
			R.value('@vCPU[1]', 'INT') AS vCPU,
			R.value('@CMB_CPUStrenght[1]', 'FLOAT') AS CMB_CPUStrenght,
			R.value('@CMB_NetworkDSpeed[1]', 'FLOAT') AS CMB_NetworkDSpeed,
			R.value('@CMB_NetworkUSpeed[1]', 'FLOAT') AS CMB_NetworkUSpeed
			
		FROM
			@XML_RDSPricing.nodes('/rds/row') AS P(R)
	END

	select @PricingDBName = cast(SET_Value as nvarchar(128))
	from Management.Settings
	where SET_Module = 'Management'
		and SET_Key = 'Cloud Pricing Database Name'

	begin try
		IF @XML_RDSPricing IS NULL
		BEGIN
			declare @cm1 nvarchar(max)
			set @cm1 = 'select LeaseContractLength, PurchaseOption, [Database Engine],
				Location, [Instance Type], [Instance Family], cast(cast(replace(Memory, '' Gib'', '''') as decimal(15, 3))*1024 as int) MemoryMB,
				iif([License Model] = ''License included'', [Database Edition], null) [Database Edition],
				sum(iif(Unit = ''Quantity'', cast(PricePerUnit as decimal(15, 3)), 0)) UpfrontPrice,
				sum(iif(Unit = ''Hrs'' and PurchaseOption <> '''', cast(PricePerUnit as decimal(15, 3))*744, 0)) MonthlyPrice,
				sum(iif(Unit = ''Hrs'' and PurchaseOption = '''', cast(PricePerUnit as decimal(15, 3)), 0)) HourlyPrice,
				sum(iif(Unit = ''Hrs'', cast(PricePerUnit as decimal(15, 3)), 0))
					+ sum(iif(Unit = ''Quantity'', cast(PricePerUnit as decimal(15, 3))/cast(left(LeaseContractLength, 1) as int)/12/744, 0)) EffectiveHourlyPrice,
					[To Location Type],
					usageType
					,[Physical Processor]
					,vCPU				
					,CMB_CPUStrenght		
					,CMB_NetworkDSpeed	
					,CMB_NetworkUSpeed	
			from ' + @PricingDBName + '.AWS.RDSPricing
			LEFT JOIN ' + @PricingDBName + '.dbo.CloudMachinesBenchmark ON [Instance Type] = CMB_MachineName
			where serviceCode = ''AmazonRDS''
				and [Product Family] = ''Database Instance''
				and [Database Engine] in (''SQL Server'', ''Oracle'', ''MySQL'')
				and not ([Database Edition] = ''Standard'' and [License Model] = ''Bring your own license'')
				AND [Database Edition] <> ''''
			group by LeaseContractLength, PurchaseOption, [Database Engine],
				Location, [Instance Type], [Instance Family], cast(cast(replace(Memory, '' Gib'', '''') as decimal(15, 3))*1024 as int),
				iif([License Model] = ''License included'', [Database Edition], null),
				[To Location Type],usageType
				,vCPU				
					,CMB_CPUStrenght		
					,CMB_NetworkDSpeed	
					,CMB_NetworkUSpeed	
					,[Physical Processor]'

			print @cm1
			insert into #RDS
			exec(@cm1)
		END ELSE
		BEGIN
			
			insert into #RDS
			select LeaseContractLength, PurchaseOption, [Database Engine],
				Location, [Instance Type], [Instance Family], cast(cast(replace(Memory, ' Gib', '') as decimal(15, 3))*1024 as int) MemoryMB,
				iif([License Model] = 'License included', [Database Edition], null) [Database Edition],
				sum(iif(Unit = 'Quantity', cast(PricePerUnit as decimal(15, 3)), 0)) UpfrontPrice,
				sum(iif(Unit = 'Hrs' and PurchaseOption <> '', cast(PricePerUnit as decimal(15, 3))*744, 0)) MonthlyPrice,
				sum(iif(Unit = 'Hrs' and PurchaseOption = '', cast(PricePerUnit as decimal(15, 3)), 0)) HourlyPrice,
				sum(iif(Unit = 'Hrs', cast(PricePerUnit as decimal(15, 3)), 0))
					+ sum(iif(Unit = 'Quantity', cast(PricePerUnit as decimal(15, 3))/cast(left(LeaseContractLength, 1) as int)/12/744, 0)) EffectiveHourlyPrice,
				[To Location Type],usageType
				,[Physical Processor]
					,vCPU				
					,CPUStrenght		
					,NetworkDSpeed	
					,NetworkUSpeed	
			from #RDSPricing
			where serviceCode = 'AmazonRDS'
				and [Product Family] = 'Database Instance'
				and [Database Engine] = 'SQL Server'
				and ([Database Edition] = 'Standard'
						or [License Model] <> 'Bring your own license')
				AND [Database Edition] <> ''
			group by LeaseContractLength, PurchaseOption, [Database Engine],
				Location, [Instance Type], [Instance Family], cast(cast(replace(Memory, ' Gib', '') as decimal(15, 3))*1024 as int),
				iif([License Model] = 'License included', [Database Edition], null),
				[To Location Type],usageType,vCPU				
					,CPUStrenght		
					,NetworkDSpeed	
					,NetworkUSpeed	
					,[Physical Processor]
		END

		insert into Consolidation.CloudRegions
		select MaxID + ROW_NUMBER() over(order by Location) ID, @CLV_ID CLV_ID, null ZoneID, Location RegionName, replace(substring(Location, charindex('(', Location, 1) + 1, 1000), ')', '') LocationName
		from (select distinct Location
				from #RDS) l
				cross join (select max(CRG_ID) MaxID
								from Consolidation.CloudRegions) r
		where not exists (select *
							from Consolidation.CloudRegions
							where CRG_CLV_ID = @CLV_ID
								and CRG_Name = Location)

		INSERT INTO Consolidation.CloudMachineCategories
		SELECT 
				ISNULL(MaxID, 0) + ROW_NUMBER() over(order by InstanceFamily) ID
				,InstanceFamily
		from (
				select 
						distinct 
						InstanceFamily
				from	#RDS
			) cat
				cross join (
								select 
										max(CMG_ID) MaxID
								from	Consolidation.CloudMachineCategories
							) g
		where not exists (
							select	
									*
							from	Consolidation.CloudMachineCategories
							WHERE	CMG_Name = InstanceFamily
							)
		
		;with RDSCLMachines as 
		(
			SELECT 
					DISTINCT 
					3 AS CLVID
					,InstanceType AS MachineName
					,PhysicalProcessor
					,vCPU AS Cores
					,CPUStrenght
					,MemoryMB
					,NetworkDSpeed
					,NetworkUSpeed
					,CMG_ID AS CM_Cat 
			FROM	#RDS r
			JOIN Consolidation.CloudMachineCategories ON CMG_Name = InstanceFamily
			WHERE	CPUStrenght IS NOT NULL
		)

		--SELECT * FROM RDSCLMachines
		MERGE  Consolidation.CloudMachineTypes cm
			using RDSCLMachines m on cm.CMT_CLV_ID = m.CLVID AND cm.CMT_Name = m.MachineName
		when matched /*AND CPUStrenght <> CMT_CPUStrength*/ then update set
			CMT_CoreCount					= Cores
			,CMT_CPUStrength				= CPUStrenght
			,CMT_MemoryMB					= MemoryMB
			,CMT_NetworkSpeedDownloadMbit	= NetworkUSpeed
			,CMT_NetworkSpeedUploadMbit		= NetworkDSpeed
			,CMT_CMG_ID						= CM_Cat
			,CMT_CPUName					= PhysicalProcessor
		when not matched then insert(CMT_CLV_ID,CMT_Name,CMT_CPUName,CMT_CoreCount,CMT_CPUStrength,CMT_MemoryMB,CMT_NetworkSpeedDownloadMbit,CMT_NetworkSpeedUploadMbit,CMT_CMG_ID,CMT_IsActive)				
		VALUES(CLVID,MachineName,PhysicalProcessor,Cores,CPUStrenght,MemoryMB,NetworkUSpeed,NetworkDSpeed,CM_Cat,1);

		if object_id('tempdb..#AllRDS') is not null
			drop table #AllRDS

		;with RDS as
				(select LeaseContractLength, PurchaseOption, Location, InstanceType, InstanceFamily, DatabaseEngine, MemoryMB, DatabaseEdition, UpfrontPrice, MonthlyPrice, HourlyPrice, EffectiveHourlyPrice,
						'Single-Availability Zone' Redundency,usageType
					from #RDS
					where usageType like '%InstanceUsage%'
					union all
					select LeaseContractLength, PurchaseOption, Location, InstanceType, InstanceFamily, DatabaseEngine, MemoryMB, DatabaseEdition, m.UpfrontPrice, m.MonthlyPrice, m.HourlyPrice, m.EffectiveHourlyPrice,
						'Multi-Availability Zone' Redundency,usageType
					from #RDS i
						cross apply (select i.UpfrontPrice + m.UpfrontPrice UpfrontPrice,
											i.MonthlyPrice + m.MonthlyPrice MonthlyPrice,
											i.HourlyPrice + m.HourlyPrice HourlyPrice,
											i.EffectiveHourlyPrice + m.EffectiveHourlyPrice EffectiveHourlyPrice
										from #RDS m
										where m.usageType like '%MirrorUsage%'
											and m.LeaseContractLength = i.LeaseContractLength
											and m.PurchaseOption = i.PurchaseOption
											and m.Location = i.Location
											and m.InstanceType = i.InstanceType
											and (m.DatabaseEdition = i.DatabaseEdition
													or (m.DatabaseEdition is null
															and i.DatabaseEdition is null)
												)
										) m
					where usageType like '%InstanceUsage%'
				)

		select 
				CRG_ID, CMT_ID, CRL_ID, CHA_ID, CHE_ID, CPM_ID, UpfrontPrice, MonthlyPrice, HourlyPrice, EffectiveHourlyPrice
		INTO	#AllRDS
		from RDS
			inner join Consolidation.CloudMachineRedundencyLevels on CRL_CLV_ID = @CLV_ID
																	and CRL_Name = Redundency
			inner join Consolidation.CloudRegions on CRG_CLV_ID = @CLV_ID
														and CRG_Name = Location
			inner join Consolidation.CloudMachinePaymentModels on (PurchaseOption = '' and CPM_Name = 'On-demand')
																or (LeaseContractLength = '1yr' and PurchaseOption = 'No Upfront' and CPM_Name = '1-Year no upfront')
																or (LeaseContractLength = '1yr' and PurchaseOption = 'Partial Upfront' and CPM_Name = '1-Year partial upfront')
																or (LeaseContractLength = '1yr' and PurchaseOption = 'All Upfront' and CPM_Name = '1-Year Full upfront')
																or (LeaseContractLength = '3yr' and PurchaseOption = 'No Upfront' and CPM_Name = '3-Year no upfront')
																or (LeaseContractLength = '3yr' and PurchaseOption = 'Partial Upfront' and CPM_Name = '3-Year partial upfront')
																or (LeaseContractLength = '3yr' and PurchaseOption = 'All Upfront' and CPM_Name = '3-Year Full upfront')
			inner join Consolidation.CloudMachineTypes on CMT_CLV_ID = @CLV_ID
															and CMT_Name = InstanceType
			inner join Consolidation.CloudHostedApplications on ' ' + CHA_Name + ' ' like '% ' + DatabaseEngine + ' %'
			left join Consolidation.CloudHostedApplicationEditions on CHE_CHA_ID = CHA_ID
																	and CHE_Name = DatabaseEdition

		IF NOT EXISTS (SELECT * FROM #AllRDS)
			Raiserror('There are no RDS prices. Please contact DBMSys Support Team',16,1)

		ELSE
		merge Consolidation.CloudMachinePricing
		using (SELECT * FROM #AllRDS
				) s on CMP_CRG_ID = CRG_ID
						and CMP_CMT_ID = CMT_ID
						and CMP_CRL_ID = CRL_ID
						and CMP_CHA_ID = CHA_ID
						and (CMP_CHE_ID = CHE_ID
								or (CMP_CHE_ID is null
										and CHE_ID is null)
							)
						and CMP_CPM_ID = CPM_ID
			when matched then update set CMP_UpfrontPaymnetUSD = UpfrontPrice,
										CMP_MonthlyPaymentUSD = MonthlyPrice,
										CMP_HourlyPaymentUSD = HourlyPrice,
										CMP_EffectiveHourlyPaymentUSD = EffectiveHourlyPrice,
										CMP_Storage_BUL_ID = 9
			when not matched then insert (CMP_CRG_ID, CMP_CMT_ID, CMP_CRL_ID, CMP_CHA_ID, CMP_CHE_ID, CMP_CPM_ID, CMP_UpfrontPaymnetUSD, CMP_MonthlyPaymentUSD, CMP_HourlyPaymentUSD,
											CMP_EffectiveHourlyPaymentUSD, CMP_Storage_BUL_ID)
									values(CRG_ID, CMT_ID, CRL_ID, CHA_ID, CHE_ID, CPM_ID, UpfrontPrice, MonthlyPrice, HourlyPrice, EffectiveHourlyPrice, 9)
			WHEN NOT MATCHED BY SOURCE AND exists (select * from Consolidation.CloudMachineTypes CM WHERE CM.CMT_ID = CMP_CMT_ID AND CM.CMT_CLV_ID = 3)
				THEN DELETE ;
	end try
	begin catch
		set @ErrorMessage = ERROR_MESSAGE()
		raiserror('Error while updating machine pricing - %s', 16, 1, @ErrorMessage)
	end catch

	begin try
		IF @XML_RDSPricing IS NULL
		BEGIN
			insert into #OutboundNetworking
			exec('select [From Location], cast(nullif(EndingRange, ''inf'') as int) EndingRange, cast(PricePerUnit as decimal(15, 3)) PricePerUnit
			from ' + @PricingDBName + '.AWS.RDSPricing
			where serviceCode = ''AWSDataTransfer''
				and [Transfer Type] = ''AWS Outbound''')
		END ELSE
		BEGIN
			insert into #OutboundNetworking
			select [From Location], cast(nullif(EndingRange, 'inf') as int) EndingRange, cast(PricePerUnit as decimal(15, 3)) PricePerUnit
			from #RDSPricing
			where serviceCode = 'AWSDataTransfer'
				and [Transfer Type] = 'AWS Outbound'
		END

		begin tran

		delete Consolidation.BillableByUsageItemLevelPricingScheme
		where exists (select *
						from Consolidation.BillableByUsageItemLevels
						where BUL_CLV_ID = @CLV_ID
							and BUL_BUI_ID = 3
							and BUP_BUL_ID = BUL_ID)

		insert into Consolidation.BillableByUsageItemLevelPricingScheme(BUP_BUL_ID, BUP_UpToNumberOfUnits, BUP_PricePerUnit, BUP_CRG_ID)
		select BUL_ID, EndingRange, PricePerUnit, CRG_ID
		from #OutboundNetworking
			inner join Consolidation.BillableByUsageItemLevels on BUL_CLV_ID = @CLV_ID
																	and BUL_BUI_ID = 3
			inner join Consolidation.CloudRegions on CRG_CLV_ID = @CLV_ID
														and CRG_Name = Location

		commit tran
	end try
	begin catch
		set @ErrorMessage = ERROR_MESSAGE()
		if @@trancount > 0
			rollback
		raiserror('Error while updating outbound networking pricing - %s', 16, 1, @ErrorMessage)
	end catch
	
	begin try
		IF @XML_RDSPricing IS NULL
		BEGIN
			insert into #Storage
			exec('select distinct [Location], iif([To Location Type] like ''%:PIOPS-Storage'', ''Single-Availability Zone'', ''Multi-Availability Zone'') , cast(PricePerUnit as decimal(15, 3)) PricePerUnit
			from ' + @PricingDBName + '.AWS.RDSPricing
			where [Product Family] = ''Database Storage''
				and ([To Location Type] like ''%:PIOPS-Storage''
					or [To Location Type] like ''%:Mirror-PIOPS-Storage''
					or [To Location Type] like ''%:Multi-AZ-PIOPS-Storage'')')
		END ELSE
		BEGIN
			insert into #Storage
			select distinct [Location], iif([To Location Type] like '%:PIOPS-Storage', 'Single-Availability Zone', 'Multi-Availability Zone') , cast(PricePerUnit as decimal(15, 3)) PricePerUnit
			from #RDSPricing
			where [Product Family] = 'Database Storage'
				and ([To Location Type] like '%:PIOPS-Storage'
					or [To Location Type] like '%:Mirror-PIOPS-Storage'
					or [To Location Type] like '%:Multi-AZ-PIOPS-Storage')
		END

		merge Consolidation.BillableByUsageItemLevelPricingScheme
		using (select BUL_ID, CRG_ID, CSL_ID, PricePerUnit
				from #Storage
					inner join Consolidation.CloudRegions on CRG_CLV_ID = @CLV_ID
																and CRG_Name = Location
					inner join Consolidation.CloudStorageRedundancyLevels on CSL_CLV_ID = @CLV_ID
																			and CSL_Name = DeploymentOption
	 				inner join Consolidation.BillableByUsageItemLevels on BUL_CLV_ID = @CLV_ID
																		and BUL_BUI_ID = 1
				) s on BUL_ID = BUP_BUL_ID
					and CRG_ID = BUP_CRG_ID
					and CSL_ID = BUP_CSL_ID
		when matched then update set BUP_PricePerUnit = PricePerUnit
		when not matched then insert(BUP_BUL_ID, BUP_CRG_ID, BUP_CSL_ID, BUP_PricePerUnit)
								values(BUL_ID, CRG_ID, CSL_ID, PricePerUnit);
	end try
	begin catch
		set @ErrorMessage = ERROR_MESSAGE()
		raiserror('Error while updating storage pricing - %s', 16, 1, @ErrorMessage)
	end catch

	truncate table #Storage

	begin try
		IF @XML_RDSPricing IS NULL
		BEGIN
			insert into #Storage
			exec('select distinct [Location], iif([To Location Type] like ''%:PIOPS'', ''Single-Availability Zone'', ''Multi-Availability Zone'') , cast(PricePerUnit as decimal(15, 3)) PricePerUnit
			from ' + @PricingDBName + '.AWS.RDSPricing
			where [Product Family] = ''Provisioned IOPS''
				and ([To Location Type] like ''%:PIOPS''
					or [To Location Type] like ''%:Mirror-PIOPS''
					or [To Location Type] like ''%:Multi-AZ-PIOPS'')')
		END ELSE
		BEGIN
			insert into #Storage
			select distinct [Location], iif([To Location Type] like '%:PIOPS', 'Single-Availability Zone', 'Multi-Availability Zone') , cast(PricePerUnit as decimal(15, 3)) PricePerUnit
			from #RDSPricing
			where [Product Family] = 'Provisioned IOPS'
				and ([To Location Type] like '%:PIOPS'
					or [To Location Type] like '%:Mirror-PIOPS'
					or [To Location Type] like '%:Multi-AZ-PIOPS')
		END

		merge Consolidation.BillableByUsageItemLevelPricingScheme
		using (select BUL_ID, CRG_ID, CSL_ID, PricePerUnit
				from #Storage
					inner join Consolidation.CloudRegions on CRG_CLV_ID = @CLV_ID
																and CRG_Name = Location
					inner join Consolidation.CloudStorageRedundancyLevels on CSL_CLV_ID = @CLV_ID
																			and left(CSL_Name, charindex('-', CSL_Name, 1) - 1) = left(DeploymentOption, charindex('-', DeploymentOption, 1) - 1)
	 				inner join Consolidation.BillableByUsageItemLevels on BUL_CLV_ID = @CLV_ID
																		and BUL_BUI_ID = 2
				) s on BUL_ID = BUP_BUL_ID
					and CRG_ID = BUP_CRG_ID
					and CSL_ID = BUP_CSL_ID
		when matched then update set BUP_PricePerUnit = PricePerUnit
		when not matched then insert(BUP_BUL_ID, BUP_CRG_ID, BUP_CSL_ID, BUP_PricePerUnit)
								values(BUL_ID, CRG_ID, CSL_ID, PricePerUnit);
	end try
	begin catch
		set @ErrorMessage = ERROR_MESSAGE()
		raiserror('Error while updating iops pricing - %s', 16, 1, @ErrorMessage)
	end catch

	if @ReturnResults = 1
		select distinct 'Missing Server' Note, InstanceFamily, InstanceType
		from #RDS
		where not exists (select *
							from Consolidation.CloudMachineTypes
							where CMT_CLV_ID = @CLV_ID
								and CMT_Name = InstanceType)
		order by InstanceFamily, InstanceType
END
GO
