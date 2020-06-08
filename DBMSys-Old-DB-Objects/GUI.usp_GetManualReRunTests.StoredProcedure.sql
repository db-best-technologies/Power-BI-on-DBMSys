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
/****** Object:  StoredProcedure [GUI].[usp_GetManualReRunTests]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_GetManualReRunTests]
	@CTR_ID INT = NULL
AS

if object_id('tempdb..#RR_Table') is not null
	drop table #RR_Table

IF @CTR_ID IS NOT NULL
BEGIN
	BEGIN TRY
		BEGIN TRAN

			SELECT
					SCT_ID		AS SCTID
					,SCT_TST_ID AS TSTID
					,SCT_MOB_ID AS MOBID
					,MOB_CTR_ID AS CTRID
			INTO	#RR_Table
			FROM	Collect.ScheduledTests
			JOIN	Inventory.MonitoredObjects ON SCT_MOB_ID = MOB_ID
			WHERE	SCT_RNR_ID = 3 
					AND SCT_STS_ID = 1

			UPDATE	Collect.ScheduledTests
			SET		SCT_STS_ID = 2
					,SCT_LaunchDate = GETUTCDATE()
			FROM	#RR_Table rr
			WHERE	SCT_ID = rr.SCTID

			SELECT
					SCTID
					,TSTID
					,MOBID
					,CTRID
			FROM	#RR_Table
			
			

		COMMIT TRAN
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK;
		THROW;
	END CATCH
END
ELSE
	raiserror('Collector ID should not be empty',16,1)
GO
