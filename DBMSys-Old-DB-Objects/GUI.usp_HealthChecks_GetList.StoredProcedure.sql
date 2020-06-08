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
/****** Object:  StoredProcedure [GUI].[usp_HealthChecks_GetList]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_HealthChecks_GetList]
	@Show_Active_Only	bit = 0
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	IF OBJECT_ID('tempdb..#tmp') IS NOT NULL
		DROP TABLE #tmp

	;WITH G AS
	(
		SELECT 
			H.HCY_HCH_ID AS HCH_ID,
			H.HCY_StartDate AS StartDate,
			SUM(H.Lo_Qty) AS Lo_Qty, SUM(H.Med_Qty) AS Med_Qty, SUM(H.Hi_Qty) AS Hi_Qty,
			ROW_NUMBER() OVER (ORDER BY H.HCY_HCH_ID, H.HCY_StartDate) AS Row_Num
		FROM
			BusinessLogic.HealthChecks_History AS H
		GROUP BY
			H.HCY_HCH_ID, H.HCY_StartDate
			
	), Res AS
	(
		SELECT 
			G.HCH_ID, 
			G.StartDate,
			H.HCH_IsActive,
			G.Lo_Qty, G.Med_Qty, G.Hi_Qty,
			ROW_NUMBER() OVER (ORDER BY G.HCH_ID, G.StartDate) AS Row_Num
		FROM 
			G		
			INNER JOIN BusinessLogic.HealthChecks AS H
			ON G.HCH_ID = H.HCH_ID
		WHERE
			@Show_Active_Only = 1 AND H.HCH_IsActive = 1 
			OR @Show_Active_Only = 0			
	)
	SELECT * 
	INTO #tmp 
	FROM Res



	;WITH R AS
	(	
		SELECT
			HC.HCH_ID, HC.HCH_Name, SH.SCH_Name, 
			MAX(VE.History_Date) OVER (PARTITION BY VE.HCH_ID) AS Max_History_Date, 
			VE.History_Date,
			HC.HCH_IsEnabled,
			HC.HCH_IsActive,
			VE.Exec_Percent,
			CASE
				WHEN RD.Lo_Qty_Diff < 0 THEN CAST(RD.Lo_Qty_Diff AS varchar(9))
				WHEN RD.Lo_Qty_Diff > 0 THEN '+'+CAST(RD.Lo_Qty_Diff AS varchar(9))
				WHEN RD.Lo_Qty_Diff = 0 THEN CAST(RD.Lo_Qty_Diff AS varchar(9))
			END AS Lo_Alert_Qty,
			CASE
				WHEN RD.Med_Qty_Diff < 0 THEN CAST(RD.Med_Qty_Diff AS varchar(9))
				WHEN RD.Med_Qty_Diff > 0 THEN '+'+CAST(RD.Med_Qty_Diff AS varchar(9))
				WHEN RD.Med_Qty_Diff = 0 THEN CAST(RD.Med_Qty_Diff AS varchar(9))
			END AS Med_Alert_Qty,
			CASE
				WHEN RD.Hi_Qty_Diff < 0 THEN CAST(RD.Hi_Qty_Diff AS varchar(9))
				WHEN RD.Hi_Qty_Diff > 0 THEN '+'+CAST(RD.Hi_Qty_Diff AS varchar(9))
				WHEN RD.Hi_Qty_Diff = 0 THEN CAST(RD.Hi_Qty_Diff AS varchar(9))
			END AS Hi_Alert_Qty,
			RD.Lo_Total_RuleViolations_Count,
			RD.Med_Total_RuleViolations_Count,
			RD.Hi_Total_RuleViolations_Count,
			(
				SELECT DISTINCT CAST(RC.RLC_CAT_ID AS varchar(2000)) +', ' AS [data()] 
				FROM 
					BusinessLogic.Rules_Categories AS RC
					INNER JOIN BusinessLogic.Rules AS R
					ON RC.RLC_RUL_ID = R.RUL_ID
					INNER JOIN BusinessLogic.Packages_Rules AS PR
					ON PR.PKR_RUL_ID = R.RUL_ID
					INNER JOIN BusinessLogic.HealthCheck_Packages AS HCP
					ON PR.PKR_PKG_ID = HCP.HCP_PKG_ID
				WHERE 
					HCP.HCP_HCH_ID = HC.HCH_ID
				FOR XML PATH('')) AS Cat_List
		FROM
			BusinessLogic.HealthChecks AS HC
			INNER JOIN BusinessLogic.Schedule AS SH
			ON HC.HCH_SCH_ID = SH.SCH_ID
			LEFT JOIN BusinessLogic.VW_HealthChecks_Executions AS VE
			ON VE.HCH_ID = HC.HCH_ID
			LEFT JOIN (
							SELECT
								C.HCH_ID, C.StartDate, 
								C.Lo_Qty AS Lo_Total_RuleViolations_Count, 
								C.Lo_Qty - ISNULL(CL.Lo_Qty, 0) AS Lo_Qty_Diff,
								C.Med_Qty AS Med_Total_RuleViolations_Count, 
								C.Med_Qty - ISNULL(CL.Med_Qty, 0) AS Med_Qty_Diff,
								C.Hi_Qty AS Hi_Total_RuleViolations_Count, 
								C.Hi_Qty - ISNULL(CL.Hi_Qty, 0) AS Hi_Qty_Diff
							FROM
								#tmp AS C
								LEFT JOIN #tmp AS CL
								ON C.HCH_ID = CL.HCH_ID
								AND C.Row_Num = CL.Row_Num + 1
					) AS RD
			ON VE.HCH_ID = RD.HCH_ID
			AND VE.History_Date = RD.StartDate
			AND VE.Exec_Percent = 100.0
		WHERE
			@Show_Active_Only = 1 AND HC.HCH_IsActive = 1 
			OR @Show_Active_Only = 0
	)
	SELECT
		R.HCH_ID, R.HCH_Name, R.SCH_Name, R.History_Date, R.HCH_IsEnabled, 
		CASE 
			WHEN R.Exec_Percent = 100 AND R.Lo_Alert_Qty IS NULL THEN CAST(0 AS varchar(9))
			WHEN R.Exec_Percent <> 100 AND R.Lo_Alert_Qty IS NULL THEN CAST(NULL AS varchar(9))
			WHEN R.Lo_Alert_Qty IS NOT NULL THEN R.Lo_Alert_Qty
		END AS Lo_Alert_Diff, 
		CASE 
			WHEN R.Exec_Percent = 100 AND R.Med_Alert_Qty IS NULL THEN CAST(0 AS varchar(9))
			WHEN R.Exec_Percent <> 100 AND R.Med_Alert_Qty IS NULL THEN CAST(NULL AS varchar(9))
			WHEN R.Med_Alert_Qty IS NOT NULL THEN R.Med_Alert_Qty
		END AS Med_Alert_Diff, 
		CASE 
			WHEN R.Exec_Percent = 100 AND R.Hi_Alert_Qty IS NULL THEN CAST(0 AS varchar(9))
			WHEN R.Exec_Percent <> 100 AND R.Hi_Alert_Qty IS NULL THEN CAST(NULL AS varchar(9))
			WHEN R.Hi_Alert_Qty IS NOT NULL THEN R.Hi_Alert_Qty
		END AS Hi_Alert_Diff,
		ISNULL(R.Lo_Total_RuleViolations_Count, 0) AS Lo_Total_RuleViolations_Count,
		ISNULL(R.Med_Total_RuleViolations_Count, 0) AS Med_Total_RuleViolations_Count,
		ISNULL(R.Hi_Total_RuleViolations_Count, 0) AS Hi_Total_RuleViolations_Count,
		R.Cat_List
	FROM R
	WHERE R.Max_History_Date = History_Date OR R.Max_History_Date IS NULL
END
GO
