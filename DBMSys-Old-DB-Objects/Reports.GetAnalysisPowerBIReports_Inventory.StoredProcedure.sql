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
/****** Object:  StoredProcedure [Reports].[GetAnalysisPowerBIReports_Inventory]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [Reports].[GetAnalysisPowerBIReports_Inventory]
--DECLARE
	@DSUGUID	UNIQUEIDENTIFIER
AS
if object_id('tempdb..#temp') is not null
	drop table #temp

	DECLARE 
			@AdmDB NVARCHAR(255)

	SELECT  
			@AdmDB = CAST(SET_Value AS NVARCHAR(255))
	FROM	Management.Settings 
	where	SET_Key = 'Cloud Pricing Database Name'

	DECLARE @CMD NVARCHAR(MAX)

	SET @CMD = 'EXEC ' + @AdmDB + '.dbo.usp_UpdateProcessingStatus ''' + CAST(@DSUGUID AS NVARCHAR(50)) + ''',5,''Upload Inventory Data to AnalysisDB'''

	EXEC (@CMD)
	
select	s.MOB_ID	AS Server_ID
		,d.MOB_ID	AS DBInstance_ID
		,CustomerName [Customer Name]
		,s.MOB_Name [Server Name]
		,sp.PLT_Name [Server Platform Type]
		,isnull(ServerVersionName, iif(isnumeric(sv.VER_Name) = 0, sv.VER_Name
		,cast(cast(sv.VER_Name as decimal(10, 2)) as varchar(10)))) [Server Version]
		,ServerMainstreamSupportEndDate [Server Mainstream Support End Date]
		,ServerExtendedSupportEndDate [Server Extended Support End Date]
		,se.EDT_Name [Server Edition]
		,iif(ISNULL(IsVM,0) = 1 OR MMD_Name LIKE '%Virtual%', 'Yes', 'No') [Virtualized]
		, CoreCount [Core Count]
		, OSS_TotalPhysicalMemoryMB [Server Memory (MB)]
		,DID_Name [Database Instance Name]
		,dp.PLT_Name [Database Instance Platform Type]
		,isnull(DatabaseInstanceVersionName,iif(dv.VER_Name like '%' + dp.PLT_Name + '%','',dp.PLT_Name + ' ') + iif(isnumeric(dv.VER_Name) = 0, dv.VER_Name
		,cast(cast(dv.VER_Name as decimal(10, 2)) as varchar(10)))) [Database Instance Version]
		,DatabaseInstanceMainstreamSupportEndDate [Database Instance Mainstream Support End Date]
		,DatabaseInstanceExtendedSupportEndDate [Database Instance Support End Date]
		,de.EDT_Name [Database Instance Edition]
		,IDB_Name [Database/Schema Name]
		,coalesce(DatabaseVersionName, DatabaseInstanceVersionName, iif(isnumeric(dv.VER_Name) = 0, dv.VER_Name, cast(cast(dv.VER_Name as decimal(10, 2)) as varchar(10)))) [Database Compatibility Level]
		,iif(IDB_Name is not null, isnull(SizeMB, 0), null) [Database Size (MB)]
		,cast(OSS_InstallDate as date) [OS Installation Date]
		,ISNULL(MMD_Name,'') [Machine Model]
		,ISNULL(MMN_Name + ' ','') [Machine Manufacturer]
		,CPUName [CPU Model]
		,CPUScore [CPU Score]  --NEW
		,IDB_LastUsageDate AS [Last Date Database as accessed]
		,DSK_TotalSpaceMB AS [Logical Disks]
		,LogicalProcessors as [Logical Processors count]
		, PhisicalCores AS [Phisical Processors count]
		,DSK_Path
into	#temp
from	(
			select 
					cast(SET_Value as varchar(200)) CustomerName
			from	Management.Settings
			where	SET_Module = 'Management'
					and SET_Key = 'Environment Name'
		) cn
		cross join Inventory.MonitoredObjects s
		inner join Management.ObjectOperationalStatuses ss on s.MOB_OOS_ID = ss.OOS_ID
		inner join Management.PlatformTypes sp on sp.PLT_ID = s.MOB_PLT_ID
		inner join Inventory.Versions sv on sv.VER_ID = s.MOB_VER_ID
		inner join Inventory.Editions se on se.EDT_ID = s.MOB_Engine_EDT_ID
		inner join Inventory.OSServers on (/*OSS_ID = s.MOB_Entity_ID
											or*/ OSS_MOB_ID = s.MOB_ID)
		left join Inventory.MachineManufacturers on MMN_ID = OSS_MMN_ID  --NEW
		left join Inventory.MachineManufacturerModels on MMD_ID = OSS_MMD_ID  --NEW
		LEFT join Inventory.Disks ON MOB_ID = DSK_MOB_ID
		cross apply (select SUM(CPUCount) CoreCount, max(IsVM) IsVM, max(CleanCPUName) CPUName, max(SingleCPUScore) CPUScore  --NEW
						,sum(NumberOfLogicalCores) LogicalProcessors
						,SUM(NumberOfCores) AS PhisicalCores
						from Consolidation.fn_CPUAnalysis()
						WHERE CR_MOB_ID = MOB_ID) c
		outer apply (select top 1 PLY_Name ServerVersionName, PLY_MainstreamSupportEndDate ServerMainstreamSupportEndDate, PLY_ExtendedSupportEndDate ServerExtendedSupportEndDate
						from ExternalData.ProductLifeCycles
						where PLY_PLT_ID = s.MOB_PLT_ID
							and PLY_MinVersionNumber <= sv.VER_Number
						order by PLY_MinVersionNumber desc) svn
		left join (Inventory.ParentChildRelationships
					inner join Inventory.MonitoredObjects d on d.MOB_ID = PCR_Child_MOB_ID
					inner join Management.ObjectOperationalStatuses ds on d.MOB_OOS_ID = ds.OOS_ID
					inner join Management.PlatformTypes dp on dp.PLT_ID = d.MOB_PLT_ID
															and dp.PLT_PLC_ID = 1
					inner join Inventory.Versions dv on dv.VER_ID = d.MOB_VER_ID
					inner join Inventory.DatabaseInstanceDetails on /*DID_OSS_ID = OSS_ID--*/DID_DFO_ID = d.MOB_Entity_ID
					inner join Inventory.Editions de on de.EDT_ID = DID_EDT_ID
					left join Inventory.InstanceDatabases on IDB_MOB_ID = d.MOB_ID
					outer apply (select top 1 PLY_Name DatabaseInstanceVersionName, PLY_MainstreamSupportEndDate DatabaseInstanceMainstreamSupportEndDate,
											PLY_ExtendedSupportEndDate DatabaseInstanceExtendedSupportEndDate
									from ExternalData.ProductLifeCycles
									where PLY_PLT_ID = d.MOB_PLT_ID
										and PLY_MinVersionNumber <= dv.VER_Number
									order by PLY_MinVersionNumber desc) dvn
					outer apply (select top 1 PLY_Name DatabaseVersionName
									from ExternalData.ProductLifeCycles
									where PLY_PLT_ID = d.MOB_PLT_ID
										and PLY_MinVersionNumber <= IDB_CompatibilityLevel/10
									order by PLY_MinVersionNumber desc) dbvn
					outer apply (select sum(SizeMB) SizeMB
									from Inventory.DatabaseFiles
										inner join PerformanceData.CounterInstances on CIN_Name = DBF_FileName
										outer apply (select top 1 cast(CRS_Value as bigint) SizeMB
											from PerformanceData.CounterResults with (forceseek)
											where CRS_MOB_ID = d.MOB_ID
												and CRS_SystemID = 3
												and CRS_CounterID = 41
												and CRS_InstanceID = CIN_ID
											order by CRS_DateTime desc) r
									where DBF_IDB_ID = IDB_ID
										and DBF_DFT_ID <> 1) sz
					) on PCR_Parent_MOB_ID = s.MOB_ID AND ds.OOS_IsOperational = 1 AND DID_OSS_ID = OSS_ID
where	sp.PLT_PLC_ID = 2
		and (PCR_IsCurrentParent = 1 or PCR_ID is null)
		and ss.OOS_IsOperational = 1

select distinct Server_ID,[Customer Name], [Server Name], [Server Platform Type], [Server Version], [Server Mainstream Support End Date], [Server Extended Support End Date]
	, [Server Edition], [Virtualized], [Core Count], [Server Memory (MB)]
	, [OS Installation Date], [Machine Model], [CPU Model], [CPU Score] --NEW
	, [Logical Processors count],[Machine Manufacturer],[Phisical Processors count]
from #temp
order by [Customer Name], [Server Name]

select distinct Server_ID,DBInstance_ID, [Customer Name], [Server Name], [Database Instance Name], [Database Instance Platform Type], [Database Instance Version]
	, [Database Instance Mainstream Support End Date], [Database Instance Support End Date], [Database Instance Edition]
from #temp
where [Database Instance Name] is not null
order by [Customer Name], [Server Name], [Database Instance Name]

select distinct DBInstance_ID, [Customer Name], [Server Name], [Database Instance Name], [Database/Schema Name], [Database Compatibility Level], [Database Size (MB)],[Last Date Database as accessed]
from #temp
where [Database/Schema Name] is not null
order by [Customer Name], [Server Name], [Database Instance Name], [Database/Schema Name]

SELECT	DISTINCT
		Server_ID
		,[Logical Disks]
		,DSK_Path
FROM	#temp


SELECT	DISTINCT 
		DBInstance_ID
		,SPA_DatabaseName
		,SPA_SchemaName
		,SPA_ObjectType
		,SPA_ObjectCount
FROM	Inventory.DBInstancePortfolioAssessment 
JOIN	#temp ON SPA_MOB_ID = DBInstance_ID
GO
