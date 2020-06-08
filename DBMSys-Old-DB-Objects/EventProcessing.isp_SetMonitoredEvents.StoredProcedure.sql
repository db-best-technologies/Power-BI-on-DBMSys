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
/****** Object:  StoredProcedure [EventProcessing].[isp_SetMonitoredEvents]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [EventProcessing].[isp_SetMonitoredEvents]
--DECLARE 
	@TT EventProcessing.TT_MonitoredEvents READONLY

AS

;WITH ExcludeInclude AS 
(
	SELECT 
			TT_MOV_ID
			,r.value('@EIE_IsInclude[1]','BIT') AS IsInclude
			,r.value('@MOB_ID','INT') AS MOBID
			,r.value('@EIE_InstanceName','NVARCHAR(255)') AS InstanceName
			,r.value('@EIE_UseLikeForInstanceName','BIT') AS UseLikeForInstanceName
			,r.value('@EIE_ValidForMinutes','int') AS ValidForMinutes

	FROM	@TT
	CROSS APPLY TT_IncludeExclude.nodes('/rows/row') as t(r)
)
, TargetTable AS 
(
	SELECT 
			*
	FROM	EventProcessing.EventIncludeExclude
	WHERE	EXISTS (SELECT * FROM ExcludeInclude WHERE EIE_MOV_ID = TT_MOV_ID)
)

MERGE	TargetTable d
USING	ExcludeInclude s ON EIE_MOV_ID = TT_MOV_ID AND EIE_MOB_ID = MOBID AND EIE_InstanceName = InstanceName
WHEN MATCHED THEN UPDATE SET
		EIE_UseLikeForInstanceName	= UseLikeForInstanceName
		,EIE_InsertDate				= GETUTCDATE()
		,EIE_ValidForMinutes		= ValidForMinutes


WHEN NOT MATCHED THEN INSERT(EIE_MOV_ID,EIE_IsInclude,EIE_MOB_ID,EIE_InstanceName,EIE_UseLikeForInstanceName,EIE_InsertDate,EIE_ValidForMinutes)
VALUES(TT_MOV_ID,IsInclude,MOBID,InstanceName,UseLikeForInstanceName,GETUTCDATE(),ValidForMinutes)

WHEN NOT MATCHED BY SOURCE THEN
	DELETE;

UPDATE	EventProcessing.MonitoredEvents
SET
		 MOV_MEG_ID		= TT_MEG_ID		
		,MOV_IsActive	= TT_MOV_IsActive
		,MOV_Weekdays	= TT_MOV_Weekdays
		,MOV_FromHour	= TT_MOV_FromHour
		,MOV_ToHour		= TT_MOV_ToHour	
		,MOV_ESV_ID		= TT_ESV_ID		
		,MOV_THL_ID		= TT_THL_ID		
FROM	@TT
WHERE	TT_MOV_ID = MOV_ID
GO
