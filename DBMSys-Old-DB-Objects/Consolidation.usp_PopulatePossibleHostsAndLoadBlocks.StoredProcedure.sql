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
/****** Object:  StoredProcedure [Consolidation].[usp_PopulatePossibleHostsAndLoadBlocks]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Consolidation].[usp_PopulatePossibleHostsAndLoadBlocks]
AS
BEGIN
	set ansi_padding on
	truncate table Consolidation.PossibleHosts
	truncate table Consolidation.LoadBlocks
	truncate table Consolidation.SingleDatabaseLoadBlocks
	truncate table Consolidation.PossibleHostsConsolidationGroupAffinity
	truncate table Consolidation.ConsolidationBlocks
	truncate table Consolidation.ConsolidationBlocks_LoadBlocks
	truncate table Consolidation.SingleDatabaseCloudLocations

	if object_id('tempdb..#PlatformsUsed') is not null
		drop table #PlatformsUsed

	declare @RedFlagHostBuffer decimal(10, 2),
		@RedFlagWorkLoadBuffer decimal(10, 2),
		@RedFlagHostBufferMultiplier decimal(10, 2),
		@RedFlagLoadBufferMultiplier decimal(10, 2),
		@DiskIOBufferPercentage decimal(10, 2),
		@IgnoreNetworkBandwidthForCloudProviderNames varchar(1000),
		@IgnorePaaSLimitingFeatures varchar(4000),
		@DiskSizeBufferPercentage decimal(10, 2),
		@CloudMachineRedundencyLevel tinyint,
		@ForceCloudMachineRedundencyLevel bit,
		@CloudMaxNumberOfMonthsCommitment tinyint,
		@CloudAgreeToPayUpfront tinyint,
		@PurchaseAppLicensingFromCloudWherePossible bit,
		@DestinationOperatingSystem varchar(100),
		@DestinationDatabaseEngine varchar(100),
		@DestinationDatabaseEngineEdition varchar(100),
		@PreferredCloudTenancy varchar(100),
		@PreferredCloudPlan varchar(100),
		@DestinationOperatingSystemID tinyint,
		@DestinationDatabaseEngineID tinyint,
		@DestinationDatabaseEngineEditionID tinyint

	select @DiskIOBufferPercentage = CAST(SET_Value as decimal(10, 2))
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Disk IO Buffer Percentage'

	select @DiskSizeBufferPercentage = CAST(SET_Value as decimal(10, 2))
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Disk Size Buffer Percentage'

	select @RedFlagHostBuffer = CAST(SET_Value as decimal(10, 2))
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Red Flag Host Buffer'

	select @RedFlagHostBuffer = CAST(SET_Value as decimal(10, 2))
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Red Flag Host Buffer'

	select @RedFlagWorkLoadBuffer = CAST(SET_Value as decimal(10, 2))
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Red Flag Work Load Buffer'

	select @IgnoreNetworkBandwidthForCloudProviderNames = CAST(SET_Value as varchar(1000))
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Ignore network bandwidth for cloud provider names'

	select @IgnorePaaSLimitingFeatures = CAST(SET_Value as varchar(4000))
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Ignore PaaS limiting features'

	;with SetValue as
			(select CAST(SET_Value as varchar(10)) RedLvl
				from Management.Settings
				where SET_Module = 'Consolidation'
					and SET_Key = 'Cloud Machine Redundancy Level'
			)
	select @CloudMachineRedundencyLevel = cast(replace(replace(RedLvl, '(', ''), ')', '') as tinyint),
		@ForceCloudMachineRedundencyLevel = iif(RedLvl like '(%)', 0, 1)
	from SetValue

	select @CloudMaxNumberOfMonthsCommitment = CAST(SET_Value as tinyint)
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Cloud Max Number Of Months Commitment'

	select @CloudAgreeToPayUpfront = CAST(SET_Value as tinyint)
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Cloud Agree To Pay Upfront'

	select @PurchaseAppLicensingFromCloudWherePossible = CAST(SET_Value as bit)
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Purchase App Licensing From Cloud Where Possible'

	select @DestinationOperatingSystem = CAST(SET_Value as varchar(100))
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Destination operating system'

	select @DestinationDatabaseEngine = CAST(SET_Value as varchar(100))
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Destination database engine'

	select @DestinationDatabaseEngineEdition = CAST(SET_Value as varchar(100))
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Destination database engine edition'
	
	select @PreferredCloudTenancy = CAST(SET_Value as varchar(100))
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Preferred cloud tenancy (Shared, Dedicated)'

	select @PreferredCloudPlan = CAST(SET_Value as varchar(100))
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Preferred cloud plan (Standard, Convertible)'

	select @DestinationOperatingSystemID = OST_ID
	from Consolidation.OSTypes
	where OST_Name = @DestinationOperatingSystem

	select @DestinationDatabaseEngineID = CHA_ID
	from Consolidation.CloudHostedApplications
	where ' '  + CHA_Name + ' ' like '% ' + @DestinationDatabaseEngine + ' %'

	select @DestinationDatabaseEngineEditionID = CHE_ID
	from Consolidation.CloudHostedApplicationEditions
	where ' '  + CHE_Name + ' ' like '% ' + @DestinationDatabaseEngineEdition + ' %'

	select @RedFlagHostBufferMultiplier = 1 + @RedFlagHostBuffer/100.,
		@RedFlagLoadBufferMultiplier = 1 + @RedFlagWorkLoadBuffer/100.

	--Loads
	insert into Consolidation.LoadBlocks(LBL_CGR_ID, LBL_MOB_ID, LBL_OST_ID, LBL_CHA_ID, LBL_CHE_ID, LBL_CPUStrength, LBL_MemoryMB,
										LBL_DataFilesDiskSize, LBL_LogFilesDiskSize, LBL_DiskSize, LBL_BlockSize,
										LBL_ReadsSec, LBL_WritesSec, LBL_DataFilesIOps, LBL_LogFilesIOps,
										LBL_ReadsMBSec, LBL_WritesMBSec, LBL_DataFilesMBPerSec, LBL_LogFilesMBPerSec,
										LBL_NetworkUsageDownloadMbit, LBL_NetworkUsageUploadMbit,
										LBL_MonthlyDiskIOPS, LBL_MonthlyNetworkOutboundMB, LBL_MonthlyNetworkInboundMB, LBL_SQLInstanceCount, LBL_HasSoftwareAssurance, LBL_IsVM)
	select CGR_ID, o.MOB_ID, case PLT_ID
								when 2 then 1
								when 4 then 2
							end OST_ID, CHA_ID, MaxEdition, CPUUsage, MemoryUsage, DataFilesMB, LogFilesMB, UsedSpace, DominantBlockSize, TotalFileReads, TotalFileWrites,
		DataFileTransfers, LogFileTransfers,
		TotalFileReadsMB, TotalFileWritesMB, DataFileTransfersMB, LogFileTransfersMB, NetworkUsageDownloadMbit, NetworkUsageUploadMbit, AvgMonthlyIOPS, AvgMonthlyNetworkOutboundIOMB,
		AvgMonthlyNetworkInboundIOMB, SQLInstances, 1 HasSoftwareAssurance, IsVM
	from Consolidation.fn_GetResourceUsage(@RedFlagLoadBufferMultiplier, @DiskSizeBufferPercentage) o
		outer apply (select top 1 CHA_ID
									from Consolidation.ParticipatingDatabaseServers
										inner join Inventory.MonitoredObjects d on d.MOB_ID = PDS_Database_MOB_ID
										inner join Management.PlatformTypes p on p.PLT_ID = d.MOB_PLT_ID
										inner join Consolidation.CloudHostedApplications on PLT_Name = CHA_Name
									where PDS_Server_MOB_ID = o.MOB_ID	
								) db
	where exists (select *
					from Consolidation.ParticipatingDatabaseServers
					where PDS_Server_MOB_ID = o.MOB_ID)
			AND DominantBlockSize IS NOT NULL
			AND IsVM IS NOT NULL


	select distinct isnull(@DestinationOperatingSystemID, LBL_OST_ID) OST_ID,
		isnull(@DestinationDatabaseEngineID, LBL_CHA_ID) CHA_ID,
		isnull(@DestinationDatabaseEngineEditionID, LBL_CHE_ID) CHE_ID
	into #PlatformsUsed
	from Consolidation.LoadBlocks

	--Per Database Load
	insert into Consolidation.LoadBlocks(LBL_CGR_ID, LBL_MOB_ID, LBL_IDB_ID, LBL_OST_ID, LBL_CHA_ID, LBL_CHE_ID, LBL_CPUStrength, LBL_MemoryMB, LBL_DiskSize, LBL_BlockSize,
										LBL_ReadsSec, LBL_WritesSec, LBL_ReadsMBSec, LBL_WritesMBSec, LBL_NetworkUsageDownloadMbit, LBL_NetworkUsageUploadMbit,
										LBL_MonthlyDiskIOPS, LBL_MonthlyNetworkOutboundMB, LBL_MonthlyNetworkInboundMB, LBL_SQLInstanceCount, LBL_HasSoftwareAssurance)
	select LBL_CGR_ID, LBL_MOB_ID, PDR_IDB_ID, LBL_OST_ID, LBL_CHA_ID, LBL_CHE_ID, LBL_CPUStrength*PDR_CPURatio, LBL_MemoryMB*PDR_MemoryRatio,
			DSI_DataFilesMBIn3Years + DSI_LogFilesMB + DSI_DataFilesMBIn3Years*.5 /* Backup */, LBL_BlockSize,
			LBL_ReadsSec*PDR_IOphRatio, LBL_WritesSec*PDR_IOphRatio, LBL_ReadsMBSec*PDR_MBphRatio, LBL_WritesMBSec*PDR_MBphRatio, LBL_NetworkUsageDownloadMbit, LBL_NetworkUsageUploadMbit,
			LBL_MonthlyDiskIOPS*PDR_IOphRatio, LBL_MonthlyNetworkOutboundMB*1./COUNT(*) over (partition by LBL_MOB_ID),
			LBL_MonthlyNetworkInboundMB*1./COUNT(*) over (partition by LBL_MOB_ID), 1, LBL_HasSoftwareAssurance
	from Consolidation.LoadBlocks
		inner join Consolidation.PerDatabaseRatios on LBL_MOB_ID = PDR_MOB_ID
		inner join Consolidation.DiskInfo on DSI_MOB_ID = LBL_MOB_ID
										and DSI_IDB_ID = PDR_IDB_ID
	WHERE LBL_BlockSize IS NOT NULL

	delete a
	from Consolidation.LoadBlocks a
	where a.LBL_IDB_ID is null
		and exists (select *
					from Consolidation.LoadBlocks b
					where b.LBL_MOB_ID = a.LBL_MOB_ID
						and b.LBL_IDB_ID is not null)

	--Single database loads for SQL PaaS
	insert into Consolidation.SingleDatabaseLoadBlocks
	select HST_ID, SDT_MOB_ID, SDT_IDB_ID, CMT_DTUs*SDT_PercentOfServerActivity RelativeDTUs,
		(SDZ_SizeMB + iif(SDZ_EstimatedYearlyGrowthMB = 0, SDZ_SizeMB*(@DiskSizeBufferPercentage/100), SDZ_EstimatedYearlyGrowthMB*3))/1024 SizeGB
	from Consolidation.SingleDatabaseTransactions
		inner join Consolidation.SingleDatabaseSizes on SDZ_MOB_ID = SDT_MOB_ID
															and SDZ_IDB_ID = SDT_IDB_ID
		inner join Inventory.InstanceDatabases on IDB_ID = SDT_IDB_ID
		inner join Inventory.MonitoredObjects on MOB_ID = SDT_MOB_ID
		inner join Consolidation.ServerPossibleHostTypes on SHT_MOB_ID = SDT_MOB_ID
		inner join Consolidation.HostTypes on HST_ID = SHT_HST_ID
		inner join Consolidation.CloudMachineTypes on CMT_CLV_ID = HST_CLV_ID
		inner join Consolidation.CloudMachineCategories on CMT_CMG_ID = CMG_ID
		inner join DTUCalculator.APIOutput on (AOT_CloudServerName = CMG_Name + ' - ' + CMT_Name or AOT_CloudServerName = CMG_Name) and MOB_ID = AOT_MOB_ID
	where not exists (select *
						from Inventory.LimitingFeatureUsage
							inner join Inventory.LimitingFeatureTypes on LFT_ID = LFU_LFT_ID
						where LFU_MOB_ID = IDB_MOB_ID
							and (LFU_IDB_ID = IDB_ID
									or LFU_IDB_ID is null)
							and not exists (select *
												from Infra.fn_SplitString(@IgnorePaaSLimitingFeatures, ',')
												where Val = LFT_Name)
							)
		and IDB_Name not in ('master', 'model', 'tempdb', 'msdb', 'ReportServer', 'ReportServerTempDB')
		and IDB_IsDistributor = 0
		and HST_IsPerSingleDatabase = 1
		and exists (select * from Consolidation.ParticipatingDatabaseServers where PDS_Server_MOB_ID = SDT_MOB_ID and PDS_Database_MOB_ID = IDB_MOB_ID)

	--On-prem
	insert into Consolidation.PossibleHosts(PSH_HST_ID, PSH_MOB_ID, PSH_OST_ID, PSH_CHE_ID, PSH_CoreCount, PSH_CPUStrength, PSH_MemoryMB, PSH_NetWorkSpeedMbit,
											PSH_NetDownloadSpeedRatio, PSH_NetUploadSpeedRatio, PSH_PricePerMonthUSD, PSH_MaxDataFilesDiskSizeMB, PSH_MaxLogFilesDiskSizeMB, PSH_MaxDiskSizeMB,
											PSH_DataFilesMaxIOPS, PSH_LogFilesMaxIOPS, PSH_TotalMaxIOPS, PSH_DataFilesMaxMBPerSec, PSH_LogFilesMaxMBPerSec, PSH_TotalMaxMBPerSec, PSH_FileTypeSeparation, PSH_IsVM)
	select HST_ID HST_ID, o.MOB_ID, case PLT_ID
								when 2 then 1
								when 4 then 2
							end OST_ID, MaxEdition, CPUCount, CPUStrength, MemoryMB, NetworkSpeedMbit, 1 DownloadRatio, 1 UploadRatio, null PricePerMonthUSD,
		iif(HST_IsLimitedByDisk = 1 and FileTypeSeparation = 1, DataFreeSpaceMBIn3Years, null),
		iif(HST_IsLimitedByDisk = 1 and FileTypeSeparation = 1, LogFreeSpaceMB, null),
		iif(HST_IsLimitedByDisk = 1 and FileTypeSeparation = 0, TotalFreeSpaceMB, null),
		iif(HST_IsLimitedByDisk = 1 and FileTypeSeparation = 1, DataMaxTransfers, null),
		iif(HST_IsLimitedByDisk = 1 and FileTypeSeparation = 1, LogMaxTransfers, null),
		iif(HST_IsLimitedByDisk = 1 and FileTypeSeparation = 0, TotalMaxTransfers, null),
		iif(HST_IsLimitedByDisk = 1 and FileTypeSeparation = 1, DataMaxMBPs, null),
		iif(HST_IsLimitedByDisk = 1 and FileTypeSeparation = 1, LogMaxMBPs, null),
		iif(HST_IsLimitedByDisk = 1 and FileTypeSeparation = 0, TotalMaxMBPs, null),
		iif(HST_IsLimitedByDisk = 1, FileTypeSeparation, 0), IsVM
	from Consolidation.fn_GetResourceUsage(@RedFlagLoadBufferMultiplier, @DiskSizeBufferPercentage) o
		inner join Consolidation.ServerPossibleHostTypes on SHT_MOB_ID = o.MOB_ID
		inner join Consolidation.HostTypes on HST_ID = SHT_HST_ID
	where HST_CLV_ID is null
		and HST_IsSharingOS = 1
		and exists (select *
					from Consolidation.ParticipatingDatabaseServers
					where PDS_Server_MOB_ID = o.MOB_ID)

	--Virtualization hosts
	insert into Consolidation.PossibleHosts(PSH_HST_ID, PSH_VES_ID, PSH_OST_ID, PSH_CoreCount, PSH_CPUStrength, PSH_MemoryMB, PSH_NetWorkSpeedMbit,
											PSH_NetDownloadSpeedRatio, PSH_NetUploadSpeedRatio, PSH_PricePerMonthUSD, PSH_FileTypeSeparation)
	select 4, VES_ID, 1, CPF_CPUCount, CPF_CPUFactor*CPF_SingleCPUScore, VES_MemoryMB, VES_NetworkSpeedMbit, 1, 1, null, 0
	from Consolidation.VirtualizationESXServers
		inner join Consolidation.CPUFactoring on VES_ID = CPF_VES_ID
	WHERE EXISTS (Select * from Consolidation.ServerPossibleHostTypes WHERE SHT_HST_ID = 4)

	--Cloud Machines
	insert into Consolidation.PossibleHosts(PSH_HST_ID, PSH_CMT_ID, PSH_CRG_ID, PSH_OST_ID, PSH_CHE_ID, PSH_CoreCount, PSH_CPUStrength, PSH_MemoryMB, PSH_NetWorkSpeedMbit, PSH_NetDownloadSpeedRatio,
											PSH_NetUploadSpeedRatio, PSH_PricePerMonthUSD, PSH_Storage_BUL_ID, PSH_MaxDiskCount, PSH_MaxDiskSizeMB, PSH_MaxIOPS8KB,
											PSH_MaxMBPerSec8KB, PSH_MaxIOPS64KB, PSH_MaxMBPerSec64KB, PSH_FileTypeSeparation, PSH_CMP_ID, PSH_PricePerDisk, PSH_CHA_ID)
	select HST_ID, CMT_ID, CMP_CRG_ID, CMP_OST_ID,  CMP_CHE_ID, CMT_CoreCount, CMT_CPUStrength, CMT_MemoryMB,
		iif(CloudProviderName is null, (CMT_NetWorkSpeedDownloadMbit + CMT_NetWorkSpeedUploadMbit), 40000) NetworkSpeed,
		iif(CloudProviderName is null, cast((CMT_NetWorkSpeedDownloadMbit + CMT_NetWorkSpeedUploadMbit)*1./CMT_NetWorkSpeedDownloadMbit as decimal(10, 6)), 1) NetworkDownloadRatio,
		iif(CloudProviderName is null, cast((CMT_NetWorkSpeedDownloadMbit + CMT_NetWorkSpeedUploadMbit)*1./CMT_NetWorkSpeedUploadMbit as decimal(10, 6)), 1) NetworkUploadRatio,
		MonthlyPriceUSD, CMC_Storage_BUL_ID, CMC_MaxDiskCount, CMC_MaxDiskCount*BUL_Limitations.value('(Parameters/@MaxGBPerDisk)[1]', 'int')*1024,
		iif(CMC_8KBIOPSLimit is null or CMC_8KBIOPSLimit > CST_MaxIOPS8KB, CST_MaxIOPS8KB, CMC_8KBIOPSLimit) MaxIOPS8KB,
		iif(CMC_8KBMBPSLimit is null or CMC_8KBMBPSLimit > CST_MaxMBPerSec8KB, CST_MaxMBPerSec8KB, CMC_8KBMBPSLimit) MaxMBPerSec8KB,
		iif(CMC_64KBIOPSLimit is null or CMC_64KBIOPSLimit > CST_MaxIOPS64KB, CST_MaxIOPS64KB, CMC_64KBIOPSLimit) MaxIOPS64KB,
		iif(CMC_64KBMBPSLimit is null or CMC_64KBMBPSLimit > CST_MaxMBPerSec64KB, CST_MaxMBPerSec64KB, CMC_64KBMBPSLimit) MaxMBPerSec64KB,
		0, CMP_ID, StoragePricePerUnit*BUL_Limitations.value('(Parameters/@MaxGBPerDisk)[1]', 'int') PricePerDisk, CMP_CHA_ID
	from Consolidation.CloudMachineTypes
		inner join Consolidation.CloudProviders on CLV_ID = CMT_CLV_ID
		inner join Consolidation.HostTypes on HST_CLV_ID = CLV_ID
		left join Consolidation.CloudMachineStorageCompatibility on CMC_CMT_ID = CMT_ID
		left join Consolidation.BillableByUsageItemLevels on BUL_ID = CMC_Storage_BUL_ID
		left join Consolidation.CloudStorageThroughput on CST_BUL_ID = CMC_Storage_BUL_ID
															and CST_DiskCount = CMC_MaxDiskCount
		left join (select Val CloudProviderName
					from Infra.fn_SplitString(@IgnoreNetworkBandwidthForCloudProviderNames, ',')
					) v on CLV_Name = CloudProviderName
		cross apply (select CMP_CRG_ID, CMP_OST_ID, CMP_CHA_ID, CMP_CHE_ID, CMP_ID, CMP_EffectiveHourlyPaymentUSD*744 MonthlyPriceUSD,
							rank() over (partition by CMP_CRG_ID, CMP_OST_ID, CMP_CHA_ID, CMP_CHE_ID
											order by iif(CPT_Name = @PreferredCloudPlan, 0, 1),
													iif(CTT_Name = @PreferredCloudTenancy, 0, 1),
													CRL_RedundencyLevel desc, CMP_EffectiveHourlyPaymentUSD) rnk
						from Consolidation.CloudMachinePricing
							inner join Consolidation.CloudMachinePaymentModels on CPM_ID = CMP_CPM_ID
							left join Consolidation.CloudMachineRedundencyLevels on CRL_ID = CMP_CRL_ID
							left join Consolidation.CloudHostingPlanTypes on CPT_ID = CMP_CPT_ID
							left join Consolidation.CloudTenancyTypes on CTT_ID = CMP_CTT_ID
						where CMP_CMT_ID = CMT_ID
							and (CMP_Storage_BUL_ID = CMC_Storage_BUL_ID
								or (CMP_Storage_BUL_ID is null
									and CMC_Storage_BUL_ID is null)
								)
							and (CRL_RedundencyLevel = @CloudMachineRedundencyLevel
									or (@ForceCloudMachineRedundencyLevel = 0
										and CRL_RedundencyLevel <= @CloudMachineRedundencyLevel
										)
									or CRL_RedundencyLevel is null
								)
							and CPM_NumberOfMonths <= @CloudMaxNumberOfMonthsCommitment
							and CPM_UpfrontType <= @CloudAgreeToPayUpfront
							and (	(@PurchaseAppLicensingFromCloudWherePossible = 0
										and CMP_CHE_ID is null)
									or @PurchaseAppLicensingFromCloudWherePossible = 1
								)
							) p
		outer apply (select avg(BUP_PricePerUnit) StoragePricePerUnit
						from Consolidation.BillableByUsageItemLevelPricingScheme a
						where BUP_BUL_ID = CMC_Storage_BUL_ID
							and (BUP_CRG_ID = CMP_CRG_ID
									or (BUP_CRG_ID is null
										and not exists (select * 
															from Consolidation.BillableByUsageItemLevelPricingScheme b
															where b.BUP_BUL_ID = a.BUP_BUL_ID
																and b.BUP_CRG_ID = CMP_CRG_ID)
										)
								)
					) b
	where CMT_IsActive = 1
		and rnk = 1
		and exists (select *
					from Consolidation.ServerPossibleHostTypes
					where SHT_HST_ID = HST_ID)
		and exists (select *
						from #PlatformsUsed
						where (CMP_OST_ID = OST_ID
								or (CMP_OST_ID is null
										and CMP_CHA_ID = CHA_ID)
								)
							and (CMP_CHA_ID = CHA_ID
									or CMP_CHA_ID is null
								)
							and (CMP_CHE_ID = CHE_ID
									or CMP_CHE_ID is null
								)
					)
		and exists (select *
					from Consolidation.ConsolidationGroups_CloudRegions
					where CGG_CRG_ID = CMP_CRG_ID)
				
	--Assoc
	insert into Consolidation.PossibleHostsConsolidationGroupAffinity
	select distinct PSH_ID, SGR_CGR_ID
	from Consolidation.PossibleHosts
		inner join Consolidation.ServerGrouping on SGR_MOB_ID = PSH_MOB_ID
		inner join Consolidation.HostTypes on HST_ID = PSH_HST_ID
	where HST_IsCloud = 0
		and HST_IsSharingOS = 1
		and not exists (select *
							from Inventory.MonitoredObjects
								inner join Inventory.OSServers on OSS_MOB_ID = MOB_ID
							where MOB_ID = PSH_MOB_ID
								and OSS_IsVirtualServer = 1)

	insert into Consolidation.PossibleHostsConsolidationGroupAffinity
	select PSH_ID, CGG_CGR_ID
	from Consolidation.PossibleHosts
		inner join Consolidation.ConsolidationGroups_CloudRegions on CGG_CRG_ID = PSH_CRG_ID
		inner join Consolidation.HostTypes on HST_ID = PSH_HST_ID
	where HST_IsCloud = 1

	insert into Consolidation.PossibleHostsConsolidationGroupAffinity
	select PSH_ID, CGR_ID
	from Consolidation.PossibleHosts
		   cross join Consolidation.ConsolidationGroups
	where PSH_VES_ID is not null
END
GO
