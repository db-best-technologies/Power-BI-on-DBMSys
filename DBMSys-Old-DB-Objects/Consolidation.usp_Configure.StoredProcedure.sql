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
/****** Object:  StoredProcedure [Consolidation].[usp_Configure]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Consolidation].[usp_Configure]
	@AllowEditionUpgradingConsolidation bit = null,
	@CloudAgreeToPayUpfront tinyint = null,
	@CloudMachineRedundancyLevel varchar(10) = null,
	@CloudMaxNumberOfMonthsCommitment tinyint = null,
	@CloudStorageRedundancyLevel tinyint = null,
	@ConsiderClusterVirtualServerAsHost bit = null,
	@ConsiderServersWithoutADatabaseInstance bit = null,
	@CounterPercentile decimal(10, 2) = null,
	@CPUBufferPercentage decimal(10, 2) = null,
	@CPUCapPercentage decimal(10, 2) = null,
	@DiskIOBufferPercentage decimal(10, 2) = null,
	@DiskIOCapPercentage decimal(10, 2) = null,
	@DiskSizeBufferPercentage decimal(10, 2) = null,
	@DiskSizeCapPercentage decimal(10, 2) = null,
	@FactorForHyperThreadedCPUs decimal(10, 2) = null,
	@IgnoreNetworkBandwidthForCloudProviderNames varchar(1000) = null,
	@IgnorePaaSLimitingFeatures varchar(4000) = null,
	@IsSQLIOused bit = null,
	@MemoryBufferPercentage decimal(10, 2) = null,
	@MemoryCapPercentage decimal(10, 2) = null,
	@NetworkSpeedBufferPercentage decimal(10, 2) = null,
	@NetworkSpeedCapPercentage decimal(10, 2) = null,
	@PercentageDifferenceOfUnderUtilizationToAlertOn tinyint = null,
	@PurchaseAppLicensingFromCloudWherePossible bit = null,
	@RedFlagHostBuffer decimal(10, 2) = null,
	@RedFlagWorkLoadBuffer decimal(10, 2) = null,
	@VirtualizationCPUCoreStretchRatio tinyint = null,
	@VirtualizationExcludeCurrentlyVirtualized bit = null,
	@VirtualizationFactorForStretchedCPUs decimal(10, 2) = null,
	@VirtualizationMemoryToReserveForESX decimal(10, 2) = null,
	@VirtualizationNumberOfBuckets int = null,
	@VirtualizationNumberOfVirtualCoresToReserveForESX tinyint = null
as

update Management.Settings
set SET_Value = @AllowEditionUpgradingConsolidation
where SET_Module = 'Consolidation'
	and SET_Key = 'Allow Edition Upgrading Consolidation'
	and @AllowEditionUpgradingConsolidation is not null

update Management.Settings
set SET_Value = @CloudAgreeToPayUpfront
where SET_Module = 'Consolidation'
	and SET_Key = 'Cloud Agree To Pay Upfront'
	and @CloudAgreeToPayUpfront is not null

update Management.Settings
set SET_Value = @CloudMachineRedundancyLevel
where SET_Module = 'Consolidation'
	and SET_Key = 'Cloud Machine Redundancy Level'
	and @CloudMachineRedundancyLevel is not null

update Management.Settings
set SET_Value = @CloudMaxNumberOfMonthsCommitment
where SET_Module = 'Consolidation'
	and SET_Key = 'Cloud Max Number Of Months Commitment'
	and @CloudMaxNumberOfMonthsCommitment is not null

update Management.Settings
set SET_Value = @CloudStorageRedundancyLevel
where SET_Module = 'Consolidation'
	and SET_Key = 'Cloud Storage Redundancy Level'
	and @CloudStorageRedundancyLevel is not null

update Management.Settings
set SET_Value = @ConsiderClusterVirtualServerAsHost
where SET_Module = 'Consolidation'
	and SET_Key = 'Consider Cluster Virtual Server As Host'
	and @ConsiderClusterVirtualServerAsHost is not null

update Management.Settings
set SET_Value = @ConsiderServersWithoutADatabaseInstance
where SET_Module = 'Consolidation'
	and SET_Key = 'Consider servers without a database instance'
	and @ConsiderServersWithoutADatabaseInstance is not null

update Management.Settings
set SET_Value = @CounterPercentile
where SET_Module = 'Consolidation'
	and SET_Key = 'Counter Percentile'
	and @CounterPercentile is not null

update Management.Settings
set SET_Value = @CPUBufferPercentage
where SET_Module = 'Consolidation'
	and SET_Key = 'CPU Buffer Percentage'
	and @CPUBufferPercentage is not null

update Management.Settings
set SET_Value = @CPUCapPercentage
where SET_Module = 'Consolidation'
	and SET_Key = 'CPU Cap Percentage'
	and @CPUCapPercentage is not null

update Management.Settings
set SET_Value = @DiskIOBufferPercentage
where SET_Module = 'Consolidation'
	and SET_Key = 'Disk IO Buffer Percentage'
	and @DiskIOBufferPercentage is not null

update Management.Settings
set SET_Value = @DiskIOCapPercentage
where SET_Module = 'Consolidation'
	and SET_Key = 'Disk IO Cap Percentage'
	and @DiskIOCapPercentage is not null

update Management.Settings
set SET_Value = @DiskSizeBufferPercentage
where SET_Module = 'Consolidation'
	and SET_Key = 'Disk Size Buffer Percentage'
	and @DiskSizeBufferPercentage is not null

update Management.Settings
set SET_Value = @DiskSizeCapPercentage
where SET_Module = 'Consolidation'
	and SET_Key = 'Disk Size Cap Percentage'
	and @DiskSizeCapPercentage is not null

update Management.Settings
set SET_Value = @FactorForHyperThreadedCPUs
where SET_Module = 'Consolidation'
	and SET_Key = 'Factor For Hyper-Threaded CPUs'
	and @FactorForHyperThreadedCPUs is not null

update Management.Settings
set SET_Value = @IgnoreNetworkBandwidthForCloudProviderNames
where SET_Module = 'Consolidation'
	and SET_Key = 'Ignore network bandwidth for cloud provider names'
	and @IgnoreNetworkBandwidthForCloudProviderNames is not null

update Management.Settings
set SET_Value = @IgnorePaaSLimitingFeatures
where SET_Module = 'Consolidation'
	and SET_Key = 'Ignore PaaS limiting features'
	and @IgnorePaaSLimitingFeatures is not null

update Management.Settings
set SET_Value = @IsSQLIOused
where SET_Module = 'Consolidation'
	and SET_Key = 'Is SQL IO used'
	and @IsSQLIOused is not null

update Management.Settings
set SET_Value = @MemoryBufferPercentage
where SET_Module = 'Consolidation'
	and SET_Key = 'Memory Buffer Percentage'
	and @MemoryBufferPercentage is not null

update Management.Settings
set SET_Value = @MemoryCapPercentage
where SET_Module = 'Consolidation'
	and SET_Key = 'Memory Cap Percentage'
	and @MemoryCapPercentage is not null

update Management.Settings
set SET_Value = @NetworkSpeedBufferPercentage
where SET_Module = 'Consolidation'
	and SET_Key = 'Network Speed Buffer Percentage'
	and @NetworkSpeedBufferPercentage is not null

update Management.Settings
set SET_Value = @NetworkSpeedCapPercentage
where SET_Module = 'Consolidation'
	and SET_Key = 'Network Speed Cap Percentage'
	and @NetworkSpeedCapPercentage is not null

update Management.Settings
set SET_Value = @PercentageDifferenceOfUnderUtilizationToAlertOn
where SET_Module = 'Consolidation'
	and SET_Key = 'Percentage Difference Of Under-Utilization To Alert On'
	and @PercentageDifferenceOfUnderUtilizationToAlertOn is not null

update Management.Settings
set SET_Value = @PurchaseAppLicensingFromCloudWherePossible
where SET_Module = 'Consolidation'
	and SET_Key = 'Purchase App Licensing From Cloud Where Possible'
	and @PurchaseAppLicensingFromCloudWherePossible is not null

update Management.Settings
set SET_Value = @RedFlagHostBuffer
where SET_Module = 'Consolidation'
	and SET_Key = 'Red Flag Host Buffer'
	and @RedFlagHostBuffer is not null

update Management.Settings
set SET_Value = @RedFlagWorkLoadBuffer
where SET_Module = 'Consolidation'
	and SET_Key = 'Red Flag Work Load Buffer'
	and @RedFlagWorkLoadBuffer is not null

update Management.Settings
set SET_Value = @VirtualizationCPUCoreStretchRatio
where SET_Module = 'Consolidation'
	and SET_Key = 'Virtualization - CPU Core Stretch Ratio'
	and @VirtualizationCPUCoreStretchRatio is not null

update Management.Settings
set SET_Value = @VirtualizationExcludeCurrentlyVirtualized
where SET_Module = 'Consolidation'
	and SET_Key = 'Virtualization - Exclude Currently Virtualized'
	and @VirtualizationExcludeCurrentlyVirtualized is not null

update Management.Settings
set SET_Value = @VirtualizationFactorForStretchedCPUs
where SET_Module = 'Consolidation'
	and SET_Key = 'Virtualization - Factor For Stretched CPUs'
	and @VirtualizationFactorForStretchedCPUs is not null

update Management.Settings
set SET_Value = @VirtualizationMemoryToReserveForESX
where SET_Module = 'Consolidation'
	and SET_Key = 'Virtualization - Memory To Reserve For ESX'
	and @VirtualizationMemoryToReserveForESX is not null

update Management.Settings
set SET_Value = @VirtualizationNumberOfBuckets
where SET_Module = 'Consolidation'
	and SET_Key = 'Virtualization - Number Of Buckets'
	and @VirtualizationNumberOfBuckets is not null

update Management.Settings
set SET_Value = @VirtualizationNumberOfVirtualCoresToReserveForESX
where SET_Module = 'Consolidation'
	and SET_Key = 'Virtualization - Number Of Virtual CoresTo Reserve For ESX'
	and @VirtualizationNumberOfVirtualCoresToReserveForESX is not null
GO
