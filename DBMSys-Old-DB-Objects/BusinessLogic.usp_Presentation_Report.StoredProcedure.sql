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
/****** Object:  StoredProcedure [BusinessLogic].[usp_Presentation_Report]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [BusinessLogic].[usp_Presentation_Report]
	@USR_ID		int,
	@HCH_ID		int,
	@ReportDate	datetime
AS
BEGIN
	DECLARE
		@Sql		nvarchar(max),
		@AdminDB	nvarchar(128)

	SELECT @AdminDB = dbo.fn_GetQuotedObjectName(CAST(SET_Value AS nvarchar(128)))
	FROM Management.Settings
	WHERE
		Set_Module = 'Management'
		AND SET_Key = 'Cloud Pricing Database Name'

	SET @Sql = N'
		WITH R AS
		(
			SELECT
				R.RUL_Name AS Issue,  
				CAST(
						(
							SELECT CAT_Name + '', '' AS [data()]
							FROM 
								BusinessLogic.Rules_Categories AS RC
								INNER JOIN BusinessLogic.Categories AS C
								ON RC.RLC_CAT_ID = C.CAT_ID
							WHERE
								R.RUL_ID = RC.RLC_RUL_ID
							FOR XML PATH('''')
						) AS nvarchar(1024)) AS Category,
				NULL AS SubCategory,
				NULL AS Risk,
				MOB.MOB_Name AS [Server],
				NULL AS [Database],
				NULL AS [Object],
				NULL AS [Owner],
				NULL AS [Phase],
				''Active'' AS [Status],
				NULL AS [Status Date]
			FROM
				BusinessLogic.Presentation AS P
				INNER JOIN BusinessLogic.HealthChecks_Reports AS HR
				ON P.PTT_HRP_ID = HR.HRP_ID
				INNER JOIN '+@AdminDB+'.dbo.Presentation_Engineer AS E
				ON P.PTT_ENG_ID = E.ENG_ID
				INNER JOIN BusinessLogic.Presentation_MOBs AS PM
				ON PM.PTM_PTT_ID = P.PTT_ID
				INNER JOIN BusinessLogic.Presentation_Rules AS PR
				ON PR.PTR_PTT_ID = P.PTT_ID
				INNER JOIN Inventory.MonitoredObjects AS MOB
				ON PM.PTM_MOB_ID = MOB.MOB_ID
				INNER JOIN BusinessLogic.Rules AS R
				ON PR.PTR_RUL_ID = R.RUL_ID
				INNER JOIN BusinessLogic.HealthChecks_History AS HY
				ON HR.HRP_HCH_ID = HY.HCY_HCH_ID
				AND HR.HRP_Report_Date = HY.HCY_StartDate
				INNER JOIN BusinessLogic.PackageRuns AS PRS
				ON HY.HCY_PKN_ID = PRS.PKN_ID
				INNER JOIN BusinessLogic.PackageRunRules AS PRR
				ON PRR.PRR_PKN_ID = PRS.PKN_ID
				AND PRR.PRR_RUL_ID = R.RUL_ID
				INNER JOIN BusinessLogic.RuleViolations AS RV
				ON RV.RLV_PRR_ID = PRR.PRR_ID
				AND RV.RLV_MOB_ID = PM.PTM_MOB_ID
				--INNER JOIN BusinessLogic.Packages_Rules AS PAR
				--ON PAR.PKR_RUL_ID = R.RUL_ID
			WHERE
				HR.HRP_Report_Date = '''+CONVERT(nvarchar(53), @ReportDate, 121)+'''
				AND HR.HRP_HCH_ID = '+CAST(@HCH_ID as nvarchar(15))+'
				AND E.ENG_USR_ID = '+CAST(@USR_ID as nvarchar(15))+'
			--	AND PAR.PKR_IsPresented = 1
		)
		SELECT DISTINCT
			Issue, SUBSTRING(Category, 1, LEN(Category) -1) AS Category,
			SubCategory, Risk, [Server], [Database], [Object], [Owner], [Phase], [Status], [Status Date]
		FROM R'
	
	EXEC sp_Executesql @Sql
END
GO
