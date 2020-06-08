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
/****** Object:  View [BusinessLogic].[VW_Enabled_HealthCheck_Cron_Table]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [BusinessLogic].[VW_Enabled_HealthCheck_Cron_Table]
AS
	SELECT
		CT.*
	FROM
		BusinessLogic.HealthChecks AS HC
		INNER JOIN BusinessLogic.HealthCheck_Cron_Table AS CT
		ON HC.HCH_ID = CT.HCT_HCH_ID
	WHERE
		HC.HCH_IsEnabled = 1
GO
