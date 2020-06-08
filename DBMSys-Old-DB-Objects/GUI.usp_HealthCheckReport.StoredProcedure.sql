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
/****** Object:  StoredProcedure [GUI].[usp_HealthCheckReport]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_HealthCheckReport]
--DECLARE 
		@HCH_ID	INT										--= 4
		,@SD	DATETIME								--= '2016-11-02 03:34:53.527'
		,@MOB_ID_List Inventory.SystemHosts_List	 	readonly
		,@RUL_MOB_List BusinessLogic.TT_MOB_RUL		 	readonly
		,@HCH_Name NVARCHAR(255) output
		,@HCH_Date DATETIME2(7) output
	
AS
BEGIN
	IF OBJECT_ID('tempdb..#Viol') IS NOT NULL
		DROP TABLE #Viol

	SELECT 
			@HCH_Name = HCH_Name
			,@HCH_Date = @SD--HCH_CreateDate
	FROM	BusinessLogic.HealthChecks
	WHERE	HCH_ID = @HCH_ID

	declare 
			@MOB_ID_ARR Inventory.SystemHosts_List
		

	if exists (select * from @MOB_ID_List)
		insert into @MOB_ID_ARR(SHS_MOB_ID)
		select SHS_MOB_ID from @MOB_ID_List
	else
		insert into @MOB_ID_ARR(SHS_MOB_ID)
		select MOB_ID from Inventory.MonitoredObjects

	declare @flt bit = 0
	if exists (select * from @RUL_MOB_List)
		set @flt = 1

	;WITH PckgRunRules AS 
	(
		SELECT 
				PRR_ID
				,PRR_RUL_ID
		FROM	BusinessLogic.PackageRunRules
		JOIN	BusinessLogic.HealthChecks_History on PRR_PKN_ID = HCY_PKN_ID
		WHERE	HCY_StartDate = @SD AND HCY_HCH_ID = @HCH_ID
	)
	SELECT 
		RLV_MOB_ID
		,PRR_RUL_ID
		,count(*) as cnt
	INTO #Viol
	FROM	
		businesslogic.RuleViolations
		JOIN	PckgRunRules on RLV_PRR_ID = PRR_ID
		left JOIN	@RUL_MOB_List on (RLV_MOB_ID = TT_MOB_ID and PRR_RUL_ID = TT_RUL_ID ) OR @flt = 0
	WHERE	
		(TT_MOB_ID is not null and TT_RUL_ID is not null and @flt = 1) or @flt = 0
	GROUP BY 
		PRR_RUL_ID
		,RLV_MOB_ID

	SELECT 
		SYS_ID
		,SYS_Name
		,MOB_ID
		,MOB_Name
		,CASE WHEN PLT_ID = 2 THEN CASE WHEN EDT_NAME like '%Server%' THEN 'Server' WHEN EDT_NAME NOT LIKE '%Server%' THEN 'Workstation' else 'Unknown' END ELSE 'Database'/*PLT_Name*/ END  as Device_Type
		,CAT_ID
		,CAT_Name
		,RUL_ID
		,RUL_Name
		,RUL_RecommendedFix as RECOMENDATION
		,cnt
		,RUL_Weight
		--	,*
	FROM	
		#Viol
		join	Inventory.MonitoredObjects on RLV_MOB_ID = MOB_ID
		join	Inventory.SystemHosts s on MOB_ID = s.SHS_MOB_ID
		join	Inventory.Systems on SHS_SYS_ID = SYS_ID
		join	BusinessLogic.Rules on PRR_RUL_ID = RUL_ID
		join	BusinessLogic.Rules_Categories on RUL_ID = RLC_RUL_ID
		join	BusinessLogic.Categories on RLC_CAT_ID = CAT_ID
		join	Management.PlatformTypes on MOB_PLT_ID = PLT_ID
		left join Inventory.Editions on MOB_Engine_EDT_ID = EDT_ID
		join	@MOB_ID_ARR a on MOB_ID = a.SHS_MOB_ID
	UNION ALL
	SELECT
		-1 AS Sys_ID,
		'Environment' AS SYS_Name,
		-1 AS MOB_ID,
		'Environment' AS MOB_Name,
		'Environment' AS Device_Type,
		-1 AS CAT_ID,
		'Environment' AS CAT_Name,
		V.PRR_RUL_ID AS RUL_ID,
		R.RUL_Name,
		cast('' as NVARCHAR(255)) as RECOMENDATION,
		V.cnt,
		R.RUL_Weight
	FROM
		#Viol AS V
		INNER JOIN BusinessLogic.Rules AS R
		ON V.PRR_RUL_ID = R.RUL_ID
	WHERE
		V.RLV_MOB_ID IS NULL
	UNION ALL
	SELECT 
		-2 AS SYS_ID,
		'Decomissioned' AS SYS_Name
		,MOB_ID
		,MOB_Name
		,CASE WHEN PLT_ID = 2 THEN CASE WHEN EDT_NAME like '%Server%' THEN 'Server' WHEN EDT_NAME NOT LIKE '%Server%' THEN 'Workstation' else 'Unknown' END ELSE 'Database'/*PLT_Name*/ END  as Device_Type
		,CAT_ID
		,CAT_Name
		,RUL_ID
		,RUL_Name
		,RUL_RecommendedFix as RECOMENDATION
		,cnt
		,RUL_Weight
		--	,*
	FROM	
		#Viol
		join	Inventory.MonitoredObjects on RLV_MOB_ID = MOB_ID
		left join	Inventory.SystemHosts s on MOB_ID = s.SHS_MOB_ID
		left join	Inventory.Systems on SHS_SYS_ID = SYS_ID
		join	BusinessLogic.Rules on PRR_RUL_ID = RUL_ID
		join	BusinessLogic.Rules_Categories on RUL_ID = RLC_RUL_ID
		join	BusinessLogic.Categories on RLC_CAT_ID = CAT_ID
		join	Management.PlatformTypes on MOB_PLT_ID = PLT_ID
		left join Inventory.Editions on MOB_Engine_EDT_ID = EDT_ID
		join	@MOB_ID_ARR a on MOB_ID = a.SHS_MOB_ID
	WHERE
		SYS_ID IS NULL

END
GO
