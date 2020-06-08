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
/****** Object:  StoredProcedure [EventProcessing].[isp_GetMonitoredEvents]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [EventProcessing].[isp_GetMonitoredEvents]
AS
	SELECT 
			MOV_ID
			,MOV_Description
			,MEG_ID
			,MEG_Description
			,MEG_IsActive
			,MOV_IsActive
			,MOV_Weekdays
			,MOV_FromHour
			,MOV_ToHour
			,ESV_ID
			,ESV_Name
			,THL_ID
			,THL_Color
			,ESV_EmailImportance 
			,CAST((
				SELECT 
						EIE_IsInclude
						,MOB_ID
						,MOB_Name
						,EIE_InstanceName
						,EIE_UseLikeForInstanceName
						,EIE_ValidForMinutes
				FROM	EventProcessing.EventIncludeExclude
				JOIN	Inventory.MonitoredObjects on EIE_MOB_ID = MOB_ID
				WHERE	MOV_ID = EIE_MOV_ID
				for xml RAW , ROOT ('rows')
				) AS XML) AS IncludeExclude
	FROM	EventProcessing.MonitoredEvents
	LEFT JOIN	EventProcessing.MonitoredEventGroups ON MOV_MEG_ID = MEG_ID
	LEFT JOIN	EventProcessing.MonitoredEvents_Categories ON MOV_ID = MCT_MOV_ID
	LEFT JOIN	BusinessLogic.Categories ON MCT_CAT_ID = CAT_ID
	LEFT JOIN	BusinessLogic.ThresholdLevels ON MOV_THL_ID = THL_ID
	LEFT JOIN	EventProcessing.EventSeverities ON MOV_ESV_ID = ESV_ID
	WHERE	EXISTS (SELECT * FROM Management.OperationConfigurations WHERE MOV_OCF_BinConcat & OCF_ID > 0)
	ORDER BY MOV_Description
GO
