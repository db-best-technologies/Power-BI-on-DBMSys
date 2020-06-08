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
/****** Object:  StoredProcedure [GUI].[usp_GetLastStep]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_GetLastStep]
	@UserMail	NVARCHAR(100) = null
AS
BEGIN
	DECLARE 
		@UserId INT = 0,
		@Sql		nvarchar(max),
		@AdminDB	nvarchar(128)

	SELECT @AdminDB = dbo.fn_GetQuotedObjectName(CAST(SET_Value AS nvarchar(128)))
	FROM Management.Settings
	WHERE
		Set_Module = 'Management'
		AND SET_Key = 'Cloud Pricing Database Name'		

	IF UPPER(isnull(@UserMail,'')) = 'DTUCALC'
		SET @UserId = -1

	--select @UserId
	IF	@UserId <> -1
	BEGIN
		SET @Sql = N'
			SELECT TOP 1 
				STEP_ID, 
				DATEDIFF(mi,STEP_DATE,GETDATE()) AS DIFF,
				u.USR_Login, 
				u.USR_Name, 
				u.USR_ID 
			FROM 
				GUI.DMOLastStep AS s 
				INNER JOIN '+@AdminDB+'.dbo.Users u 
				on s.USR_ID = u.USR_ID 
			ORDER BY 
				STEP_DATE DESC--WHERE USR_ID = @UserId'

		EXEC sp_ExecuteSql @Sql
	END
	ELSe
		SELECT STEP_ID,/*DATEDIFF(mi,STEP_DATE,GETDATE())*/STEP_DATE AS DIFF,@UserMail as USR_Login, '' as USR_Name ,@UserId as USR_ID FROM GUI.DMOLastStep WHERE USR_ID = -1
END
GO
