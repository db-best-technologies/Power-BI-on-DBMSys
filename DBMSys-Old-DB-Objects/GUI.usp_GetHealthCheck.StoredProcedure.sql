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
/****** Object:  StoredProcedure [GUI].[usp_GetHealthCheck]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_GetHealthCheck]
	@HCH_ID	int
AS
BEGIN
	SELECT HCH_ID, HCH_SCH_ID, HCH_Name, HCH_CreateDate, HCH_IsEnabled, HCH_IsActive
	FROM [BusinessLogic].[HealthChecks]
	WHERE HCH_ID = @HCH_ID

	SELECT HCP_ID, HCP_PKG_ID, HCP_HCH_ID
	FROM [BusinessLogic].[HealthCheck_Packages]
	WHERE HCP_HCH_ID = @HCH_ID

	SELECT HMO_ID, HMO_HCH_ID, HMO_MOB_ID
	FROM [BusinessLogic].[HealthChecks_MonitoredObjects]
	WHERE HMO_HCH_ID = @HCH_ID
END
GO
