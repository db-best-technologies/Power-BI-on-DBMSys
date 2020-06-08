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
/****** Object:  StoredProcedure [BusinessLogic].[usp_PresentationMOBs_Get]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [BusinessLogic].[usp_PresentationMOBs_Get]
	@USR_ID		int,
	@HCH_ID		int,
	@ReportDate	datetime
AS
BEGIN
	DECLARE
		@PTT_ID		int,
		@Sql		nvarchar(max),
		@AdminDB	nvarchar(128)

	SELECT @AdminDB = dbo.fn_GetQuotedObjectName(CAST(SET_Value AS nvarchar(128)))
	FROM Management.Settings
	WHERE
		Set_Module = 'Management'
		AND SET_Key = 'Cloud Pricing Database Name'	

	SET @Sql = N'
		SELECT
			PM.PTM_MOB_ID
		FROM
			BusinessLogic.Presentation AS P
			INNER JOIN BusinessLogic.HealthChecks_Reports AS HR
			ON P.PTT_HRP_ID = HR.HRP_ID
			INNER JOIN '+@AdminDB+'.dbo.Presentation_Engineer AS E
			ON P.PTT_ENG_ID = E.ENG_ID
			INNER JOIN BusinessLogic.Presentation_MOBs AS PM
			ON PM.PTM_PTT_ID = P.PTT_ID
		WHERE
			HR.HRP_Report_Date = '''+CONVERT(nvarchar(53), @ReportDate, 121)+'''
			AND HR.HRP_HCH_ID = '+CAST(@HCH_ID as nvarchar(15))+'
			AND E.ENG_USR_ID = '+CAST(@USR_ID as nvarchar(15))

	EXEC sp_ExecuteSql @Sql
END
GO
