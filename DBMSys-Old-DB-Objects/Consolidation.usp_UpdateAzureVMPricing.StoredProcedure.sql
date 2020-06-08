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
/****** Object:  StoredProcedure [Consolidation].[usp_UpdateAzureVMPricing]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Consolidation].[usp_UpdateAzureVMPricing]
--declare
	@XML_AzurePricing		xml = null,
	@ReturnResults bit = 1
AS

	set nocount on

	declare @SQL nvarchar(max),
			@ErrorMessage nvarchar(1000),
			@ErrorLine int,
			@CloudPricingDatabaseName nvarchar(128),
			@AzurePricingSchemaName nvarchar(128)

	if object_id('tempdb..#Machines') is not null
		drop table #Machines

	if object_id('tempdb..#Alerts') is not null
		drop table #Alerts

	create table #Machines
		(MachineName varchar(100) collate database_default,
		Cores int,
		MemoryMB int,
		RegionName varchar(100) collate database_default,
		Price decimal(15, 3),
		ApplicationEdition varchar(100) collate database_default
		,CLVID TINYINT
		,CPUStrenght	FLOAT
		,NetworkUSpeed	INT
		,NetworkDSpeed	INT
		,CM_Cat			NVARCHAR(255)
		,DTU			INT
		,VM_Disk		INT
		,Machinetype	NVARCHAR(255)
		)

	create table #Alerts
		(MachineName varchar(100) collate database_default,
		Note varchar(500) collate database_default)

	select @CloudPricingDatabaseName = cast(SET_Value as nvarchar(128))
	from Management.Settings
	where SET_Module = 'Management'
		and SET_Key = 'Cloud Pricing Database Name'

	select @AzurePricingSchemaName = cast(SET_Value as nvarchar(128))
	from Management.Settings
	where SET_Module = 'Management'
		and SET_Key = 'Azure Pricing Schema Name'

	----------- Creating temporary tables for export from file --------------------------------------------------
	IF OBJECT_ID('tempdb..#AllPrices') IS NOT NULL
		DROP TABLE #AllPrices


	IF OBJECT_ID('tempdb..#VirtualMachine') IS NOT NULL
		DROP TABLE #VirtualMachine

	CREATE TABLE #VirtualMachine
	(
		Id			bigint			NOT NULL,
		Name		nvarchar(255)	NOT NULL,
		Tier		nvarchar(255)	NOT NULL,
		Size		nvarchar(255)	NOT NULL,
		Cores		smallint		NOT NULL,
		Ram			float			NOT NULL,
		[Disk]		int				NOT NULL,
		DiskType	nvarchar(255)	NOT NULL,
		LinuxSupportPrice	float	NOT NULL,
		CMB_CPUStrenght		INT NULL,
		CMB_NetworkUSpeed	INT NULL,
		CMB_NetworkDSpeed	INT NULL
	)

	IF OBJECT_ID('tempdb..#VirtualMachinePrice') IS NOT NULL
		DROP TABLE #VirtualMachinePrice

	CREATE TABLE #VirtualMachinePrice
	(
		Id			bigint			NOT NULL,
		VmId		bigint			NOT NULL,
		RegionId	bigint			NOT NULL,
		[Type]		nvarchar(255)	NULL,
		License		nvarchar(255)	NULL,
		Price		smallmoney		NOT NULL
	)

	IF OBJECT_ID('tempdb..#Region') IS NOT NULL
		DROP TABLE #Region

	CREATE TABLE #Region
	(
		Id		bigint			NOT NULL,
		Name	nvarchar(500)	NOT NULL
	)

	IF OBJECT_ID('tempdb..#Storage') IS NOT NULL
		DROP TABLE #Storage

	CREATE TABLE #Storage
	(
		Id					bigint			NOT NULL,
		TransactionPrice	smallmoney		NOT NULL,
		[Type]				nvarchar(255)	NOT NULL,
		Tier				nvarchar(255)	NOT NULL,
		Redundancy			nvarchar(255)	NOT NULL,
		TypeDescription		nvarchar(255)	NOT NULL
	)

	IF OBJECT_ID('tempdb..#StoragePrice') IS NOT NULL
		DROP TABLE #StoragePrice

	CREATE TABLE #StoragePrice
	(
		Id			bigint		NOT NULL,
		LimitId		bigint		NOT NULL,
		StorageId	bigint		NOT NULL,
		Price		smallmoney	NOT NULL,
		RegionId	bigint		NOT NULL
	)

	IF OBJECT_ID('tempdb..#StorageLimit') IS NOT NULL
		DROP TABLE #StorageLimit

	CREATE TABLE #StorageLimit
	(
		Id		bigint	NOT NULL,
		Limit	float	NOT NULL
	)
	
	IF OBJECT_ID('tempdb..#PremiumStoragePrice') IS NOT NULL
		DROP TABLE #PremiumStoragePrice

	CREATE TABLE #PremiumStoragePrice
	(
		Id					bigint	NOT NULL,
		RegionId			bigint	NOT NULL,
		PremiumStorageId	bigint	NOT NULL,
		Price				float	NOT NULL
	)

	IF OBJECT_ID('tempdb..#PremiumStorage') IS NOT NULL
		DROP TABLE #PremiumStorage

	CREATE TABLE #PremiumStorage
	(
		Id			bigint			NOT NULL,
		[Type]		nvarchar(255)	NOT NULL,
		TypeSize	nvarchar(255)	NOT NULL,
		Size		float	NOT NULL,
		Iops		float	NOT NULL,
		Speed		float	NOT NULL
	)

	IF OBJECT_ID('tempdb..#NetworkLimit') IS NOT NULL
		DROP TABLE #NetworkLimit

	CREATE TABLE #NetworkLimit
	(
		Id		bigint	NOT NULL,
		Limit	float	NOT NULL
	)

	IF OBJECT_ID('tempdb..#NetworkPrice') IS NOT NULL
		DROP TABLE #NetworkPrice

	CREATE TABLE #NetworkPrice
	(
		Id			bigint		NOT NULL,
		RegionId	bigint		NOT NULL,
		LimitId		bigint		NOT NULL,
		Price		smallmoney	NOT NULL
	)

	-- Temporary tables filling if needed
	IF @XML_AzurePricing IS NOT NULL
	BEGIN
		INSERT INTO #VirtualMachine(Id, Name, Tier, Size, Cores, Ram, [Disk], DiskType, LinuxSupportPrice, CMB_CPUStrenght, CMB_NetworkDSpeed, CMB_NetworkUSpeed)
		SELECT
			R.value('@id[1]', 'bigint') AS Id,
			R.value('@name[1]', 'nvarchar(255)') AS Name,
			R.value('@tier[1]', 'nvarchar(255)') AS Tier,
			R.value('@size[1]', 'nvarchar(255)') AS Size,
			R.value('@cores[1]', 'smallint') AS Cores,
			R.value('@ram[1]', 'float') AS Ram,
			R.value('@disk[1]', 'int') AS [Disk],
			R.value('@disktype[1]', 'nvarchar(255)') AS DiskType,
			R.value('@linuxsupportprice[1]', 'float') AS LinuxSupportPrice,
			R.value('@CMB_CPUStrenght[1]', 'float') AS CMB_CPUStrenght,
			R.value('@CMB_NetworkDSpeed[1]', 'float') AS CMB_NetworkDSpeed,
			R.value('@CMB_NetworkUSpeed[1]', 'float') AS CMB_NetworkUSpeed
		FROM
			@XML_AzurePricing.nodes('/azure_virtualmachine/row') AS P(R)

		INSERT INTO #VirtualMachinePrice(Id, VmId, RegionId, [Type], License, Price)
		SELECT
			R.value('@id[1]', 'bigint') AS Id,
			R.value('@vmid[1]', 'bigint') AS VmId,
			R.value('@regionid[1]', 'bigint') AS RegionId,
			R.value('@type[1]', 'nvarchar(255)') AS [Type],
			R.value('@license[1]', 'nvarchar(255)') AS License,
			R.value('@price[1]', 'smallmoney') AS Price
		FROM
			@XML_AzurePricing.nodes('/azure_virtualmachineprice/row') AS P(R)


		INSERT INTO #Region(Id, Name)
		SELECT
			R.value('@id[1]', 'bigint') AS Id,
			R.value('@name[1]', 'nvarchar(500)') AS Name
		FROM
			@XML_AzurePricing.nodes('/azure_region/row') AS P(R)

		INSERT INTO #Storage(Id, TransactionPrice, [Type], Tier, Redundancy, TypeDescription)
		SELECT
			R.value('@id[1]', 'bigint') AS Id,
			R.value('@transactionprice[1]', 'smallmoney') AS TransactionPrice,
			R.value('@type[1]', 'nvarchar(255)') AS [Type],
			R.value('@tier[1]', 'nvarchar(255)') AS Tier,
			R.value('@redundancy[1]', 'nvarchar(255)') AS Redundancy,
			R.value('@typedescription[1]', 'nvarchar(255)') AS TypeDescription
		FROM
			@XML_AzurePricing.nodes('/azure_storage/row') AS P(R)

		INSERT INTO #StoragePrice(Id, LimitId, StorageId, Price, RegionId)
		SELECT
			R.value('@id[1]', 'bigint') AS Id,
			R.value('@limitid[1]', 'bigint') AS LimitId,
			R.value('@storageid[1]', 'bigint') AS StorageId,
			R.value('@price[1]', 'smallmoney') AS Price,
			R.value('@regionid[1]', 'bigint') AS RegionId
		FROM
			@XML_AzurePricing.nodes('/azure_storageprice/row') AS P(R)

		INSERT INTO #StorageLimit(Id, Limit)
		SELECT
			R.value('@id[1]', 'bigint') AS Id,
			R.value('@limit[1]', 'float') AS Limit
		FROM
			@XML_AzurePricing.nodes('/azure_storagelimit/row') AS P(R)

		INSERT INTO #NetworkLimit(Id, Limit)
		SELECT
			R.value('@id[1]', 'bigint') AS Id,
			R.value('@limit[1]', 'float') AS Limit
		FROM
			@XML_AzurePricing.nodes('/azure_networklimit/row') AS P(R)

		INSERT INTO #PremiumStoragePrice(Id, RegionId, PremiumStorageId, Price)
		SELECT
			R.value('@id[1]', 'bigint') AS Id,
			R.value('@regionid[1]', 'bigint') AS RegionId,
			R.value('@premiumstorageid[1]', 'bigint') AS PremiumStorageId,
			R.value('@price[1]', 'float') AS Price
		FROM
			@XML_AzurePricing.nodes('/azure_premiumstorageprice/row') AS P(R)

		INSERT INTO #PremiumStorage(Id, [Type], TypeSize, Size, Iops, Speed)
		SELECT
			R.value('@id[1]', 'bigint') AS Id,
			R.value('@type[1]', 'nvarchar(255)') AS [Type],
			R.value('@typesize[1]', 'nvarchar(255)') AS TypeSize,
			R.value('@size[1]', 'float') AS Size,
			R.value('@iops[1]', 'float') AS Iops,
			R.value('@speed[1]', 'float') AS Speed
		FROM
			@XML_AzurePricing.nodes('/azure_premiumstorage/row') AS P(R)

		INSERT INTO #NetworkPrice(Id, RegionId, LimitId, Price)
		SELECT
			R.value('@id[1]', 'bigint') AS Id,
			R.value('@regionid[1]', 'bigint') AS RegionId,
			R.value('@limitid[1]', 'bigint') AS LimitId,
			R.value('@price[1]', 'smallmoney') AS Price
		FROM
			@XML_AzurePricing.nodes('/azure_networkprice/row') AS P(R)

	END


	-------------------------------------------------
	
	IF @XML_AzurePricing IS NULL
	BEGIN
		set @SQL =
		'select m.Tier + '' '' + replace(Size, '' '', ''_'')  + IIF(p.type = ''SQL DBMI Server'','' '' + REPLACE(CMB_MachineName,''DBMI_'',''''),'''') MachineName
		,cast(Cores as int) Cores, cast(Ram as decimal(10, 2))*1024 MemoryMB,
			r.Name RegionName, cast(Price as decimal(15, 3)) Price, p.License ApplicationEdition
			,CASE WHEN p.type = ''SQL Server'' THEN 4
					WHEN p.type = ''SQL DBMI Server'' THEN 5
					ELSE 1 END AS CLVID
			, CMB_CPUStrenght
			, CMB_NetworkUSpeed
			, CMB_NetworkDSpeed
			, m.Tier AS CM_Cat
			, IIF(m.Name like ''%-dtu-%'',m.Size,NULL) as DTU
			, m.Disk
			, p.[Type]
		from ' + quotename(@CloudPricingDatabaseName) + '.' + quotename(@AzurePricingSchemaName) + '.VirtualMachine m
			inner join ' + quotename(@CloudPricingDatabaseName) + '.' + quotename(@AzurePricingSchemaName) + '.VirtualMachinePrice p on p.VmId = m.Id
			inner join ' + quotename(@CloudPricingDatabaseName) + '.' + quotename(@AzurePricingSchemaName) + '.Region r on r.Id = p.RegionId
			left  join ' + quotename(@CloudPricingDatabaseName) + '.dbo.CloudMachinesBenchmark cmb on ( CMB_CLV_ID = 1 AND CMB_MachineName = m.Tier + '' '' + replace(Size, '' '', ''_'')
																										OR m.Name like ''%-'' + REPLACE(CMB_MachineName,''DBMI_'','''') + ''-%'')
		where p.[Type] in (''Windows'', ''SQL Server'',''SQL DBMI Server'')
				and (License in (''SQL Standard'', ''SQL Enterprise'', ''SQL Web'')
						or License is null)
				AND (p.type = ''SQL Server'' OR CMB_CPUStrenght IS NOT NULL)
				AND NOT (p.[Type] = ''SQL DBMI Server'' AND  m.Name LIKE ''%gen_-software-%'')
				'
				
						
		begin try
			--2448
			print @SQL

			insert into #Machines
			exec(@SQL)
		end try
		begin catch
			select @ErrorMessage = ERROR_MESSAGE(),
				@ErrorLine = ERROR_LINE()

			raiserror('Error retrieving pricing data from [%s] database "%s" in line %d', 16, 1, @CloudPricingDatabaseName, @ErrorMessage, @ErrorLine)
			return
		end catch
	END ELSE
	BEGIN
		begin try
			INSERT INTO #Machines
			SELECT 
				m.Tier + ' ' + replace(Size, ' ', '_') /*+ IIF(p.type = 'SQL DBMI Server',' ' + REPLACE(CMB_MachineName,'DBMI_',''),'')*/ MachineName
				,cast(Cores as int) Cores, cast(Ram as decimal(10, 2))*1024 MemoryMB,
				r.Name RegionName, cast(Price as decimal(15, 3)) Price, p.License ApplicationEdition
				,CASE WHEN p.type = 'SQL Server' THEN 4
					WHEN p.type = 'SQL DBMI Server' THEN 5
					ELSE 1 END AS CLVID
				, CMB_CPUStrenght
				, CMB_NetworkUSpeed
				, CMB_NetworkDSpeed
				, m.Tier AS CM_Cat
				, IIF(m.Name like '%-dtu-%',m.Size,NULL) as DTU
				, m.Disk
				, p.[Type]
			FROM 
				#VirtualMachine AS m
				inner join #VirtualMachinePrice AS p ON p.VmId = m.Id
				inner join #Region AS r on r.Id = p.RegionId

			WHERE
				p.[Type] in ('Windows', 'SQL Server','SQL DBMI Server')
				and (
						License in ('SQL Standard', 'SQL Enterprise', 'SQL Web')
						or License is null
					)
				AND NOT (p.[Type] = 'SQL DBMI Server' AND  m.Name LIKE '%gen_-software-%')
		end try
		begin catch
			select @ErrorMessage = ERROR_MESSAGE(),
				@ErrorLine = ERROR_LINE()

			raiserror('Error retrieving pricing data from [%s] database "%s" in line %d', 16, 1, @CloudPricingDatabaseName, @ErrorMessage, @ErrorLine)
			return
		end catch
	END

	UPDATE	#Machines 
	SET		ApplicationEdition = 'SQL Enterprise'
			
	WHERE	CLVID in (4, 5)

	begin try
		begin transaction

		
		insert into Consolidation.CloudRegions
		select distinct row_number() over(order by RegionName) + MaxID RegionID, CLVID, 1, RegionName, null
		from (select distinct RegionName,CLVID from #Machines) m
			cross join (select max(CRG_ID) MaxID from Consolidation.CloudRegions) r
		where not exists (select *
							from Consolidation.CloudRegions
							where CRG_CLV_ID = CLVID
								and CRG_Name = RegionName collate database_default)

		;with CloudMachines AS 
		(
			SELECT 
					DISTINCT 
					MachineName	
					,MAX(Cores) AS Cores
					,MemoryMB	
					,CLVID	
					,CPUStrenght	
					,NetworkUSpeed	
					,NetworkDSpeed	
					,CMG_ID AS CM_Cat	
					,DTU	
					,MAX(VM_Disk) AS VM_Disk
			
			FROM	#Machines
			LEFT JOIN Consolidation.CloudMachineCategories ON CM_Cat = CMG_Name
			GROUP BY MachineName	
					
					,MemoryMB	
					,CLVID	
					,CPUStrenght	
					,NetworkUSpeed	
					,NetworkDSpeed	
					,CMG_ID
					,DTU	
					
		)
		
		MERGE  Consolidation.CloudMachineTypes cm
			using CloudMachines m on cm.CMT_CLV_ID = m.CLVID AND cm.CMT_Name = m.MachineName
		when matched AND CPUStrenght <> CMT_CPUStrength then update set
			CMT_CoreCount					= Cores
			,CMT_CPUStrength				= CPUStrenght
			,CMT_MemoryMB					= MemoryMB
			,CMT_NetworkSpeedDownloadMbit	= NetworkUSpeed
			,CMT_NetworkSpeedUploadMbit		= NetworkDSpeed
			,CMT_CMG_ID						= CM_Cat
			,CMT_DTUs						= DTU
			,CMT_MaxStorageGB				= VM_Disk

		when not matched then insert(CMT_CLV_ID,CMT_Name,CMT_CPUName,CMT_CoreCount,CMT_CPUStrength,CMT_MemoryMB,CMT_NetworkSpeedDownloadMbit,CMT_NetworkSpeedUploadMbit,CMT_CMG_ID,CMT_DTUs,CMT_MaxStorageGB,CMT_IsActive)				
		VALUES(CLVID,MachineName,NULL,Cores,CPUStrenght,MemoryMB,NetworkUSpeed,NetworkDSpeed,CM_Cat,DTU,VM_Disk,1)
		
		
		 
--		 rollback
		--select * from Consolidation.CloudMachineTypes

		;with NewPrices as
				(
					select CRG_ID, CMT_ID, CHE_ID, Price, CASE WHEN CLVID = 1 THEN 4 WHEN CLVID = 5 THEN 100 ELSE NULL END Storage_BUL_ID, CHE_CHA_ID AS CHA_ID
					from #Machines
						inner join Consolidation.CloudMachineTypes on CMT_CLV_ID = CLVID
																		and CMT_Name = MachineName
						inner join Consolidation.CloudRegions on CRG_CLV_ID = CLVID
																	and CRG_Name = RegionName collate database_default
						left join Consolidation.CloudHostedApplicationEditions on CHE_CHA_ID = 1--CHA_ID/*1
																					and 'SQL ' + CHE_Name = ApplicationEdition collate database_default 


					WHERE	CLVID IN (1,4)
					UNION ALL
					select CRG_ID, CMT_ID, NULL AS CHE_ID, Price, CASE WHEN CLVID = 1 THEN 4 WHEN CLVID = 5 THEN 100 ELSE NULL END Storage_BUL_ID, CHA_ID AS CHA_ID
					from #Machines
						inner join Consolidation.CloudMachineTypes on CMT_CLV_ID = CLVID
																		and CMT_Name = MachineName
						inner join Consolidation.CloudRegions on CRG_CLV_ID = CLVID
																	and CRG_Name = RegionName collate database_default
						left join Consolidation.CloudHostedApplications ON CHA_Name LIKE SUBSTRING(Machinetype,1,CHARINDEX(' ',Machinetype)-1) + ' %' OR CHA_Name LIKE '% ' + SUBSTRING(Machinetype,1,CHARINDEX(' ',Machinetype)-1) + ' %'
						


					WHERE	CLVID = 5
					
						
				)
			, SSDMachines as
				(select CMP_CMT_ID, CMP_Storage_BUL_ID BUL_ID, iif(count(distinct CMP_CRG_ID)*100/RegionCount > 60, 1, 0) IsForAll, CMP_CHA_ID
					from Consolidation.CloudMachinePricing
						cross join (select count(*) RegionCount from Consolidation.CloudRegions where CRG_CLV_ID = 1) r
					where CMP_Storage_BUL_ID in (5, 12, 13)
					group by CMP_CMT_ID, CMP_Storage_BUL_ID, RegionCount,CMP_CHA_ID
				)
			, AllPrices as
				(select *
					from NewPrices
					union
					select CRG_ID, CMT_ID, CHE_ID, Price, BUL_ID Storage_BUL_ID, CHA_ID
					from NewPrices
						inner join SSDMachines on CMT_ID = CMP_CMT_ID
					where IsForAll = 1
						or exists (select *
									from Consolidation.CloudMachinePricing
									where CMP_CMT_ID = CMT_ID
										and CMP_CRG_ID = CRG_ID
										and CMP_Storage_BUL_ID = BUL_ID
								)
				)

		SELECT 
				*
		INTO	#AllPrices
		FROM	AllPrices

		--select * from #AllPrices order by crg_id,cmt_id,cha_id,che_id,storage_bul_id,price
		
		IF NOT EXISTS (SELECT * FROM #AllPrices)
			Raiserror('There are no AZURE prices. Please contact DBMSys Support Team',16,1)

		merge Consolidation.CloudMachinePricing d
			using #AllPrices s
				on CMP_CRG_ID = CRG_ID
					and CMP_CMT_ID = CMT_ID
					and CMP_OST_ID = 1
					and (CMP_CHE_ID = CHE_ID
							or (CMP_CHE_ID is null
								and CHE_ID is null
								)
						)
					and CMP_Storage_BUL_ID = Storage_BUL_ID
					AND (CMP_CHA_ID = CHA_ID
						OR	(
								CMP_CHA_ID IS NULL 
								AND CHA_ID IS NULL
							)
						)
							
			when matched /*and CMP_HourlyPaymentUSD <> Price*/ then update set
									CMP_HourlyPaymentUSD = Price,
									CMP_EffectiveHourlyPaymentUSD = Price
			when not matched then insert(CMP_CRG_ID, CMP_CMT_ID, CMP_CRL_ID, CMP_OST_ID, CMP_CHE_ID, CMP_CPM_ID, CMP_UpfrontPaymnetUSD, CMP_MonthlyPaymentUSD, CMP_HourlyPaymentUSD, CMP_EffectiveHourlyPaymentUSD, CMP_Storage_BUL_ID, CMP_CHA_ID)
									values(CRG_ID, CMT_ID, null, 1, CHE_ID, 1, 0, 0, Price, Price, Storage_BUL_ID, CHA_ID)
			WHEN NOT MATCHED BY SOURCE AND exists (select * from Consolidation.CloudMachineTypes CM WHERE CM.CMT_ID = d.CMP_CMT_ID AND CM.CMT_CLV_ID IN (1,4))
				THEN DELETE ;


		INSERT INTO Consolidation.CloudMachineStorageCompatibility(CMC_CMT_ID,CMC_Storage_BUL_ID,CMC_MaxDiskCount)
		SELECT 
				CMT_ID
				,100
				,255 
		FROM	Consolidation.CloudMachineTypes 
		WHERE	CMT_CLV_ID = 5
				AND	NOT EXISTS (SELECT * FROM Consolidation.CloudMachineStorageCompatibility WHERE CMC_CMT_ID = CMT_ID)


		insert into #Alerts
		select distinct MachineName, 'Does not exist in database' Note
		from #Machines
		where not exists (select *
							from Consolidation.CloudMachineTypes
							where CMT_CLV_ID = 1
								and CMT_Name = MachineName
						)
		union all
		select distinct MachineName,
			stuff(
			concat(iif(CMT_CoreCount <> Cores, concat(', Core count difference, (current = ', CMT_CoreCount, ', new = ', Cores, ')'), ''),
					iif(CMT_MemoryMB <> MemoryMB, concat(', Memory amount difference, (current = ', CMT_MemoryMB, ', new = ', MemoryMB, ')'), ''))
					, 1, 2, '')
		from #Machines
			left join Consolidation.CloudMachineTypes on CMT_CLV_ID = 1
														and CMT_Name = MachineName
		where CMT_CoreCount <> Cores
				or CMT_MemoryMB <> MemoryMB

				
		commit tran
		--rollback
		--select 'Machine prices updated successfully!' Result
	end try
	begin catch
		select @ErrorMessage = ERROR_MESSAGE(),
			@ErrorLine = ERROR_LINE()

		if @@trancount > 0
			rollback

		raiserror('Error updating machine prices "%s" in line %d', 16, 1, @ErrorMessage, @ErrorLine)
	end catch

	
IF @XML_AzurePricing IS NULL
	BEGIN

		set @SQL = '
		DECLARE @BULID INT
		SELECT @BULID = MAX(BUL_ID) FROM Consolidation.BillableByUsageItemLevels

		;WITH UsageItemLevels AS 
		(
			SELECT 
					l.*
			FROM	Consolidation.BillableByUsageItemLevels l
			JOIN	Consolidation.BillableByUsageItems ON BUL_BUI_ID = BUI_ID
			WHERE	BUI_Name = ''Storage space''
					AND BUL_CLV_ID = 1
		)
		, sourc AS 
		(
			SELECT 
					ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RN
					,1						AS CLVID
					,''Storage space''		AS BUINAME
					,IIF([Type] LIKE ''%SSD'',''SSD '',''HDD '') + TypeSize	AS BULNAME
					
					,''<Parameters MaxGBPerDisk="'' + CAST(Size as NVARCHAR(10)) + ''" />''AS BULLimitations
					
					,''Calculate all item levels together'' AS BURName
				--	,* 
			FROM	DBMSYS_ADM.Azurepriceloader.PremiumStorage
			WHERE	[Type] like ''%SSD''
		)

		MERGE UsageItemLevels
		USING (
				SELECT 
						RN + @BULID AS RN
						,CLVID
						,BUI_ID AS BUIID
						,BULNAME
						,BULLimitations
						,BUR_ID	AS BURID
				FROM	sourc
				JOIN	Consolidation.BillableByUsageItems ON BUI_Name = BUIName
				JOIN	Consolidation.BillableByUsageItemLevelItemRelationshipTypes ON BUR_Description = BURName
			) s	ON BUL_Name = BULNAME

		WHEN MATCHED AND CAST(BULLimitations AS NVARCHAR(255)) <> CAST(BUL_Limitations AS NVARCHAR(255)) THEN UPDATE
		SET 
				BUL_Limitations	= BULLimitations
				,BUL_IsActive	= 1
									
		WHEN NOT MATCHED THEN INSERT(BUL_ID,BUL_CLV_ID, BUL_BUI_ID, BUL_Name, BUL_UnitName, BUL_Limitations, BUL_IsActive, BUL_BUR_ID)
		VALUES(RN,CLVID, BUIID, BULName, ''GB'', BULLimitations, 1, BURID);
		
		/*WHEN NOT MATCHED BY SOURCE AND BUL_IsActive = 1	THEN UPDATE
		SET
			BUL_IsActive = 0;*/'

		BEGIN TRY
			
			PRINT @SQL
			EXEC	(@SQL)
			
		END TRY
		BEGIN CATCH
			SELECT 
				@ErrorMessage = ERROR_MESSAGE()
				,@ErrorLine = ERROR_LINE()

			raiserror('Error updating premium storages "%s" in line %d', 16, 1, @ErrorMessage, @ErrorLine)
		end catch

	END 
		ELSE
	BEGIN
		BEGIN TRY
			DECLARE @BULID INT
			SELECT @BULID = MAX(BUL_ID) FROM Consolidation.BillableByUsageItemLevels

			;WITH UsageItemLevels AS 
			(
				SELECT 
						l.*
				FROM	Consolidation.BillableByUsageItemLevels l
				JOIN	Consolidation.BillableByUsageItems ON BUL_BUI_ID = BUI_ID
				WHERE	BUI_Name = 'Storage space'
						AND BUL_CLV_ID = 1
			)
			, sourc AS 
			(
				SELECT 
						ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RN
						,1						AS CLVID
						,'Storage space'		AS BUINAME
						,IIF([Type] LIKE '%SSD','SSD ','HDD ') + TypeSize	AS BULNAME
					
						,'<Parameters MaxGBPerDisk="' + CAST(Size as NVARCHAR(10)) + '" />'AS BULLimitations
					
						,'Calculate all item levels together' AS BURName
					--	,* 
				FROM	#PremiumStorage
				WHERE	[Type] like '%SSD'
			)

			MERGE UsageItemLevels
			USING (
					SELECT 
							RN + @BULID AS RN
							,CLVID
							,BUI_ID AS BUIID
							,BULNAME
							,BULLimitations
							,BUR_ID	AS BURID
					FROM	sourc
					JOIN	Consolidation.BillableByUsageItems ON BUI_Name = BUIName
					JOIN	Consolidation.BillableByUsageItemLevelItemRelationshipTypes ON BUR_Description = BURName
				) s	ON BUL_Name = BULNAME

			WHEN MATCHED AND CAST(BULLimitations AS NVARCHAR(255)) <> CAST(BUL_Limitations AS NVARCHAR(255)) THEN UPDATE
			SET 
					BUL_Limitations	= BULLimitations
					,BUL_IsActive	= 1
									
			WHEN NOT MATCHED THEN INSERT(BUL_ID,BUL_CLV_ID, BUL_BUI_ID, BUL_Name, BUL_UnitName, BUL_Limitations, BUL_IsActive, BUL_BUR_ID)
			VALUES(RN,CLVID, BUIID, BULName, 'GB', BULLimitations, 1, BURID);
		END TRY
		BEGIN CATCH
			rollback tran
			SELECT 
				@ErrorMessage = ERROR_MESSAGE()
				,@ErrorLine = ERROR_LINE()

			raiserror('Error updating premium storages "%s" in line %d', 16, 1, @ErrorMessage, @ErrorLine)
		end catch
	END

	IF @XML_AzurePricing IS NULL
	BEGIN
		set @SQL =
		';with StorageTranData as
			(select top 1 cast(TransactionPrice as decimal(15, 10)) Price
				from ' + quotename(@CloudPricingDatabaseName) + '.' + quotename(@AzurePricingSchemaName) + '.Storage s
				where TypeDescription = ''Page Blob and Disk''
					and Redundancy in (''LRS'')
			)
		update p
		set BUP_PricePerUnit = (select Price from StorageTranData)
		from Consolidation.BillableByUsageItems
			inner join Consolidation.BillableByUsageItemLevels on BUL_BUI_ID = BUI_ID
			inner join Consolidation.BillableByUsageItemLevelPricingScheme p on BUP_BUL_ID = BUL_ID
		where BUI_Name = ''Storage transactions''
			and BUL_CLV_ID = 1'

		begin try
			exec(@SQL)
			--select 'Storage Transaction prices updated successfully!' Result
		end try
		begin catch
			select @ErrorMessage = ERROR_MESSAGE(),
				@ErrorLine = ERROR_LINE()

			raiserror('Error updating storage transaction prices "%s" in line %d', 16, 1, @ErrorMessage, @ErrorLine)
		end catch
	END ELSE
	BEGIN
		BEGIN TRY
			;with StorageTranData as
						(select top 1 cast(TransactionPrice as decimal(15, 10)) Price
							from #Storage s
							where TypeDescription = 'Page Blob and Disk'
								and Redundancy in ('LRS')
						)
			update p
			set BUP_PricePerUnit = (select Price from StorageTranData)
			from Consolidation.BillableByUsageItems
				inner join Consolidation.BillableByUsageItemLevels on BUL_BUI_ID = BUI_ID
				inner join Consolidation.BillableByUsageItemLevelPricingScheme p on BUP_BUL_ID = BUL_ID
			where BUI_Name = 'Storage transactions'
				and BUL_CLV_ID = 1
		END TRY
		BEGIN CATCH
			select @ErrorMessage = ERROR_MESSAGE(),
				@ErrorLine = ERROR_LINE()

			raiserror('Error updating storage transaction prices "%s" in line %d', 16, 1, @ErrorMessage, @ErrorLine)
		END CATCH
	END

	IF @XML_AzurePricing IS NULL
	BEGIN
		set @SQL =
		';with StoragePricing as
				(select distinct s.Tier, s.Redundancy, Limit, r.Name RegionName, cast(Price as decimal(15, 10)) Price
					from ' + quotename(@CloudPricingDatabaseName) + '.' + quotename(@AzurePricingSchemaName) + '.Storage s
						inner join ' + quotename(@CloudPricingDatabaseName) + '.' + quotename(@AzurePricingSchemaName) + '.StoragePrice p on p.StorageId = s.Id
						inner join ' + quotename(@CloudPricingDatabaseName) + '.' + quotename(@AzurePricingSchemaName) + '.StorageLimit l on l.Id = p.LimitId
						inner join ' + quotename(@CloudPricingDatabaseName) + '.' + quotename(@AzurePricingSchemaName) + '.Region r on r.Id = p.RegionId
					where TypeDescription = ''Page Blob and Disk''
						and Redundancy in (''LRS'', ''GRS'')
				)
		merge Consolidation.BillableByUsageItemLevelPricingScheme d
			using (select BUL_ID, CSL_ID, CRG_ID, Limit, Price
						from StoragePricing s
							inner join (Consolidation.BillableByUsageItems
											inner join Consolidation.BillableByUsageItemLevels on BUL_BUI_ID = BUI_ID)
									on BUI_Name = ''Storage space''
										and BUL_CLV_ID = 1
										and (Tier = ''Basic''
												and BUL_Name in (''Standard'', ''Basic storage space'')
											)
							inner join Consolidation.CloudStorageRedundancyLevels on CSL_Name like ''%('' + Redundancy + '')'' collate database_default
							inner join Consolidation.CloudRegions on CRG_CLV_ID = 1
																		and CRG_Name = RegionName collate database_default
					) s
				on BUP_BUL_ID = BUL_ID
					and BUP_CSL_ID = CSL_ID
					and BUP_CRG_ID = CRG_ID
					and Limit = BUP_UpToNumberOfUnits
				when matched and BUP_PricePerUnit <> Price then update
								set BUP_PricePerUnit = Price
				when not matched then insert(BUP_BUL_ID, BUP_CSL_ID, BUP_CRG_ID, BUP_UpToNumberOfUnits, BUP_PricePerUnit)
										values(BUL_ID, CSL_ID, CRG_ID, Limit, Price);'

		begin try
			exec(@SQL)
			--select 'Storage prices updated successfully!' Result
		end try
		begin catch
			select @ErrorMessage = ERROR_MESSAGE(),
				@ErrorLine = ERROR_LINE()

			raiserror('Error updating storage prices "%s" in line %d', 16, 1, @ErrorMessage, @ErrorLine)
		end catch
	END ELSE
	BEGIN
		BEGIN TRY
			;with StoragePricing as
							(select distinct s.Tier, s.Redundancy, Limit, r.Name RegionName, cast(Price as decimal(15, 10)) Price
								from #Storage s
									inner join #StoragePrice p on p.StorageId = s.Id
									inner join #StorageLimit l on l.Id = p.LimitId
									inner join #Region r on r.Id = p.RegionId
								where TypeDescription = 'Page Blob and Disk'
									and Redundancy in ('LRS', 'GRS')
							)
			merge Consolidation.BillableByUsageItemLevelPricingScheme d
			using (select BUL_ID, CSL_ID, CRG_ID, Limit, Price
						from StoragePricing s
							inner join (Consolidation.BillableByUsageItems
											inner join Consolidation.BillableByUsageItemLevels on BUL_BUI_ID = BUI_ID)
									on BUI_Name = 'Storage space'
										and BUL_CLV_ID = 1
										and (Tier = 'Basic'
												and BUL_Name in ('Standard', 'Basic storage space')
											)
							inner join Consolidation.CloudStorageRedundancyLevels on CSL_Name like '%(' + Redundancy + ')' collate database_default
							inner join Consolidation.CloudRegions on CRG_CLV_ID = 1
																		and CRG_Name = RegionName collate database_default
					) s
				on BUP_BUL_ID = BUL_ID
					and BUP_CSL_ID = CSL_ID
					and BUP_CRG_ID = CRG_ID
					and Limit = BUP_UpToNumberOfUnits
				when matched and BUP_PricePerUnit <> Price then update
								set BUP_PricePerUnit = Price
				when not matched then insert(BUP_BUL_ID, BUP_CSL_ID, BUP_CRG_ID, BUP_UpToNumberOfUnits, BUP_PricePerUnit)
										values(BUL_ID, CSL_ID, CRG_ID, Limit, Price);
		END TRY
		BEGIN CATCH
			select @ErrorMessage = ERROR_MESSAGE(),
				@ErrorLine = ERROR_LINE()

			raiserror('Error updating storage prices "%s" in line %d', 16, 1, @ErrorMessage, @ErrorLine)
		END CATCH

	END

	IF @XML_AzurePricing IS NULL
	BEGIN
		set @SQL =
		';with StoragePricing as
				(select distinct s.[TypeSize] Name, r.Name RegionName, p.Price/s.Size Price
					from ' + quotename(@CloudPricingDatabaseName) + '.' + quotename(@AzurePricingSchemaName) + '.PremiumStoragePrice p
						inner join ' + quotename(@CloudPricingDatabaseName) + '.' + quotename(@AzurePricingSchemaName) + '.PremiumStorage s on s.Id = p.PremiumStorageId
						inner join ' + quotename(@CloudPricingDatabaseName) + '.' + quotename(@AzurePricingSchemaName) + '.Region r on r.Id = p.RegionId
					WHERE s.[Type] <> ''unmanaged-disks''
				)
		merge Consolidation.BillableByUsageItemLevelPricingScheme d
			using (select BUL_ID, CRG_ID, Price
						from StoragePricing
							inner join (Consolidation.BillableByUsageItems
										inner join Consolidation.BillableByUsageItemLevels on BUL_BUI_ID = BUI_ID
																							and BUI_Name = ''Storage space''
																							and BUL_CLV_ID = 1) on BUL_Name = ''SSD '' + Name collate database_default
							inner join Consolidation.CloudRegions on CRG_CLV_ID = 1
																		and CRG_Name = RegionName collate database_default
					) s
				on BUP_BUL_ID = BUL_ID
					and BUP_CRG_ID = CRG_ID
				when matched and BUP_PricePerUnit <> Price then update
								set BUP_PricePerUnit = Price
				when not matched then insert(BUP_BUL_ID, BUP_CRG_ID, BUP_PricePerUnit)
										values(BUL_ID, CRG_ID, Price);'
		begin try
			print '*************************************************************'
			PRINT @SQL
			exec(@SQL)
			--select 'Premium storage prices updated successfully!' Result
		end try
		begin catch
			select @ErrorMessage = ERROR_MESSAGE(),
				@ErrorLine = ERROR_LINE()

			raiserror('Error updating premium storage prices "%s" in line %d', 16, 1, @ErrorMessage, @ErrorLine)
		end catch
	END ELSE
	BEGIN

		
		BEGIN TRY
			;with StoragePricing as
							(select distinct s.[TypeSize] Name, r.Name RegionName, p.Price/s.Size Price
								from #PremiumStoragePrice p
									inner join #PremiumStorage s on s.Id = p.PremiumStorageId
									inner join #Region r on r.Id = p.RegionId
							)
			merge Consolidation.BillableByUsageItemLevelPricingScheme d
				using (select BUL_ID, CRG_ID, Price
							from StoragePricing
								inner join (Consolidation.BillableByUsageItems
											inner join Consolidation.BillableByUsageItemLevels on BUL_BUI_ID = BUI_ID
																								and BUI_Name = 'Storage space'
																								and BUL_CLV_ID = 1) on BUL_Name = 'SSD ' + Name collate database_default
								inner join Consolidation.CloudRegions on CRG_CLV_ID = 1
																			and CRG_Name = RegionName collate database_default
						) s
					on BUP_BUL_ID = BUL_ID
						and BUP_CRG_ID = CRG_ID
					when matched and BUP_PricePerUnit <> Price then update
									set BUP_PricePerUnit = Price
					when not matched then insert(BUP_BUL_ID, BUP_CRG_ID, BUP_PricePerUnit)
											values(BUL_ID, CRG_ID, Price);
		END TRY
		BEGIN CATCH
			select @ErrorMessage = ERROR_MESSAGE(),
				@ErrorLine = ERROR_LINE()

			raiserror('Error updating premium storage prices "%s" in line %d', 16, 1, @ErrorMessage, @ErrorLine)
		END CATCH

	END

	IF @XML_AzurePricing IS NULL
	BEGIN
		set @SQL =
		';with NetworkPricing as
				(select Limit, r.Name RegionName, cast(Price as decimal(15, 10)) Price
					from ' + quotename(@CloudPricingDatabaseName) + '.' + quotename(@AzurePricingSchemaName) + '.NetworkPrice n
						inner join ' + quotename(@CloudPricingDatabaseName) + '.' + quotename(@AzurePricingSchemaName) + '.NetworkLimit l on l.Id = n.LimitId
						inner join ' + quotename(@CloudPricingDatabaseName) + '.' + quotename(@AzurePricingSchemaName) + '.Region r on r.Id = n.RegionId
				)
		merge Consolidation.BillableByUsageItemLevelPricingScheme d
			using (select BUL_ID, CRG_ID, Limit, Price
						from NetworkPricing s
							inner join (Consolidation.BillableByUsageItems
											inner join Consolidation.BillableByUsageItemLevels on BUL_BUI_ID = BUI_ID)
									on BUI_Name = ''Network usage''
										and BUL_CLV_ID = 1
										and BUL_Name = ''Basic outbound network traffic''
							inner join Consolidation.CloudRegions on CRG_CLV_ID = 1
																		and CRG_Name = RegionName collate database_default
					) s
				on BUP_BUL_ID = BUL_ID
					and BUP_CRG_ID = CRG_ID
					and Limit = BUP_UpToNumberOfUnits
				when matched and BUP_PricePerUnit <> Price then update
								set BUP_PricePerUnit = Price
				when not matched then insert(BUP_BUL_ID, BUP_CRG_ID, BUP_UpToNumberOfUnits, BUP_PricePerUnit)
										values(BUL_ID, CRG_ID, Limit, Price);'

		begin try
			exec(@SQL)
			--select 'Network prices updated successfully!' Result
		end try
		begin catch
			select @ErrorMessage = ERROR_MESSAGE(),
				@ErrorLine = ERROR_LINE()

			raiserror('Error updating network prices "%s" in line %d', 16, 1, @ErrorMessage, @ErrorLine)
		end catch
	END ELSE
	BEGIN
		BEGIN TRY
			;with NetworkPricing as
					(select Limit, r.Name RegionName, cast(Price as decimal(15, 10)) Price
						from #NetworkPrice n
							inner join #NetworkLimit l on l.Id = n.LimitId
							inner join #Region r on r.Id = n.RegionId
					)
			merge Consolidation.BillableByUsageItemLevelPricingScheme d
				using (select BUL_ID, CRG_ID, Limit, Price
							from NetworkPricing s
								inner join (Consolidation.BillableByUsageItems
												inner join Consolidation.BillableByUsageItemLevels on BUL_BUI_ID = BUI_ID)
										on BUI_Name = 'Network usage'
											and BUL_CLV_ID = 1
											and BUL_Name = 'Basic outbound network traffic'
								inner join Consolidation.CloudRegions on CRG_CLV_ID = 1
																			and CRG_Name = RegionName collate database_default
						) s
					on BUP_BUL_ID = BUL_ID
						and BUP_CRG_ID = CRG_ID
						and Limit = BUP_UpToNumberOfUnits
					when matched and BUP_PricePerUnit <> Price then update
									set BUP_PricePerUnit = Price
					when not matched then insert(BUP_BUL_ID, BUP_CRG_ID, BUP_UpToNumberOfUnits, BUP_PricePerUnit)
											values(BUL_ID, CRG_ID, Limit, Price);

		END TRY
		BEGIN CATCH
			select @ErrorMessage = ERROR_MESSAGE(),
				@ErrorLine = ERROR_LINE()

			raiserror('Error updating network prices "%s" in line %d', 16, 1, @ErrorMessage, @ErrorLine)
		END CATCH
	END

	if exists (select *
				from #Alerts
				)
		and @ReturnResults = 1
	begin
		select 'Please handle the following:' Alert

		select *
		from #Alerts
	end
GO
