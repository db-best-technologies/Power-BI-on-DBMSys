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
/****** Object:  StoredProcedure [GUI].[usp_HealthCheck_Run]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_HealthCheck_Run]
	@HCH_ID					int,
	@PeriodStartDate		date = null,
	@PeriodEndDate			date = null,
	@ValueAggregationType	tinyint = 1, --Avg.
	@Percentile				tinyint = null,
	@IgnorePerformanceData	bit = 1--,
	--@ClearHistory			bit = 0
AS
BEGIN

	set nocount on
	set transaction isolation level read uncommitted

	DECLARE
		@Package_ID				int,
		@PKN_ID					int,
		@CurrentDate			datetime,
		@MonitoredObjectList	nvarchar(max)

	SET @CurrentDate = getdate()

	SET @MonitoredObjectList = ''

	SET @MonitoredObjectList = (
		SELECT CAST(HMO_MOB_ID AS varchar(16))+', ' AS [data()] 
		FROM BusinessLogic.HealthChecks_MonitoredObjects 
		WHERE HMO_HCH_ID = @HCH_ID
		FOR XML PATH(''))


	DECLARE A CURSOR LOCAL FORWARD_ONLY FOR
		SELECT HP.HCP_PKG_ID
		FROM BusinessLogic.HealthCheck_Packages AS HP
		WHERE HP.HCP_HCH_ID = @HCH_ID

	OPEN A

	FETCH NEXT FROM A INTO @Package_ID

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		EXEC [BusinessLogic].[usp_RunPackage]
			@PackageID = @Package_ID,
			@PeriodStartDate = @PeriodStartDate,
			@PeriodEndDate = @PeriodEndDate,
			@ValueAggregationType = @ValueAggregationType,
			@Percentile = @Percentile,
			@MonitoredObjectList = @MonitoredObjectList,
			@IgnorePerformanceData = @IgnorePerformanceData,
			@ClearHistory = 0,
			@PKN_ID = @PKN_ID output

		;WITH R AS
		(
			SELECT
				--@PKN_ID, @HCH_ID, @CurrentDate,
				PRR.PRR_PKN_ID,
				COUNT(DISTINCT PRR.PRR_RUL_ID) AS Runned_Qty,
				COUNT(RV.RLV_ID) AS RuleViolations_Qty,
				CASE WHEN R.RUL_Weight < 0.33 AND RV.RLV_PRR_ID IS NOT NULL THEN COUNT(*) END AS Lo_Qty,
				CASE WHEN R.RUL_Weight >= 0.33 AND R.RUL_Weight < 0.66 AND RV.RLV_PRR_ID IS NOT NULL THEN COUNT(*) END AS Med_Qty,
				CASE WHEN R.RUL_Weight >= 0.66 AND RV.RLV_PRR_ID IS NOT NULL THEN COUNT(*) END AS Hi_Qty
			FROM
				BusinessLogic.PackageRunRules AS PRR
				INNER JOIN BusinessLogic.Rules AS R
				ON PRR.PRR_RUL_ID = R.RUL_ID
				LEFT JOIN BusinessLogic.RuleViolations AS RV
				ON PRR.PRR_ID = RV.RLV_PRR_ID
			WHERE
				PRR_PKN_ID = @PKN_ID
			GROUP BY 
				PRR.PRR_PKN_ID, R.RUL_Weight, RV.RLV_PRR_ID
		)
		INSERT INTO BusinessLogic.HealthChecks_History(HCY_PKN_ID, HCY_HCH_ID, HCY_StartDate, Runned_Qty, RuleViolations_Qty, Lo_Qty, Med_Qty, Hi_Qty)
		SELECT 
			PRR_PKN_ID, @HCH_ID, @CurrentDate, 
			SUM(Runned_Qty) AS Runned_Qty, 
			SUM(RuleViolations_Qty) AS RuleViolations_Qty, 
			SUM(ISNULL(Lo_Qty, 0)) AS Lo_Qty, 
			SUM(ISNULL(Med_Qty, 0)) AS Med_Qty, 
			SUM(ISNULL(Hi_Qty, 0)) AS Hi_Qty
		FROM R
		GROUP BY PRR_PKN_ID

		FETCH NEXT FROM A INTO @Package_ID
	END

	CLOSE A
	DEALLOCATE A

	INSERT INTO BusinessLogic.HealthChecks_Reports(HRP_HCH_ID, HRP_Report_Date)
	VALUES (@HCH_ID, @CurrentDate)

END
GO
