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
/****** Object:  StoredProcedure [BusinessLogic].[usp_Healthcheck_Run_Queue]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [BusinessLogic].[usp_Healthcheck_Run_Queue]
AS
BEGIN
	DECLARE 
		@HCH_ID		INT
		,@SLT_ID	INT
		,@ERRMSG	NVARCHAR(MAX)
		,@ObsoleteData	datetime2(3)

	SET @ObsoleteData = dateadd(year, -1, getdate())

	EXEC GUI.usp_HealthCheck_StartList_Add

	-- Runs Logging
	INSERT INTO Internal.HealthChecks_Runs (HCR_Date)
	VALUES (GETDATE())

	-- Delete old data (1 year)
	DELETE FROM Internal.HealthChecks_Runs
	WHERE HCR_Date < @ObsoleteData

	DECLARE A CURSOR LOCAL FORWARD_ONLY FOR
		SELECT 
				SLT_ID
				,SLT_HCH_ID
		FROM	BusinessLogic.SheduledTasks
		WHERE	SLT_EndDate IS NULL
				AND SLT_Status IS NULL
		ORDER BY SLT_StartDate

	OPEN A

	FETCH NEXT FROM A INTO @SLT_ID,@HCH_ID

	WHILE @@FETCH_STATUS = 0
	BEGIN 
	
		BEGIN TRY
			-- 0-? ?????????, 1-????????? ???, 2-??????
			UPDATE 	BusinessLogic.SheduledTasks	set SLT_Status = 0 where SLT_ID = @SLT_ID

			EXEC GUI.usp_HealthCheck_Run @HCH_ID

			UPDATE 	BusinessLogic.SheduledTasks	set SLT_Status = 1, SLT_EndDate = GETDATE() where SLT_ID = @SLT_ID

		END TRY
		BEGIN CATCH
			set @ERRMSG = ERROR_MESSAGE()

			UPDATE 	BusinessLogic.SheduledTasks	set SLT_Status = 2, SLT_EndDate = GETDATE(),SLT_Message = @ERRMSG where SLT_ID = @SLT_ID

		END CATCH

		FETCH NEXT FROM A INTO @SLT_ID,@HCH_ID
	END

	CLOSE A
	DEALLOCATE A
END
GO
