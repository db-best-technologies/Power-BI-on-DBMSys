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
/****** Object:  UserDefinedFunction [Consolidation].[fn_GetResourceUsage]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Consolidation].[fn_GetResourceUsage](@RedFlagLoadBufferMultiplier decimal(10, 2),
													@DiskSizeBufferPercentage decimal(10, 2)) returns table
as
	return (with Resources as
					(select CGR_ID, CGR_Name GroupName, MOB_ID, MOB_Name ServerName,
								ceiling(iif(RedFlaggedResources like '%;CPU;%', @RedFlagLoadBufferMultiplier, cast(1 as decimal(10, 2)))*CPI_CPUUsage) CPUUsage,
								ceiling(iif(RedFlaggedResources like '%;Memory;%', @RedFlagLoadBufferMultiplier, cast(1 as decimal(10, 2)))*MMI_MemoryUsage) MemoryUsage,
								ceiling((NTI_NetworkUsageDownloadMbit + NTI_NetworkUsageUploadMbit)) NetworkUsage,
								CPF_CPUCount CoreCount, ceiling(CPI_CPUStrength) CPUStrength, MMI_TotalMemoryMB MemoryMB,
								cast(iif(NTI_NetworkUsageDownloadMbit + NTI_NetworkUsageUploadMbit > NTI_NetworkSpeedMbit, NTI_NetworkSpeedMbit*10, NTI_NetworkSpeedMbit) as int) NetworkSpeedMbit,
								iif(CPF_IsVM = 1, 'Virtual', 'Physical') ServerType,
								CPF_IsVM IsVM,
								ceiling(iif(RedFlaggedResources like '%;Disk;%', @RedFlagLoadBufferMultiplier, cast(1 as decimal(10, 2)))*DII_DataFileTransfers) DataFilesDiskIOPS,
								ceiling(iif(RedFlaggedResources like '%;Disk;%', @RedFlagLoadBufferMultiplier, cast(1 as decimal(10, 2)))*DII_LogFileTransfers) LogFilesDiskIOPS,
								ceiling(iif(RedFlaggedResources like '%;Disk;%', @RedFlagLoadBufferMultiplier, cast(1 as decimal(10, 2)))*DII_TempdbTransfers) TempdbDiskIOPS,
								ceiling(iif(RedFlaggedResources like '%;Disk;%', @RedFlagLoadBufferMultiplier, cast(1 as decimal(10, 2)))*DTI_DataFileTransfersMB) DataFilesDiskMBPerSec,
								ceiling(iif(RedFlaggedResources like '%;Disk;%', @RedFlagLoadBufferMultiplier, cast(1 as decimal(10, 2)))*DTI_LogFileTransfersMB) LogFilesDiskMBPerSec,
								ceiling(iif(RedFlaggedResources like '%;Disk;%', @RedFlagLoadBufferMultiplier, cast(1 as decimal(10, 2)))*DTI_TempdbTransfersMB) TempdbDiskMBPerSec,
								ceiling(iif(RedFlaggedResources like '%;Disk;%', @RedFlagLoadBufferMultiplier, cast(1 as decimal(10, 2)))*DII_TotalReads + DII_TotalWrites) TotalIOPs,
								ceiling(iif(RedFlaggedResources like '%;Disk;%', @RedFlagLoadBufferMultiplier, cast(1 as decimal(10, 2)))*DII_TotalReads) TotalFileReads,
								ceiling(iif(RedFlaggedResources like '%;Disk;%', @RedFlagLoadBufferMultiplier, cast(1 as decimal(10, 2)))*DII_TotalWrites) TotalFileWrites,
								ceiling(iif(RedFlaggedResources like '%;Disk;%', @RedFlagLoadBufferMultiplier, cast(1 as decimal(10, 2)))*DII_DataFileTransfers) DataFileTransfers,
								ceiling(iif(RedFlaggedResources like '%;Disk;%', @RedFlagLoadBufferMultiplier, cast(1 as decimal(10, 2)))*DII_LogFileTransfers) LogFileTransfers,
								ceiling(iif(RedFlaggedResources like '%;Disk;%', @RedFlagLoadBufferMultiplier, cast(1 as decimal(10, 2)))*DTI_TotalReadsMB) TotalFileReadsMB,
								ceiling(iif(RedFlaggedResources like '%;Disk;%', @RedFlagLoadBufferMultiplier, cast(1 as decimal(10, 2)))*DTI_TotalWritesMB) TotalFileWritesMB,
								ceiling(iif(RedFlaggedResources like '%;Disk;%', @RedFlagLoadBufferMultiplier, cast(1 as decimal(10, 2)))*DTI_DataFileTransfersMB) DataFileTransfersMB,
								ceiling(iif(RedFlaggedResources like '%;Disk;%', @RedFlagLoadBufferMultiplier, 1.)*DTI_LogFileTransfersMB) LogFileTransfersMB,
								DSI_DataFilesMB DataFilesMB, DSI_LogFilesMB LogFilesMB,
								DSI_UsedSpace + isnull(nullif(DSI_YearlyGrowthMB, 0)*3, DSI_UsedSpace*@DiskSizeBufferPercentage/100) UsedSpace,
								DSI_FileTypeSeparation FileTypeSeparation, DSI_DataFreeSpaceMBIn3Years DataFreeSpaceMBIn3Years, DSI_LogFreeSpaceMB LogFreeSpaceMB,
								DSI_TotalFreeSpaceMB TotalFreeSpaceMB, DII_DataMaxTransfers DataMaxTransfers, DII_LogMaxTransfers LogMaxTransfers,
								DII_TotalMaxTransfers TotalMaxTransfers, DTI_DataMaxMBPs DataMaxMBPs, DTI_LogMaxMBPs LogMaxMBPs, DTI_TotalMaxMBPs TotalMaxMBPs,
								BSI_DominantBlockSize DominantBlockSize, NTI_NetworkUsageDownloadMbit NetworkUsageDownloadMbit, NTI_NetworkUsageUploadMbit NetworkUsageUploadMbit,
								DII_AvgMonthlyIOPS AvgMonthlyIOPS, NTI_AvgMonthlyNetworkOutboundIOMB AvgMonthlyNetworkOutboundIOMB, NTI_AvgMonthlyNetworkInboundIOMB AvgMonthlyNetworkInboundIOMB,
								cast(MAC_PercentActive as int) PercentActive, SQLInstances, MaxEdition, CPI_CPUCount CPUCount, MOB_PLT_ID PLT_ID
							from Inventory.MonitoredObjects o
								inner join Consolidation.ServerGrouping on SGR_MOB_ID = MOB_ID
								inner join Consolidation.ConsolidationGroups on CGR_ID = SGR_CGR_ID
								left join Consolidation.CPUFactoring on CPF_MOB_ID = MOB_ID
								left join Consolidation.CPUInfo on CPI_MOB_ID = MOB_ID
								left join Consolidation.MemoryInfo on MMI_MOB_ID = MOB_ID
								left join Consolidation.NetworkInfo on NTI_MOB_ID = MOB_ID
								left join Consolidation.DiskIOInfo on DII_MOB_ID = MOB_ID
								left join Consolidation.DiskThroughputInfo on DTI_MOB_ID = MOB_ID
								left join Consolidation.MachineActivity on MAC_MOB_ID = MOB_ID
								left join Consolidation.BlockSizes on BSI_MOB_ID = MOB_ID
								left join Consolidation.DiskInfo on DSI_MOB_ID = MOB_ID
								outer apply (select COUNT(*) SQLInstances,
													MAX(case when EDT_Name like '%Enterprise%' or EDT_Name like '%DataCenter%' or EDT_Name like '%Business Intelligence%' then 5
															when EDT_Name like '%Standard%' then 4
															when EDT_Name like '%Developer%' then 2
															when EDT_Name like '%Express%' then 1
															else 1 end) MaxEdition
												from Inventory.MonitoredObjects d
													inner join Inventory.DatabaseInstanceDetails on DID_DFO_ID = d.MOB_Entity_ID
													inner join Inventory.Editions on EDT_ID = DID_EDT_ID
												where MOB_PLT_ID = 1
													and exists (select *
																	from Consolidation.ParticipatingDatabaseServers
																	where PDS_Server_MOB_ID = o.MOB_ID
																		and PDS_Database_MOB_ID = d.MOB_ID)
												) s
								outer apply (select (select distinct ';' + PCG_Name
														from Consolidation.RedFlagsByResourceType
															inner join Consolidation.ParticipatingDatabaseServers on RFR_MOB_ID in (PDS_Server_MOB_ID, PDS_Database_MOB_ID)
															inner join PerformanceData.PerformanceCounterGroups on PCG_ID = RFR_PCG_ID
														where PDS_Server_MOB_ID = CPI_MOB_ID
														for xml path('')) + ';' RedFlaggedResources
												) rf
							)
					select *,
						ceiling(CPUUsage*100/CPUStrength) CPUUsagePercentage,
						ceiling(MemoryUsage*100/MemoryMB) MemoryUsagePercentage,
						ceiling(NetworkUsage*100/NetworkSpeedMbit) NetworkUsagePercentage
					from Resources
				)
GO
