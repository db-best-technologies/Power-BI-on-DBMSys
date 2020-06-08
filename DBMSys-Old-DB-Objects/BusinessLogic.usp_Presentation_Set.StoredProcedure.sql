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
/****** Object:  StoredProcedure [BusinessLogic].[usp_Presentation_Set]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [BusinessLogic].[usp_Presentation_Set]
	@USR_ID		int,
	@HCH_ID		int,
	@ReportDate	datetime,
	@Rule_List	BusinessLogic.PresentationRules readonly,
	@MOB_List	BusinessLogic.PresentationMOBs readonly
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

	BEGIN TRAN

	IF OBJECT_ID('tempdb..#t') IS NOT NULL
		DROP TABLE #t

	CREATE TABLE #t(PTT_ID int)

	BEGIN TRY
		SET @Sql = N'
			INSERT INTO #t(PTT_ID)
			SELECT P.PTT_ID
			FROM
				BusinessLogic.Presentation AS P
				INNER JOIN BusinessLogic.HealthChecks_Reports AS HR
				ON P.PTT_HRP_ID = HR.HRP_ID
				INNER JOIN '+@AdminDB+'.dbo.Presentation_Engineer AS E
				ON P.PTT_ENG_ID = E.ENG_ID
			WHERE
				HR.HRP_Report_Date = '''+CONVERT(nvarchar(53), @ReportDate, 121)+'''
				AND HR.HRP_HCH_ID = '+CAST(@HCH_ID as nvarchar(15))+'
				AND E.ENG_USR_ID = '+CAST(@USR_ID as nvarchar(15))

		EXEC sp_ExecuteSql @Sql

		SELECT TOP 1 @PTT_ID = PTT_ID FROM #t

		IF @PTT_ID IS NULL
		BEGIN
			DELETE FROM #t

			SET @Sql = N'
				INSERT INTO BusinessLogic.Presentation (PTT_HRP_ID, PTT_ENG_ID)
				SELECT
					R.HRP_ID, E.ENG_ID
				FROM
					BusinessLogic.HealthChecks_Reports AS R,
					'+@AdminDB+'.dbo.Presentation_Engineer AS E
				WHERE
					R.HRP_Report_Date = '''+CONVERT(nvarchar(53), @ReportDate, 121)+'''
					AND R.HRP_HCH_ID = '+CAST(@HCH_ID as nvarchar(15))+'
					AND E.ENG_USR_ID = '+CAST(@USR_ID as nvarchar(15))+'

				INSERT INTO #t(PTT_ID) VALUES (SCOPE_IDENTITY())'

			EXEC sp_ExecuteSql @Sql

			SELECT TOP 1 @PTT_ID = PTT_ID FROM #t
		END

		DELETE FROM BusinessLogic.Presentation_MOBs WHERE PTM_PTT_ID = @PTT_ID
		DELETE FROM BusinessLogic.Presentation_Rules WHERE PTR_PTT_ID = @PTT_ID

		INSERT INTO BusinessLogic.Presentation_MOBs (PTM_PTT_ID, PTM_MOB_ID)
		SELECT @PTT_ID, MOB_ID FROM @MOB_List

		INSERT INTO BusinessLogic.Presentation_Rules (PTR_PTT_ID, PTR_RUL_ID, PTR_Priority)
		SELECT @PTT_ID, R.RUL_ID, R.RUL_Severity
		FROM @Rule_List AS R

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN

		DECLARE
			@Msg	nvarchar(1025)

		SET @Msg = ERROR_MESSAGE()

		RAISERROR(@Msg, 16, 1)
	END CATCH

END
GO
