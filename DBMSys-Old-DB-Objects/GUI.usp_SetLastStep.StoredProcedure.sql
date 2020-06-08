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
/****** Object:  StoredProcedure [GUI].[usp_SetLastStep]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_SetLastStep]
	@UserMail	NVARCHAR(100)
	,@StepID	INT
AS
BEGIN
	DECLARE 
		@UserId		int,
		@Sql		nvarchar(max),
		@AdminDB	nvarchar(128)

	SELECT @AdminDB = dbo.fn_GetQuotedObjectName(CAST(SET_Value AS nvarchar(128)))
	FROM Management.Settings
	WHERE
		Set_Module = 'Management'
		AND SET_Key = 'Cloud Pricing Database Name'

	IF OBJECT_ID('tempdb..#t') IS NOT NULL
		DROP TABLE #t

	CREATE TABLE #t (UserID int)

	IF UPPER(@UserMail) <> 'DTUCALC'
	BEGIN
		SET @Sql = N'
			INSERT INTO #t(UserID)
			SELECT USR_ID FROM '+@AdminDB+'.dbo.Users WHERE USR_Login = '''+@UserMail+''''

		EXEC sp_ExecuteSql @Sql

		SELECT TOP 1 @UserId = UserID FROM #t

		IF @UserId IS NULL
		BEGIN
			RAISERROR('Unknown User Name',16,1)
			RETURN;
		END
	END ELSE
	BEGIN
		SET @UserId = -1
	END

	IF EXISTS (SELECT * FROM GUI.DMOLastStep WHERE USR_ID = @UserId)
	BEGIN
		UPDATE	GUI.DMOLastStep 
		SET		STEP_ID = @StepID
				,STEP_DATE = GETDATE()
		WHERE	USR_ID = @UserId
	END ELSE
	BEGIN
		INSERT INTO GUI.DMOLastStep(USR_ID,STEP_ID,STEP_DATE)
		SELECT @UserId,@StepID,GETDATE()
	END
END
GO
