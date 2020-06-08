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
/****** Object:  StoredProcedure [Consolidation].[usp_FinalizeOnPremConsolidation]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Consolidation].[usp_FinalizeOnPremConsolidation]
as
declare @CPUBufferPercentage int,
		@MemoryBufferPercentage int,
		@DiskIOBufferPercentage int,
		@CPUCapPercentage int,
		@MemoryCapPercentage int,
		@CPUStretchingRatio decimal(10, 2),
		@RedFlagHostBuffer decimal(10, 2),
		@RedFlagLoadBuffer decimal(10, 2)

select @CPUBufferPercentage = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'CPU Buffer Percentage'

select @MemoryBufferPercentage = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Memory Buffer Percentage'

select @DiskIOBufferPercentage = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Disk IO Buffer Percentage'

select @CPUCapPercentage = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'CPU Cap Percentage'

select @MemoryCapPercentage = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Memory Cap Percentage'

select @CPUStretchingRatio = CAST(SET_Value as decimal(10, 2))
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Virtualization - CPU Core Stretch Ratio'

select @RedFlagHostBuffer = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Red Flag Host Buffer'

select @RedFlagLoadBuffer = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Red Flag Work Load Buffer'

declare @CPUBufferForCalculation decimal(10, 2) = 1 + @CPUBufferPercentage/100.,
		@MemoryBufferForCalculation decimal(10, 2) = 1 + @MemoryBufferPercentage/100.,
		@CPUCapForCalculation decimal(10, 2) = @CPUCapPercentage/100.,
		@MemoryCapForCalculation decimal(10, 2) = @MemoryCapPercentage/100.,
		@RedFlagHostBufferMultiplier decimal(10, 2) = 1 + @RedFlagHostBuffer/100.,
		@RedFlagLoadBufferMultiplier decimal(10, 2) = 1 + @RedFlagLoadBuffer/100.

set nocount on
if OBJECT_ID('tempdb..#BestPerMachine') is not null
	drop table #BestPerMachine
if OBJECT_ID('tempdb..#MachinesNotInTopBlocks') is not null
	drop table #MachinesNotInTopBlocks
if OBJECT_ID('tempdb..#UnnecessaryMigrations') is not null
	drop table #UnnecessaryMigrations
if OBJECT_ID('tempdb..#MSCoreCountFactor') is not null
	drop table #MSCoreCountFactor
if OBJECT_ID('tempdb..#CoreInfo') is not null
	drop table #CoreInfo

truncate table Consolidation.WeakMachines

create table #MSCoreCountFactor
	(CoreCount int null,
	CPUNamePattern varchar(100) null,
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
						or (PSN_Name like CPUNamePattern collate database_default
							and MachineCoreCount >= CPUNamePatternMinCoreCount)
				) f

--Reset
update Consolidation.ConsolidationBlocks
set CLB_DLR_ID = null
from Consolidation.HostTypes
where CLB_DLR_ID in (3, 4)
	and CLB_HST_ID = HST_ID
	and HST_NumberOfInstancesPerHost = 1

update Consolidation.ConsolidationBlocks_LoadBlocks
set CBL_DLR_ID = null
from Consolidation.HostTypes
where CBL_DLR_ID in (2, 3)
	and CBL_HST_ID = HST_ID
	and HST_NumberOfInstancesPerHost = 1

;with Combinations as -- ConsolidationCombinations
			(select CBL_ID ID, CLB_ID BlockID, PSH_ID MachineID, CBL_LBL_ID SourceMachineID, COUNT(*) over(partition by CLB_ID) MachinesInBlock,
					PSH_PricePerMonthUSD Price, CLB_CHE_ID
				from Consolidation.ConsolidationBlocks
					inner join Consolidation.ConsolidationBlocks_LoadBlocks on CBL_CLB_ID = CLB_ID
					inner join Consolidation.PossibleHosts on PSH_ID = CLB_PSH_ID
					inner join Consolidation.HostTypes on HST_ID = PSH_HST_ID
				where CLB_DLR_ID is null
					and CBL_DLR_ID is null
					and HST_NumberOfInstancesPerHost = 1
			)
	, BlockRanking as
			(select BlockID, row_number() over (partition by MachineID order by CLB_CHE_ID desc, MachinesInBlock desc) BlockRank
				from (select distinct BlockID, MachineID, CLB_CHE_ID, MachinesInBlock
						from Combinations) c
			)
	, RankedBlocks as
			(select ID, c.BlockID, MachineID, SourceMachineID, Price, MachinesInBlock, BlockRank
				from Combinations c
					inner join BlockRanking r on c.BlockID = r.BlockID
			)
	, MachinesNotInTopRankedBlocks as
			(select ID, BlockID, MachineID, SourceMachineID, Price, MachinesInBlock, BlockRank, ROW_NUMBER() over (partition by SourceMachineID order by Price) brn
				from RankedBlocks rb
				where exists
					(
						select *
						from RankedBlocks r
						group by SourceMachineID
						having min(BlockRank) > 1
							and rb.SourceMachineID = r.SourceMachineID
								and rb.BlockRank = min(BlockRank)
					)
			)
select distinct MachineID, BlockID, SourceMachineID, MachinesInBlock, Price
into #MachinesNotInTopBlocks
from MachinesNotInTopRankedBlocks
where brn = 1

;with Combinations as -- ConsolidationCombinations
			(select CBL_ID ID, CLB_ID BlockID, PSH_ID MachineID, CBL_LBL_ID SourceMachineID, COUNT(*) over(partition by CLB_ID) MachinesInBlock,
					PSH_PricePerMonthUSD Price
				from Consolidation.ConsolidationBlocks
					inner join Consolidation.ConsolidationBlocks_LoadBlocks on CBL_CLB_ID = CLB_ID
					inner join Consolidation.PossibleHosts on PSH_ID = CLB_PSH_ID
					inner join Consolidation.HostTypes on HST_ID = PSH_HST_ID
				where CLB_DLR_ID is null
					and CBL_DLR_ID is null
					and HST_NumberOfInstancesPerHost = 1
			)
	, BlockRanking as
			(select BlockID, row_number() over (partition by MachineID order by MachinesInBlock desc) BlockRank
				from (select distinct BlockID, MachineID, MachinesInBlock
						from Combinations) c
			)
	, RankedBlocks as
			(select ID, c.BlockID, MachineID, SourceMachineID, MachinesInBlock, BlockRank, Price,
					ROW_NUMBER() over (order by MachinesInBlock desc) TieBreaker
				from Combinations c
					inner join BlockRanking r on c.BlockID = r.BlockID
			)
select ID, BlockID, MachineID, SourceMachineID, MachinesInBlock, Price, TieBreaker
into #BestPerMachine
from RankedBlocks b
where BlockRank = 1
		and not exists (select *
						from #MachinesNotInTopBlocks n
						where b.MachineID = MachineID)
union all
select ID, r.BlockID, r.MachineID, SourceMachineID, MachinesInBlock, Price, TieBreaker
from RankedBlocks r
		inner join (select BlockID, MachineID, ROW_NUMBER() over(partition by MachineID order by MachinesInBlock desc, Price) MachineBlockRank
						from #MachinesNotInTopBlocks n) n on r.BlockID = n.BlockID
where MachineBlockRank = 1

update Consolidation.ConsolidationBlocks
set CLB_DLR_ID = 3
where CLB_DLR_ID is null
	and CLB_ID not in (select BlockID
						from #BestPerMachine)
	and exists (select *
				from Consolidation.HostTypes
				where HST_ID = CLB_HST_ID
					and HST_NumberOfInstancesPerHost = 1)

update Consolidation.ConsolidationBlocks_LoadBlocks
set CBL_DLR_ID = 3
where CBL_DLR_ID is null
	and CBL_ID in (select ID
					from #BestPerMachine b
					where exists (select *
									from #BestPerMachine b1
									where b1.SourceMachineID = b.SourceMachineID
										and b1.BlockID <> b.BlockID
										and (b1.MachinesInBlock > b.MachinesInBlock
												or (b1.MachinesInBlock = b.MachinesInBlock
														and b1.Price < b.Price)
												or (b1.MachinesInBlock = b.MachinesInBlock
														and b1.Price = b.Price
														and b1.TieBreaker > b.TieBreaker)
											)
									)
				)

;with Combinations as -- ConsolidationCombinations
			(select PSH_ID, LBL_ID, CLB_ID, PSH_MOB_ID, LBL_MOB_ID, LBL_ID SourceMachineID, PSH_PricePerMonthUSD Price, CLB_DLR_ID, CBL_DLR_ID
				from Consolidation.ConsolidationBlocks
					inner join Consolidation.ConsolidationBlocks_LoadBlocks on CBL_CLB_ID = CLB_ID
					inner join Consolidation.PossibleHosts on PSH_ID = CLB_PSH_ID
					inner join Consolidation.LoadBlocks on LBL_ID = CBL_LBL_ID
					inner join Consolidation.HostTypes on HST_ID = PSH_HST_ID
				where HST_NumberOfInstancesPerHost = 1
			)
	, FilteredCombinations as -- ConsolidationCombinations
			(select PSH_ID, LBL_ID, CLB_ID, PSH_MOB_ID, LBL_MOB_ID, SourceMachineID, Price
				from Combinations
				where CLB_DLR_ID is null
					and CBL_DLR_ID is null
			)
select c.LBL_ID SourceMachineID, c.CLB_ID CurrentBlockID, c1.CLB_ID ShouldBeBlockID
into #UnnecessaryMigrations
from FilteredCombinations c
	cross apply (select top 1 c1.CLB_ID
					from FilteredCombinations c1
					where c1.PSH_MOB_ID = c.LBL_MOB_ID
				) c1
where PSH_MOB_ID <> LBL_MOB_ID
	and exists (select *
					from Combinations c2
					where c2.CLB_ID = c1.CLB_ID
						and c2.LBL_ID = c.LBL_ID
				)

update Consolidation.ConsolidationBlocks_LoadBlocks
set CBL_DLR_ID = 3
from #UnnecessaryMigrations
where CBL_CLB_ID = CurrentBlockID
	and CBL_LBL_ID = SourceMachineID

update Consolidation.ConsolidationBlocks_LoadBlocks
set CBL_DLR_ID = null
from #UnnecessaryMigrations
where CBL_CLB_ID = ShouldBeBlockID
	and CBL_LBL_ID = SourceMachineID

update Consolidation.ConsolidationBlocks
set CLB_DLR_ID = 4
where CLB_DLR_ID is null
	and not exists (select *
						from Consolidation.ConsolidationBlocks_LoadBlocks
						where CBL_CLB_ID = CLB_ID
							and CBL_DLR_ID is null
					)
	and exists (select *
				from Consolidation.HostTypes
				where HST_ID = CLB_HST_ID
					and HST_NumberOfInstancesPerHost = 1)

;with Duplicates as
		(select CBL_ID A_CBL_ID, CBL_LBL_ID, row_number() over (partition by CBL_LBL_ID order by CLB_CappedCPUStrength desc, CLB_CappedMemoryMB desc) rn
			from Consolidation.ConsolidationBlocks
				inner join Consolidation.ConsolidationBlocks_LoadBlocks on CBL_CLB_ID = CLB_ID
				inner join Consolidation.HostTypes on HST_ID = CLB_HST_ID
			where HST_NumberOfInstancesPerHost = 1
				and CLB_DLR_ID is null
				and CBL_DLR_ID is null
		)
update Consolidation.ConsolidationBlocks_LoadBlocks
set CBL_DLR_ID = 2
from Duplicates
where CBL_ID = A_CBL_ID
	and rn > 1

--;with Combinations as -- ConsolidationCombinations
--		(select LBL_CGR_ID, PSH_MOB_ID, LBL_MOB_ID, LBL_ID SourceMachineID, PSH_PricePerMonthUSD Price,
--				CLB_OST_ID, CLB_CHA_ID, CLB_ID, CLB_CHE_ID
--			from Consolidation.ConsolidationBlocks
--				inner join Consolidation.ConsolidationBlocks_LoadBlocks on CBL_CLB_ID = CLB_ID
--				inner join Consolidation.PossibleHosts on PSH_ID = CLB_PSH_ID
--				inner join Consolidation.LoadBlocks on LBL_ID = CBL_LBL_ID
--				inner join Consolidation.HostTypes on HST_ID = PSH_HST_ID
--			where CLB_DLR_ID is null
--				and CBL_DLR_ID is null
--				and HST_NumberOfInstancesPerHost = 1
--		)
--	, OnPrem as
--		(select LBL_CGR_ID OPR_CGR_ID, PSH_MOB_ID New_MOB_ID, LBL_MOB_ID Original_MOB_ID, Price, CLB_OST_ID, CLB_CHA_ID, 0 RedFlagged, CHE_Name Edition
--			from Combinations
--				left join Consolidation.CloudHostedApplicationEditions on CHE_ID = CLB_CHE_ID
--			union all
--			select LBL_CGR_ID OPR_CGR_ID, PSH_MOB_ID New_MOB_ID, LBL_MOB_ID Original_MOB_ID, PSH_PricePerMonthUSD Price, LBL_OST_ID, LBL_CHA_ID, 1 RedFlagged, CHE_Name Edition
--			from Consolidation.LoadBlocks
--				inner join Consolidation.PossibleHosts on PSH_MOB_ID = LBL_MOB_ID
--				inner join Inventory.MonitoredObjects on MOB_ID = PSH_MOB_ID
--				left join Consolidation.CloudHostedApplicationEditions on CHE_ID = LBL_CHE_ID
--			where not exists (select *
--								from Combinations
--								where LBL_ID = SourceMachineID)
--				and exists (select *
--								from Consolidation.ServerPossibleHostTypes
--								where SHT_MOB_ID = LBL_MOB_ID
--									and SHT_HST_ID in (1, 2))
--		)
--insert into Consolidation.OnPrem
--select p.*, o.MachineCoreCount OriginalCoreCount, o.LicensingCores OriginalLicensingCoreCount,
--	n.MachineCoreCount NewCoreCount, n.LicensingCores NewLicensingCoreCount
--from OnPrem p
--	inner join #CoreInfo o on o.PRS_MOB_ID = Original_MOB_ID
--	inner join #CoreInfo n on n.PRS_MOB_ID = Original_MOB_ID

;with NeedABoost as
		(select PSH_MOB_ID, case when CPUCap < CPUBuffered then 1 else 0 end CPU,
				case when MemoryCap < MemoryBuffered then 1 else 0 end Memory, PSH_MemoryMB, OPR_NewCoreCount CoreCount,
				case when MemoryCap < MemoryBuffered
						then ((MemoryBuffered/@MemoryCapPercentage*100 - PSH_MemoryMB) + 1023)/1024*1024
						else (cast(ceiling(PSH_MemoryMB*(@RedFlagHostBufferMultiplier - 1)) as int) + 1023)/1024*1024
					end AddMemory,
				cast(case when CPUCap < CPUBuffered
					then ceiling((CPUBuffered*100.0/PSH_CPUStrength)/@CPUCapPercentage*PSH_CoreCount - PSH_CoreCount) -- OPR_NewCoreCount
					else OPR_NewCoreCount*(@RedFlagHostBufferMultiplier - 1)
					end as int) AddCores,
				case when isnull(PSH_MaxDiskSizeMB, PSH_MaxDataFilesDiskSizeMB) < 0 then -isnull(PSH_MaxDiskSizeMB, PSH_MaxDataFilesDiskSizeMB) end AddDiskSpace,
				LBL_CGR_ID
			from Consolidation.PossibleHosts
				inner join Consolidation.LoadBlocks on LBL_MOB_ID = PSH_MOB_ID
				cross apply (select cast(PSH_CPUStrength*@CPUCapForCalculation as int) CPUCap,
								cast(PSH_MemoryMB*@MemoryCapForCalculation as int) MemoryCap,
								cast(LBL_CPUStrength*@CPUBufferForCalculation as int) CPUBuffered,
								cast(LBL_MemoryMB*@MemoryBufferForCalculation as int) MemoryBuffered
								) c
				inner join Consolidation.VW_OnPrem r on OPR_New_MOB_ID = PSH_MOB_ID
												and OPR_RedFlagged = 1
			where (CPUCap < CPUBuffered
					or MemoryCap < MemoryBuffered
					or (isnull(PSH_MaxDiskSizeMB, PSH_MaxDataFilesDiskSizeMB) is not null
							and isnull(PSH_MaxDiskSizeMB, PSH_MaxDataFilesDiskSizeMB) < 0)
						)
		)
insert into Consolidation.WeakMachines
select distinct PSH_MOB_ID,
		stuff(concat(case when CPU = 1 then case when AddCores > 0 then concat(', Add ', AddCores, ' Core(s)') else ', More CPU strength is needed' end end,
					case when Memory = 1 then case when AddMemory > 0 then concat(', Add ', case when AddMemory > 10240 then 10240 else AddMemory end, ' MB of RAM') else ', More memory is needed' end end,
					case when AddDiskSpace is not null then concat(', Add ', AddDiskSpace/1024, 'GB of disk space to accommodate data growth in the next 3 years') end
					), 1, 2, '') Comments, Memory, CPU
from NeedABoost
GO
