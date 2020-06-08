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
/****** Object:  StoredProcedure [BusinessLogic].[usp_RuleList_Get]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [BusinessLogic].[usp_RuleList_Get]
	@HCH_ID		int,
	@ReportDate	datetime
AS
BEGIN
	SELECT
		R.RUL_ID, R.RUL_Weight, R.RUL_Name, C.CAT_Name, COUNT(*) AS RuleViolations_Qty
	FROM
		BusinessLogic.Categories AS C
		INNER JOIN BusinessLogic.Rules_Categories AS RC
		ON C.CAT_ID = RC.RLC_CAT_ID
		INNER JOIN BusinessLogic.Rules AS R
		ON RC.RLC_RUL_ID = R.RUL_ID
		INNER JOIN BusinessLogic.PackageRunRules AS PR
		ON PR.PRR_RUL_ID = R.RUL_ID
		INNER JOIN BusinessLogic.RuleViolations AS RW
		ON RW.RLV_PRR_ID = PR.PRR_ID
		INNER JOIN BusinessLogic.PackageRuns AS P
		ON P.PKN_ID = PR.PRR_PKN_ID
		INNER JOIN BusinessLogic.HealthChecks_History AS RH
		ON RH.HCY_PKN_ID = P.PKN_ID
	WHERE
		RH.HCY_HCH_ID = @HCH_ID
		AND RH.HCY_StartDate = @ReportDate
		AND RW.RLV_MOB_ID IS NOT NULL
	GROUP BY
		R.RUL_ID, R.RUL_Weight, R.RUL_Name, C.CAT_Name
END
GO
