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
/****** Object:  StoredProcedure [GUI].[usp_Get_Executive_Summary]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_Get_Executive_Summary]
--declare
	@ReportType		tinyint = 1,
	@ShowInActive	bit = 0,
	@MOB_ID_List	Inventory.SystemHosts_List readonly
	
AS
BEGIN
	IF object_id('tempdb..#Result') is not null
		DROP TABLE #Result

	CREATE TABLE #Result
	(
		MOB_ID					int, 
		SYS_Name				nvarchar(512),
		ComputerName			nvarchar(512), 
		SQLServerProductName	nvarchar(512), 
		SQLServerVersion		nvarchar(512), 
		SQLServerServicePack	nvarchar(512), 
		SQLServerEdition		nvarchar(512), 
		OperatingSystem			nvarchar(512), 
		OperatingSystemServicePack   nvarchar(512), 
		OSArchitectureType		nvarchar(512), 
		NumberOfProcessors		int, 
		NumberOfTotalCores		int, 
		NumberOfLogicalProcessors   int, 
		LicensedCores			int, 
		SystemMemoryMB			nvarchar(512), 
		MachineType				nvarchar(512), 
		MachineManufacturer		nvarchar(512), 
		MachineModel			nvarchar(512), 
		DB_COUNT				int, 
		PLT_ID					tinyint,
		Edition					nvarchar(512),
		PCR_Child_MOB_ID		int, 
		Device_Type				nvarchar(512), 
		SQL_InstanceName		nvarchar(512), 
		DB_PLT_ID				tinyint, 
		PLT_Name				nvarchar(512) ,
		DB_PLT_Name				nvarchar(512), 
	)

	INSERT INTO #Result
	EXEC usp_Get_Executive
		@ReportType = @ReportType,
		@ShowInActive = @ShowInActive,
		@MOB_ID_List = @MOB_ID_List


	if @ReportType = 1
	select 
			mob_id,
			SYS_Name,
			ComputerName,
			/*REPLACE(REPLACE(SQLServerProductName,'Microsoft SQL Server','SQL'),'Edition','') as*/ SQLServerProductName,
			SQLServerVersion,
			SQLServerEdition,
			OperatingSystem,
			MachineType,
			DB_COUNT
			,Device_Type
			,SQL_InstanceName
			,PCR_Child_MOB_ID
	from	#Result 
	order by 1, 2


	if @ReportType = 2
	select 
			mob_id,
			SYS_Name,
			ComputerName,
			SQLServerProductName,
			SQLServerVersion,
			SQLServerServicePack,
			SQLServerEdition,
			OperatingSystem,
			OperatingSystemServicePack,
			OSArchitectureType,
			NumberOfProcessors, 
			NumberOfTotalCores, 
			LicensedCores, 
			MachineType,
			DB_COUNT,
			Edition as Win_Edition
			,Device_Type
			,SQL_InstanceName
			,PCR_Child_MOB_ID
			,PLT_Name
			,DB_PLT_Name
	from	#Result
	order by 1, 2

	if @ReportType = 3
	begin

		; with oosupp as 
		(
			select 
				MOB_ID
				, PLY_Name SQLVersion
				, PLY_ReleaseDate
				, PLY_MainstreamSupportEndDate
				, PLY_ExtendedSupportEndDate
			from Inventory.MonitoredObjects
				inner join Inventory.Versions on VER_ID = MOB_VER_ID
				cross apply (select top 1 *
								from ExternalData.ProductLifeCycles
								where PLY_MinVersionNumber < VER_Number
								order by PLY_MinVersionNumber desc) v
			where	PLY_MainstreamSupportEndDate < sysdatetime()
		)
		select	distinct 
				r.MOB_ID,
				SYS_Name,
				ComputerName,
				SQLServerProductName,
				SQLServerVersion,
				SQLServerServicePack,
				SQLServerEdition,
				OperatingSystem,
				OperatingSystemServicePack,
				OSArchitectureType,
				NumberOfProcessors, 
				NumberOfTotalCores, 
				LicensedCores, 
				ROUND((cast(case when SystemMemoryMB = 'N/A' then '0' else SystemMemoryMB end as int) + 1) / 1024.0,2) as SystemMemoryMB,
				MachineType,
				MachineManufacturer,
				MachineModel,
				DB_COUNT,
				IIF(PLT_ID = 2,case when s1.MOB_ID is null then 0 else 1 end,0) as Out_Of_Support_win
				,IIF(PLT_ID = 1,case when s1.MOB_ID is null then 0 else 1 end, case when s2.MOB_ID is null then 0 else 1 end) as Out_Of_Support_sql
				,Device_Type
				,SQL_InstanceName
				,PCR_Child_MOB_ID
		from	#Result r
		--left join	Inventory.ParentChildRelationships rel on r.MOB_ID = rel.PCR_Parent_MOB_ID 
		left join	oosupp s1 on r.MOB_ID = s1.MOB_ID
		left join	oosupp s2 on PCR_Child_MOB_ID = s2.MOB_ID
	END

	if @ReportType = 4
	BEGIN

		if object_id('tempdb..#ResourceRecommendations') is not null
			drop table #ResourceRecommendations

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

		exec [Consolidation].[usp_Reports_ResourceUtilization] @ReturnResults = 0

		select
				MOB_ID
				,SYS_Name
				,ComputerName
				,SQLServerProductName
				,SQLServerVersion
				,SQLServerServicePack
				,SQLServerEdition
				,OperatingSystem
				,OperatingSystemServicePack
				,OSArchitectureType
				,NumberOfProcessors 
				,NumberOfTotalCores 
				,NumberOfLogicalProcessors
				,LicensedCores
				,SystemMemoryMB
				,MachineType
				,MachineManufacturer
				,MachineModel 
				,DB_COUNT
				,PLT_ID
				,Edition
				,CGR_Name as GroupName
				,AlertType
				,Recommendation
				,Device_Type 
				,SQL_InstanceName
				,PCR_Child_MOB_ID
		from	#Result	
		join	#ResourceRecommendations on ComputerName = ServerName
		join	Consolidation.ServerGrouping on MOB_ID = SGR_MOB_ID
		join	Consolidation.ConsolidationGroups on SGR_CGR_ID = CGR_ID

	END

	SELECT 
			MAX(TRH_EndDate)  as LastUpdDate
	FROM	Collect.TestRunHistory WITH (NOLOCK)
END
GO
