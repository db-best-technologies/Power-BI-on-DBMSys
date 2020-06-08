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
/****** Object:  StoredProcedure [GUI].[usp_Report_InstanceLevelMapView]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUI].[usp_Report_InstanceLevelMapView]
as
declare @FromDate datetime2(3),
		@ToDate datetime2(3)
select @FromDate = min(CRS_DateTime),
	@ToDate = max(CRS_DateTime)
from PerformanceData.CounterResults

if object_id('tempdb..#Processors') is not null
	drop table #Processors

select PRS_MOB_ID, PSN_Name ProcessorName, cast(COUNT(*) as varchar(5)) Processors,
	cast(COUNT(*)*NumberOfCores as varchar(5)) CoreCount,
	cast(COUNT(*)*LogicalProcessors as varchar(5)) LogicalProcessors,
	CPB_Mark CPUScore
into #Processors
from Inventory.Processors
	left join Inventory.ProcessorNames on PSN_ID = PRS_PSN_ID
	cross apply (select isnull(PRS_NumberOfCores,
										case when PRS_NumberOfCores is null
											or (PRS_NumberOfCores = 1
													and (PSN_Name like '%Quad%'
															or PSN_Name like '%Dual%')
												)
										then case when PSN_Name like '%Quad%' then 4
													when PSN_Name like '%Dual%' then 2
													else 1
												end
										else 1
									end) NumberOfCores
				) n
	cross apply (select case when NumberOfCores < PRS_NumberOfLogicalProcessors
							then PRS_NumberOfLogicalProcessors
							else NumberOfCores
						end LogicalProcessors
				) n1
	outer apply (select replace(replace(replace(replace(replace(replace(ltrim(rtrim(replace(replace(replace(replace(replace(replace(PSN_Name, '(R)', ''), '(TM)', ''), 'CPU ', ''), '  ', ' ^'), '^ ', ''), '^', ''))), ' 0 ', ''),
						' Processor ', ' '), 'Dual Core', '[Dual CPU]'), 'Dual-Core', '[Dual CPU]'), '0@', '0 @'), ' MP ', ' ') CleanCPUName) c
	outer apply (select top 1 CPB_Name,
							case when PSN_Name not like '%Quad%' and CPB_Name like '%Quad%' then 2.5
								when PSN_Name not like '%Dual%' and CPB_Name like '%Dual%' then 1.5
								else 1
							end * CPB_Mark CPB_Mark
					from ExternalData.CPUBenchmark
					where replace(CPB_Name, '[Quad CPU] Quad-Core', 'Quad-Core') in (CleanCPUName, replace(CleanCPUName, '@', ' @'))
							or replace(CPB_Name, '[Quad CPU] ', '')  in (CleanCPUName, replace(CleanCPUName, '@', ' @'))
							or replace(CPB_Name, '[Dual CPU] ', '')  in (CleanCPUName, replace(CleanCPUName, '@', ' @'))
					order by len(CPB_Name) desc
				) b
group by PRS_MOB_ID, PSN_Name, NumberOfCores, LogicalProcessors, CPB_Mark

;with Processors as
		(select *
			from #Processors
		)
	, Disks as
		(select DSK_MOB_ID, DSK_Path, cast(DSK_TotalSpaceMB/1024 as varchar(20)) TotalSizeGB, FreeSpaceGB
			from Inventory.Disks
				outer apply (select top 1 cast(cast(CRS_Value as int)/1024 as varchar(20)) FreeSpaceGB
								from PerformanceData.CounterResults
									left join PerformanceData.CounterInstances on CIN_ID = CRS_InstanceID
								where CRS_MOB_ID = DSK_MOB_ID
										and CIN_Name = DSK_Path
										and CRS_SystemID = 4
										and CRS_CounterID = 27
										and CRS_DateTime between @FromDate and @ToDate
								order by CRS_DateTime desc) r
			where DSK_Path like '%:%'
		)
select s.MOB_Name ComputerName, isnull(DID_InstanceName, '') InstanceName, 
	isnull('Microsoft SQL Server ' + de.EDT_Name, 'No SQL Server data available') SQLServerProductName,
	isnull('SQL ' + left(dv.VER_Name, charindex(' -', dv.VER_Name + ' -', 1) - 1), 'N/A') SQLServerVersion,
	isnull(dp.PRL_Name, 'N/A') SQLServerServicePack,
	isnull(de.EDT_Name, 'N/A') SQLServerEdition,
	case when DID_IsClustered = 1 then 'Yes' when DID_IsClustered = 0 then 'No' else 'N/A' end IsClustered,
	case DID_IsClustered when 1 then s.MOB_Name else '' end SQLServerClusterNetworkName,
	isnull(ServiceStatus, 'N/A') SQLServiceState,
	isnull(StartingMode, 'N/A') SQLServiceStartMode,
	isnull(alias + ' (' + cast(OSS_Language as varchar(10)) + ')', 'N/A') [Language],
	coalesce(se.EDT_Name, 'N/A') OperatingSystem,
	isnull(sp.PRL_Name, 'N/A') OperatingSystemServicePack,
	isnull(cast(case when se.EDT_Name is not null then isnull(OSS_Architecture, 32) end as char(2)) + '-bit', 'N/A') OSArchitectureType,
	Processors NumberOfProcessors, CoreCount NumberOfTotalCores, LogicalProcessors NumberOfLogicalProcessors, ProcessorName CPU, CPUScore,
	isnull(cast(OSS_TotalPhysicalMemoryMB as varchar(100)), 'N/A') SystemMemoryMB,
	'"' + isnull(stuff(replace((select char(13)+char(10) + DSK_Path
						from Disks
						where DSK_MOB_ID = s.MOB_ID
						order by DSK_Path
						for xml path('')), '&#x0D;', char(13)), 1, 2, ''), 'N/A') + '"' LogicalDiskDriveName,
	'"' + isnull(stuff(replace((select char(13)+char(10) + TotalSizeGB
						from Disks
						where DSK_MOB_ID = s.MOB_ID
						order by DSK_Path
						for xml path('')), '&#x0D;', char(13)), 1, 2, ''), 'N/A') + '"' LogicalDiskSizeGB,
	'"' + isnull(stuff(replace((select char(13)+char(10) + FreeSpaceGB
						from Disks
						where DSK_MOB_ID = s.MOB_ID
						order by DSK_Path
						for xml path('')), '&#x0D;', char(13)), 1, 2, ''), 'N/A') + '"' LogicalDiskFreeSpaceGB,
	case when OSS_IsVirtualServer = 1 then 'Virtual' else 'Physical' end MachineType,
	coalesce(MMN_Name, 'N/A') MachineManufacturer,
	isnull(MMD_Name, 'N/A') MachineModel,
	DatabaseCount, OSS_InstallDate WindowsInstallationDate
from Inventory.OSServers
	inner join Inventory.MonitoredObjects s on OSS_MOB_ID = s.MOB_ID
	outer apply (select distinct MOB_ID, DID_InstanceName, DID_IsClustered, DID_PRL_ID, DID_EDT_ID, MOB_VER_ID, MOB_OOS_ID
					from Inventory.DatabaseInstanceDetails
						inner join Inventory.MonitoredObjects d on d.MOB_Entity_ID = DID_DFO_ID
						inner join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
																and PLT_PLC_ID = 1
					where d.MOB_OOS_ID = 1
						and DID_OSS_ID = OSS_ID) d
	outer apply (select case when d.MOB_ID is not null then COUNT(*) end DatabaseCount
					from Inventory.InstanceDatabases
					where IDB_MOB_ID = d.MOB_ID
						and IDB_Name not in ('master', 'msdb', 'model', 'tempdb', 'distribution')
				) dbs
	outer apply (select sum(cast(Processors as int)) Processors, sum(cast(CoreCount as int)) CoreCount, sum(cast(LogicalProcessors as int)) LogicalProcessors, sum(CPUScore) CPUScore
					from Processors
					where PRS_MOB_ID = s.MOB_ID) prs
	outer apply (select top 1 ProcessorName
					from Processors
					where PRS_MOB_ID = s.MOB_ID
					order by CPUScore desc) prs1
	left join Inventory.Versions dv on d.MOB_VER_ID = dv.VER_ID
	left join Inventory.ProductLevels dp on DID_PRL_ID = dp.PRL_ID
	left join Inventory.Editions de on DID_EDT_ID = de.EDT_ID
	left join Inventory.Versions sv on s.MOB_VER_ID = sv.VER_ID
	left join Inventory.Editions se on s.MOB_Engine_EDT_ID = se.EDT_ID
	left join Inventory.ProductLevels sp on OSS_PRL_ID = sp.PRL_ID
	left join sys.syslanguages on OSS_Language = lcid
	left join Inventory.MachineManufacturers on MMN_ID = OSS_MMN_ID
	left join inventory.MachineManufacturerModels on MMD_ID = OSS_MMD_ID
	outer apply (select SSM_Name StartingMode, SST_Name ServiceStatus
					from Inventory.OperatingSystemServices
						left join Inventory.ServiceNames on SNM_ID = OSR_SNM_ID
						left join Inventory.ServiceStartModes on SSM_ID = OSR_SSM_ID
						left join Inventory.ServiceStates on SST_ID = OSR_SST_ID
						left join Inventory.SQLComponentTypes on LEFT(SNM_Name + '$', CHARINDEX('$', SNM_Name + '$', 1) - 1) like SMT_ServiceName
					where SMT_DisplayName = 'Database Engine'
							and OSR_MOB_ID = s.MOB_ID
							and (SUBSTRING(SNM_Name, CHARINDEX('$', SNM_Name + '$', 1) + 1, 100) = DID_InstanceName
									or SUBSTRING(SNM_Name, CHARINDEX('$', SNM_Name + '$', 1) + 1, 100) = '' and DID_InstanceName is null)
					) osr
where s.MOB_OOS_ID = 1
	and d.MOB_OOS_ID = 1
order by 1, 2, 3
GO
