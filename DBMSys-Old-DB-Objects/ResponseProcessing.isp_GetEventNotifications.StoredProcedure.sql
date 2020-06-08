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
/****** Object:  StoredProcedure [ResponseProcessing].[isp_GetEventNotifications]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [ResponseProcessing].[isp_GetEventNotifications]
AS
SELECT
		ESP_MOV_ID
		,MOV_Description
		, G.groupName AS GroupName 
		,ESP_IsActive
		,ESP_RSP_ID
		,ESP_EST_ID -- Subscription trigger On Open/ On Close / both/ custom report
		,ESP_IncludeOpenAndShut	
		,ESP_RGT_ID	
		,ESP_RespondOnceForMultipleIdenticalEvents
		,ESP_RerunEveryXSeconds / 60.0 AS [Remind each min]
		,ESP_RerunMaxNumberOfTimes
		,ESP_ProcessingInterval
FROM	EventProcessing.MonitoredEvents
	INNER JOIN	ResponseProcessing.EventSubscriptions	ON MOV_ID = ESP_MOV_ID
	OUTER APPLY (SELECT groupName, Name as atrName
					FROM
					(
						SELECT 					
						Name = t.n.value('@Name', 'varchar(500)')
						,groupName = t.n.value ('@Value', 'varchar(500)')
						FROM ESP_Parameters.nodes('/Parameters/Parameter') as t(n)
					) AS T
					WHERE Name = 'Contact Lists') AS G
	WHERE atrName = 'Contact Lists'
ORDER BY ESP_MOV_ID ASC

	SELECT	 CLS_ID
			,CLS_Name
	FROM ResponseProcessing.ContactLists
	ORDER BY CLS_ID ASC
GO
