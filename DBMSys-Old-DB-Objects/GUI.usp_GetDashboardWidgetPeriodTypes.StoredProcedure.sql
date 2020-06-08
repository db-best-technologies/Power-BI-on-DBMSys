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
/****** Object:  StoredProcedure [GUI].[usp_GetDashboardWidgetPeriodTypes]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_GetDashboardWidgetPeriodTypes]
	--DECLARE
		@DWT_ID INT = 4
AS
IF @DWT_ID IS NULL
	SELECT 
			DWP_ID
			,DWP_Name
			,DWP_IntervalTime
			,DWP_IntervalType
			,DWI_ID
			,DWI_IntervalTime
			,DWI_IntervalType
	FROM	gui.DashboardWidgetPeriodTypes
	JOIN	GUI.DashboardWidgetPeriodTypeIntervals ON DWP_ID = DWI_DWP_ID
	UNION ALL
	SELECT 
		DWP_ID
		,DWP_Name
		,NULL AS DWP_IntervalTime
		,NULL AS DWP_IntervalType
		,DWI_ID
		,DWI_IntervalTime
		,DWI_IntervalType
	FROM	GUI.DashboardWidgetPeriodTypes
	cross apply 
			(
					select 
							MIN(DWI_ID) AS DWI_ID 
							,DWI_IntervalTime
							,DWI_IntervalType 
					FROM	GUI.DashboardWidgetPeriodTypeIntervals where DWI_DWP_ID in (2,3,4,5,6,7)
					GROUP BY DWI_IntervalTime
							,DWI_IntervalType 
						
			)p
	WHERE	DWP_IntervalTime = 0
ELSE
	IF EXISTS (SELECT * FROM GUI.DashboardWidgetType WHERE DWT_ID = @DWT_ID AND DWT_IsOnlyLast = 0)
		SELECT 
				DWP_ID
				,DWP_Name
				,DWP_IntervalTime
				,DWP_IntervalType
				,DWI_ID
				,DWI_IntervalTime
				,DWI_IntervalType
		FROM	GUI.DashboardWidgetPeriodTypes
		JOIN	GUI.DashboardWidgetPeriodTypeIntervals ON DWP_ID = DWI_DWP_ID
		WHERE	DWP_IntervalTime > 0
	ELSE
		SELECT 
			DWP_ID
			,DWP_Name
			,NULL AS DWP_IntervalTime
			,NULL AS DWP_IntervalType
			,/*NULL AS*/ DWI_ID
			,/*NULL AS*/ DWI_IntervalTime
			,/*NULL AS*/ DWI_IntervalType
	FROM	GUI.DashboardWidgetPeriodTypes
	cross apply 
			(
					select 
							MIN(DWI_ID) AS DWI_ID 
							,DWI_IntervalTime
							,DWI_IntervalType 
					FROM	GUI.DashboardWidgetPeriodTypeIntervals where DWI_DWP_ID in (2,3,4,5,6,7)
					GROUP BY DWI_IntervalTime
							,DWI_IntervalType 
						
			)p
	WHERE	DWP_IntervalTime = 0
GO
