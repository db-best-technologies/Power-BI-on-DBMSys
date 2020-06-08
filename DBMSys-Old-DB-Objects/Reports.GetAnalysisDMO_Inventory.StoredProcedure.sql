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
/****** Object:  StoredProcedure [Reports].[GetAnalysisDMO_Inventory]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reports].[GetAnalysisDMO_Inventory]
--DECLARE
	@DSUGUID	UNIQUEIDENTIFIER 
AS
BEGIN
	set nocount on
	DECLARE 
			@AdmDB NVARCHAR(255)

	SELECT  
			@AdmDB = CAST(SET_Value AS NVARCHAR(255))
	FROM	Management.Settings 
	where	SET_Key = 'Cloud Pricing Database Name'

	DECLARE @CMD NVARCHAR(MAX)

	IF OBJECT_ID('tempdb..#IsLiteDMO') IS NOT NULL
		DROP TABLE #IsLiteDMO

	CREATE TABLE #IsLiteDMO
	(
		DMOName Nvarchar(255)
	)

	SET @CMD = 'SELECT 
						DMO_Name
				FROM	' + @AdmDB + '.dbo.DBMSysUnits 
				LEFT JOIN	' + @AdmDB + '.dbo.DMOTypes ON DSU_DMO_ID = DMO_ID
				WHERE	DSU_GUID = ''' + CAST(@DSUGUID AS NVARCHAR(50))  + ''''

	INSERT INTO #IsLiteDMO(DMOName)
	EXEC (@CMD)

	declare @DiskIOBufferPercentage int,
			@DiskSizeBufferPercentage int

	IF EXISTS (SELECT * FROM #IsLiteDMO WHERE DMOName = 'Light DMO')
	BEGIN

		SET @CMD = 'EXEC ' + @AdmDB + '.dbo.usp_UpdateProcessingStatus ''' + CAST(@DSUGUID AS NVARCHAR(50)) + ''',6,''Upload DMO Data to AnalysisDB'''

		EXEC (@CMD)

		update Management.Settings
		set SET_Value = iif(exists (select * from Management.DefinedObjects inner join Management.PlatformTypes on PLT_ID = DFO_PLT_ID where PLT_PLC_ID = 2), 1, 0)
		where SET_Module = 'Consolidation'
			and SET_Key = 'Consider servers without a database instance'

		update Management.Settings
		set SET_Value = 5
		where SET_Module = 'Consolidation'
			and SET_Key = 'CPU Buffer Percentage'

		update Management.Settings
		set SET_Value = 5
		where SET_Module = 'Consolidation'
			and SET_Key = 'Disk IO Buffer Percentage'

		update Management.Settings
		set SET_Value = 5
		where SET_Module = 'Consolidation'
			and SET_Key = 'Disk Size Buffer Percentage'

		update Management.Settings
		set SET_Value = 5
		where SET_Module = 'Consolidation'
			and SET_Key = 'Memory Buffer Percentage'

		update Management.Settings
		set SET_Value = 5
		where SET_Module = 'Consolidation'
			and SET_Key = 'Network Speed Buffer Percentage'

		update Management.Settings
		set SET_Value = 80
		where SET_Module = 'Consolidation'
			and SET_Key = 'CPU Cap Percentage'

		update Management.Settings
		set SET_Value = 80
		where SET_Module = 'Consolidation'
			and SET_Key = 'Disk IO Cap Percentage'

		update Management.Settings
		set SET_Value = 80
		where SET_Module = 'Consolidation'
			and SET_Key = 'Disk Size Cap Percentage'

		update Management.Settings
		set SET_Value = 90
		where SET_Module = 'Consolidation'
			and SET_Key = 'Memory Cap Percentage'

		update Management.Settings
		set SET_Value = 90
		where SET_Module = 'Consolidation'
			and SET_Key = 'Network Speed Cap Percentage'

		update Management.Settings
		set SET_Value = 'Microsoft Azure VM (IaaS),Amazon EC2'
		where SET_Module = 'Consolidation'
			and SET_Key = 'Ignore network bandwidth for cloud provider names'

		update Management.Settings
		set SET_Value = 0
		where SET_Module = 'Consolidation'
			and SET_Key = 'Include Availability Group Secondaries'
	
		exec Consolidation.usp_CheckCPUInfo @ReportMissingCPUsToAdm = 1
		if @@ERROR <> 0 return
		exec Consolidation.usp_DiscoverCollectionExceptions @CompensateWithCapacityForMissingPerformance = 1,
															@ReturnResults = 0
		exec Consolidation.usp_PopulateParticipatingDatabaseServers

		truncate table Consolidation.ConsolidationGroups
		insert into Consolidation.ConsolidationGroups
		values(1, 'General')

		truncate table Consolidation.ServerGrouping
		insert into Consolidation.ServerGrouping
		select distinct PDS_Server_MOB_ID, 1
		from Consolidation.ParticipatingDatabaseServers

		truncate table Consolidation.ConsolidationGroups_CloudRegions
		insert into Consolidation.ConsolidationGroups_CloudRegions
		select 1, CRG_ID
		from Consolidation.CloudRegions
		where CRG_ID in (3, 18)

		truncate table Consolidation.ServerPossibleHostTypes
		insert into Consolidation.ServerPossibleHostTypes(SHT_MOB_ID, SHT_HST_ID)
		select MOB_ID, HST_ID
		from Consolidation.HostTypes
			cross join (select distinct PDS_Server_MOB_ID MOB_ID from Consolidation.ParticipatingDatabaseServers) p
		where HST_ID in (5, 7, 1)

		exec Consolidation.usp_CalculateMachineActivity
		exec Consolidation.usp_AggregateDiskInfo @ReturnResults = 0
		exec Consolidation.usp_CalculateWorkloads @ReturnResults = 0
		exec Consolidation.usp_UpdateAllCloudPricing @ReturnResults = 0
		exec Consolidation.usp_PopulatePossibleHostsAndLoadBlocks

		truncate table Consolidation.WarningMessages

		IF OBJECT_ID('tempdb..#WarningMessages') IS NOT NULL
			DROP TABLE #WarningMessages

		CREATE TABLE #WarningMessages
			(
				WMS_MOB_ID			int NOT NULL,
				WMS_WarningMessage	varchar(1000) NOT NULL
			)



		insert into Consolidation.LoadBlocks(LBL_CGR_ID, LBL_MOB_ID, LBL_OST_ID, LBL_CHA_ID, LBL_CHE_ID, LBL_CPUStrength, LBL_MemoryMB, LBL_DiskSize, LBL_BlockSize, LBL_ReadsSec,
												LBL_ReadsMBSec, LBL_WritesSec, LBL_WritesMBSec, LBL_NetworkUsageDownloadMbit, LBL_NetworkUsageUploadMbit, LBL_MonthlyDiskIOPS,
												LBL_MonthlyNetworkOutboundMB, LBL_MonthlyNetworkInboundMB, LBL_SQLInstanceCount, LBL_IsVM)
		output inserted.LBL_MOB_ID, 
			'Due to missing performance data, capacity data has been used where possible. '
			+ iif(inserted.LBL_MonthlyDiskIOPS = 0, ' A value of 0 was used for disk Utilization.', '')
			+ iif(inserted.LBL_MonthlyNetworkOutboundMB = 0 and inserted.LBL_MonthlyNetworkInboundMB = 0, ' A value of 0 was used for network Utilization.', '')
		into #WarningMessages(WMS_MOB_ID, WMS_WarningMessage)
		select 1 CGR_ID, PSH_MOB_ID, PSH_OST_ID, PSH_CHA_ID, PSH_CHE_ID, PSH_CPUStrength, PSH_MemoryMB, coalesce(UsedSpace, DiskSizeMB, 0) DiskSize, isnull(DominantBlockSize, 8) DiskBlockSize,
			isnull(TotalFileReads, 0) ReadsSec, isnull(TotalFileReadsMB, 0) ReadMBSec, isnull(TotalFileWrites, 0) WitesSec, isnull(TotalFileWritesMB, 0) WritesMBSec,
			isnull(NetworkUsageDownloadMbit, 0) NetworkUsageDownloadMbit, isnull(NetworkUsageUploadMbit, 0) NetworkUsageUploadMbit, isnull(AvgMonthlyIOPS, 0) MonthlyDiskIOPS,
			isnull(AvgMonthlyNetworkOutboundIOMB, 0) MonthlyNetworkOutboundMB, isnull(AvgMonthlyNetworkInboundIOMB, 0) MonthlyNetworkInboundMB,
			SQLInstances SQLInstanceCount, isnull(IsVM, 0) IsVM
		from Consolidation.PossibleHosts
			outer apply Consolidation.fn_GetResourceUsage(1, 5)
			outer apply (select sum(DSK_TotalSpaceMB) DiskSizeMB
							from Inventory.Disks
							where DSK_MOB_ID = PSH_MOB_ID) ds
		where PSH_HST_ID = 1
			and not exists (select *
							from Consolidation.LoadBlocks
							where LBL_MOB_ID = PSH_MOB_ID)
			AND DominantBlockSize IS NOT NULL

		INSERT INTO Consolidation.WarningMessages(WMS_MOB_ID, WMS_WarningMessage)
		SELECT WMS_MOB_ID, MIN(WMS_WarningMessage) 
		FROM #WarningMessages
		GROUP BY WMS_MOB_ID

		exec Consolidation.usp_ProcessOnPremConsolidationAndCloud @IncludeOnPrem = 0, @PrintOutput = 0
		exec Consolidation.usp_FinalizeCloudProcess @ReturnResults = 0

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

		;with CPUs as
				(select PRS_MOB_ID, max(PSN_Name) PSN_Name, sum(isnull(PRS_NumberOfCores, 1)) MachineCoreCount
					from Inventory.Processors
						inner join Inventory.ProcessorNames on PSN_ID = PRS_PSN_ID
					group by PRS_MOB_ID
				)
		select PRS_MOB_ID, MachineCoreCount, MachineCoreCount*coalesce(Factor, 1) LicensingCores
		into #CoreInfo
		from CPUs
			outer apply (select Factor Factor
							from #MSCoreCountFactor
							where MachineCoreCount = CoreCount
								or (PSN_Name like CPUNamePattern
									and MachineCoreCount >= CPUNamePatternMinCoreCount)
						) f

		select MOB_ID,CLV_Name CloudProvider, MOB_Name OriginalMachineName, CMT_Name VMType, isnull(BUL_Name, '') StorageType, isnull(nullif(DiskCount, 0), 1) DiskCount,
			isnull(OST_Name, '') OperatingSystem,
			isnull(CHA_Name, '') DatabaseEngine,
			isnull(CHE_Name, '') DatabaseEngineEdition,
			cast(CMT_CoreCount as int) NumberOfCores,
			CLB_BasePricePerMonthUSD EffectiveMachineMonthlyCost,
			cast(MAC_PercentActive as decimal(10, 3)) PercentActive,
			cast(CLB_BasePricePerMonthUSD*MAC_PercentActive/100 as decimal(15, 3)) ActivePercentCalculatedPrice,
			isnull(cast(cast(DSI_DataFilesMB/1024. as decimal(10, 2)) as varchar(100)), '') CurrentDataFileSizeGB,
			isnull(cast(cast(DSI_DataFilesMBIn3Years/1024. as decimal(10, 2)) as varchar(100)), '') EstimatedDataFilesGBIn3Years,
			isnull(cast(cast(DSI_LogFilesMB/1024. as decimal(10, 2)) as varchar(100)), '') LogFilesSizeGB,
			isnull(cast(cast(DSI_TempdbMB/1024. as decimal(10, 2)) as varchar(100)), '') TempdbSizeGB,
			isnull(cast(cast((LBL_DiskSize - isnull(DSI_DataFilesMB, 0) - isnull(DSI_LogFilesMB, 0) - isnull(DSI_TempdbMB, 0))/1024. as decimal(10, 2)) as varchar(100)), '') NonSQLDiskSizeGB,
			isnull(cast(ceiling(DII_DataFileTransfers + DII_DataFileTransfers*(@DiskIOBufferPercentage/100.)) as varchar(100)), '') DataFileIOPS,
			isnull(cast(ceiling(DII_LogFileTransfers + DII_LogFileTransfers*(@DiskIOBufferPercentage/100.)) as varchar(100)), '') LogFileIOPS,
			isnull(cast(ceiling(DII_TempdbTransfers + DII_TempdbTransfers*(@DiskIOBufferPercentage/100.)) as varchar(100)), '') TempdbIOPS,
			isnull(cast(TotalIOPS as varchar(100)), '') TotalIOPS,
			WMS_WarningMessage WarningMessage,
			cast(null as varchar(2000)) ReasonCannotBeMigratedToCloud,
			cast(null as varchar(100)) OriginalMachineOperatingSystem,
			cast(null as varchar(100)) OriginalMachineDatabaseEngine,
			cast(null as varchar(100)) OriginalMachineDatabaseEngineEdition,
			cast(null as varchar(100)) OriginalMachineCores,
			cast(null as varchar(2000)) ReasonCannotParticipateInAssessment,
			1 HasCloudMatch,
			0 InAssessment,
			0 MisingData
			,HST_ID
			,HST_Name
		from
			--(
			--	select 
			--			cast(SET_Value as varchar(200)) CustomerName
			--	from	Management.Settings
			--	where	SET_Module = 'Management'
			--			and SET_Key = 'Environment Name'
			--) cn 
			--cross join 
			Consolidation.HostTypes
			inner join Consolidation.CloudProviders on CLV_ID = HST_CLV_ID
			inner join Consolidation.ConsolidationBlocks on CLB_HST_ID = HST_ID
			inner join Consolidation.ConsolidationBlocks_LoadBlocks on CBL_CLB_ID = CLB_ID
			inner join Consolidation.LoadBlocks on LBL_ID = CBL_LBL_ID
			cross apply (select ceiling((LBL_ReadsSec+LBL_WritesSec) + (LBL_ReadsMBSec+LBL_WritesMBSec)*(@DiskIOBufferPercentage/100.)) TotalIOPS,
								ceiling((LBL_ReadsMBSec+LBL_WritesMBSec) + (LBL_ReadsMBSec+LBL_WritesMBSec)*(@DiskIOBufferPercentage/100.)) TotalMBPS,
								ceiling(LBL_DiskSize*(@DiskSizeBufferPercentage/100.)) TotalDiskSizeMB
						) r
			inner join Inventory.MonitoredObjects on MOB_ID = LBL_MOB_ID
			inner join Consolidation.PossibleHosts on PSH_ID = CLB_PSH_ID
			left join Consolidation.BillableByUsageItemLevels on BUL_ID = PSH_Storage_BUL_ID
			inner join Consolidation.CloudMachineTypes on CMT_ID = PSH_CMT_ID
			left join Consolidation.OSTypes on OST_ID = CLB_OST_ID
			left join Consolidation.CloudHostedApplications on CHA_ID = CLB_CHA_ID
			left join Consolidation.CloudHostedApplicationEditions on CLB_CHE_ID = CHE_ID
			inner join Consolidation.DiskIOInfo on DII_MOB_ID = LBL_MOB_ID
			inner join Consolidation.DiskInfo on DSI_MOB_ID = LBL_MOB_ID
			inner join Consolidation.MachineActivity on MAC_MOB_ID = LBL_MOB_ID
			left join Consolidation.WarningMessages on WMS_MOB_ID = LBL_MOB_ID
			outer apply (select top 1 CST_DiskCount DiskCount
							from Consolidation.CloudStorageThroughput
							where CST_BUL_ID = BUL_ID
								and BUL_Limitations.value('(Parameters/@MaxGBPerDisk)[1]', 'int')*1024*CST_DiskCount >= TotalDiskSizeMB
								and CST_MaxIOPS8KB >= iif(CLB_DiskBlockSize = 8, TotalIOPS, 0)
								and CST_MaxMBPerSec8KB >= iif(CLB_DiskBlockSize = 8, TotalMBPS, 0)
								and CST_MaxIOPS64KB >= iif(CLB_DiskBlockSize = 64, TotalIOPS, 0)
								and CST_MaxMBPerSec64KB >= iif(CLB_DiskBlockSize = 64, TotalMBPS, 0)
							order by CST_DiskCount) d
		where CLB_DLR_ID is null
			and CBL_DLR_ID is null
		union all
		select DISTINCT MOB_ID,CLV_Name CloudProvider, MOB_Name OriginalMachineName,
			cast(null as varchar(100)) VMType,
			cast(null as varchar(100)) StorageType,
			cast(null as tinyint) DiskCount,
			cast(null as varchar(100)) OperatingSystem,
			cast(null as varchar(100)) DatabaseEngine,
			cast(null as varchar(100)) DatabaseEngineEdition,
			cast(null as int) NumberOfCores,
			cast(null as decimal(15, 3)) EffectiveMachineMonthlyCost,
			cast(null as decimal(10, 3)) PercentActive,
			cast(null as decimal(15, 3)) ActivePercentCalculatedPrice,
			cast(null as varchar(100)) CurrentDataFileSizeGB,
			cast(null as varchar(100)) EstimatedDataFilesGBIn3Years,
			cast(null as varchar(100)) LogFilesSizeGB,
			cast(null as varchar(100)) TempdbSizeGB,
			cast(null as varchar(100)) NonSQLDiskSizeGB,
			cast(null as varchar(100)) DataFileIOPS,
			cast(null as varchar(100)) LogFileIOPS,
			cast(null as varchar(100)) TempdbIOPS,
			cast(null as varchar(100)) TotalIOPS,
			WMS_WarningMessage WarningMessage,
			EXP_Reason ReasonCannotBeMigratedToCloud,
			OST_Name OriginalMachineOperatingSystem,
			isnull(CHA_Name, '') OriginalMachineDatabaseEngine,
			isnull(CHE_Name, '') OriginalMachineDatabaseEngineEdition,
			MachineCoreCount OriginalMachineCores,
			cast(null as varchar(2000)) ReasonCannotParticipateInAssessment,
			0 HasCloudMatch,
			1 InAssessment,
			0 MisingData
			,HST_ID
			,HST_Name
		from 
			--(
			--	select 
			--			cast(SET_Value as varchar(200)) CustomerName
			--	from	Management.Settings
			--	where	SET_Module = 'Management'
			--			and SET_Key = 'Environment Name'
			--) cn 
			--cross join 
			Consolidation.HostTypes
			inner join Consolidation.CloudProviders on CLV_ID = HST_CLV_ID
			cross join Consolidation.LoadBlocks l
			inner join Inventory.MonitoredObjects on MOB_ID = LBL_MOB_ID
			inner join Consolidation.OSTypes on OST_ID = LBL_OST_ID
			left join Consolidation.CloudHostedApplications on CHA_ID = LBL_CHA_ID
			left join Consolidation.CloudHostedApplicationEditions on LBL_CHE_ID = CHE_ID
			left join Consolidation.WarningMessages on WMS_MOB_ID = LBL_MOB_ID
			cross apply (select top 1 EXP_Reason
							from Consolidation.Exceptions
							where EXP_EXT_ID = 3
								and EXP_MOB_ID = MOB_ID
								and EXP_HST_ID = HST_ID
						) e
			inner join #CoreInfo on PRS_MOB_ID = MOB_ID
		where not exists (select *
							from Consolidation.ConsolidationBlocks_LoadBlocks
							where CBL_LBL_ID = LBL_ID
								and CBL_HST_ID = HST_ID)
		union all
		select DISTINCT MOB_ID,CLV_Name CloudProvider, MOB_Name OriginalMachineName,
			cast(null as varchar(100)) VMType,
			cast(null as varchar(100)) StorageType,
			cast(null as tinyint) DiskCount,
			cast(null as varchar(100)) OperatingSystem,
			cast(null as varchar(100)) DatabaseEngine,
			cast(null as varchar(100)) DatabaseEngineEdition,
			cast(null as int) NumberOfCores,
			cast(null as decimal(15, 3)) EffectiveMachineMonthlyCost,
			cast(null as decimal(10, 3)) PercentActive,
			cast(null as decimal(15, 3)) ActivePercentCalculatedPrice,
			cast(null as varchar(100)) CurrentDataFileSizeGB,
			cast(null as varchar(100)) EstimatedDataFilesGBIn3Years,
			cast(null as varchar(100)) LogFilesSizeGB,
			cast(null as varchar(100)) TempdbSizeGB,
			cast(null as varchar(100)) NonSQLDiskSizeGB,
			cast(null as varchar(100)) DataFileIOPS,
			cast(null as varchar(100)) LogFileIOPS,
			cast(null as varchar(100)) TempdbIOPS,
			cast(null as varchar(100)) TotalIOPS,
			cast(null as varchar(1000)) WarningMessage,
			cast(null as varchar(2000)) ReasonCannotBeMigratedToCloud,
			isnull(PLT_Name, '') OriginalMachineOperatingSystem,
			isnull(DatabasePlatformName, '') OriginalMachineDatabaseEngine,
			isnull(DatabaseEdition, '') OriginalMachineDatabaseEngineEdition,
			MachineCoreCount OriginalMachineCores,
			EXP_Reason ReasonCannotParticipateInAssessment,
			0 HasCloudMatch,
			0 InAssessment,
			1 MisingData
			,HST_ID
			,HST_Name
		from 
			--(
			--	select 
			--			cast(SET_Value as varchar(200)) CustomerName
			--	from	Management.Settings
			--	where	SET_Module = 'Management'
			--			and SET_Key = 'Environment Name'
			--) cn 
			--cross join 
			Consolidation.HostTypes
			inner join Consolidation.CloudProviders on CLV_ID = HST_CLV_ID
			cross join Inventory.MonitoredObjects s
			left join Management.PlatformTypes sp on PLT_ID = MOB_PLT_ID
			outer apply (select top 1 dp.PLT_Name DatabasePlatformName, EDT_Name DatabaseEdition
							from Inventory.ParentChildRelationships
								inner join Inventory.MonitoredObjects d on d.MOB_ID = PCR_Child_MOB_ID
								inner join Management.PlatformTypes dp on dp.PLT_ID = d.MOB_PLT_ID
								inner join Inventory.DatabaseInstanceDetails on DID_DFO_ID = d.MOB_Entity_ID
								left join Inventory.Editions on EDT_ID = DID_EDT_ID
							where PCR_Parent_MOB_ID = s.MOB_ID
								and dp.PLT_PLC_ID = 1) c
			cross apply (select top 1 EXP_Reason
							from Consolidation.Exceptions
							where EXP_EXT_ID = 1
								and EXP_MOB_ID = MOB_ID
						) e
			left join #CoreInfo on PRS_MOB_ID = MOB_ID
		where HST_ID in (5, 7)
			and PLT_PLC_ID = 2
			and not exists (select *
							from Consolidation.LoadBlocks
							where LBL_MOB_ID = MOB_ID)
							
	END
	ELSE
	IF EXISTS (SELECT * FROM #IsLiteDMO WHERE DMOName = 'FULL DMO')
	BEGIN
		
		IF OBJECT_ID('tempdb..#CompletedSteps') IS NOT NULL
			DROP TABLE #CompletedSteps
		create table #CompletedSteps
		(
			StepID			INT
			,Ordinal		INT
			,StepName		NVARCHAR(255)
			,StepStatus		NVARCHAR(255)
			,PRH_EndDate	DATETIME

		)

		INSERT INTO #CompletedSteps
		exec CapacityPlanningWizard.usp_GetProcessSteps


		IF NOT EXISTS (SELECT * FROM #CompletedSteps WHERE PRH_EndDate IS NULL OR StepStatus NOT LIKE '%Completed at %')
		BEGIN
				
		if OBJECT_ID('tempdb..#FMSCoreCountFactor') is not null
			drop table #FMSCoreCountFactor

		if OBJECT_ID('tempdb..#FCoreInfo') is not null
			drop table #FCoreInfo

		create table #FMSCoreCountFactor
			(CoreCount int null,
			CPUNamePattern varchar(100) collate database_default null,
			CPUNamePatternMinCoreCount int null,
			Factor decimal(10, 2))
		insert into #FMSCoreCountFactor
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
/*
;with CPU as
				(select PRS_MOB_ID, max(PSN_Name) PSN_Name, sum(isnull(PRS_NumberOfCores, 1)) MachineCoreCount
					from Inventory.Processors
						inner join Inventory.ProcessorNames on PSN_ID = PRS_PSN_ID
					group by PRS_MOB_ID
				)
		select PRS_MOB_ID, MachineCoreCount, MachineCoreCount*coalesce(Factor, 1) LicensingCores
		into #CoreInfo
		from CPUs
			outer apply (select Factor Factor
							from #MSCoreCountFactor
							where MachineCoreCount = CoreCount
								or (PSN_Name like CPUNamePattern
									and MachineCoreCount >= CPUNamePatternMinCoreCount)
						) f
						*/
;with CPUs as
				(select PRS_MOB_ID, max(PSN_Name) PSN_Name, sum(isnull(PRS_NumberOfCores, 1)) MachineCoreCount
					from Inventory.Processors
						inner join Inventory.ProcessorNames on PSN_ID = PRS_PSN_ID
					group by PRS_MOB_ID
				)
		select PRS_MOB_ID, MachineCoreCount, MachineCoreCount*coalesce(Factor, 1) LicensingCores
		into #FCoreInfo
		from CPUs
			outer apply (select Factor Factor
							from #FMSCoreCountFactor
							where MachineCoreCount = CoreCount
								or (PSN_Name like CPUNamePattern
									and MachineCoreCount >= CPUNamePatternMinCoreCount)
						) f

		select DISTINCT 1 as QType, MOB_ID,CLV_Name CloudProvider, MOB_Name OriginalMachineName, CMT_Name VMType, isnull(BUL_Name, '') StorageType, isnull(nullif(DiskCount, 0), 1) DiskCount,
			isnull(OST_Name, '') OperatingSystem,
			isnull(CHA_Name, '') DatabaseEngine,
			isnull(CHE_Name, '') DatabaseEngineEdition,
			cast(CMT_CoreCount as int) NumberOfCores,
			CLB_BasePricePerMonthUSD EffectiveMachineMonthlyCost,
			cast(MAC_PercentActive as decimal(10, 3)) PercentActive,
			cast(CLB_BasePricePerMonthUSD*MAC_PercentActive/100 as decimal(15, 3)) ActivePercentCalculatedPrice,
			isnull(cast(cast(DSI_DataFilesMB/1024. as decimal(10, 2)) as varchar(100)), '') CurrentDataFileSizeGB,
			isnull(cast(cast(DSI_DataFilesMBIn3Years/1024. as decimal(10, 2)) as varchar(100)), '') EstimatedDataFilesGBIn3Years,
			isnull(cast(cast(DSI_LogFilesMB/1024. as decimal(10, 2)) as varchar(100)), '') LogFilesSizeGB,
			isnull(cast(cast(DSI_TempdbMB/1024. as decimal(10, 2)) as varchar(100)), '') TempdbSizeGB,
			isnull(cast(cast((LBL_DiskSize - isnull(DSI_DataFilesMB, 0) - isnull(DSI_LogFilesMB, 0) - isnull(DSI_TempdbMB, 0))/1024. as decimal(10, 2)) as varchar(100)), '') NonSQLDiskSizeGB,
			isnull(cast(ceiling(DII_DataFileTransfers + DII_DataFileTransfers*(@DiskIOBufferPercentage/100.)) as varchar(100)), '') DataFileIOPS,
			isnull(cast(ceiling(DII_LogFileTransfers + DII_LogFileTransfers*(@DiskIOBufferPercentage/100.)) as varchar(100)), '') LogFileIOPS,
			isnull(cast(ceiling(DII_TempdbTransfers + DII_TempdbTransfers*(@DiskIOBufferPercentage/100.)) as varchar(100)), '') TempdbIOPS,
			isnull(cast(TotalIOPS as varchar(100)), '') TotalIOPS,
			WMS_WarningMessage WarningMessage,
			cast(null as varchar(2000)) ReasonCannotBeMigratedToCloud,
			cast(null as varchar(100)) OriginalMachineOperatingSystem,
			cast(null as varchar(100)) OriginalMachineDatabaseEngine,
			cast(null as varchar(100)) OriginalMachineDatabaseEngineEdition,
			cast(null as varchar(100)) OriginalMachineCores,
			cast(null as varchar(2000)) ReasonCannotParticipateInAssessment,
			1 HasCloudMatch,
			0 InAssessment,
			0 MisingData
			,HST_ID
			,HST_Name
		from
			--(
			--	select 
			--			cast(SET_Value as varchar(200)) CustomerName
			--	from	Management.Settings
			--	where	SET_Module = 'Management'
			--			and SET_Key = 'Environment Name'
			--) cn 
			--cross join 
			Consolidation.HostTypes
			inner join Consolidation.CloudProviders on CLV_ID = HST_CLV_ID
			inner join Consolidation.ConsolidationBlocks on CLB_HST_ID = HST_ID
			inner join Consolidation.ConsolidationBlocks_LoadBlocks on CBL_CLB_ID = CLB_ID
			inner join Consolidation.LoadBlocks on LBL_ID = CBL_LBL_ID
			cross apply (select ceiling((LBL_ReadsSec+LBL_WritesSec) + (LBL_ReadsMBSec+LBL_WritesMBSec)*(@DiskIOBufferPercentage/100.)) TotalIOPS,
								ceiling((LBL_ReadsMBSec+LBL_WritesMBSec) + (LBL_ReadsMBSec+LBL_WritesMBSec)*(@DiskIOBufferPercentage/100.)) TotalMBPS,
								ceiling(LBL_DiskSize*(@DiskSizeBufferPercentage/100.)) TotalDiskSizeMB
						) r
			inner join Inventory.MonitoredObjects on MOB_ID = LBL_MOB_ID
			inner join Consolidation.PossibleHosts on PSH_ID = CLB_PSH_ID
			left join Consolidation.BillableByUsageItemLevels on BUL_ID = PSH_Storage_BUL_ID
			inner join Consolidation.CloudMachineTypes on CMT_ID = PSH_CMT_ID
			left join Consolidation.OSTypes on OST_ID = CLB_OST_ID
			left join Consolidation.CloudHostedApplications on CHA_ID = CLB_CHA_ID
			left join Consolidation.CloudHostedApplicationEditions on CLB_CHE_ID = CHE_ID
			inner join Consolidation.DiskIOInfo on DII_MOB_ID = LBL_MOB_ID
			inner join Consolidation.DiskInfo on DSI_MOB_ID = LBL_MOB_ID
			inner join Consolidation.MachineActivity on MAC_MOB_ID = LBL_MOB_ID
			left join Consolidation.WarningMessages on WMS_MOB_ID = LBL_MOB_ID
			outer apply (select top 1 CST_DiskCount DiskCount
							from Consolidation.CloudStorageThroughput
							where CST_BUL_ID = BUL_ID
								and BUL_Limitations.value('(Parameters/@MaxGBPerDisk)[1]', 'int')*1024*CST_DiskCount >= TotalDiskSizeMB
								and CST_MaxIOPS8KB >= iif(CLB_DiskBlockSize = 8, TotalIOPS, 0)
								and CST_MaxMBPerSec8KB >= iif(CLB_DiskBlockSize = 8, TotalMBPS, 0)
								and CST_MaxIOPS64KB >= iif(CLB_DiskBlockSize = 64, TotalIOPS, 0)
								and CST_MaxMBPerSec64KB >= iif(CLB_DiskBlockSize = 64, TotalMBPS, 0)
							order by CST_DiskCount) d
		where CLB_DLR_ID is null
			and CBL_DLR_ID is null
		union all
		select DISTINCT 2 as QType, MOB_ID,CLV_Name CloudProvider, MOB_Name OriginalMachineName,
			cast(null as varchar(100)) VMType,
			cast(null as varchar(100)) StorageType,
			cast(null as tinyint) DiskCount,
			cast(null as varchar(100)) OperatingSystem,
			cast(null as varchar(100)) DatabaseEngine,
			cast(null as varchar(100)) DatabaseEngineEdition,
			cast(null as int) NumberOfCores,
			cast(null as decimal(15, 3)) EffectiveMachineMonthlyCost,
			cast(null as decimal(10, 3)) PercentActive,
			cast(null as decimal(15, 3)) ActivePercentCalculatedPrice,
			cast(null as varchar(100)) CurrentDataFileSizeGB,
			cast(null as varchar(100)) EstimatedDataFilesGBIn3Years,
			cast(null as varchar(100)) LogFilesSizeGB,
			cast(null as varchar(100)) TempdbSizeGB,
			cast(null as varchar(100)) NonSQLDiskSizeGB,
			cast(null as varchar(100)) DataFileIOPS,
			cast(null as varchar(100)) LogFileIOPS,
			cast(null as varchar(100)) TempdbIOPS,
			cast(null as varchar(100)) TotalIOPS,
			WMS_WarningMessage WarningMessage,
			EXP_Reason ReasonCannotBeMigratedToCloud,
			OST_Name OriginalMachineOperatingSystem,
			isnull(CHA_Name, '') OriginalMachineDatabaseEngine,
			isnull(CHE_Name, '') OriginalMachineDatabaseEngineEdition,
			MachineCoreCount OriginalMachineCores,
			cast(null as varchar(2000)) ReasonCannotParticipateInAssessment,
			0 HasCloudMatch,
			1 InAssessment,
			0 MisingData
			,HST_ID
			,HST_Name
		from 
			--(
			--	select 
			--			cast(SET_Value as varchar(200)) CustomerName
			--	from	Management.Settings
			--	where	SET_Module = 'Management'
			--			and SET_Key = 'Environment Name'
			--) cn 
			--cross join 
			Consolidation.HostTypes
			inner join Consolidation.CloudProviders on CLV_ID = HST_CLV_ID
			cross join Consolidation.LoadBlocks l
			inner join Inventory.MonitoredObjects on MOB_ID = LBL_MOB_ID
			inner join Consolidation.OSTypes on OST_ID = LBL_OST_ID
			left join Consolidation.CloudHostedApplications on CHA_ID = LBL_CHA_ID
			left join Consolidation.CloudHostedApplicationEditions on LBL_CHE_ID = CHE_ID
			left join Consolidation.WarningMessages on WMS_MOB_ID = LBL_MOB_ID
			cross apply (select top 1 EXP_Reason
							from Consolidation.Exceptions
							where EXP_EXT_ID = 3
								and EXP_MOB_ID = MOB_ID
								and EXP_HST_ID = HST_ID
						) e
			inner join #FCoreInfo on PRS_MOB_ID = MOB_ID
		where not exists (select *
							from Consolidation.ConsolidationBlocks_LoadBlocks
							where CBL_LBL_ID = LBL_ID
								and CBL_HST_ID = HST_ID)
		union all
		select DISTINCT 3 as QType, MOB_ID,CLV_Name CloudProvider, MOB_Name OriginalMachineName,
			cast(null as varchar(100)) VMType,
			cast(null as varchar(100)) StorageType,
			cast(null as tinyint) DiskCount,
			cast(null as varchar(100)) OperatingSystem,
			cast(null as varchar(100)) DatabaseEngine,
			cast(null as varchar(100)) DatabaseEngineEdition,
			cast(null as int) NumberOfCores,
			cast(null as decimal(15, 3)) EffectiveMachineMonthlyCost,
			cast(null as decimal(10, 3)) PercentActive,
			cast(null as decimal(15, 3)) ActivePercentCalculatedPrice,
			cast(null as varchar(100)) CurrentDataFileSizeGB,
			cast(null as varchar(100)) EstimatedDataFilesGBIn3Years,
			cast(null as varchar(100)) LogFilesSizeGB,
			cast(null as varchar(100)) TempdbSizeGB,
			cast(null as varchar(100)) NonSQLDiskSizeGB,
			cast(null as varchar(100)) DataFileIOPS,
			cast(null as varchar(100)) LogFileIOPS,
			cast(null as varchar(100)) TempdbIOPS,
			cast(null as varchar(100)) TotalIOPS,
			cast(null as varchar(1000)) WarningMessage,
			cast(null as varchar(2000)) ReasonCannotBeMigratedToCloud,
			isnull(PLT_Name, '') OriginalMachineOperatingSystem,
			isnull(DatabasePlatformName, '') OriginalMachineDatabaseEngine,
			isnull(DatabaseEdition, '') OriginalMachineDatabaseEngineEdition,
			MachineCoreCount OriginalMachineCores,
			EXP_Reason ReasonCannotParticipateInAssessment,
			0 HasCloudMatch,
			0 InAssessment,
			1 MisingData
			,HST_ID
			,HST_Name
		from 
			--(
			--	select 
			--			cast(SET_Value as varchar(200)) CustomerName
			--	from	Management.Settings
			--	where	SET_Module = 'Management'
			--			and SET_Key = 'Environment Name'
			--) cn 
			--cross join 
			Consolidation.HostTypes
			inner join Consolidation.CloudProviders on CLV_ID = HST_CLV_ID
			cross join Inventory.MonitoredObjects s
			left join Management.PlatformTypes sp on PLT_ID = MOB_PLT_ID
			outer apply (select top 1 dp.PLT_Name DatabasePlatformName, EDT_Name DatabaseEdition
							from Inventory.ParentChildRelationships
								inner join Inventory.MonitoredObjects d on d.MOB_ID = PCR_Child_MOB_ID
								inner join Management.PlatformTypes dp on dp.PLT_ID = d.MOB_PLT_ID
								inner join Inventory.DatabaseInstanceDetails on DID_DFO_ID = d.MOB_Entity_ID
								left join Inventory.Editions on EDT_ID = DID_EDT_ID
							where PCR_Parent_MOB_ID = s.MOB_ID
								and dp.PLT_PLC_ID = 1) c
			cross apply (select top 1 EXP_Reason
							from Consolidation.Exceptions
							where EXP_EXT_ID = 1
								and EXP_MOB_ID = MOB_ID
						) e
			left join #FCoreInfo on PRS_MOB_ID = MOB_ID
		where/* HST_ID in (5, 7)
			and*/ PLT_PLC_ID = 2
			and not exists (select *
							from Consolidation.LoadBlocks
							where LBL_MOB_ID = MOB_ID)
		order by MOB_ID,QType

		END
	END
	
END
GO
