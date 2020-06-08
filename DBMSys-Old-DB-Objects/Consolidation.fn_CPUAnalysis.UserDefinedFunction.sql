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
/****** Object:  UserDefinedFunction [Consolidation].[fn_CPUAnalysis]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Consolidation].[fn_CPUAnalysis]() returns table
as
return with CPUs as
			(select MOB_ID CR_MOB_ID, CAST(null as int) CR_VES_ID, CleanCPUName, OSS_InstallDate, max(PRS_MaxClockSpeed/100*100) MaxClockSpeed, max(PCA_Caption) CPUDescription,
						count(*) CPUCount, case when OSS_IsVirtualServer = 1 then 1 else 0 end IsVM,
						iif(MOB_PLT_ID = 2, sum(PRS_NumberOfCores), isnull(max(PRS_NumberOfCores), count(*)))  NumberOfCores,
						iif(MOB_PLT_ID = 2, sum(PRS_NumberOfLogicalProcessors), isnull(max(PRS_NumberOfLogicalProcessors), count(*)))  NumberOfLogicalCores,
						cast(null as int) OriginalCoreCount, cast(null as varchar(100)) CPUName, cast(null as int) SingleCPUScore,
						PSN_Name RawCPUName
				from Inventory.Processors
					inner join Inventory.ProcessorNames on PSN_ID = PRS_PSN_ID
					left join Inventory.ProcessorCaptions on PCA_ID = PRS_PCA_ID
					inner join Inventory.MonitoredObjects on MOB_ID = PRS_MOB_ID
					cross apply (select replace(replace(replace(replace(replace(replace(ltrim(rtrim(replace(replace(replace(replace(replace(replace(PSN_Name, '(R)', ''), '(TM)', ''), 'CPU ', '')
													, '  ', ' ^'), '^ ', ''), '^', ''))), ' 0 ', ''),
													' Processor ', ' '), 'Dual Core', '[Dual CPU]'), 'Dual-Core', '[Dual CPU]'), '0@', '0 @'), ' MP ', ' ') CleanCPUName) c
					inner join Inventory.OSServers on (/*OSS_ID = MOB_Entity_ID
														or*/ OSS_MOB_ID = MOB_ID)
					
					
				group by MOB_ID, MOB_PLT_ID, CleanCPUName, OSS_InstallDate, case when OSS_IsVirtualServer = 1 then 1 else 0 end, PSN_Name
				union all
				select null, VES_ID, VES_CPUName, null, null, null, VES_NumberOfCPUSockets, null, null, null, null, null, null, VES_CPUName
				from Consolidation.VirtualizationESXServers
			)
		, CPUMarks as
			(select CPB_Name, CPB_Mark,
				replace(CPB_Name, '[Quad CPU] Quad-Core', 'Quad-Core') Name1,
				replace(CPB_Name, '[Quad CPU] ', '') Name2,
				replace(CPB_Name, '[Dual CPU] ', '') Name3
			from ExternalData.CPUBenchmark
			)
		, Final as
			(select CR_MOB_ID, CR_VES_ID, CleanCPUName, OSS_InstallDate, MaxClockSpeed, CPUDescription,
				c1.CPUCount, IsVM, NumberOfCores, NumberOfLogicalCores, CCI_CoreCount OriginalCoreCount, CPB_Name CPUName, CPB_Mark SingleCPUScore, RawCPUName,
				case when NumberOfCores/c1.CPUCount < 4 then c1.CPUCount*4 else NumberOfCores end LicensedCores
			from CPUs
				outer apply (select top 1 CPB_Name, CPB_Mark,
								case when CPUCount = 4 and CPB_Name like '[[]Quad CPU] %'
										then 4
									when CPUCount >= 2 and (CPB_Name like '[[]Dual CPU] %' or CPB_Name like '[[]Quad CPU] %')
										then 2
									else 0
								end ResetCPUCount
								from CPUMarks
								where (Name1 in (CleanCPUName, replace(CleanCPUName, '@', ' @'), replace(CleanCPUName, '- ', '-'))
										or (Name2 in (CleanCPUName, replace(CleanCPUName, '@', ' @')) and (CPUCount%4 = 0 or IsVM = 1))
										or (Name3  in (CleanCPUName, replace(CleanCPUName, '@', ' @')) and (CPUCount%2 = 0 or IsVM = 1))
										)
								order by case when CPUCount = 2 and CPB_Name like '[[]Dual CPU] %'
												or CPUCount = 4 and CPB_Name like '[[]Quad CPU] %'
											then 1
										else 0
									end desc, len(CPB_Name) desc
							) b
				outer apply (select top 1 CCI_CoreCount*case when CPB_Name like '[[]Dual CPU] %' and CCI_CPUName not like '[[]Dual CPU] %' then 2
															when CPB_Name like '[[]Quad CPU] %' and CCI_CPUName not like '[[]Quad CPU] %' then 4
															else 1
														end CCI_CoreCount
								from ExternalData.CPUCoreInfo
								where replace(CPB_Name, '- ', '-') like '%' + CCI_CPUName + '%'
													or CPB_Name = CCI_CPUName
													or CleanCPUName = CCI_CPUName
													or (CPB_Name is null
															and CleanCPUName like '%' + CCI_CPUName + '%')
								order by len(CCI_CPUName) desc) c
				cross apply (select case when ResetCPUCount > 0 and NumberOfCores = CCI_CoreCount*ResetCPUCount then CPUCount/ResetCPUCount else CPUCount end CPUCount) c1
		)
	select *
	from Final
GO
