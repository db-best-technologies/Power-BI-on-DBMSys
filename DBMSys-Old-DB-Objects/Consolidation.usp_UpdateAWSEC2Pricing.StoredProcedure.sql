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
/****** Object:  StoredProcedure [Consolidation].[usp_UpdateAWSEC2Pricing]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Consolidation].[usp_UpdateAWSEC2Pricing]
--declare
	@XML_EC2Pricing		xml = null,
	@ReturnResults bit = 1
AS
BEGIN

	set nocount on
	declare 
		@PricingDBName nvarchar(128),
		@CLV_ID tinyint = 2,
		@ErrorMessage nvarchar(2000),
		@Sql	nvarchar(max)

	if object_id('tempdb..#EC2') is not null
		drop table #EC2

	if object_id('tempdb..#XML_EC2Pricing') is not null
		drop table #XML_EC2Pricing

	create table #EC2
		(LeaseContractLength varchar(200),
		PurchaseOption varchar(200),
		Location varchar(200),
		InstanceType varchar(200),
		InstanceFamily varchar(200),
		OperatingSystem varchar(200),
		MemoryMB int,
		vCPU varchar(200),
		UpfrontPrice decimal(15, 3),
		MonthlyPrice decimal(15, 3),
		HourlyPrice decimal(15, 3),
		EffectiveHourlyPrice decimal(15, 3),
		Tenancy varchar(100),
		OfferingClass varchar(100),
		SQLLicense varchar(100),
		CPUStrenght		INT ,
		NetworkUSpeed	INT ,
		NetworkDSpeed	INT ,
		ECU				NVARCHAR(255),
		PhysicalProcessor	NVARCHAR(255)
		
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
		PricePerUnit decimal(15, 3))

	select @PricingDBName = cast(SET_Value as nvarchar(128))
	from Management.Settings
	where SET_Module = 'Management'
		and SET_Key = 'Cloud Pricing Database Name'

	CREATE TABLE #XML_EC2Pricing 
	(
		Unit					nvarchar(255),
		PricePerUnit			float,
		LeaseContractLength		nvarchar(255),
		PurchaseOption			nvarchar(255),
		OfferingClass			nvarchar(255),
		[Product Family]		nvarchar(255),
		serviceCode				nvarchar(255),
		[Location]				nvarchar(255),
		[Instance Type]			nvarchar(255),
		[Instance Family]		nvarchar(255),
		vCPU					int,
		Memory					nvarchar(255),
		[Operating System]		nvarchar(255),
		[From Location]			nvarchar(255),
		EndingRange				nvarchar(255),
		[Transfer Type]			nvarchar(255),
		[Storage Media]			nvarchar(255),
		[Volume Type]			nvarchar(255),
		Tenancy					nvarchar(255),
		[Pre Installed S/W]		nvarchar(255),
		CPUStrenght				INT ,
		NetworkUSpeed			INT ,
		NetworkDSpeed			INT ,
		ECU						NVARCHAR(255),
		[Physical Processor]	NVARCHAR(255)
	)

	IF @XML_EC2Pricing IS NOT NULL
	BEGIN
		INSERT INTO #XML_EC2Pricing (
			Unit, PricePerUnit, LeaseContractLength, PurchaseOption, OfferingClass, [Product Family], serviceCode, [Location], [Instance Type],
			[Instance Family], vCPU, Memory, [Operating System], [From Location], EndingRange, [Transfer Type], [Storage Media], [Volume Type], Tenancy, [Pre Installed S/W],
			CPUStrenght		,
			NetworkUSpeed	,
			NetworkDSpeed	,
			ECU,
			[Physical Processor]
			)
		SELECT
			R.value('@unit[1]', 'nvarchar(255)') AS Unit,
			R.value('@priceperunit[1]', 'float') AS PricePerUnit,
			R.value('@leasecontractlength[1]', 'nvarchar(255)') AS LeaseContractLength,
			R.value('@purchaseoption[1]', 'nvarchar(255)') AS PurchaseOption,
			R.value('@offeringclass[1]', 'nvarchar(255)') AS OfferingClass,
			R.value('@product_family[1]', 'nvarchar(255)') AS [Product Family],
			R.value('@servicecode[1]', 'nvarchar(255)') AS serviceCode,
			R.value('@location[1]', 'nvarchar(255)') AS [Location],
			R.value('@instance_type[1]', 'nvarchar(255)') AS [Instance Type],
			R.value('@instance_family[1]', 'nvarchar(255)') AS [Instance Family],
			R.value('@vcpu[1]', 'int') AS vCPU,
			R.value('@memory[1]', 'nvarchar(255)') AS Memory,
			R.value('@operating_system[1]', 'nvarchar(255)') AS [Operating System],
			R.value('@from_location[1]', 'nvarchar(255)') AS [From Location],
			R.value('@endingrange[1]', 'nvarchar(255)') AS EndingRange,
			R.value('@transfer_type[1]', 'nvarchar(255)') AS [Transfer Type],
			R.value('@storage_media[1]', 'nvarchar(255)') AS [Storage Media],
			R.value('@volume_type[1]', 'nvarchar(255)') AS [Volume Type],
			R.value('@tenancy[1]', 'nvarchar(255)') AS Tenancy,
			R.value('@pre_installed_sw[1]', 'nvarchar(255)') AS [Pre Installed S/W],
			R.value('@CMB_CPUStrenght[1]', 'nvarchar(255)') AS [CPUStrenght],
			R.value('@CMB_NetworkUSpeed[1]', 'nvarchar(255)') AS [NetworkUSpeed],
			R.value('@CMB_NetworkDSpeed[1]', 'nvarchar(255)') AS [NetworkDSpeed] ,
			R.value('@ECU[1]', 'nvarchar(255)') AS [ECU],
			R.value('@PhysicalProcessor[1]', 'nvarchar(255)') AS [Physical Processor]
			
		FROM
			@XML_EC2Pricing.nodes('/ec2/row') AS P(R)	
	END		

	begin try
		/*if (@XML_EC2Pricing IS NULL)
		BEGIN*/
			SET @Sql = 
				'insert into #EC2
					select LeaseContractLength, PurchaseOption,
					Location, [Instance Type], [Instance Family], [Operating System], cast(cast(replace(replace(Memory,'','',''''), '' Gib'', '''') as decimal(15, 3))*1024 as int) MemoryMB, vCPU,
					sum(iif(Unit = ''Quantity'', cast(PricePerUnit as decimal(15, 3)), 0)) UpfrontPrice,
					sum(iif(Unit = ''Hrs'' and PurchaseOption <> '''', cast(PricePerUnit as decimal(15, 3))*744, 0)) MonthlyPrice,
					sum(iif(Unit = ''Hrs'' and PurchaseOption = '''', cast(PricePerUnit as decimal(15, 3)), 0)) HourlyPrice,
					sum(iif(Unit = ''Hrs'', cast(PricePerUnit as decimal(15, 3)), 0))
						+ sum(iif(Unit = ''Quantity'', cast(PricePerUnit as decimal(15, 3))/cast(left(LeaseContractLength, 1) as int)/12/744, 0)) EffectiveHourlyPrice,
					Tenancy, OfferingClass,
					case [Pre Installed S/W]
						when ''SQL Std'' then ''SQL Standard''
						when ''SQL Ent'' then ''SQL Enterprise''
						when ''NA'' then null
					end SQLLicense
					,CMB_CPUStrenght	
					,CMB_NetworkUSpeed	
					,CMB_NetworkDSpeed
					,ECU
					,[Physical Processor]
				from ' + IIF(@XML_EC2Pricing IS NULL,@PricingDBName + '.AWS.EC2Pricing','#XML_EC2Pricing') + '
				LEFT JOIN	' + @PricingDBName + '.dbo.CloudMachinesBenchmark ON [Instance Type] = CMB_MachineName AND CMB_CLV_ID = 2
				where serviceCode = ''AmazonEC2''
					and [Product Family] = ''Compute Instance''
					and [Operating System] in (''Windows'', ''Linux'')
					and OfferingClass in (''convertible'', ''standard'')
					and [Pre Installed S/W] in (''NA'', ''SQL Ent'', ''SQL Std'')
				group by LeaseContractLength, PurchaseOption,
					Location, [Instance Type], [Instance Family], [Operating System], cast(cast(replace(replace(Memory,'','',''''), '' Gib'', '''') as decimal(15, 3))*1024 as int), vCPU,
					Tenancy, OfferingClass,
					case [Pre Installed S/W]
						when ''SQL Std'' then ''SQL Standard''
						when ''SQL Ent'' then ''SQL Enterprise''
						when ''NA'' then null
					end
					,CMB_CPUStrenght	
					,CMB_NetworkUSpeed	
					,CMB_NetworkDSpeed
					,ECU
					,[Physical Processor]
					'
					print @SQL
			exec (@Sql)
		/*END ELSE
		BEGIN
			-- Load data from the import file
			WITH EC2A AS
			(
				select LeaseContractLength, PurchaseOption,
					Location, [Instance Type], [Instance Family], [Operating System], cast(cast(replace(replace(Memory,',',''), ' Gib', '') as decimal(15, 3))*1024 as int) MemoryMB, vCPU,
					sum(iif(Unit = 'Quantity', cast(PricePerUnit as decimal(15, 3)), 0)) UpfrontPrice,
					sum(iif(Unit = 'Hrs' and PurchaseOption <> '', cast(PricePerUnit as decimal(15, 3))*744, 0)) MonthlyPrice,
					sum(iif(Unit = 'Hrs' and PurchaseOption = '', cast(PricePerUnit as decimal(15, 3)), 0)) HourlyPrice,
					sum(iif(Unit = 'Hrs', cast(PricePerUnit as decimal(15, 3)), 0))
						+ sum(iif(Unit = 'Quantity', cast(PricePerUnit as decimal(15, 3))/cast(left(LeaseContractLength, 1) as int)/12/744, 0)) EffectiveHourlyPrice,
					Tenancy, OfferingClass,
					case [Pre Installed S/W]
						when 'SQL Std' then 'SQL Standard'
						when 'SQL Ent' then 'SQL Enterprise'
						when 'NA' then null
					end SQLLicense
					,CPUStrenght	
					,NetworkUSpeed	
					,NetworkDSpeed
					,ECU
					,PhysicalProcessor
				from 
					#XML_EC2Pricing
				where serviceCode = 'AmazonEC2'
					and [Product Family] = 'Compute Instance'
					and [Operating System] in ('Windows', 'Linux')
					and OfferingClass in ('convertible', 'standard')
					and [Pre Installed S/W] in ('NA', 'SQL Ent', 'SQL Std')
				group by LeaseContractLength, PurchaseOption,
					Location, [Instance Type], [Instance Family], [Operating System], cast(cast(replace(replace(Memory,',',''), ' Gib', '') as decimal(15, 3))*1024 as int), vCPU,
					Tenancy, OfferingClass,
					case [Pre Installed S/W]
						when 'SQL Std' then 'SQL Standard'
						when 'SQL Ent' then 'SQL Enterprise'
						when 'NA' then null
					end
					,CPUStrenght	
					,NetworkUSpeed	
					,NetworkDSpeed
					,ECU
					,PhysicalProcessor
			)
			insert into #EC2
			select LeaseContractLength, PurchaseOption, Location, [Instance Type], [Instance Family], [Operating System], MemoryMB, vCPU,
				UpfrontPrice, MonthlyPrice, HourlyPrice, EffectiveHourlyPrice, Tenancy, OfferingClass, SQLLicense,CPUStrenght,NetworkUSpeed,NetworkDSpeed,ECU,PhysicalProcessor
			from EC2A
		END*/

		insert into Consolidation.CloudRegions
		select ISNULL(MaxID, 0) + ROW_NUMBER() over(order by Location) ID, @CLV_ID CLV_ID, null ZoneID, Location RegionName, replace(substring(Location, charindex('(', Location, 1) + 1, 1000), ')', '') LocationName
		from (select distinct Location
				from #EC2) l
				cross join (select max(CRG_ID) MaxID
								from Consolidation.CloudRegions) r
		where not exists (select *
							from Consolidation.CloudRegions
							where CRG_CLV_ID = 2
								and CRG_Name = Location)

		INSERT INTO Consolidation.CloudMachineCategories
		SELECT 
				ISNULL(MaxID, 0) + ROW_NUMBER() over(order by InstanceFamily) ID
				,InstanceFamily
		from (
				select 
						distinct 
						InstanceFamily
				from	#EC2
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

		;with CloudMachines AS 
		(
			SELECT 
					DISTINCT 
					InstanceType AS MachineName	
					,vCPU AS Cores
					,MemoryMB	
					,2 AS CLVID	
					,CPUStrenght AS CPUStrenght	
					,NetworkUSpeed	
					,NetworkDSpeed	
					,CMG_ID AS CM_Cat	
					,CASE WHEN ECU = 'Variable' THEN 0 ELSE CAST(ECU AS FLOAT) END AS ECU
					,PhysicalProcessor
			FROM	#EC2
			JOIN	Consolidation.CloudMachineCategories ON InstanceFamily = CMG_Name
			WHERE	CPUStrenght IS NOT NULL
					
		)
		
		MERGE  Consolidation.CloudMachineTypes cm
			using CloudMachines m on cm.CMT_CLV_ID = m.CLVID AND cm.CMT_Name = m.MachineName
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
		


		if object_id('tempdb..#AllEC2') is not null
			drop table #AllEC2

		select 
					CRG_ID, CMT_ID, OST_ID, CPM_ID, UpfrontPrice, MonthlyPrice, HourlyPrice, EffectiveHourlyPrice, CTT_ID, CPT_ID, CHE_ID,
					case when SQLLicense is not null then 1
						else null
					end CHA_ID
		INTO	#AllEC2
		from #EC2
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
			inner join Consolidation.OSTypes on OST_Name = OperatingSystem
			inner join Consolidation.CloudTenancyTypes on CTT_Name = Tenancy
			inner join Consolidation.CloudHostingPlanTypes on CPT_Name = OfferingClass
			left join Consolidation.CloudHostedApplicationEditions on CHE_CHA_ID = 1
																	and CHE_Name = case SQLLicense
																						when 'SQL Standard' then 'Standard'
																						when 'SQL Enterprise' then 'Enterprise'
																					end

		IF NOT EXISTS (SELECT * FROM #AllEC2)
			Raiserror('There are no EC2 prices. Please contact DBMSys Support Team',16,1)

		ELSE
		merge Consolidation.CloudMachinePricing
		using (SELECT * FROM #AllEC2
				) s on CMP_CRG_ID = CRG_ID
						and CMP_CMT_ID = CMT_ID
						and CMP_OST_ID = OST_ID
						and CMP_CPM_ID = CPM_ID
						and CMP_CTT_ID = CTT_ID
						and CMP_CPT_ID = CPT_ID
						and (CMP_CHE_ID = CHE_ID
								or (CMP_CHE_ID is null
									and CHE_ID is null)
							)
						and (CMP_CHA_ID = CHA_ID
								or (CMP_CHE_ID is null
									and CHE_ID is null)
							) 
			when matched then update set CMP_UpfrontPaymnetUSD = UpfrontPrice,
										CMP_MonthlyPaymentUSD = MonthlyPrice,
										CMP_HourlyPaymentUSD = HourlyPrice,
										CMP_EffectiveHourlyPaymentUSD = EffectiveHourlyPrice,
										CMP_Storage_BUL_ID = 6
			when not matched then insert (CMP_CRG_ID, CMP_CMT_ID, CMP_OST_ID, CMP_CPM_ID, CMP_UpfrontPaymnetUSD, CMP_MonthlyPaymentUSD, CMP_HourlyPaymentUSD, CMP_EffectiveHourlyPaymentUSD, CMP_Storage_BUL_ID,
											CMP_CTT_ID, CMP_CPT_ID, CMP_CHE_ID, CMP_CHA_ID)
									values(CRG_ID, CMT_ID, OST_ID, CPM_ID, UpfrontPrice, MonthlyPrice, HourlyPrice, EffectiveHourlyPrice, 6, CTT_ID, CPT_ID, CHE_ID, CHA_ID)
			WHEN NOT MATCHED BY SOURCE AND exists (select * from Consolidation.CloudMachineTypes CM WHERE CM.CMT_ID = CMP_CMT_ID AND CM.CMT_CLV_ID = 2)
				THEN DELETE ;
	end try
	begin catch
		set @ErrorMessage = ERROR_MESSAGE()
		raiserror('Error while updating machine pricing - %s', 16, 1, @ErrorMessage)
	end catch

	begin try
		if (@XML_EC2Pricing IS NULL)
		BEGIN
			insert into #OutboundNetworking
			exec('select [From Location], cast(nullif(EndingRange, ''inf'') as int) EndingRange, cast(PricePerUnit as decimal(15, 3)) PricePerUnit
			from ' + @PricingDBName + '.AWS.EC2Pricing
			where serviceCode = ''AWSDataTransfer''
				and [Transfer Type] = ''AWS Outbound''')
		END ELSE
		BEGIN
			INSERT INTO #OutboundNetworking
			SELECT [From Location], cast(nullif(EndingRange, 'inf') as int) EndingRange, cast(PricePerUnit as decimal(15, 3)) PricePerUnit
			FROM
				#XML_EC2Pricing
			WHERE 
				serviceCode = 'AWSDataTransfer'
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
														and CRG_Name = [Location]

		commit tran
	end try
	begin catch
		set @ErrorMessage = ERROR_MESSAGE()
		if @@trancount > 0
			rollback
		raiserror('Error while updating outbound networking pricing - %s', 16, 1, @ErrorMessage)
	end catch

	begin try
		if (@XML_EC2Pricing IS NULL)
		BEGIN
			insert into #Storage
			exec('select Location, cast(PricePerUnit as decimal(15, 3)) PricePerUnit
			from ' + @PricingDBName + '.AWS.EC2Pricing
			where [Product Family] = ''Storage''
				and [Storage Media] = ''SSD-backed''
				and [Volume Type] = ''General Purpose''')
		END ELSE
		BEGIN
			INSERT INTO #Storage
			SELECT [Location], cast(PricePerUnit as decimal(15, 3)) PricePerUnit
			FROM
				#XML_EC2Pricing		
			where 
				[Product Family] = 'Storage'
				and [Storage Media] = 'SSD-backed'
				and [Volume Type] = 'General Purpose'
		END

		merge Consolidation.BillableByUsageItemLevelPricingScheme
		using (select BUL_ID, CRG_ID, PricePerUnit
				from #Storage
					inner join Consolidation.CloudRegions on CRG_CLV_ID = @CLV_ID
																and CRG_Name = [Location]
	 				inner join Consolidation.BillableByUsageItemLevels on BUL_CLV_ID = @CLV_ID
																		and BUL_BUI_ID = 1
				) s on BUL_ID = BUP_BUL_ID
					and CRG_ID = BUP_CRG_ID
		when matched then update set BUP_PricePerUnit = PricePerUnit
		when not matched then insert(BUP_BUL_ID, BUP_CRG_ID, BUP_PricePerUnit)
								values(BUL_ID, CRG_ID, PricePerUnit);
	end try
	begin catch
		set @ErrorMessage = ERROR_MESSAGE()
		raiserror('Error while updating storage pricing - %s', 16, 1, @ErrorMessage)
	end catch

	truncate table #Storage

	begin try
		if (@XML_EC2Pricing IS NULL)
		BEGIN
			insert into #Storage
			exec('select Location, cast(PricePerUnit as decimal(15, 3)) PricePerUnit
			from ' + @PricingDBName + '.AWS.EC2Pricing
			where [Product Family] = ''Storage''
				and [Storage Media] = ''SSD-backed''
				and [Volume Type] = ''Provisioned IOPS''')
		END ELSE
		BEGIN
			insert into #Storage
			SELECT [Location], cast(PricePerUnit as decimal(15, 3)) PricePerUnit
			FROM
				#XML_EC2Pricing		
			WHERE
				[Product Family] = 'Storage'
				and [Storage Media] = 'SSD-backed'
				and [Volume Type] = 'Provisioned IOPS'			
		END

		merge Consolidation.BillableByUsageItemLevelPricingScheme
		using (select BUL_ID, CRG_ID, PricePerUnit
				from #Storage
					inner join Consolidation.CloudRegions on CRG_CLV_ID = @CLV_ID
																and CRG_Name = [Location]
	 				inner join Consolidation.BillableByUsageItemLevels on BUL_CLV_ID = @CLV_ID
																		and BUL_BUI_ID = 2
				) s on BUL_ID = BUP_BUL_ID
					and CRG_ID = BUP_CRG_ID
		when matched then update set BUP_PricePerUnit = PricePerUnit
		when not matched then insert(BUP_BUL_ID, BUP_CRG_ID, BUP_PricePerUnit)
								values(BUL_ID, CRG_ID, PricePerUnit);
	end try
	begin catch
		set @ErrorMessage = ERROR_MESSAGE()
		raiserror('Error while updating iops pricing - %s', 16, 1, @ErrorMessage)
	end catch

	if @ReturnResults = 1
		select distinct 'Missing Server' Note, InstanceFamily, InstanceType
		from #EC2
		where not exists (select *
							from Consolidation.CloudMachineTypes
							where CMT_CLV_ID = @CLV_ID
								and CMT_Name = InstanceType)
		order by InstanceFamily, InstanceType
END
GO
