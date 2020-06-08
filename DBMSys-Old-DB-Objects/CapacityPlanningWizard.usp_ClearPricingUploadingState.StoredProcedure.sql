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
/****** Object:  StoredProcedure [CapacityPlanningWizard].[usp_ClearPricingUploadingState]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [CapacityPlanningWizard].[usp_ClearPricingUploadingState]
	@Timeout	int = 15
AS
BEGIN
	-- Clear the old sessions by timeout
	UPDATE CapacityPlanningWizard.CloudPricingUploadingState
	SET CPS_State = 1 -- Error
	WHERE 
		CPS_State = 0
		AND DATEDIFF(mi, CPS_LaunchDate, sysdatetime()) > @Timeout -- 15 minutes = timeout
END
GO
