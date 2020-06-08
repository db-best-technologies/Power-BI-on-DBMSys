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
/****** Object:  StoredProcedure [dbo].[usp_Get_Executive]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_Get_Executive]
	@ReportType tinyint = 1
	,@ShowInActive bit = 0
	,@MOB_ID_List Inventory.SystemHosts_List readonly
AS
BEGIN
	
	declare 
		@MOB_ID_ARR	Inventory.SystemHosts_List,
		@FromDate	datetime2(3),
		@ToDate		datetime2(3)

	if exists (select * from @MOB_ID_List)
		insert into @MOB_ID_ARR(SHS_MOB_ID)
		select SHS_MOB_ID from @MOB_ID_List
	else
		insert into @MOB_ID_ARR(SHS_MOB_ID)
		select MOB_ID from Inventory.MonitoredObjects

	if object_id('tempdb..#Processors') is not null
		drop table #Processors

	SELECT 
			CR_MOB_ID AS PRS_MOB_ID,
			CPUCount AS Processors,
			NumberOfCores AS CoreCount,
			NumberOfLogicalCores AS LogicalProcessors,
			LicensedCores,
			SingleCPUScore AS CPUScore
	INTO #Processors
	FROM Consolidation.fn_CPUAnalysis()

	SELECT
		@FromDate = min(CRS_DateTime),
		@ToDate = max(CRS_DateTime)
	FROM 
		PerformanceData.CounterResults


	;WITH ServerList AS
	(
		SELECT MOB_ID AS S_MOB_ID
		FROM 
			Inventory.MonitoredObjects AS o
			INNER JOIN Management.ObjectOperationalStatuses 
			ON MOB_OOS_ID = OOS_ID
			--join @MOB_ID_ARR arr on o.MOB_ID = arr.SHS_MOB_ID
			INNER JOIN Inventory.OSServers 
			ON OSS_MOB_ID = MOB_ID
		WHERE exists (select *
							from Management.PlatformTypes
							where PLT_ID = MOB_PLT_ID
								and PLT_PLC_ID = 2)
					and exists (
									select 1 from @MOB_ID_ARR arr where o.MOB_ID = arr.SHS_MOB_ID
									union all
									select 1 from Inventory.ParentChildRelationships
									join @MOB_ID_ARR on PCR_Child_MOB_ID = SHS_MOB_ID
									where PCR_Parent_MOB_ID = o.MOB_ID)
									
				and ( OOS_IsOperational = 1 or @ShowInactive = 1)
		)
	, Processors as
		(select *
			from #Processors
		)
	select 
			s.MOB_ID,
			SYS_Name,
			s.MOB_Name ComputerName,
			case when PCR_Parent_MOB_ID is null then null else  isnull(/*'Microsoft SQL Server '*/d.VER_Name + ' ' + d.EDT_Name, 'No DBMS data available') end SQLServerProductName,
			case when PCR_Parent_MOB_ID is null then null else  isnull(left(ltrim(rtrim(d.VER_Name)), charindex(' -', d.VER_Name + ' -', 1) - 1), 'N/A') end SQLServerVersion,
			case when PCR_Parent_MOB_ID is null then null else  isnull(d.PRL_Name, 'N/A') end SQLServerServicePack,
			case when PCR_Parent_MOB_ID is null then null else  isnull(d.EDT_Name, 'N/A') end SQLServerEdition,
			coalesce(LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(se.EDT_NAME,'Microsoft',''),'Windows',''),'(R)',''),'®',''),'Edition',''))),'N/A') OperatingSystem,
			isnull(sp.PRL_Name, 'N/A') OperatingSystemServicePack,
			isnull(cast(case when se.EDT_Name is not null then isnull(OSS_Architecture, 32) end as char(2)) + '-bit', 'N/A') OSArchitectureType,
			Processors NumberOfProcessors, 
			CoreCount NumberOfTotalCores, 
			LogicalProcessors NumberOfLogicalProcessors, 
			LicensedCores, 
			isnull(cast(OSS_TotalPhysicalMemoryMB as varchar(100)), 'N/A') SystemMemoryMB,
			case when OSS_IsVirtualServer = 1 then 'Virtual' else 'Physical' end MachineType,
			coalesce(MMN_Name, 'N/A') MachineManufacturer,
			isnull(MMD_Name, 'N/A') MachineModel 
			,IDB.DB_COUNT
			,MOB_PLT_ID as PLT_ID
			,LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(se.EDT_NAME,'Microsoft',''),'Windows',''),'(R)',''),'SERVER',''),'®',''),'Edition',''))) as Edition
			,PCR_Child_MOB_ID
			,CASE WHEN se.EDT_NAME like '%Server%' THEN 'Server' WHEN se.EDT_NAME NOT LIKE '%Server%' THEN 'Workstation' else 'Unknown' END as Device_Type
			,/*d.DID_InstanceName as*/ SQL_InstanceName
			,DB_PLT_ID
			,PLT_Name
			,DB_PLT_Name
	--into	#Result
	from	Inventory.OSServers
	inner join Inventory.MonitoredObjects s on OSS_MOB_ID = s.MOB_ID
	inner join	Management.PlatformTypes on s.MOB_PLT_ID = PLT_ID
	left join Inventory.SystemHosts on MOB_ID = SHS_MOB_ID
	left join Inventory.Systems on SHS_SYS_ID = SYS_ID
	left join Consolidation.ServerGrouping on SGR_MOB_ID = MOB_ID
	left join Consolidation.ConsolidationGroups on CGR_ID = SGR_CGR_ID
	left join (select PCR_Parent_MOB_ID,DID_InstanceName, DID_IsClustered, EDT_Name + IIF(EDT_Name LIKE '%Edition%','','Edition') AS EDT_Name, IIF(MOB_PLT_ID = 1,'Microsoft SQL Server ','') + VER_Name AS VER_Name, PRL_Name,PCR_Child_MOB_ID,d.MOB_Name as SQL_InstanceName, d.MOB_PLT_ID as DB_PLT_ID,PLT_Name as DB_PLT_Name
					from Inventory.ParentChildRelationships
						inner join Inventory.MonitoredObjects d on d.MOB_ID = PCR_Child_MOB_ID
						join @MOB_ID_ARR arr on d.MOB_ID = arr.SHS_MOB_ID
						inner join Inventory.DatabaseInstanceDetails on d.MOB_Entity_ID = DID_DFO_ID
						inner join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
																and PLT_PLC_ID = 1
						inner join Inventory.Versions dv on d.MOB_VER_ID = dv.VER_ID
						left join Inventory.ProductLevels dp on DID_PRL_ID = dp.PRL_ID
						left join Inventory.Editions de on DID_EDT_ID = de.EDT_ID
					where	MOB_OOS_ID = 1 or @ShowInactive = 1
					) d on PCR_Parent_MOB_ID = s.MOB_ID 
	outer apply (select sum(Processors) Processors, sum(CoreCount) CoreCount, sum(LogicalProcessors) LogicalProcessors, sum(LicensedCores) LicensedCores, sum(CPUScore) CPUScore
					from Processors
					where PRS_MOB_ID = s.MOB_ID) prs
	
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
	outer apply(
					SELECT 
							count(*) as DB_COUNT
					from	Inventory.InstanceDatabases idb_db
					where	d.PCR_Child_MOB_ID = idb_db.IDB_MOB_ID
						
				) IDB
	where	exists (select *
					from ServerList
					where s.MOB_ID = S_MOB_ID)
	union all
	select  
			MOB_ID,
			SYS_Name,
			MOB_Name,
			/*isnull('Microsoft SQL Server ' + EDT_Name, 'No SQL Server data available')*/isnull(IIF(MOB_PLT_ID = 1,'Microsoft SQL Server ','') + VER_Name + ' ' + EDT_Name + IIF(EDT_Name LIKE '%Edition%','','Edition'), 'No DBMS data available') SQLServerProductName,
			isnull(left(ltrim(rtrim(IIF(MOB_PLT_ID = 1,'Microsoft SQL Server ','') + VER_Name)), charindex(' -', IIF(MOB_PLT_ID = 1,'Microsoft SQL Server ','') + VER_Name + ' -', 1) - 1), 'N/A') SQLServerVersion,
			isnull(PRL_Name, 'N/A') SQLServerServicePack,
			isnull(EDT_Name + IIF(EDT_Name LIKE '%Edition%','','Edition'), 'N/A') SQLServerEdition,
			null,
			null,
			null,
			Processors NumberOfProcessors, 
			CoreCount NumberOfTotalCores, 
			LogicalProcessors NumberOfLogicalProcessors,
			LicensedCores, 
			null,
			null,
			null,
			null,
			IDB.DB_COUNT
			,NULL--PLT_ID
			,null
			,null
			,'Database'
			,MOB_Name
			,PLT_ID
			,NULL
			,PLT_Name
	from	Inventory.MonitoredObjects d 
	left join Inventory.SystemHosts on MOB_ID = SHS_MOB_ID
	left join Inventory.Systems on SHS_SYS_ID = SYS_ID
	inner join Inventory.DatabaseInstanceDetails on d.MOB_Entity_ID = DID_DFO_ID
	inner join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
											and PLT_PLC_ID = 1
	inner join Inventory.Versions dv on d.MOB_VER_ID = dv.VER_ID
	left join Inventory.ProductLevels dp on DID_PRL_ID = dp.PRL_ID
	left join Inventory.Editions de on DID_EDT_ID = de.EDT_ID
	outer apply(
					SELECT 
							count(*) as DB_COUNT
					from	Inventory.InstanceDatabases
					where	IDB_MOB_ID = d.MOB_ID
						
				) IDB
	outer apply (select sum(Processors) Processors, sum(CoreCount) CoreCount, sum(LogicalProcessors) LogicalProcessors, sum(LicensedCores) LicensedCores, sum(CPUScore) CPUScore
					from Processors
					where PRS_MOB_ID = d.MOB_ID) prs
	where not exists (select * from Inventory.ParentChildRelationships where PCR_Child_MOB_ID = d.MOB_ID)

END
GO
