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
/****** Object:  StoredProcedure [Consolidation].[usp_VirtualizationPreProcess]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Consolidation].[usp_VirtualizationPreProcess]
as
truncate table Consolidation.VirtualizationBuckets
delete Consolidation.Exceptions where EXP_EXT_ID = 2

declare @CPUBufferPercentage int,
	@MemoryBufferPercentage int,
	@NetworkBufferPercentage int,
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

select @CPUStretchingRatio = CAST(SET_Value as decimal(10, 2))
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Virtualization - CPU Core Stretch Ratio'

select @StretchedCPUFactor = CAST(SET_Value as decimal(10, 2))
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Virtualization - Factor For Stretched CPUs'

if object_id('tempdb..#Groups') is not null
	drop table #Groups
create table #Groups
	(CGR_ID int)
if object_id('tempdb..#AvailableHosts') is not null
	drop table #AvailableHosts
if object_id('tempdb..#LoadBlocks') is not null
	drop table #LoadBlocks

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

select LBL_ID A_LBL_ID, LBL_MOB_ID, LBL_IDB_ID, isnull(nullif((MemoryUsage+4095)/4096*4096, 0), 4096) Memory,
	CoresNeeded Cores,
	stuff(
		case when MaxAvailableVirtualCores < CoresNeeded
			then concat(', Number of cores required is ', CoresNeeded
						, ' - Number of cores available is ', cast(MaxAvailableVirtualCores as int))
			else ''
		end
		+
		case when MaxMemory < MemoryUsage
			then concat(', Memory required is ', cast(MemoryUsage/1024 as int), 'GB - Memory available is ', cast(MaxMemory/1024 as int), 'GB')
			else ''
		end
		+
		case when MaxNetworkSpeed < NetworkUsage
			then concat(', Network speed required is ', cast(NetworkUsage as int), 'Mbit - Network speed available is ', cast(MaxNetworkSpeed as int), 'Mbit')
			else ''
		end
		, 1, 2, '') Reason
into #LoadBlocks
from Consolidation.LoadBlocks a
	cross apply (select (LBL_CPUStrength + LBL_CPUStrength*(@CPUBufferPercentage/100.))*100/@CPUCapPercentagePerVM CPUUsage,
					cast(((LBL_MemoryMB + LBL_MemoryMB*(@MemoryBufferPercentage/100.))*100/@MemoryCapPercentagePerVM + 1023) as int)/1024*1024 MemoryUsage,
					(LBL_NetworkUsageDownloadMbit + LBL_NetworkUsageUploadMbit
						+ (LBL_NetworkUsageDownloadMbit + LBL_NetworkUsageUploadMbit)*(@NetworkBufferPercentage/100.))*100/@NetworkCapPercentagePerVM NetworkUsage,
					(LBL_NetworkUsageDownloadMbit + LBL_NetworkUsageDownloadMbit*(@NetworkBufferPercentage/100.))*100/@NetworkCapPercentagePerVM NetworkDownloadUsage,
					(LBL_NetworkUsageUploadMbit + LBL_NetworkUsageUploadMbit*(@NetworkBufferPercentage/100.))*100/@NetworkCapPercentagePerVM NetworkUploadUsage
				) u
	cross apply (select MAX(CPUStrengthPerCore) MaxCPUStrengthPerCore,
					MAX(AvailableVirtualCores) MaxAvailableVirtualCores,
					MAX(AvailableMemoryMB) MaxMemory,
					MAX(AvailableNetworkSpeedMbit) MaxNetworkSpeed
				from #AvailableHosts
				where (CGR_ID = LBL_CGR_ID
						or CGR_ID is null)) m
	cross apply (select isnull(nullif((cast(ceiling(CPUUsage*1./MaxCPUStrengthPerCore) as int) + 1)/2*2, 0), 1) CoresNeeded
				) ci
where (@ExcludeCurrentlyVirtualized = 0
			or not exists (select *
							from Inventory.MonitoredObjects
								inner join Inventory.OSServers on MOB_ID = OSS_MOB_ID
								left join Inventory.MachineManufacturerModels on MMD_ID = OSS_MMD_ID
							where MOB_ID = LBL_MOB_ID
								and MMD_Name like '%Virtual%')
		)

insert into Consolidation.Exceptions
select 2, LBL_MOB_ID, LBL_IDB_ID, Reason, 4
from #LoadBlocks
where Reason <> ''

delete #LoadBlocks
where Reason <> ''

if @Buckets > 0
begin
	with Input as
			(select distinct Memory, Cores
				from #LoadBlocks
			)
		, BucketInput as
			(select *, NTILE(@Buckets) over(order by Memory) MemoryBucket,
				NTILE(@Buckets) over (order by Cores) CoresBucket
				from Input
			)
		, MemBuck as
			(select MemoryBucket, MIN(Memory) FromMemory, MAX(Memory) ToMemory
				from BucketInput
				group by MemoryBucket
			)
		, CPUBuck as
			(select CoresBucket, MIN(Cores) FromCores, MAX(Cores) ToCores
				from BucketInput
				group by CoresBucket
			)
	insert into Consolidation.VirtualizationBuckets
	select MemoryBucket Bucket, FromCores, ToCores, FromMemory, ToMemory
	from MemBuck m
		inner join CPUBuck c on MemoryBucket = CoresBucket

	update Consolidation.LoadBlocks
	set LBL_VBC_ID = VBC_ID
	from #LoadBlocks
		cross apply (select top 1 *
						from Consolidation.VirtualizationBuckets
						where Cores <= VBC_ToNumberOfCores
							and Memory <= VBC_ToMemoryMB
						order by VBC_SizeRank) b
	where LBL_ID = A_LBL_ID
end
GO
