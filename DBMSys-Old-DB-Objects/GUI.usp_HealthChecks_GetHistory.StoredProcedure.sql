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
/****** Object:  StoredProcedure [GUI].[usp_HealthChecks_GetHistory]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_HealthChecks_GetHistory]
	@HCH_ID		int,
	@Start_From	int = NULL,
	@Count		int = NULL
AS
BEGIN
	DECLARE
		@Sql	nvarchar(max)

	SET @Sql = '
		WITH R AS
		(
			SELECT
				ROW_NUMBER() OVER (ORDER BY VE.HCH_ID, VE.History_Date desc) AS RowNum,
				VE.HCH_ID,
				VE.History_Date,
				CASE WHEN Exec_Percent = 100 THEN ''Done'' ELSE ''In Progress'' END AS Exec_Status,
				VE.Exec_Percent,
				VE.Lo_Qty, VE.Med_Qty, VE.Hi_Qty,
				VE.RuleViolations_Qty AS Alert_Qty
			FROM
				BusinessLogic.VW_HealthChecks_Executions AS VE
			WHERE
				VE.HCH_ID = '+CAST(@HCH_ID AS nvarchar(6))+'
		) SELECT '

		IF @Count IS NOT NULL SET @Sql = @Sql +'TOP '+CAST(@Count AS nvarchar(6))+' '

		SET @Sql = @Sql + '
			HCH_ID, History_Date, Exec_Status, Exec_Percent, Alert_Qty, Lo_Qty, Med_Qty, Hi_Qty
			FROM R WHERE 1=1'

	IF @Start_From IS NOT NULL
		SET @Sql = @Sql + ' AND RowNum >= '+CAST(@Start_From AS nvarchar(6))

	SET @Sql = @Sql + ' ORDER BY RowNum'

	EXEC (@Sql)

END
GO
