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
/****** Object:  StoredProcedure [GUI].[HealthCheck_Activate]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[HealthCheck_Activate]
	@HCH_ID		int,
	@Is_Active	bit output
AS
BEGIN
	-- Check status
	IF EXISTS (SELECT 1 FROM BusinessLogic.HealthChecks WHERE HCH_IsEnabled = 0 AND HCH_ID = @HCH_ID)
	BEGIN
		UPDATE BusinessLogic.HealthChecks
		SET 
			HCH_Name = CASE WHEN HCH_IsActive = 1 THEN HCH_Name+'_Deleted_On_'+CONVERT(nvarchar(63), getdate(), 126) ELSE HCH_Name END,
			HCH_IsActive = CASE WHEN HCH_IsActive = 0 THEN 1 ELSE 0 END
		WHERE HCH_ID = @HCH_ID

		SELECT @Is_Active = HCH_IsActive
		FROM BusinessLogic.HealthChecks
		WHERE HCH_ID = @HCH_ID

	END ELSE BEGIN
		RAISERROR('Can not inactivate enabled healthcheck', 16, 1)
	END
END
GO
