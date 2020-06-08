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
/****** Object:  StoredProcedure [Consolidation].[usp_CheckCPUInfo]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Consolidation].[usp_CheckCPUInfo]
--declare
	@ReportMissingCPUsToAdm bit = 0
as
BEGIN
	set nocount on
	set ansi_warnings off
	if OBJECT_ID('tempdb..#CPUs') is not null
		drop table #CPUs
	if OBJECT_ID('tempdb..#MSCoreCountFactor') is not null
		drop table #MSCoreCountFactor

	truncate table Consolidation.CPUFactoring

	declare @CPUStretchingRatio decimal(10, 2),
		@StretchedCPUFactor decimal(10, 2),
		@HyperThreadingCPUFactor decimal(10, 2),
		@SQL nvarchar(max),
		@AdminDatabaseName nvarchar(128)

	select @CPUStretchingRatio = CAST(SET_Value as decimal(10, 2))
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Virtualization - CPU Core Stretch Ratio'

	select @StretchedCPUFactor = CAST(SET_Value as decimal(10, 2))
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Virtualization - Factor For Stretched CPUs'

	select @HyperThreadingCPUFactor = CAST(SET_Value as decimal(10, 2))
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Factor For Hyper-Threaded CPUs'

	select @AdminDatabaseName = CAST(SET_Value as nvarchar(128))
	from Management.Settings
	where SET_Module = 'Management'
		and SET_Key = 'Cloud Pricing Database Name'

	/*if @ReportMissingCPUsToAdm = 1
	begin*/
		set @SQL =
		'merge ExternalData.CPUBenchmark l
			using ' + quotename(@AdminDatabaseName) + '.CPUData.CPUBenchmark c 
				on l.CPB_Name = c.CPB_Name
				and c.CPB_Mark is not null
			when matched and l.CPB_Mark <> c.CPB_Mark then
				update set CPB_Mark = c.CPB_Mark
			when not matched then insert(CPB_Name, CPB_Mark)
								values(c.CPB_Name, c.CPB_Mark);

		merge ExternalData.CPUCoreInfo l
			using ' + quotename(@AdminDatabaseName) + '.CPUData.CPUCoreInfo c 
				on l.CCI_CPUName = c.CCI_CPUName
				and c.CCI_CoreCount is not null
			when matched and l.CCI_CoreCount <> c.CCI_CoreCount then
				update set CCI_CoreCount = c.CCI_CoreCount
			when not matched then insert(CCI_CPUName, CCI_CoreCount)
								values(c.CCI_CPUName, c.CCI_CoreCount);'

		exec(@SQL)
	--end

	select *
	into #CPUs
	from Consolidation.fn_CPUAnalysis()
	where exists (select *
					from Inventory.MonitoredObjects
					where MOB_ID = CR_MOB_ID
						and MOB_OOS_ID in (0, 1))
		or CR_MOB_ID is null

	if exists (select *
				from #CPUs
				where SingleCPUScore is null
					or OriginalCoreCount is null)
	begin
		
			set @SQL =
			'insert into ' + quotename(@AdminDatabaseName) + '.CPUData.MissingCPUs(MSC_CPUName, MSC_InstallationDate, MSC_MaxClockSpeed, MSC_CPUDescription, MSC_CPUScore, MSC_CoreCount, MSC_IsAdded)
			select CleanCPUName [CPU Name], max(OSS_InstallDate) [Installation Date],
				max(MaxClockSpeed) [Max Clock Speed], max(CPUDescription) [Description],
				max(SingleCPUScore) [CPU Score], max(OriginalCoreCount) [Core Count], 0 AS IsAdded
			from #CPUs
			where (SingleCPUScore is null
					or OriginalCoreCount is null)
				and not exists (select * from ' + quotename(@AdminDatabaseName) + '.CPUData.MissingCPUs where MSC_CPUName = CleanCPUName and MSC_IsAdded = 0) 
			group by CleanCPUName'

			exec(@Sql)
		if @ReportMissingCPUsToAdm = 1
			begin
			IF EXISTS (SELECT top 1 1 FROM #CPUs WHERE SingleCPUScore IS NULL OR OriginalCoreCount IS NULL)
			BEGIN
				SELECT
					C.CR_MOB_ID AS MOB_ID,
					M.MOB_Name,
					CASE WHEN C.SingleCPUScore IS NULL THEN 1 ELSE 0 END AS Is_CPUBenchmarkMissing,
					CASE WHEN C.OriginalCoreCount IS NULL THEN 1 ELSE 0 END AS Is_CPUCoreCountMissing
					--CPUName AS [CPU Name]
				FROM 
					#CPUs AS C
					INNER JOIN Inventory.MonitoredObjects AS M
					ON C.CR_MOB_ID = M.MOB_ID 
				WHERE 
					C.SingleCPUScore is null
					OR C.OriginalCoreCount is null
			END ELSE
			BEGIN
				SELECT
					CAST(NULL AS int) AS MOB_ID,
					CAST(NULL AS nvarchar(255)) AS MOB_Name,
					CAST(NULL AS bit) AS Is_CPUBenchmarkMissing,
					CAST(NULL AS bit) AS Is_CPUCoreCountMissing
					--CAST(NULL AS NVARCHAR(255)) AS [CPU Name]
				WHERE 0=1
			END

			--raiserror('Missing CPUs reported. DMO cannot proceed until missing data is provided', 16, 1)
		end
		else
			select CleanCPUName [CPU Name], max(OSS_InstallDate) [Installation Date],
				max(MaxClockSpeed) [Max Clock Speed], max(CPUDescription) [Description],
				max(SingleCPUScore) [CPU Score], max(OriginalCoreCount) [Core Count]
			from #CPUs
			where SingleCPUScore is null
				or OriginalCoreCount is null
			group by CleanCPUName

		return
	end

	;with CPUFactoring as
			(select CR_MOB_ID, CR_VES_ID,
				case when CR_VES_ID is not null
							then CPUCount
						when IsVM = 0
							then case when NumberOfLogicalCores = NumberOfCores and CPUCount is not null then CPUCount
									when CPUCount < OriginalCoreCount and NumberOfCores is null then CPUCount
									when NumberOfCores > CPUCount or NumberOfCores is null
										then CPUCount * 1.0 /case when CPUName like '%Dual%' then 2
															when CPUName like '%Quad%' then 4
															when NumberOfCores is null then OriginalCoreCount
															else 1
														end
										else 1
									end
								* case when NumberOfLogicalCores = NumberOfCores*2
										then @HyperThreadingCPUFactor
										else 1
									end
						when IsVM = 1
							then case when OriginalCoreCount > coalesce(NumberOfCores, CPUCount)
										then coalesce(NumberOfCores, CPUCount)*1./OriginalCoreCount
									when OriginalCoreCount < coalesce(NumberOfCores, CPUCount)
										then OriginalCoreCount*1./coalesce(NumberOfCores, CPUCount)
									else 1
								end
					end CPUFactor,
				CPUName,
				case when CR_VES_ID is null
					then SingleCPUScore
					else SingleCPUScore*@StretchedCPUFactor
				end SingleCPUScore,
				case when CR_VES_ID is not null
					then OriginalCoreCount*CPUCount*@CPUStretchingRatio
					else coalesce(NumberOfCores, CPUCount)
				end CPUCount, isnull(IsVM, 0) IsVM
			from #CPUs
			)
	insert into Consolidation.CPUFactoring
	select distinct CR_MOB_ID, CR_VES_ID, case when CPUFactor >= 2 then CPUFactor * .75 else CPUFactor end CPUFactor, CPUName, SingleCPUScore, CPUCount, IsVM, 0
	from CPUFactoring

	;with UsableCores as
			(select CPF_MOB_ID MOB_ID, DID_NumberOfAvailableSchedulers/HyperThreadingFactor UsableCoreCount
				from Consolidation.CPUFactoring c
					cross apply (select top 1 MOB_ID, MOB_Name, DID_NumberOfAvailableSchedulers
									from Consolidation.ParticipatingDatabaseServers
										inner join Inventory.MonitoredObjects on MOB_ID = PDS_Database_MOB_ID
										inner join Inventory.DatabaseInstanceDetails on DID_DFO_ID = MOB_Entity_ID
									where PDS_Server_MOB_ID = CPF_MOB_ID
									order by DID_NumberOfAvailableSchedulers desc) d
					cross apply (select iif(sum(PRS_NumberOfCores) *2 = sum(PRS_NumberOfLogicalProcessors), 2, 1) HyperThreadingFactor
								from Inventory.Processors
								where PRS_MOB_ID = CPF_MOB_ID) h
				where DID_NumberOfAvailableSchedulers is not null
					and DID_NumberOfAvailableSchedulers <> CPF_CPUCount
					and DID_NumberOfAvailableSchedulers <> CPF_CPUCount*2
					and DID_NumberOfAvailableSchedulers/2 < CPF_CPUCount
					and CPF_IsUsableCoreCountApplied = 0
			)
	update c
	set CPF_CPUCount = UsableCoreCount,
		CPF_CPUFactor = UsableCoreCount*1./CPF_CPUCount*CPF_CPUFactor,
		CPF_IsUsableCoreCountApplied = 1
	from Consolidation.CPUFactoring c
		inner join UsableCores on MOB_ID = CPF_MOB_ID
END
GO
