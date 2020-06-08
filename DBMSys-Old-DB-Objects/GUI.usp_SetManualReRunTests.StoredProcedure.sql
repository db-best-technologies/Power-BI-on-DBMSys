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
/****** Object:  StoredProcedure [GUI].[usp_SetManualReRunTests]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_SetManualReRunTests]
--DECLARE 
		@RR_List GUI.TT_ReRunTests readonly

AS

if object_id('tempdb..#RR_Table') is not null
	drop table #RR_Table

CREATE TABLE #RR_Table
(
	RT_MOB_ID INT
	,RT_TST_ID INT
)

INSERT INTO #RR_Table
--	TESTS
SELECT
		RR_MOB_ID
		,RR_TST_ID
FROM	@RR_List
WHERE	RR_TST_ID IS NOT NULL
UNION ALL
--	Query Types
SELECT
		DISTINCT
		f.MOB_ID
		,f.TST_ID
FROM	Collect.fn_GetObjectTests(NULL) f
JOIN	@RR_List rr ON f.MOB_ID = rr.RR_MOB_ID AND f.TST_QRT_ID = RR_QRT_ID
WHERE	RR_QRT_ID IS NOT NULL AND RR_TST_ID IS NULL
UNION ALL
--	Query Types
SELECT
		DISTINCT
		f.MOB_ID
		,f.TST_ID
FROM	Collect.fn_GetObjectTests(NULL) f
JOIN	@RR_List rr ON f.MOB_ID = rr.RR_MOB_ID
WHERE	RR_QRT_ID IS NULL AND RR_TST_ID IS NULL

DECLARE 
		@MOBID	INT
		,@TSTID	INT

BEGIN TRY
	BEGIN TRAN

		declare cReRuns cursor static forward_only for
			select	DISTINCT
					RT_MOB_ID
					,RT_TST_ID
			FROM	#RR_Table

		open cReRuns
		fetch next from cReRuns into @MOBID,@TSTID
		while @@fetch_status = 0
		begin
	
			EXEC Collect.usp_ScheduleTestManually @TSTID,@MOBID

			fetch next from cReRuns into @MOBID,@TSTID
		end
		close cReRuns
		deallocate cReRuns

	COMMIT TRAN
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK;
	THROW;
END CATCH
GO
