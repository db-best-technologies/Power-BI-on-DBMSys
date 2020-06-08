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
/****** Object:  StoredProcedure [Consolidation].[usp_Reports_AzureDBMILimitingFeatures]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Consolidation].[usp_Reports_AzureDBMILimitingFeatures]
--DECLARE
	@ShowReport BIT = 1

AS
	IF OBJECT_ID('tempdb..#DBMILimitingFeatures') IS NOT NULL
		DROP TABLE #DBMILimitingFeatures
	CREATE TABLE #DBMILimitingFeatures
	(
		MOBID			INT
		,EntityName		NVARCHAR(MAX)
		,FeatureName	NVARCHAR(MAX)
		,FDescription	NVARCHAR(MAX)
	)
	INSERT INTO #DBMILimitingFeatures
	SELECT 
			DLF_MOB_ID
			,DLF_Entityname + ISNULL('\' + DLF_EntityChildName,'') 
			,DLF_LimitedF
			,DLF_LimitedF + ' ' + DLF_Entityname + ISNULL('\' + DLF_EntityChildName,'')
	FROM	Inventory.DBMILimitingFeatures
	WHERE	DLF_IsDeleted = 0
	UNION ALL
	--	Compatibility level
	SELECT 
			IDB_MOB_ID
			,IDB_Name
			,'Database Compatibility Level' 
			,'Database ' + IDB_Name + ' Compatibility Level = ' + CAST(IDB_CompatibilityLevel AS NVARCHAR(5))
	FROM	Inventory.InstanceDatabases
	JOIN	Inventory.MonitoredObjects on MOB_ID = IDB_MOB_ID
	WHERE	IDB_CompatibilityLevel < 100
			AND MOB_PLT_ID = 1
			AND IDB_IsDeleted = 0
			AND IDB_Name NOT IN ('master','tempdb','model','msdb')
	UNION ALL 
	--	Windows user are not supported
	SELECT 
			INL_MOB_ID
			,INL_Name
			,'Logins'
			,'Windows logins ' + INL_Name
	FROM	Inventory.InstanceLogins
	JOIN	Inventory.InstanceLoginTypes ON ILT_ID = INL_ILT_ID
	WHERE	ILT_Name LIKE '%WINDOWS%'
			AND INL_Name NOT LIKE '%NT %'
	UNION ALL
	--	Collation
	SELECT 
			MOB_ID
			,DID_Name
			,'Collation'
			,'Database ' + DID_Name + ' collation is ' + CLT_Name
	FROM	Inventory.DatabaseInstanceDetails 
	JOIN	Inventory.CollationTypes ON DID_CLT_ID = CLT_ID
	JOIN	Management.DefinedObjects ON DFO_ID = DID_DFO_ID
	JOIN	Inventory.MonitoredObjects ON DFO_ID = MOB_Entity_ID AND DFO_PLT_ID = MOB_PLT_ID
	WHERE	CLT_Name <> 'SQL_Latin1_General_CP1_CI_AS'
	UNION ALL
	--	Multiple log files 
	SELECT
			IDB_MOB_ID
			,IDB_Name
			,'Multiple log files'
			,'Log files count = ' + CAST(COUNT(1) AS NVARCHAR(50))
	FROM	Inventory.DatabaseFiles
	JOIN	Inventory.DatabaseFileTypes ON DFT_ID = DBF_DFT_ID
	JOIN	Inventory.InstanceDatabases ON IDB_ID = DBF_IDB_ID
	WHERE	DFT_Name = 'Log'
	GROUP BY IDB_MOB_ID
			,IDB_Name
	HAVING COUNT(1)>1
	UNION ALL
	--	DB files count
	SELECT
			IDB_MOB_ID
			,IDB_Name
			,'DB files count more then 280'
			,'Log files count = ' + CAST(COUNT(1) AS NVARCHAR(50))
	FROM	Inventory.DatabaseFiles
	JOIN	Inventory.InstanceDatabases ON IDB_ID = DBF_IDB_ID
	GROUP BY IDB_MOB_ID
			,IDB_Name
	HAVING COUNT(1)>280
	UNION ALL
	--	filestream
	SELECT	DISTINCT
			IDB_MOB_ID
			,IDB_Name 
			,'Filestream filetypes'
			,'Database file <' + DFT_Name + '> has Filestream type'
	FROM	Inventory.DatabaseFiles
	JOIN	Inventory.DatabaseFileTypes ON DFT_ID = DBF_DFT_ID
	JOIN	Inventory.InstanceDatabases ON IDB_ID = DBF_IDB_ID
	WHERE	DFT_Name = 'Filestream'
	UNION ALL
	--	TempDB size & count
	SELECT 
			DBF_MOB_ID
			,IDB_Name
			,'TempDB size & count'
			,'TempDB ' + ISNULL('max size = ' + CAST(MAX(CRS_Value) AS NVARCHAR(10)) + ' &','') + ' count = ' + CAST(COUNT(1) AS NVARCHAR(10))
	FROM	Inventory.DatabaseFiles 
	JOIN	Inventory.InstanceDatabases ON DBF_IDB_ID = IDB_ID
	OUTER APPLY (
					select 
							top 1 CRS_Value 
					from	PerformanceData.CounterResults WITH (NOLOCK)
					JOIN	PerformanceData.CounterInstances ON CIN_ID = CRS_InstanceID
					where	CRS_CounterID = 41 
							and CRS_SystemID = 3 
							and CRS_MOB_ID = IDB_MOB_ID
							AND CIN_Name = DBF_Name
					order by CRS_DateTime desc
				)siz
	WHERE	IDB_Name = 'tempdb'
	GROUP BY DBF_MOB_ID, IDB_Name
	HAVING COUNT(*) > 12 OR MAX(CRS_Value)*1.0 / 1024.0 > 14
	UNION ALL
	-- sp_configure option
	SELECT 
			ICF_MOB_ID
			,'SQL Server'
			,ICT_Name + ' enabled'
			,'Run value = ' + CAST(ICF_ConfiguredValue AS NVARCHAR(10))
	FROM	Inventory.InstanceConfigurations c
	JOIN	Inventory.InstanceConfigurationTypes t on c.ICF_ICT_ID = t.ICT_ID
	WHERE	t.ICT_Name IN 
			('allow polybase export'
			,'allow updates'
			,'filestream_access_level'
			,'remote data archive'
			,'remote proc tran'
			,'external scripts enabled'
			,'xp_cmdshell'
			)
			AND ICF_ConfiguredValue = 1
			OR ICF_ConfiguredValue <> 65536 
			AND ICT_Name = 'max text repl size' 
	UNION ALL
	--	filestream
	SELECT 
			IDB_MOB_ID
			,IDB_Name
			,'Filegroups contains Filestream'
			,DFG_Name + ' located on ' + DBF_FileName
	FROM	Inventory.InstanceDatabases
	JOIN	Inventory.DatabaseFiles on DBF_IDB_ID = IDB_ID
	JOIN	Inventory.DatabaseFileGroups ON DBF_DFG_ID = DFG_ID
	JOIN	Inventory.FileGroupTypes ON FGT_ID = DFG_FGT_ID
	WHERE	FGT_Name = 'FileStream FileGroup'
	UNION ALL
	-- Unsupported linked servers
	SELECT 
			LNS_MOB_ID
			,LNS_Name
			,'Non-SQL linked servers'
			,'Linked server to ' + LNS_DataSource + ISNULL('(' + PLT_Name + ')','')
	FROM	Inventory.LinkedServers
	JOIN	Inventory.LinkedServerProviders ON LPR_ID = LNS_LPR_ID
	OUTER APPLY (
					SELECT 
							PLT_Name
					FROM	Inventory.MonitoredObjects
					JOIN	Management.PlatformTypes ON PLT_ID = MOB_PLT_ID
					WHERE	LNS_DataSource_MOB_ID = MOB_ID
				)p
	WHERE	NOT EXISTS (SELECT * FROM Inventory.DBMISupportedLinkedServerProviders WHERE LPR_Name = DLP_Name)
	UNION ALL
	--	SQL Alerts
	SELECT 
			ISA_MOB_ID
			,'SQL Server'
			,'Alerts'
			,ISA_Name
	FROM	inventory.InstanceAlerts


	DELETE FROM #DBMILimitingFeatures
	WHERE	NOT EXISTS (SELECT * FROM CapacityPlanningWizard.DatabaseInstanceLimitingFeaturesList WHERE ILF_Name = FeatureName AND ILF_IsEnabled = 1)


	IF OBJECT_ID('tempdb..#DBMILFeature') IS NULL
		CREATE TABLE #DBMILFeature
		(
			CGR_Name				NVARCHAR(255)
			,ServerName				NVARCHAR(255)
			,DatabaseInstanceName	NVARCHAR(255)
			,CanMoveToAzureDBMI		BIT
			,Reason					NVARCHAR(MAX)
			,MOBID					INT
			,CLVID					INT
		)
	TRUNCATE TABLE #DBMILFeature

	;WITH GroupFeat AS 
	(
		SELECT 
				DISTINCT MOBID
				,isnull(stuff((SELECT DISTINCT N', ' + a2.FeatureName 
						FROM #DBMILimitingFeatures a2
					WHERE a1.MOBID = a2.MOBID
					ORDER BY N', ' + a2.FeatureName
					FOR XML PATH(''), TYPE).value('.', 'nvarchar(4000)'),1,2,N''),N'') as FeatureList
		FROM	#DBMILimitingFeatures a1
	)

	INSERT INTO #DBMILFeature
	SELECT 
			CGR_Name
			,s.MOB_Name	AS ServerName
			,i.MOB_Name AS DatabaseInstanceName
			,IIF(g.MOBID IS NULL,1,0) AS CanMoveToAzureDBMI
			,FeatureList AS Reason
			,s.MOB_ID
			,5
	FROM	Consolidation.ParticipatingDatabaseServers
	JOIN	Inventory.MonitoredObjects i ON PDS_Database_MOB_ID = i.MOB_ID
	JOIN	Inventory.MonitoredObjects s ON PDS_Server_MOB_ID = s.MOB_ID
	JOIN	Consolidation.ServerGrouping ON PDS_Server_MOB_ID = SGR_MOB_ID
	JOIN	Consolidation.ConsolidationGroups ON SGR_CGR_ID = CGR_ID
	LEFT JOIN GroupFeat g ON i.MOB_ID = g.MOBID
	WHERE	i.MOB_PLT_ID = 1


	IF @ShowReport = 1
	BEGIN

		SELECT 'Mapping'
		SELECT 
				CGR_Name	AS GroupName
				,MOB_Name	AS ServerName
		FROM	Consolidation.ParticipatingDatabaseServers
		JOIN	Inventory.MonitoredObjects ON MOB_ID = PDS_Database_MOB_ID
		JOIN	Consolidation.ServerGrouping ON PDS_Server_MOB_ID = SGR_MOB_ID
		JOIN	Consolidation.ConsolidationGroups ON SGR_CGR_ID = CGR_ID
		WHERE	MOB_PLT_ID = 1
		

		SELECT 'Server with limiting features list'
		SELECT 
				CGR_Name
				,ServerName
				,DatabaseInstanceName
				,CanMoveToAzureDBMI
				,Reason 
		FROM	#DBMILFeature


		SELECT 'Limitations'
		SELECT 
				CGR_Name
				,s.MOB_Name	AS ServerName
				,i.MOB_Name AS DatabaseInstanceName
				,g.FeatureName
				,g.FDescription
		FROM	Consolidation.ParticipatingDatabaseServers
		JOIN	Inventory.MonitoredObjects i ON PDS_Database_MOB_ID = i.MOB_ID
		JOIN	Inventory.MonitoredObjects s ON PDS_Server_MOB_ID = s.MOB_ID
		JOIN	Consolidation.ServerGrouping ON PDS_Server_MOB_ID = SGR_MOB_ID
		JOIN	Consolidation.ConsolidationGroups ON SGR_CGR_ID = CGR_ID
		JOIN	#DBMILimitingFeatures g ON i.MOB_ID = g.MOBID
		WHERE	i.MOB_PLT_ID = 1
		ORDER BY CGR_Name,DatabaseInstanceName,FeatureName,EntityName

	END
GO
