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
/****** Object:  StoredProcedure [GUI].[usp_GetDataCollectionHealth]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_GetDataCollectionHealth] 
--DECLARE
	@IntervalHour INT = 1
AS
set nocount on;

DECLARE @Exc TABLE
(
	MOBID		INT
	,MOBNAME	NVARCHAR(255)
	,reason		NVARCHAR(MAX)
)

declare @TRH TABLE 
(
	TRH_MOB_ID		int NOT NULL
	,CNT	INT
	,INDEX IDX_TRH_MOB_ID#TRH_TRS_ID (TRH_MOB_ID)
)
INSERT INTO @TRH
SELECT	
		TRH_MOB_ID
		,COUNT(1)
FROM	Collect.TestRunHistory
WHERE	TRH_TRS_ID = 4 
		AND TRH_InsertDate>=DATEADD(HH,-@IntervalHour, GETUTCDATE())
GROUP BY TRH_MOB_ID


INSERT INTO @Exc
EXEC CapacityPlanningWizard.usp_GetParticipatingAndExcludedServers

;with MOB_VERT as 
(			
	SELECT 
			MOB_ClientID
			,PLC_Name
			,CTR_ID
			,CTR_Name
			,COUNT(DISTINCT MOB_ID) MOB_CNT
			,SUM(IIF(MOBID IS NOT NULL,1,0)) AS DMOAcc
			,SUM(CNTERR) AS CNTERR
	FROM	Inventory.MonitoredObjects
	JOIN	Collect.Collectors ON CTR_ID = MOB_CTR_ID
	JOIN	Management.PlatformTypes ON PLT_ID = MOB_PLT_ID
	JOIN	Management.PlatformCategories on PLC_ID = PLT_PLC_ID
	JOIN	Management.ObjectOperationalStatuses on OOS_ID = MOB_OOS_ID
	LEFT JOIN @Exc ON MOB_ID = MOBID and reason is null
	OUTER APPLY (
					SELECT	TOP 1
							1 AS CNTERR
					FROM	@TRH
					WHERE	TRH_MOB_ID = MOB_ID				
				)err
	where	OOS_IsOperational = 1
	GROUP BY MOB_ClientID,PLC_Name,CTR_ID,CTR_Name

	
) --select * from MOB_VERT

, MOBCNT AS 
(
	SELECT 
			MOB_ClientID
			,CTR_ID
			,CTR_Name
			,[Database Instance]
			,[Operating System Server]

	from	MOB_VERT
	pivot (sum(MOB_CNT) for PLC_NAME IN ([Database Instance],[Operating System Server]))p
	
) 
--select * from MOBCNT

, MOBCNT_DMO AS 
(
	SELECT 
			MOB_ClientID
			,CTR_ID
			,CTR_Name
			,[Database Instance]
			,[Operating System Server]
	from	MOB_VERT
	pivot (sum(DMOAcc) for PLC_NAME IN ([Database Instance],[Operating System Server]))p1
)
--select * from MOBCNT_DMO

,MOBCNT_ERR AS
(
	SELECT 
			MOB_ClientID
			,CTR_ID
			,CTR_Name
			,[Database Instance]
			,[Operating System Server]
	from	MOB_VERT
	pivot (sum(CNTERR) for PLC_NAME IN ([Database Instance],[Operating System Server]))p1
) 
--select * from MOBCNT_ERR

, ALLCNT AS 
(
	SELECT 
			CTR_ID
			,CTR_Name
			,SUM(ISNULL([Database Instance],0)) AS DatabaseInstance
			,SUM(ISNULL([Operating System Server],0)) AS OperatingSystemServer
			,[Database Instance DMO] AS DatabaseInstanceDMO
			,[Operating System Server DMO] AS OperatingSystemServerDMO
			,[Database Instance ERR] AS DatabaseInstanceERR
			,[Operating System Server ERR] AS OperatingSystemServerERR
	FROM	MOBCNT m1
	OUTER APPLY (
					SELECT 
							SUM(ISNULL([Database Instance],0)) AS [Database Instance DMO]
							,SUM(ISNULL([Operating System Server],0)) AS [Operating System Server DMO]
					FROM	MOBCNT_DMO m2
					WHERE	m1.CTR_ID = m2.CTR_ID
				)dmo
	OUTER APPLY (
					SELECT 
							SUM(ISNULL([Database Instance],0)) AS [Database Instance ERR]
							,SUM(ISNULL([Operating System Server],0)) AS [Operating System Server ERR]
					FROM	MOBCNT_ERR m2
					WHERE	m1.CTR_ID = m2.CTR_ID
				)err
	GROUP BY [Database Instance DMO]
			,[Operating System Server DMO]
			,[Database Instance ERR]
			,[Operating System Server ERR]
			,CTR_ID
			,CTR_Name
)

SELECT 
		*
FROM	ALLCNT
--JOIN	TRH ON TRH_CTR_ID = CTR_ID
CROSS APPLY (	
				SELECT 
						TOP 1 
						TRH_InsertDate	AS ImportedTo
						,TRH_EndDate	AS CollectTo
				FROM	Collect.TestRunHistory 
				WHERE	CTR_ID = TRH_CTR_ID 
				ORDER BY TRH_ID DESC
			)trhma
CROSS APPLY (
				SELECT 
						TOP 1 
						TRH_EndDate AS CollectFrom
				FROM	Collect.TestRunHistory 
				WHERE	CTR_ID = TRH_CTR_ID 
				ORDER BY TRH_ID
			)trhmi
ORDER BY 1
GO
