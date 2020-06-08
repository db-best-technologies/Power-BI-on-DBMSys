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
/****** Object:  StoredProcedure [Consolidation].[usp_ProcessVirtualization]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Consolidation].[usp_ProcessVirtualization]
as
declare @CPUBufferPercentage int,
	@MemoryBufferPercentage int,
	@NetworkBufferPercentage int,
	@DiskIOBufferPercentage int,
	@CPUCapPercentagePerVM int,
	@MemoryCapPercentagePerVM int,
	@NetworkCapPercentagePerVM int,
	@ESXVirtualCores int,
	@ESXMemory int,
	@ExcludeCurrentlyVirtualized bit,
	@Buckets int,
	@CPUStretchingRatio decimal(10, 2),
	@StretchedCPUFactor decimal(10, 2)

select @CPUBufferPercentage = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'CPU Buffer Percentage'

select @MemoryBufferPercentage = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Memory Buffer Percentage'

select @NetworkBufferPercentage = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Network Speed Buffer Percentage'

select @DiskIOBufferPercentage = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Disk IO Buffer Percentage'

select @CPUCapPercentagePerVM = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'CPU Cap Percentage'

select @MemoryCapPercentagePerVM = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Memory Cap Percentage'

select @NetworkCapPercentagePerVM = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Network Speed Cap Percentage'

select @ESXVirtualCores = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Virtualization - Number Of Virtual CoresTo Reserve For ESX'

select @ESXMemory = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Virtualization - Memory To Reserve For ESX'

select @ExcludeCurrentlyVirtualized = CAST(SET_Value as bit)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Virtualization - Exclude Currently Virtualized'

select @Buckets = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Virtualization - Number Of Buckets'

select @Buckets = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Virtualization - Number Of Buckets'

select @CPUStretchingRatio = CAST(SET_Value as decimal(10, 2))
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Virtualization - CPU Core Stretch Ratio'

select @StretchedCPUFactor = CAST(SET_Value as decimal(10, 2))
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Virtualization - Factor For Stretched CPUs'

delete Consolidation.ConsolidationBlocks_LoadBlocks
where CBL_HST_ID = 4

delete Consolidation.ConsolidationBlocks
where CLB_HST_ID = 4

if object_id('tempdb..#Groups') is not null
	drop table #Groups
create table #Groups
	(CGR_ID int)
if object_id('tempdb..#AvailableHosts') is not null
	drop table #AvailableHosts
if object_id('tempdb..#AvailableHosts') is not null
	drop table #AvailableHosts
if object_id('tempdb..#Loads') is not null
	drop table #Loads

insert into #Groups
select PSA_CGR_ID
from Consolidation.PossibleHosts
	inner join Consolidation.PossibleHostsConsolidationGroupAffinity on PSA_PSH_ID = PSH_ID
where PSH_HST_ID = 4

select CGR_ID, PSH_ID, PSH_OST_ID, PSH_CoreCount - @ESXVirtualCores AvailableVirtualCores,
			PSH_CPUStrength*@StretchedCPUFactor/PSH_CoreCount CPUStrengthPerCore, PSH_MemoryMB - @ESXMemory AvailableMemoryMB,
			PSH_NetworkSpeedMbit AvailableNetworkSpeedMbit
into #AvailableHosts
from Consolidation.PossibleHosts
	inner join Consolidation.PossibleHostsConsolidationGroupAffinity on PSA_PSH_ID = PSH_ID
	inner join #Groups on (CGR_ID = PSA_CGR_ID
								or PSA_CGR_ID is null)
	cross apply (select (PSH_CoreCount - @ESXVirtualCores) AvailableVirtualCores) c
where PSH_HST_ID = 4

declare @LBL_ID int,
	@CGR_ID int,
	@CoreCount int,
	@CPUUsage int,
	@MemoryMB bigint,
	@NetworkMbit bigint,
	@NetworDownloadkMbit bigint,
	@NetworkUploadMbit bigint,
	@DiskBlockSize int,
	@Edition varchar(100),
	@CurrentBlockID int

declare cLoadBlocks cursor static for
	select LBL_ID, LBL_CGR_ID, isnull(BucketCores, Cores) Cores, ISNULL(BucketCPUUsage, CPUUsage) CPUUsage, isnull(BucketMemory, MemoryUsage) MemoryUsage,
		NetworkUsage, NetworkDownloadUsage, NetworkUploadUsage, LBL_BlockSize, LBL_CHE_ID
	from Consolidation.LoadBlocks
		cross apply (select MAX(CPUStrengthPerCore) MaxCPUStrengthPerCore
					from #AvailableHosts
					where (CGR_ID = LBL_CGR_ID
							or CGR_ID is null)) m
		cross apply (select (LBL_CPUStrength + LBL_CPUStrength*(@CPUBufferPercentage/100.))*100/@CPUCapPercentagePerVM CPUUsage,
						cast(((LBL_MemoryMB + LBL_MemoryMB*(@MemoryBufferPercentage/100.))*100/@MemoryCapPercentagePerVM + 1023) as int)/1024*1024 MemoryUsage,
						(LBL_NetworkUsageDownloadMbit + LBL_NetworkUsageUploadMbit
							+ (LBL_NetworkUsageDownloadMbit + LBL_NetworkUsageUploadMbit)*(@NetworkBufferPercentage/100.))*100/@NetworkCapPercentagePerVM NetworkUsage,
						(LBL_NetworkUsageDownloadMbit + LBL_NetworkUsageDownloadMbit*(@NetworkBufferPercentage/100.))*100/@NetworkCapPercentagePerVM NetworkDownloadUsage,
						(LBL_NetworkUsageUploadMbit + LBL_NetworkUsageUploadMbit*(@NetworkBufferPercentage/100.))*100/@NetworkCapPercentagePerVM NetworkUploadUsage
					) u
		cross apply (select isnull(nullif((cast(ceiling(CPUUsage/MaxCPUStrengthPerCore) as int) + 1)/2*2, 0), 1) Cores) ci
		outer apply (select case when Cores < VBC_FromNumberOfCores
									then VBC_FromNumberOfCores
								when Cores > VBC_ToNumberOfCores
									then VBC_ToNumberOfCores
								else Cores
							end BucketCores,
							case when Cores < VBC_FromNumberOfCores
									then VBC_FromNumberOfCores
								when Cores > VBC_ToNumberOfCores
									then VBC_ToNumberOfCores
								else Cores
							end*MaxCPUStrengthPerCore BucketCPUUsage,
							case when MemoryUsage < VBC_FromMemoryMB
									then VBC_FromMemoryMB
								when MemoryUsage > VBC_ToMemoryMB
									then VBC_ToMemoryMB
								else MemoryUsage
							end BucketMemory
						from Consolidation.VirtualizationBuckets
						where VBC_ID = LBL_VBC_ID
							and @Buckets > 0
					) b
	where exists (select *
					from #AvailableHosts
					where (CGR_ID = LBL_CGR_ID
							or CGR_ID is null)
						and AvailableVirtualCores >= Cores
						and AvailableMemoryMB >= MemoryUsage
						and AvailableNetworkSpeedMbit >= NetworkUsage)
		and (@ExcludeCurrentlyVirtualized = 0
				or not exists (select *
								from Inventory.MonitoredObjects
									inner join Inventory.OSServers on MOB_ID = OSS_MOB_ID
									
								where MOB_ID = LBL_MOB_ID
									and OSS_IsVirtualServer = 1)
			)
		and not exists (select *
							from Consolidation.Exceptions
							where EXP_EXT_ID = 2
								and EXP_MOB_ID = LBL_MOB_ID
								and (EXP_IDB_ID = LBL_IDB_ID
										or (EXP_IDB_ID is null
											and LBL_IDB_ID is null
											)
									)
						)
		and exists (select *
						from Consolidation.ServerPossibleHostTypes
						where SHT_MOB_ID = LBL_MOB_ID
							and SHT_HST_ID = 4)
	order by LBL_CGR_ID, LBL_CHE_ID, Cores desc

open cLoadBlocks
fetch next from cLoadBlocks into @LBL_ID, @CGR_ID, @CoreCount, @CPUUsage, @MemoryMB, @NetworkMbit, @NetworDownloadkMbit, @NetworkUploadMbit, @DiskBlockSize, @Edition
while @@FETCH_STATUS = 0
begin
	select @CurrentBlockID = null

	select top 1 @CurrentBlockID = CLB_ID
	from Consolidation.ConsolidationBlocks
		inner join #AvailableHosts on CLB_PSH_ID = PSH_ID
		cross apply (select SUM(isnull(CBL_VirtualCoreCount, 0)) UsedCores,
							SUM(isnull(CBL_BufferedMemoryMB, 0)) MemoryMB,
							SUM(isnull(CBL_BufferedNetworkSpeedMbit, 0)) NetworkSpeedMbit
						from Consolidation.ConsolidationBlocks_LoadBlocks
						where CBL_CLB_ID = CLB_ID) c
	where CLB_CGR_ID = @CGR_ID
		and @CoreCount <= (AvailableVirtualCores - UsedCores)
		and @MemoryMB <= CLB_CappedMemoryMB - MemoryMB
		and @NetworkMbit <= CLB_CappedNetworkSpeedMbit - NetworkSpeedMbit
	order by CLB_ID, case when @Edition = CLB_CHE_ID then 0 else 1 end

	if @CurrentBlockID is null
	begin
		insert into Consolidation.ConsolidationBlocks(CLB_HST_ID, CLB_CGR_ID, CLB_PSH_ID, CLB_OST_ID, CLB_CappedCPUStrength, CLB_CappedMemoryMB,
														CLB_CappedNetworkSpeedMbit, CLB_DiskBlockSize, CLB_CHE_ID)
		select top 1 4, @CGR_ID, PSH_ID, PSH_OST_ID, AvailableVirtualCores*CPUStrengthPerCore, AvailableMemoryMB, AvailableNetworkSpeedMbit, @DiskBlockSize, 0--@Edition
		from #AvailableHosts
		where CGR_ID = @CGR_ID
			or CGR_ID is null

		set @CurrentBlockID = SCOPE_IDENTITY()
	end

	insert into Consolidation.ConsolidationBlocks_LoadBlocks(CBL_HST_ID, CBL_CLB_ID, CBL_LBL_ID, CBL_BufferedCPUStrength, CBL_BufferedMemoryMB,
																CBL_BufferedNetworkSpeedMbit, CBL_BufferedNetworkDownloadSpeedMbit, CBL_BufferedNetworkUploadSpeedMbit,
																CBL_VirtualCoreCount)
	select 4, @CurrentBlockID, @LBL_ID, @CPUUsage, @MemoryMB, @NetworkMbit, @NetworDownloadkMbit, @NetworkUploadMbit, @CoreCount

	fetch next from cLoadBlocks into @LBL_ID, @CGR_ID, @CoreCount, @CPUUsage, @MemoryMB, @NetworkMbit, @NetworDownloadkMbit, @NetworkUploadMbit, @DiskBlockSize, @Edition
end
close cLoadBlocks
deallocate cLoadBlocks
GO
