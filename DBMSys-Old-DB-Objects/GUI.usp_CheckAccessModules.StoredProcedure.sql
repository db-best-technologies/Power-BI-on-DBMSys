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
/****** Object:  StoredProcedure [GUI].[usp_CheckAccessModules]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_CheckAccessModules]
--DECLARE 
		@MOD_ID		INT = 1
		,@IsAccess	BIT OUTPUT
		,@Reason	NVARCHAR(20) OUTPUT
		,@DSUGUID	UNIQUEIDENTIFIER 
AS
SET @IsAccess = 0

DECLARE 
		
		@Sql		nvarchar(max),
		@AdminDB	nvarchar(128)

	SELECT @AdminDB = dbo.fn_GetQuotedObjectName(CAST(SET_Value AS nvarchar(128)))
	FROM Management.Settings
	WHERE
		Set_Module = 'Management'
		AND SET_Key = 'Cloud Pricing Database Name'		
	
	set @Reason = ''

	IF OBJECT_ID('tempdb..#IsFullDMO') IS NOT NULL
		DROP TABLE #IsFullDMO

	CREATE TABLE #IsFullDMO
	(
		DMOName Nvarchar(255)
	)

	SET @Sql = 'SELECT 
						DMO_Name
				FROM	' + @AdminDB + '.dbo.DBMSysUnits 
				LEFT JOIN	' + @AdminDB + '.dbo.DMOTypes ON DSU_DMO_ID = DMO_ID
				WHERE	DSU_GUID = ''' + CAST(@DSUGUID AS NVARCHAR(50))  + ''''

	INSERT INTO #IsFullDMO(DMOName)
	EXEC (@Sql)

	IF NOT EXISTS (SELECT * FROM #IsFullDMO WHERE DMOName = 'Full DMO') AND @MOD_ID = 4
	BEGIN
		SET @Reason = 'NotFullDMO'
		SET @IsAccess = 0
	END
	ELSE
	SELECT 
			@IsAccess = 1
	FROM	Management.Modules
	WHERE	MOD_ID = @MOD_ID
			AND EXISTS (
						SELECT 
								* 
						FROM	Management.OperationConfigurations 
						WHERE	MOD_OCF_BinConcat & OCF_ID <> 0 
								AND OCF_IsApply = 1
						)
IF @Reason = '' 
	IF @IsAccess = 1
		SET @Reason = 'Enable'
	ELSE
		SET @Reason = 'DisableDMOTemplate'
GO
