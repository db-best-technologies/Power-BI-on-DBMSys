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
/****** Object:  StoredProcedure [Consolidation].[usp_Reports_VirtualizationAvailabilityGroupSecondariesLayout]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Consolidation].[usp_Reports_VirtualizationAvailabilityGroupSecondariesLayout]
	@MaxPrimariesPerOneSecondary int = 3
as

set nocount on
declare @MOB_ID int,
		@CGR_ID int,
		@CoreCount int,
		@MemoryMB int,
		@DiskSizeMB int,
		@WritesSec int,
		@BlockID int,
		@HOS_ID int,
		@HostCoreCount int,
		@HostMemoryMB int,
		@DiskIOBufferPercentage int,
		@DiskSizeBufferPercentage int

if object_id('tempdb..#LoadBlocks') is not null
	drop table #LoadBlocks
if object_id('tempdb..#Blocks') is not null
	drop table #Blocks
if object_id('tempdb..#BlockMachines') is not null
	drop table #BlockMachines
if object_id('tempdb..#Hosts') is not null
	drop table #Hosts
if object_id('tempdb..#HostBlocks') is not null
	drop table #HostBlocks

create table #Blocks
				(BLK_ID int identity,
				BLK_CGR_ID int,
				BLK_TotalIOPS int,
				BLK_TotalDiskSizeMB int,
				BLK_MaxCoreCount int,
				BLK_MaxMemory int)

create table #BlockMachines
				(BLM_BLK_ID int,
				BLM_MOB_ID int)

create table #Hosts
				(HOS_ID int identity,
				HOS_CGR_ID int,
				HOS_TotalCores int,
				HOS_TotalMemory int)

create table #HostBlocks
				(HBS_HOS_ID int,
				HBS_BLK_ID int)

select @DiskIOBufferPercentage = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Disk IO Buffer Percentage'

select @DiskSizeBufferPercentage = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Disk Size Buffer Percentage'

declare cLoadBlocks cursor static forward_only for
	select LBL_MOB_ID, CLB_CGR_ID,
		CBL_VirtualCoreCount,
		CBL_BufferedMemoryMB,
		LBL_DiskSize + LBL_DiskSize*(@DiskSizeBufferPercentage/100.) DiskSize,
		LBL_WritesSec + LBL_WritesSec*(@DiskIOBufferPercentage/100.) DieskWrites
	from Consolidation.LoadBlocks
		inner join Consolidation.ConsolidationBlocks_LoadBlocks on CBL_LBL_ID = LBL_ID
		inner join Consolidation.ConsolidationBlocks on CLB_ID = CBL_CLB_ID
		inner join Consolidation.ConsolidationGroups on CGR_ID = CLB_CGR_ID
	where CBL_DLR_ID is null
		and CLB_HST_ID = 4
		and CLB_DLR_ID is null
	order by CGR_Name, CBL_VirtualCoreCount desc

open cLoadBlocks
fetch next from cLoadBlocks into @MOB_ID, @CGR_ID, @CoreCount, @MemoryMB, @DiskSizeMB, @WritesSec
while @@FETCH_STATUS = 0
begin
	set @BlockID = null

	select @BlockID = BLK_ID
	from #Blocks
	where BLK_CGR_ID = @CGR_ID
		and (select count(*)
				from #BlockMachines
				where BLM_BLK_ID = BLK_ID) <= @MaxPrimariesPerOneSecondary

	if @BlockID is null
	begin
		insert into #Blocks
		values(@CGR_ID, @WritesSec, @DiskSizeMB, @CoreCount, @MemoryMB)

		set @BlockID = scope_identity()
	end
	else
		update #Blocks
		set BLK_TotalIOPS += @WritesSec,
				BLK_TotalDiskSizeMB += @DiskSizeMB,
				BLK_MaxCoreCount = iif(BLK_MaxCoreCount < @CoreCount, @CoreCount, BLK_MaxCoreCount),
				BLK_MaxMemory = iif(BLK_MaxMemory < @MemoryMB, @MemoryMB, BLK_MaxMemory)
		where BLK_ID = @BlockID

	insert into #BlockMachines
	values(@BlockID, @MOB_ID)

	fetch next from cLoadBlocks into @MOB_ID, @CGR_ID, @CoreCount, @MemoryMB, @DiskSizeMB, @WritesSec
end
close cLoadBlocks
deallocate cLoadBlocks

select @HostCoreCount = PSH_CoreCount,
	@HostMemoryMB = PSH_MemoryMB
from Consolidation.PossibleHosts
where PSH_VES_ID is not null

declare cBlocks cursor static forward_only for
	select BLK_ID, BLK_CGR_ID, BLK_MaxCoreCount, BLK_MaxMemory
	from #Blocks
		inner join Consolidation.ConsolidationGroups on CGR_ID = BLK_CGR_ID
	order by CGR_Name, BLK_MaxCoreCount desc

open cBlocks
fetch next from cBlocks into @BlockID, @CGR_ID, @CoreCount, @MemoryMB
while @@FETCH_STATUS = 0
begin
	set @HOS_ID = null

	select top 1 @HOS_ID = HOS_ID
	from #Hosts
	where HOS_CGR_ID = @CGR_ID
		and HOS_TotalCores + @CoreCount <= @HostCoreCount
		and HOS_TotalMemory + @MemoryMB <= @HostMemoryMB

	if @HOS_ID is null
	begin
		insert into #Hosts
		values(@CGR_ID, @CoreCount, @MemoryMB)

		set @HOS_ID = SCOPE_IDENTITY()
	end
	else
		update #Hosts
		set HOS_TotalCores += @CoreCount,
			HOS_TotalMemory += @MemoryMB
		where HOS_ID = @HOS_ID

	insert into #HostBlocks
	values(@HOS_ID, @BlockID)

	fetch next from cBlocks into @BlockID, @CGR_ID, @CoreCount, @MemoryMB
end
close cBlocks
deallocate cBlocks

select 'Hosts'

select CGR_Name GroupName, HOS_ID HostID, HOS_TotalCores CoreCount
from #Hosts
	inner join Consolidation.ConsolidationGroups on CGR_ID = HOS_CGR_ID
order by CGR_Name, HostID

select 'VMs'

select CGR_Name GroupName, BLK_ID VMID, HBS_HOS_ID HostID, BLK_MaxCoreCount CoreCount, BLK_MaxMemory MemoryMB, BLK_TotalDiskSizeMB/1024 DiskSizeGB, BLK_TotalIOPS IOPS
from #Blocks
	inner join Consolidation.ConsolidationGroups on CGR_ID = BLK_CGR_ID
	inner join #HostBlocks on HBS_BLK_ID = BLK_ID
order by CGR_Name, HostID, VMID

select 'Mapping'

select CGR_Name GroupName, MOB_Name ServerName, BLK_ID VMID
from #BlockMachines
	inner join #Blocks on BLK_ID = BLM_BLK_ID
	inner join Consolidation.ConsolidationGroups on CGR_ID = BLK_CGR_ID
	inner join Inventory.MonitoredObjects on MOB_ID = BLM_MOB_ID
order by VMID
GO
