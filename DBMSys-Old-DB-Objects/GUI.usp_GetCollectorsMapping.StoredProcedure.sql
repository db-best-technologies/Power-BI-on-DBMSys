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
/****** Object:  StoredProcedure [GUI].[usp_GetCollectorsMapping]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_GetCollectorsMapping]
--DECLARE	
		@CTR_ID	INT = NULL
AS
SELECT
		CTR_ID
		,CTR_Name
		,SYS_ID
		,SYS_Name
		,MOB_ID
		,MOB_Name
		,PLT_ID
		,PLT_Name
FROM	Inventory.MonitoredObjects
LEFT JOIN	Collect.Collectors ON MOB_CTR_ID = CTR_ID
JOIN	Inventory.SystemHosts ON MOB_ID = SHS_MOB_ID
JOIN	Inventory.Systems ON SHS_SYS_ID = SYS_ID
JOIN	Management.PlatformTypes ON PLT_ID = MOB_PLT_ID
JOIN	Management.ObjectOperationalStatuses ON OOS_ID = MOB_OOS_ID
WHERE	(MOB_CTR_ID = @CTR_ID AND CTR_ID IS NOT NULL OR @CTR_ID IS NULL)
		AND OOS_IsOperational = 1
ORDER BY CTR_NAME,MOB_Name
GO
