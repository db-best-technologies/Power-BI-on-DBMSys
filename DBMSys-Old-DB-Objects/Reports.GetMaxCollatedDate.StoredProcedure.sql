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
/****** Object:  StoredProcedure [Reports].[GetMaxCollatedDate]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reports].[GetMaxCollatedDate]
--DECLARE
		@MaxCollDate	DATETIME2(3)	OUTPUT
		,@IsFullDMO		BIT = 0
AS

IF @IsFullDMO = 0
	SELECT	TOP 1
			@MaxCollDate = TRH_StartDate
	FROM	Collect.TestRunHistory
	WHERE	TRH_TRS_ID = 3
	ORDER BY TRH_ID DESC
ELSE
BEGIN
	SET @MaxCollDate = NULL
	IF OBJECT_ID('tempdb..#CompletedSteps') IS NOT NULL
		DROP TABLE #CompletedSteps
	create table #CompletedSteps
	(
		StepID			INT
		,Ordinal		INT
		,StepName		NVARCHAR(255)
		,StepStatus		NVARCHAR(255)
		,PRH_EndDate	DATETIME

	)

	INSERT INTO #CompletedSteps
	exec CapacityPlanningWizard.usp_GetProcessSteps

	IF NOT EXISTS (SELECT * FROM #CompletedSteps WHERE PRH_EndDate IS NULL OR StepStatus NOT LIKE '%Completed at %')
		SELECT TOP 1 @MaxCollDate = PRH_EndDate FROM #CompletedSteps ORDER BY StepID DESC
			
END
GO
