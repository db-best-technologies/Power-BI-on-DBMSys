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
/****** Object:  StoredProcedure [GUI].[usp_GetDashboardWidgetInstanceTree]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_GetDashboardWidgetInstanceTree]
--DECLARE
	@SystemID	INT = NULL
	,@CounterID	INT = NULL
AS

;WITH comb as 
(
	SELECT 
			DISTINCT 
			CCB_MOB_ID
			,NULL AS CCB_CounterID
			,NULL AS CCB_CSY_ID
			,CCB_CIN_ID
	FROM	PerformanceData.CounterCombinations
	WHERE	@SystemID IS NULL
			AND @CounterID IS NULL
	UNION ALL
	SELECT 
			DISTINCT 
			CCB_MOB_ID
			,CCB_CounterID
			,CCB_CSY_ID
			,CCB_CIN_ID
	FROM	PerformanceData.CounterCombinations
	WHERE	@SystemID IS NOT NULL
			AND @CounterID IS NOT NULL
			AND @SystemID = CCB_CSY_ID
			AND @CounterID = CCB_CounterID

)
	select	distinct 
			SYS_ID
			,SYS_Name
			,MOB_ID
			,MOB_Name
			,CIN_ID
			,CIN_Name
			,SHS_ShortName AS SystemHost_ShortName
			,PLT_ID AS SystemHostType_Id
			,PLT_NAME AS SystemHostType_Name
			,MOB_OOS_ID
	from	Inventory.MonitoredObjects
	JOIN	Management.ObjectOperationalStatuses on MOB_OOS_ID = OOS_ID
	JOIN	Inventory.SystemHosts on MOB_ID = SHS_MOB_ID
	JOIN	Inventory.Systems on SYS_ID = SHS_SYS_ID
	JOIN	Management.PlatformTypes on MOB_PLT_ID = PLT_ID
	JOIN	comb on MOB_ID = CCB_MOB_ID AND (CCB_CounterID = @CounterID AND CCB_CSY_ID = @SystemID OR @CounterID IS NULL AND @SystemID IS NULL)
	LEFT JOIN	PerformanceData.CounterInstances on CCB_CIN_ID = CIN_ID and @CounterID IS NOT NULL AND @SystemID IS NOT NULL
	WHERE	OOS_IsOperational = 1
	ORDER BY SYS_Name,MOB_Name,CIN_Name
GO
