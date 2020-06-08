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
/****** Object:  StoredProcedure [Consolidation].[usp_Reports_ResourceUtilization]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Consolidation].[usp_Reports_ResourceUtilization]
	@ReturnResults bit = 1
as
set nocount on

declare @RedFlagWorkLoadBuffer decimal(10, 2),
		@CPUBufferPercentage decimal(10, 2),
		@MemoryBufferPercentage decimal(10, 2),
		@NetworkBufferPercentage decimal(10, 2),
		@DiskIOBufferPercentage decimal(10, 2),
		@DiskSizeBufferPercentage decimal(10, 2),
		@CPUCapPercentage decimal(10, 2),
		@MemoryCapPercentage decimal(10, 2),
		@NetworkCapPercentage decimal(10, 2),
		@DiskIOCapPercentage decimal(10, 2),
		@DiskSizeCapPercentage decimal(10, 2),
		@AlertOnUnderUsageDiff int

if object_id('tempdb..#ResourceRecommendations') is null
	create table #ResourceRecommendations
		(ServerName nvarchar(128),
		ServerType varchar(100),
		CoreCount int,
		MemoryGB bigint,
		AlertType varchar(100),
		PercentageOfResourceUsed bigint,
		Recommendation varchar(100),
		ResourceCount int,
		ResourceType varchar(100))

truncate table #ResourceRecommendations

if object_id('tempdb..#ResourceUsage') is not null
	drop table #ResourceUsage

select @RedFlagWorkLoadBuffer = CAST(SET_Value as decimal(10, 2))
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Red Flag Work Load Buffer'

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

select @DiskSizeBufferPercentage = CAST(SET_Value as decimal(10, 2))
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Disk Size Buffer Percentage'

select @CPUCapPercentage = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'CPU Cap Percentage'

select @MemoryCapPercentage = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Memory Cap Percentage'

select @NetworkCapPercentage = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Network Speed Cap Percentage'

select @AlertOnUnderUsageDiff = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Percentage Difference Of Under-Utilization To Alert On'

select *
into #ResourceUsage
from Consolidation.fn_GetResourceUsage(1 + @RedFlagWorkLoadBuffer/100., @DiskSizeBufferPercentage)

if @ReturnResults = 1
begin
	select 'Resource usage'

	select GroupName, ServerName, CoreCount, PercentActive, MemoryMB/1025 MemoryGB, CPUUsagePercentage, MemoryUsagePercentage,
		isnull(cast(DataFilesDiskIOPS as varchar(20)), '') DataFilesDiskIOPS,
		isnull(cast(LogFilesDiskIOPS as varchar(20)), '') LogFilesDiskIOPS,
		isnull(cast(TempdbDiskIOPS as varchar(20)), '') TempdbDiskIOPS,
		isnull(cast(DataFilesDiskMBPerSec as varchar(20)), '') DataFilesDiskMBPerSec,
		isnull(cast(LogFilesDiskMBPerSec as varchar(20)), '') LogFilesDiskMBPerSec,
		isnull(cast(TempdbDiskMBPerSec as varchar(20)), '') TempdbDiskMBPerSec,
		isnull(cast(TotalIOPs as varchar(20)), '') TotalIOPs
	from #ResourceUsage

	select 'Resource recommendations'
end
;with BufferedResourceUsage as
		(select *,
			cast(CPUUsagePercentage + CPUUsagePercentage*(@CPUBufferPercentage/100.) as int) BufferedCPUUsage,
			cast(MemoryUsagePercentage + MemoryUsagePercentage*(@MemoryBufferPercentage/100.) as int) BufferedMemoryUsage,
			cast(NetworkUsagePercentage + NetworkUsagePercentage*(NetworkUsagePercentage/100.) as int) BufferedNetworkingUsage
		from #ResourceUsage
		)
	, ResourceChanges as
		(select ServerName, ServerType, CoreCount, MemoryMB/1024 MemoryGB, 'Over-Utilized CPU' AlertType, CPUUsagePercentage PercentageOfResourceUsed,
				concat('Add ', iif(ceiling(CoreCount*ceiling(BufferedCPUUsage/(@CPUCapPercentage*1.)*100)/100 - CoreCount) < 2, 2, ceiling(CoreCount*ceiling(BufferedCPUUsage/(@CPUCapPercentage*1.)*100)/100 - CoreCount)),
						' CPU cores') Recommendation,
				iif(ceiling(CoreCount*ceiling(BufferedCPUUsage/(@CPUCapPercentage*1.)*100)/100 - CoreCount) < 2, 2, ceiling(CoreCount*ceiling(BufferedCPUUsage/(@CPUCapPercentage*1.)*100)/100 - CoreCount)) ResourceCount,
				'CPU' ResourceType
			from BufferedResourceUsage
			where BufferedCPUUsage > @CPUCapPercentage
			union
			select ServerName, ServerType, CoreCount, MemoryMB/1024 MemoryGB, 'Over-Utilized Memory' AlertType, MemoryUsagePercentage PercentageOfResourceUsed,
				concat('Add ', cast((ceiling(MemoryMB*ceiling(BufferedMemoryUsage/(@MemoryCapPercentage*1.)*100)/100 - MemoryMB) + 4095) as int)/4096*4096/1024,
						'GB of RAM') Recommendation,
				cast((ceiling(MemoryMB*ceiling(BufferedMemoryUsage/(@MemoryCapPercentage*1.)*100)/100 - MemoryMB) + 4095) as int)/4096*4096/1024 ResourceCount,
				'Memory' ResourceType
			from BufferedResourceUsage
			where BufferedMemoryUsage > @MemoryCapPercentage
			union
			--select ServerName, ServerType, CoreCount, MemoryMB/1024 MemoryGB, NetworkSpeedMbit, 'Over-Utilized Network bandwidth' AlertType, NetworkUsagePercentage PercentageOfResourceUsed,
			--	'Consider using a wider network bandwidth' Recommendation
			--from BufferedResourceUsage
			--where BufferedNetworkingUsage > @NetworkCapPercentage
			--union
			select ServerName, ServerType, CoreCount, MemoryMB/1024 MemoryGB, 'Under-Utilized CPU' AlertType, CPUUsagePercentage PercentageOfResourceUsed,
				concat('You can reduce the number of CPU cores by ', cast(floor(CoreCount*((@CPUCapPercentage - BufferedCPUUsage)/100.)) as int)/2*2) Recommendation,
				-cast(floor(CoreCount*((@CPUCapPercentage - BufferedCPUUsage)/100.)) as int)/2*2 ResourceCount,
				'CPU' ResourceType
			from BufferedResourceUsage
			where CoreCount > 2
				and BufferedCPUUsage < @CPUCapPercentage - @AlertOnUnderUsageDiff
				and not exists (select *
								from Consolidation.RedFlagsByResourceType
									inner join Consolidation.ParticipatingDatabaseServers on RFR_MOB_ID in (PDS_Server_MOB_ID, PDS_Database_MOB_ID)
								where RFR_PCG_ID = 1
									and PDS_Server_MOB_ID = MOB_ID
								)
			union
			select ServerName, ServerType, CoreCount, MemoryMB/1024 MemoryGB, 'Under-Utilized Memory' AlertType, MemoryUsagePercentage PercentageOfResourceUsed,
				concat('You can reduce the amount of memory by ', cast(floor(MemoryMB*((@MemoryCapPercentage - BufferedMemoryUsage)/100.)) as int)/2*2/4096*4, 'GB') Recommendation,
				-cast(floor(MemoryMB*((@MemoryCapPercentage - BufferedMemoryUsage)/100.)) as int)/2*2/4096*4 ResourceCount,
				'Memory' ResourceType
			from BufferedResourceUsage
			where BufferedMemoryUsage < @MemoryCapPercentage - @AlertOnUnderUsageDiff
				and not exists (select *
								from Consolidation.RedFlagsByResourceType
									inner join Consolidation.ParticipatingDatabaseServers on RFR_MOB_ID in (PDS_Server_MOB_ID, PDS_Database_MOB_ID)
								where RFR_PCG_ID = 2
									and PDS_Server_MOB_ID = MOB_ID
								)
		)
insert into #ResourceRecommendations
select ServerName, ServerType, CoreCount, MemoryGB, AlertType, PercentageOfResourceUsed, Recommendation, ResourceCount, ResourceType
from ResourceChanges
where ResourceCount <> 0

if @ReturnResults = 1
	select ServerName, ServerType, CoreCount, MemoryGB, AlertType, PercentageOfResourceUsed, Recommendation
	from #ResourceRecommendations
	order by AlertType, ServerName
GO
