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
/****** Object:  StoredProcedure [GUI].[usp_HealthCheck_Enable]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_HealthCheck_Enable]
	@HCH_ID		int,
	@Is_Enabled	bit output
AS
BEGIN
	UPDATE BusinessLogic.HealthChecks
	SET HCH_IsEnabled = CASE WHEN HCH_IsEnabled = 1 THEN 0 ELSE 1 END
	WHERE HCH_ID = @HCH_ID

	SELECT @Is_Enabled = HCH_IsEnabled
	FROM BusinessLogic.HealthChecks
	WHERE HCH_ID = @HCH_ID
END
GO
