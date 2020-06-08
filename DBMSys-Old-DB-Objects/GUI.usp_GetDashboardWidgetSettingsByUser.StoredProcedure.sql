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
/****** Object:  StoredProcedure [GUI].[usp_GetDashboardWidgetSettingsByUser]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_GetDashboardWidgetSettingsByUser]
--DECLARE
		@USR_ID		INT
		,@DUS_ID	INT = NULL
AS
select 
		DUS_ID
		,DUS_Name
		,DUS_DWT_ID
		,DUS_CSY_ID
		,DUS_CounteID
		,DUS_IntervalTime
		,DUS_IntervalPeriod
		,DUS_DWP_ID
		,DUS_DCT_ID
		,DUS_ThresholdType	
		,DUS_ThresholdPerc	
		,DUS_NegativeType	
		,DUS_NegativeValue	
		,DUS_NeutralType	
		,DUS_NeutralValue	
		,DUS_PositiveType	
		,DUS_PositiveValue	
		,DUS_DCC_ID
		,DUS_OrderId
		,DUS_Width
		,DUS_Height
from	GUI.DashboardWidgetsUserSettings
WHERE	DUS_USR_ID = @USR_ID
		AND ISNULL(@DUS_ID,DUS_ID) = DUS_ID

SELECT 
		DUS_ID
		,DWH_MOB_ID
		,DWH_CIN_ID
FROM	GUI.DashboardWidgetsUserSettings
JOIN	GUI.DashboradWidgetHostsInstances on DUS_ID = DWH_DUS_ID
WHERE	DUS_USR_ID = @USR_ID
		AND ISNULL(@DUS_ID,DUS_ID) = DUS_ID
GO
