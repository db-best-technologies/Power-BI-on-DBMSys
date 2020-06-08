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
/****** Object:  StoredProcedure [Consolidation].[usp_Reports_CloudConsolidationAndOneToOne]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Consolidation].[usp_Reports_CloudConsolidationAndOneToOne]
	@CLV_ID tinyint
as
declare @DiskIOBufferPercentage int,
	@DiskSizeBufferPercentage int,
	@ZoneID tinyint,
	@Consolidation_HST_ID int,
	@OneToOne_HST_ID int

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

select @Consolidation_HST_ID = HST_ID 
from Consolidation.HostTypes
where HST_CLV_ID = @CLV_ID
	and HST_IsConsolidation = 1

select @OneToOne_HST_ID = HST_ID 
from Consolidation.HostTypes
where HST_CLV_ID = @CLV_ID
	and HST_IsConsolidation = 0

;with CPUs as
		(select PRS_MOB_ID, max(PSN_Name) PSN_Name, sum(isnull(PRS_NumberOfCores, 1)) MachineCoreCount
			from Inventory.Processors
				inner join Inventory.ProcessorNames on PSN_ID = PRS_PSN_ID
			where exists (select * from Consolidation.ParticipatingDatabaseServers where PRS_MOB_ID = PDS_Server_MOB_ID)
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

select *
into #Payment
from Consolidation.fn_Reports_BillableByUsageCostBreakdown(@CLV_ID, default)
/*
select CLV_Name CloudProvider
from Consolidation.CloudProviders
where CLV_ID = @CLV_ID
*/

select 'Considered for Cloud'
select CGR_Name ServerGroup, MOB_Name OriginalMachineName, isnull(IDB_Name, '') DatabaseName,
	case when EXP_Reason is not null
		then 'No'
		else 'Yes'
	end [CanMoveToCloud?],
	isnull(EXP_Reason, '') Reasons,
	OST_Name OperatingSystem,
	isnull(CHA_Name, '') DatabaseEngine,
	isnull(CHE_Name, '') DatabaseEngineEdition,
	MachineCoreCount Cores,
	LicensingCores LicensedCores
from Consolidation.LoadBlocks l
	inner join Inventory.MonitoredObjects on MOB_ID = LBL_MOB_ID
	left join Inventory.InstanceDatabases on IDB_ID = LBL_IDB_ID
	inner join Consolidation.ServerGrouping on SGR_MOB_ID = MOB_ID
	inner join Consolidation.ConsolidationGroups on CGR_ID = SGR_CGR_ID
	inner join Consolidation.OSTypes on OST_ID = LBL_OST_ID
	left join Consolidation.CloudHostedApplications on CHA_ID = LBL_CHA_ID
	left join Consolidation.CloudHostedApplicationEditions on LBL_CHE_ID = CHE_ID
	outer apply (select top 1 EXP_Reason
					from Consolidation.Exceptions
					where EXP_EXT_ID = 3
						and EXP_MOB_ID = MOB_ID
						and EXP_HST_ID in (@Consolidation_HST_ID, @OneToOne_HST_ID)
						and (EXP_IDB_ID = LBL_IDB_ID
								or (EXP_IDB_ID is null
										and LBL_IDB_ID is null)
							)
				) e
	inner join #CoreInfo on PRS_MOB_ID = MOB_ID
order by ServerGroup, OriginalMachineName

select 'By usage billables'
select 'Consolidation: ' + ItemType as ItemType, ItemLevelName ItemSubType, isnull(StorageRedundancyLevelName, '') StorageRedundancyLevel, Units,
	iif(AmountToPay is null, 'Consult cloud provider regarding price as usage is very high', cast(AmountToPay as varchar(20))) AmountToPay
from Consolidation.fn_Reports_BillableByUsageCostBreakdown(@CLV_ID, @Consolidation_HST_ID)
union
select 'One-To-One: ' + ItemType as ItemType, ItemLevelName ItemSubType, isnull(StorageRedundancyLevelName, '') StorageRedundancyLevel, Units,
	iif(AmountToPay is null, 'Consult cloud provider regarding price as usage is very high', cast(AmountToPay as varchar(20))) AmountToPay
from Consolidation.fn_Reports_BillableByUsageCostBreakdown(@CLV_ID, @OneToOne_HST_ID)
order by /*StorageRedundancyLevelRank,*/ ItemType

select 'Consolidated - Summary'
select CGR_Name ServerGroup, isnull(SUM(CLB_BasePricePerMonthUSD), 0) EffectiveMonthlyCostWithoutStorageAndNetwork,
	TotalMachines, sum(Machines) CloudWorthyMachines, COUNT(distinct CLB_ID) CloudMachines,
	sum(iif(CPM_NumberOfMonths = 36, CMP_UpfrontPaymnetUSD, 0)) [3YearUpfrontPayment],
	sum(iif(CPM_NumberOfMonths = 12, CMP_UpfrontPaymnetUSD, 0)) [1YearUpfrontPayment],
	sum(CMP_MonthlyPaymentUSD) [ReservedPlanMonthlyPayment],
	sum(CMP_HourlyPaymentUSD*744) OnDemandMonthlyPayment
from (select LBL_CGR_ID, count(*) TotalMachines
		from Consolidation.LoadBlocks
		group by LBL_CGR_ID
				) n
	inner join Consolidation.ConsolidationGroups on CGR_ID = LBL_CGR_ID
	left join (Consolidation.ConsolidationBlocks
				inner join Consolidation.CloudMachinePricing on CMP_ID = CLB_CMP_ID
				inner join Consolidation.CloudMachinePaymentModels on CPM_ID = CMP_CPM_ID) on CGR_ID = CLB_CGR_ID
																					and CLB_DLR_ID is null
																					and CLB_HST_ID = @Consolidation_HST_ID
	outer apply (select count(*) Machines
					from Consolidation.ConsolidationBlocks_LoadBlocks
						inner join Consolidation.LoadBlocks on LBL_ID = CBL_LBL_ID
					where CBL_CLB_ID = CLB_ID
						and CBL_DLR_ID is null
				) l
group by CGR_Name, TotalMachines
order by ServerGroup

select 'Consolidated - Core count'
;with Licenses as
	(select CHA_Name DatabaseEngine, CHE_Name Edition, CMT_CoreCount NumberOfCores, case when CMT_CoreCount < 4 and CHA_ID = 1 then 4 else CMT_CoreCount end NumberOfLicensedCores,
			CHE_IsFree, PSH_CHE_ID, CLB_HST_ID
		from Consolidation.ConsolidationBlocks
			inner join Consolidation.PossibleHosts on PSH_ID = CLB_PSH_ID
			inner join Consolidation.CloudMachineTypes on CMT_ID = PSH_CMT_ID
			inner join Consolidation.ConsolidationGroups on CGR_ID = CLB_CGR_ID
			inner join Consolidation.CloudHostedApplications on CHA_ID = CLB_CHA_ID
			inner join Consolidation.CloudHostedApplicationEditions on CHE_ID = CLB_CHE_ID
		where CLB_DLR_ID is null
			and CLB_HST_ID = @Consolidation_HST_ID
	)
select DatabaseEngine, Edition, sum(NumberOfCores) NumberOfCores, sum(NumberOfLicensedCores) NumberOfLicensedCores,
	sum(case when CHE_IsFree = 0 and PSH_CHE_ID is null then NumberOfLicensedCores else 0 end) LicensesNotBoughtFromVendor
from Licenses
group by DatabaseEngine, Edition
order by DatabaseEngine, Edition

select 'Consolidated - VMs needed'
select CGR_Name ServerGroup, CMT_Name VMType, isnull(BUL_Name, '') StorageType, isnull(nullif(DiskCount, 0), '') DiskCount,
	isnull(OST_Name, '') OperatingSystem,
	isnull(CHA_Name, '') DatabaseEngine,
	isnull(CHE_Name, '') DatabaseEngineEdition,
	CMT_CoreCount NumberOfCores,
	CLB_ID BlockID, CLB_BasePricePerMonthUSD BasePrice, BlockMachines,
	isnull(cast(CurrentDataFileSize as varchar(100)), '') CurrentDataFileSizeMB,
	isnull(cast(EstimatedDataFilesMBIn3Years as varchar(100)), '') EstimatedDataFilesMBIn3Years,
	isnull(cast(LogFilesSizeMB as varchar(100)), '') LogFilesSizeMB,
	isnull(cast(TempdbSizeMB as varchar(100)), '') TempdbSizeMB,
	isnull(cast(NonSQLDiskSizeMB as varchar(100)), '') NonSQLDiskSizeMB,
	isnull(cast(TotalDiskSizeMB as varchar(100)), '') TotalDiskSizeMB,
	isnull(cast(DataFileIOPS as varchar(100)), '') DataFileIOPS,
	isnull(cast(LogFileIOPS as varchar(100)), '') LogFileIOPS,
	isnull(cast(TempdbIOPS as varchar(100)), '') TempdbIOPS,
	isnull(cast(TotalIOPS as varchar(100)), '') TotalIOPS
from Consolidation.ConsolidationBlocks
	cross apply (select count(*) BlockMachines,
						sum(DSI_DataFilesMB) CurrentDataFileSize, sum(DSI_DataFilesMBIn3Years) EstimatedDataFilesMBIn3Years, sum(DSI_LogFilesMB) LogFilesSizeMB,
						sum(DSI_TempdbMB) TempdbSizeMB,
						sum(LBL_DiskSize - isnull(DSI_DataFilesMB, 0) - isnull(DSI_LogFilesMB, 0) - isnull(DSI_TempdbMB, 0)) NonSQLDiskSizeMB,
						sum(ceiling(DII_DataFileTransfers + DII_DataFileTransfers*(@DiskIOBufferPercentage/100.))) DataFileIOPS,
						sum(ceiling(DII_LogFileTransfers + DII_LogFileTransfers*(@DiskIOBufferPercentage/100.))) LogFileIOPS,
						sum(ceiling(DII_TempdbTransfers + DII_TempdbTransfers*(@DiskIOBufferPercentage/100.))) TempdbIOPS,
						sum(ceiling((LBL_ReadsSec+LBL_WritesSec) + (LBL_ReadsSec+LBL_WritesSec)*(@DiskIOBufferPercentage/100.))) TotalIOPS,
						sum(ceiling((LBL_ReadsMBSec+LBL_WritesMBSec) + (LBL_ReadsMBSec+LBL_WritesMBSec)*(@DiskIOBufferPercentage/100.))) TotalMBPS,
						sum(ceiling(LBL_DiskSize + LBL_DiskSize*(@DiskSizeBufferPercentage/100.))) TotalDiskSizeMB
					from Consolidation.ConsolidationBlocks_LoadBlocks
						inner join Consolidation.LoadBlocks on LBL_ID = CBL_LBL_ID
						inner join Consolidation.DiskIOInfo on DII_MOB_ID = LBL_MOB_ID
						inner join Consolidation.DiskInfo on DSI_MOB_ID = LBL_MOB_ID
					where CBL_CLB_ID = CLB_ID
						and CBL_DLR_ID is null
				) l
	inner join Consolidation.PossibleHosts on PSH_ID = CLB_PSH_ID
	left join Consolidation.BillableByUsageItemLevels on BUL_ID = PSH_Storage_BUL_ID
	inner join Consolidation.CloudMachineTypes on CMT_ID = PSH_CMT_ID
	inner join Consolidation.ConsolidationGroups on CGR_ID = CLB_CGR_ID
	left join Consolidation.OSTypes on OST_ID = CLB_OST_ID
	left join Consolidation.CloudHostedApplications on CHA_ID = CLB_CHA_ID
	left join Consolidation.CloudHostedApplicationEditions on CLB_CHE_ID = CHE_ID
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
	and CLB_HST_ID = @Consolidation_HST_ID
order by CGR_Name, VMType, OST_Name desc, DatabaseEngine, DatabaseEngineEdition

select 'Consolidated - Assign machines'
;with Payment as
		(select ItemType, sum(AmountToPayWithoutUnPriced) AmountToPay
			from Consolidation.fn_Reports_BillableByUsageCostBreakdown(@CLV_ID, @Consolidation_HST_ID)
			where StorageRedundancyLevelRank = 1
			group by ItemType
		)
	, UsageBillables as
		(select [Storage space] MonthlyStorageCost, [Storage transactions] EstimatedMonthlyStorageTransactionsCost, [Network usage] EstimatedMonthlyNetworkCost
			from Payment
				pivot (sum(AmountToPay)
						for ItemType IN ([Storage space], [Storage transactions], [Network usage])) p
		)
select CGR_Name ServerGroup, CMT_Name VMType,
	isnull(OST_Name, '') OperatingSystem,
	isnull(CHA_Name, '') DatabaseEngine,
	isnull(CHE_Name, '') DatabaseEngineEdition,
	CLB_ID BlockID, MOB_Name OriginalMachineName, ISNULL(IDB_Name, '') DatabaseName,
	cast(CLB_BasePricePerMonthUSD/COUNT(*) over (partition by CLB_ID) as decimal(10, 2)) RelativeEffectiveMachineMonthlyCost,
	cast(CBL_BufferedDiskSizeMB*1./SUM(CBL_BufferedDiskSizeMB) over()*MonthlyStorageCost as decimal(15, 3)) RelativeStoragePrice,
	cast(CBL_AvgMonthlyIOPS*1./SUM(CBL_AvgMonthlyIOPS) over()*EstimatedMonthlyStorageTransactionsCost as decimal(15, 3)) RelativeStorageTransactionPrice,
	cast(CBL_AvgMonthlyNetworkOutboundMB*1./SUM(CBL_AvgMonthlyNetworkOutboundMB) over()*EstimatedMonthlyNetworkCost as decimal(15, 3)) RelativeNetworkPrice
from Consolidation.ConsolidationBlocks
	inner join Consolidation.ConsolidationBlocks_LoadBlocks on CBL_CLB_ID = CLB_ID
	inner join Consolidation.PossibleHosts on PSH_ID = CLB_PSH_ID
	inner join Consolidation.CloudMachineTypes on CMT_ID = PSH_CMT_ID
	inner join Consolidation.LoadBlocks on LBL_ID = CBL_LBL_ID
	inner join Inventory.MonitoredObjects on MOB_ID = LBL_MOB_ID
	inner join Consolidation.ConsolidationGroups on CGR_ID = CLB_CGR_ID
	left join Consolidation.OSTypes on OST_ID = CLB_OST_ID
	left join Consolidation.CloudHostedApplications on CHA_ID = CLB_CHA_ID
	left join Consolidation.CloudHostedApplicationEditions on CLB_CHE_ID = CHE_ID
	cross join UsageBillables
	left join Inventory.InstanceDatabases on IDB_ID = LBL_IDB_ID
where CLB_DLR_ID is null
	and CBL_DLR_ID is null
	and CLB_HST_ID = @Consolidation_HST_ID
order by ServerGroup, VMType, BlockID

select 'Consolidation conflicts'
select *
from Consolidation.fn_ConsolidationConflicts(@CLV_ID)

select 'One-To-One - Summary'
select CGR_Name ServerGroup, isnull(SUM(CLB_BasePricePerMonthUSD), 0) EffectiveMonthlyCostWithoutStorageAndNetwork,
	isnull(cast(SUM(iif(CPM_NumberOFMonths = 0, CLB_BasePricePerMonthUSD*MAC_PercentActive/100, CLB_BasePricePerMonthUSD)) as decimal(18, 3)), 0) EffectiveMonthlyCostWithoutStorageAndNetworkWithAvailabilityPercentage,
	TotalMachines, COUNT(distinct CLB_ID) CloudWorthyMachines,
	sum(iif(CPM_NumberOfMonths = 36, CMP_UpfrontPaymnetUSD, 0)) [3YearUpfrontPayment],
	sum(iif(CPM_NumberOfMonths = 12, CMP_UpfrontPaymnetUSD, 0)) [1YearUpfrontPayment],
	sum(CMP_MonthlyPaymentUSD) [ReservedPlanMonthlyPayment],
	sum(CMP_HourlyPaymentUSD*744) OnDemandMonthlyPayment
from (select LBL_CGR_ID, count(*) TotalMachines
		from Consolidation.LoadBlocks
		group by LBL_CGR_ID
				) n
	inner join Consolidation.ConsolidationGroups on CGR_ID = LBL_CGR_ID
	left join (Consolidation.ConsolidationBlocks
				inner join Consolidation.CloudMachinePricing on CMP_ID = CLB_CMP_ID
				inner join Consolidation.CloudMachinePaymentModels on CPM_ID = CMP_CPM_ID) on CGR_ID = CLB_CGR_ID
																					and CLB_DLR_ID is null
																					and CLB_HST_ID = @OneToOne_HST_ID
	left join Consolidation.ConsolidationBlocks_LoadBlocks on CBL_CLB_ID = CLB_ID
	left join Consolidation.LoadBlocks on LBL_ID = CBL_LBL_ID
	left join Consolidation.MachineActivity on MAC_MOB_ID = LBL_MOB_ID
group by CGR_Name, TotalMachines
order by ServerGroup

select 'One-To-One - Core count'
;with Licenses as
	(select CHA_Name DatabaseEngine, CHE_Name Edition, CMT_CoreCount NumberOfCores, case when CMT_CoreCount < 4 and CHA_ID = 1 then 4 else CMT_CoreCount end NumberOfLicensedCores,
			CHE_IsFree, PSH_CHE_ID, CLB_HST_ID
		from Consolidation.ConsolidationBlocks
			inner join Consolidation.PossibleHosts on PSH_ID = CLB_PSH_ID
			inner join Consolidation.CloudMachineTypes on CMT_ID = PSH_CMT_ID
			inner join Consolidation.ConsolidationGroups on CGR_ID = CLB_CGR_ID
			inner join Consolidation.CloudHostedApplications on CHA_ID = CLB_CHA_ID
			inner join Consolidation.CloudHostedApplicationEditions on CHE_ID = CLB_CHE_ID
		where CLB_DLR_ID is null
			and CLB_HST_ID = @OneToOne_HST_ID
	)
select DatabaseEngine, Edition, sum(NumberOfCores) NumberOfCores, sum(NumberOfLicensedCores) NumberOfLicensedCores,
	sum(case when CHE_IsFree = 0 and PSH_CHE_ID is null then NumberOfLicensedCores else 0 end) LicensesNotBoughtFromVendor
from Licenses
group by DatabaseEngine, Edition
order by DatabaseEngine, Edition

select 'One-To-One - VMs needed'
select CGR_Name ServerGroup, CMT_Name VMType, isnull(BUL_Name, '') StorageType, isnull(nullif(DiskCount, 0), '') DiskCount,
	isnull(OST_Name, '') OperatingSystem,
	isnull(CHA_Name, '') DatabaseEngine,
	isnull(CHE_Name, '') DatabaseEngineEdition,
	CMT_CoreCount NumberOfCores,
	MOB_Name OriginalMachineName, ISNULL(IDB_Name, '') DatabaseName, CLB_ID BlockID, CLB_BasePricePerMonthUSD EffectiveMachineMonthlyCost, cast(MAC_PercentActive as decimal(10, 3)) PercentActive,
	cast(CLB_BasePricePerMonthUSD*MAC_PercentActive/100 as decimal(15, 3)) ActivePercentCalculatedPrice,
	isnull(cast(DSI_DataFilesMB as varchar(100)), '') CurrentDataFileSizeMB,
	isnull(cast(DSI_DataFilesMBIn3Years as varchar(100)), '') EstimatedDataFilesMBIn3Years,
	isnull(cast(DSI_LogFilesMB as varchar(100)), '') LogFilesSizeMB,
	isnull(cast(DSI_TempdbMB as varchar(100)), '') TempdbSizeMB,
	isnull(cast(LBL_DiskSize - isnull(DSI_DataFilesMB, 0) - isnull(DSI_LogFilesMB, 0) - isnull(DSI_TempdbMB, 0) as varchar(100)), '') NonSQLDiskSizeMB,
	isnull(cast(ceiling(DII_DataFileTransfers + DII_DataFileTransfers*(@DiskIOBufferPercentage/100.)) as varchar(100)), '') DataFileIOPS,
	isnull(cast(ceiling(DII_LogFileTransfers + DII_LogFileTransfers*(@DiskIOBufferPercentage/100.)) as varchar(100)), '') LogFileIOPS,
	isnull(cast(ceiling(DII_TempdbTransfers + DII_TempdbTransfers*(@DiskIOBufferPercentage/100.)) as varchar(100)), '') TempdbIOPS,
	isnull(cast(TotalIOPS as varchar(100)), '') TotalIOPS
from Consolidation.ConsolidationBlocks
	inner join Consolidation.ConsolidationBlocks_LoadBlocks on CBL_CLB_ID = CLB_ID
	inner join Consolidation.LoadBlocks on LBL_ID = CBL_LBL_ID
	cross apply (select ceiling((LBL_ReadsSec+LBL_WritesSec) + (LBL_ReadsMBSec+LBL_WritesMBSec)*(@DiskIOBufferPercentage/100.)) TotalIOPS,
						ceiling((LBL_ReadsMBSec+LBL_WritesMBSec) + (LBL_ReadsMBSec+LBL_WritesMBSec)*(@DiskIOBufferPercentage/100.)) TotalMBPS,
						ceiling(LBL_DiskSize + LBL_DiskSize*(@DiskSizeBufferPercentage/100.)) TotalDiskSizeMB
				) r
	inner join Inventory.MonitoredObjects on MOB_ID = LBL_MOB_ID
	inner join Consolidation.PossibleHosts on PSH_ID = CLB_PSH_ID
	left join Consolidation.BillableByUsageItemLevels on BUL_ID = PSH_Storage_BUL_ID
	inner join Consolidation.CloudMachineTypes on CMT_ID = PSH_CMT_ID
	inner join Consolidation.ConsolidationGroups on CGR_ID = CLB_CGR_ID
	left join Consolidation.OSTypes on OST_ID = CLB_OST_ID
	left join Consolidation.CloudHostedApplications on CHA_ID = CLB_CHA_ID
	left join Consolidation.CloudHostedApplicationEditions on CLB_CHE_ID = CHE_ID
	inner join Consolidation.DiskIOInfo on DII_MOB_ID = LBL_MOB_ID
	inner join Consolidation.DiskInfo on DSI_MOB_ID = LBL_MOB_ID
											and (DSI_IDB_ID = LBL_IDB_ID
													or (DSI_IDB_ID is null
														and LBL_IDB_ID is null)
												)
	inner join Consolidation.MachineActivity on MAC_MOB_ID = LBL_MOB_ID
	left join Inventory.InstanceDatabases on IDB_ID = LBL_IDB_ID
	outer apply (select top 1 CST_DiskCount DiskCount
					from Consolidation.CloudStorageThroughput
					where CST_BUL_ID = BUL_ID
						and BUL_Limitations.value('(Parameters/@MaxGBPerDisk)[1]', 'int')*1024*CST_DiskCount >= TotalDiskSizeMB
						and CST_MaxIOPS8KB >= iif(CLB_DiskBlockSize = 8, TotalIOPS, 0)
						and CST_MaxMBPerSec8KB >= iif(CLB_DiskBlockSize = 8, TotalMBPS, 0)
						and CST_MaxIOPS64KB >= iif(CLB_DiskBlockSize = 64, TotalIOPS, 0)
						and CST_MaxMBPerSec64KB >= iif(CLB_DiskBlockSize = 64, TotalMBPS, 0)
					order by CST_DiskCount) d
where CLB_HST_ID = @OneToOne_HST_ID
	and CLB_DLR_ID is null
	and CBL_DLR_ID is null
order by CGR_Name, VMType, OST_Name desc, DatabaseEngine, DatabaseEngineEdition
GO
