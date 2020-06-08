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
/****** Object:  StoredProcedure [GUI].[usp_GetMaintenanceWindows]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_GetMaintenanceWindows]
		@MWG_ID INT = NULL
as
SELECT	DISTINCT
		MWG_ID
		,MOB_ID
		,CONVERT(NVARCHAR(33),MWG_StartTime,126) as MWG_StartTime
		,CONVERT(NVARCHAR(33),MWG_EndTime,126) as MWG_EndTime
		,MWG_Description
FROM	Operational.MaintenanceWindowGroups
JOIN	Operational.MaintenanceWindows on MWG_ID = MTW_MWG_ID
JOIN	Inventory.MonitoredObjects on MTW_MOB_ID = MOB_ID
WHERE	ISNULL(@MWG_ID,MWG_ID) = MWG_ID
		and MTW_IsDeleted = 0
GO
