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
/****** Object:  StoredProcedure [Collect].[usp_SetTestExecutionStatus]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Collect].[usp_SetTestExecutionStatus]
--DECLARE  
		@TRH_ID   int,  
		@ErrorMessage nvarchar(2000),
		@TRH_EndDate DATETIME2(3) = NULL
AS  
BEGIN  
 SET NOCOUNT ON;  

	DECLARE @CTRID INT

	SELECT
			@CTRID = TRH_CTR_ID
	FROM	Collect.TestRunHistory
	--JOIN	Inventory.MonitoredObjects on TRH_MOB_ID = MOB_ID
	WHERE	TRH_ID = @TRH_ID
  
	UPDATE Collect.TestRunHistory  
	SET TRH_TRS_ID = CASE WHEN @ErrorMessage IS NULL  
		THEN 3  
		ELSE 4  
		END,  
	TRH_EndDate = CASE WHEN TRH_StartDate IS NOT NULL  
		THEN ISNULL(@TRH_EndDate ,GETUTCDATE())
		ELSE NULL  
		END,  
	TRH_ErrorMessage = @ErrorMessage  
	WHERE TRH_ID = @TRH_ID  

	UPDATE	Collect.Collectors
	SET		CTR_LastResponceDate = GETUTCDATE()
	WHERE	CTR_ID = @CTRID
END
GO
