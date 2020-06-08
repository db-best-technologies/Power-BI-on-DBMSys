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
/****** Object:  View [BusinessLogic].[VW_HealthChecks_Executions]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [BusinessLogic].[VW_HealthChecks_Executions]
AS
	SELECT
		HC.HCH_ID, 
		HS.HCY_StartDate AS History_Date,
		HC.HCH_SCH_ID,
		SUM(HS.RuleViolations_Qty) AS RuleViolations_Qty,
		SUM(PR.PKN_TotalRulesQty) AS Total_Qty, 
		SUM(HS.Runned_Qty) AS Runned_Qty, 
		SUM(HS.Lo_Qty) AS Lo_Qty,
		SUM(HS.Med_Qty) AS Med_Qty,
		SUM(HS.Hi_Qty) AS Hi_Qty,
		CAST(SUM(HS.Runned_Qty) AS numeric(9,2))/CAST(SUM(PR.PKN_TotalRulesQty) AS numeric(9,2))*100 AS Exec_Percent
	FROM
		-- HealthChecks link with PackageRuns
		BusinessLogic.HealthChecks AS HC
		INNER JOIN BusinessLogic.HealthChecks_History AS HS
		ON HC.HCH_ID = HS.HCY_HCH_ID
		INNER JOIN BusinessLogic.PackageRuns AS PR
		ON PR.PKN_ID = HS.HCY_PKN_ID
	GROUP BY
		HC.HCH_ID, HS.HCY_StartDate, HC.HCH_SCH_ID
GO
