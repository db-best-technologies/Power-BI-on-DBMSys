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
/****** Object:  StoredProcedure [Consolidation].[usp_Reports_CloudAvailabilityGroupSecondariesLayout]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Consolidation].[usp_Reports_CloudAvailabilityGroupSecondariesLayout]
	@CLV_ID tinyint
as
set nocount on
declare @CPUCapPercentage int,
		@MemoryCapPercentage int,
		@DiskIOCapPercentage int,
		@DiskSizeMBCapPercentage int,
		@MaxIOPS int,
		@MaxCPUScore int,
		@MaxMemory int,
		@MaxDiskSizeMB int,
		@MOB_ID int,
		@CGR_ID int,
		@CPUStrength int,
		@MemoryMB int,
		@DiskSizeMB int,
		@WritesSec int,
		@BlockID int,
		@DiskIOBufferPercentage int

if object_id('tempdb..#PossibleHosts') is not null
	drop table #PossibleHosts
if object_id('tempdb..#LoadBlocks') is not null
	drop table #LoadBlocks
if object_id('tempdb..#Blocks') is not null
	drop table #Blocks
if object_id('tempdb..#BlockMachines') is not null
	drop table #BlockMachines

select @CPUCapPercentage = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'CPU Cap Percentage'

select @MemoryCapPercentage = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Memory Cap Percentage'

select @DiskIOCapPercentage = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Disk IO Cap Percentage'

select @DiskSizeMBCapPercentage = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Disk Size Cap Percentage'

select @DiskIOBufferPercentage = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Disk IO Buffer Percentage'

create table #Blocks
				(BLK_ID int identity,
				BLK_CGR_ID int,
				BLK_TotalIOPS int,
				BLK_TotalDiskSizeMB int,
				BLK_MaxCPU int,
				BLK_MaxMemory int)

create table #BlockMachines
				(BLM_BLK_ID int,
				BLM_MOB_ID int)

select CMT_Name, PSH_PricePerMonthUSD, PSH_CRG_ID,
	cast(PSH_MaxIOPS8KB/isnull(CDF_WritesFactor, 1.6) as int)*@DiskIOCapPercentage/100 WriteIOPS,
	PSH_CPUStrength*@CPUCapPercentage/100 CPUStrength,
	PSH_MemoryMB*@MemoryCapPercentage/100 MemoryMB,
	PSH_MaxDiskSizeMB*@DiskSizeMBCapPercentage/100 MaxDiskSizeMB
into #PossibleHosts
from Consolidation.PossibleHosts
	inner join Consolidation.CloudMachineTypes on CMT_ID = PSH_CMT_ID
	inner join Consolidation.CloudMachineStorageCompatibility on CMC_CMT_ID = CMT_ID
	inner join Consolidation.HostTypes on HST_ID = PSH_HST_ID
	left join Consolidation.CloudMachinesDiskFactors on CDF_BUL_ID = CMC_Storage_BUL_ID
													and CDF_DiskCount = PSH_MaxDiskCount
where HST_CLV_ID = @CLV_ID

select top 1 @MaxIOPS = WriteIOPS,
		@MaxCPUScore = CPUStrength,
		@MaxMemory = MemoryMB,
		@MaxDiskSizeMB = MaxDiskSizeMB
from #PossibleHosts
order by WriteIOPS desc

declare cLoadBlocks cursor static forward_only for
	select distinct LBL_MOB_ID, LBL_CGR_ID,
			CBL_BufferedCPUStrength,
			CBL_BufferedMemoryMB,
			CBL_BufferedDiskSizeMB,
			LBL_WritesSec + LBL_WritesSec*(@DiskIOBufferPercentage/100.) DieskWrites
	from Consolidation.ConsolidationBlocks_LoadBlocks
		inner join Consolidation.ConsolidationBlocks on CLB_ID = CBL_CLB_ID
		inner join Consolidation.HostTypes on HST_ID = CLB_HST_ID
		inner join Consolidation.LoadBlocks on LBL_ID = CBL_LBL_ID
	where HST_CLV_ID = @CLV_ID
		and CBL_DLR_ID is null
		and CLB_DLR_ID is null
		and CBL_BufferedCPUStrength <= @MaxCPUScore
		and CBL_BufferedMemoryMB <= @MaxMemory

open cLoadBlocks
fetch next from cLoadBlocks into @MOB_ID, @CGR_ID, @CPUStrength, @MemoryMB, @DiskSizeMB, @WritesSec
while @@FETCH_STATUS = 0
begin
	set @BlockID = null

	select @BlockID = BLK_ID
	from #Blocks
	where BLK_CGR_ID = @CGR_ID
		and BLK_TotalIOPS + @WritesSec < @MaxIOPS
		and BLK_TotalDiskSizeMB + @DiskSizeMB < @MaxDiskSizeMB

	if @BlockID is null
	begin
		insert into #Blocks
		values(@CGR_ID, @WritesSec, @DiskSizeMB, @CPUStrength, @MemoryMB)

		set @BlockID = scope_identity()
	end
	else
		update #Blocks
		set BLK_TotalIOPS += @WritesSec,
				BLK_TotalDiskSizeMB += @DiskSizeMB,
				BLK_MaxCPU = iif(BLK_MaxCPU < @CPUStrength, @CPUStrength, BLK_MaxCPU),
				BLK_MaxMemory = iif(BLK_MaxMemory < @MemoryMB, @MemoryMB, BLK_MaxMemory)
		where BLK_ID = @BlockID

	insert into #BlockMachines
	values(@BlockID, @MOB_ID)

	fetch next from cLoadBlocks into @MOB_ID, @CGR_ID, @CPUStrength, @MemoryMB, @DiskSizeMB, @WritesSec
end
close cLoadBlocks
deallocate cLoadBlocks

select 'Servers'

select CGR_Name GroupName, BLK_ID MachineID, CMT_Name MachineType, PSH_PricePerMonthUSD MonthlyPrice, BLK_TotalDiskSizeMB/1024 DiskSizeGB, BLK_TotalIOPS IOPS
from #Blocks
	inner join Consolidation.ConsolidationGroups_CloudRegions on CGG_CGR_ID = BLK_CGR_ID
	inner join Consolidation.ConsolidationGroups on CGR_ID = BLK_CGR_ID
	cross apply (select top 1 CMT_Name, PSH_PricePerMonthUSD
					from #PossibleHosts
					where PSH_CRG_ID = CGG_CRG_ID
						and CPUStrength >= BLK_MaxCPU
						and MemoryMB >= BLK_MaxMemory
						and WriteIOPS >= BLK_TotalIOPS
						and MaxDiskSizeMB >= BLK_TotalDiskSizeMB
					order by PSH_PricePerMonthUSD) p

select 'Mapping'

select CGR_Name GroupName, MOB_Name ServerName, BLK_ID MachineID
from #BlockMachines
	inner join #Blocks on BLK_ID = BLM_BLK_ID
	inner join Consolidation.ConsolidationGroups on CGR_ID = BLK_CGR_ID
	inner join Inventory.MonitoredObjects on MOB_ID = BLM_MOB_ID
order by MachineID
GO
