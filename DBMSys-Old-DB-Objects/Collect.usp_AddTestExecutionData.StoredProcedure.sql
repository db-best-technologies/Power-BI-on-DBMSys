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
/****** Object:  StoredProcedure [Collect].[usp_AddTestExecutionData]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Collect].[usp_AddTestExecutionData]
--DECLARE  
	@ClientId INT,  
	@MOB_ID INT = NULL,
	@PLT_Name NVARCHAR(50),  
	@TST_ID INT,
	@TSV_ID INT,
	@SCT_ID INT = NULL,
	@TST_OutputTable NVARCHAR(257),  
	@SCT_LaunchDate DATETIME2(3),  
	@SCT_ProcessStartDate DATETIME2(3),   
	@SCT_ProcessEndDate DATETIME2(3),   
	@TRH_ErrorMessage NVARCHAR(2000) = NULL,   
	@TRH_ID INT OUTPUT  ,
	@CTR_ID	INT = NULL,
	@TRH_SourceHash BIGINT = NULL
	,@MOB_GUIDKey	NVARCHAR(256) = NULL
AS  
BEGIN  
 SET NOCOUNT ON;  
  
  IF @MOB_GUIDKey IS NOT NULL AND @MOB_ID IS NULL 
	SELECT
			@MOB_ID = MOM_MOB_ID
	FROM	Inventory.MonitoringObectMapping
	WHERE	MOM_ObjGUID = @MOB_GUIDKey

	IF @MOB_ID IS NOT NULL 
	BEGIN

		 DECLARE 
		   @PLT_ID INT,  
		   @TRS_ID INT,  
		   @TRH_EndDate DATETIME2(3) --= @SCT_ProcessEndDate--NULL  

		   select @PLT_ID = PLT_ID from Management.PlatformTypes WHERE PLT_Name = @PLT_Name
   
		 DECLARE @t TABLE  
		 (  
		  id INT  
		 )   
   
		 BEGIN TRY  
		  BEGIN TRANSACTION   

				IF EXISTS (SELECT TOP 1 1 FROM Collect.TestRunHistory WHERE TRH_TST_ID = @TST_ID AND TRH_MOB_ID = @MOB_ID AND TRH_EndDate = @SCT_ProcessEndDate and TRH_SourceHash = @TRH_SourceHash)
				BEGIN
					declare @ex NVARCHAR(255) = CAST(@TRH_SourceHash AS NVARCHAR(32))
					--SELECT 'TRH_ID = ' + CAST(TRH_ID AS NVARCHAR(10)) + ', TST_ID = ' + CAST(@TST_ID AS NVARCHAR(10))+ ', MOB_ID = ' + CAST(@MOB_ID AS NVARCHAR(10))   FROM Collect.TestRunHistory WHERE TRH_TST_ID = @TST_ID AND TRH_MOB_ID = @MOB_ID AND TRH_EndDate > @SCT_ProcessEndDate
					RAISERROR('Current test result for TST_ID = %d and MOB_ID = %d exist, HASH = %s ',16,1,@TST_ID,@MOB_ID,@ex)
				END
				ELSE
				IF EXISTS (SELECT TOP 1 1 FROM Collect.TestRunHistory WHERE TRH_TST_ID = @TST_ID AND TRH_MOB_ID = @MOB_ID AND TRH_EndDate >= @SCT_ProcessEndDate)
				BEGIN
					
					SELECT 'TRH_ID = ' + CAST(TRH_ID AS NVARCHAR(10)) + ', TST_ID = ' + CAST(@TST_ID AS NVARCHAR(10))+ ', MOB_ID = ' + CAST(@MOB_ID AS NVARCHAR(10))   FROM Collect.TestRunHistory WHERE TRH_TST_ID = @TST_ID AND TRH_MOB_ID = @MOB_ID AND TRH_EndDate > @SCT_ProcessEndDate
					RAISERROR('The newest test result for TST_ID = %d and MOB_ID = %d exist',16,1,@TST_ID,@MOB_ID)
				END

				ELSE
				BEGIN

					  IF @SCT_ID IS NOT NULL
						UPDATE	Collect.ScheduledTests
						SET		SCT_STS_ID = 4
								,SCT_LaunchDate = @SCT_ProcessStartDate
								,SCT_ProcessStartDate = @SCT_ProcessStartDate
								,SCT_ProcessEndDate = @SCT_ProcessEndDate
						WHERE	SCT_ID = @SCT_ID
								AND SCT_RNR_ID = 3
						ELSE
						BEGIN
						  --Add ScheduledTest  
						  INSERT INTO Collect.ScheduledTests(SCT_ClientID, SCT_TST_ID, SCT_TSV_ID, SCT_MOB_ID, SCT_DateToRun, SCT_RNR_ID, SCT_InsertDate, SCT_STS_ID, SCT_LaunchDate, SCT_ProcessStartDate, SCT_ProcessEndDate)  
						  OUTPUT inserted.SCT_ID INTO @t(id)  
						  VALUES(@ClientId, @TST_ID, @TSV_ID, @MOB_ID, @SCT_LaunchDate, 1 /*Scheduled*/, GETUTCDATE(), 4 /*Complete*/, @SCT_ProcessStartDate, @SCT_ProcessStartDate, @SCT_ProcessEndDate)  
						  SELECT @SCT_ID = id FROM @t 
						END 
  
					  IF(@TRH_ErrorMessage IS NULL OR @TRH_ErrorMessage = '')  
						SET @TRS_ID = 2 /*Running*/    
					  ELSE  
					   BEGIN  
							SET @TRS_ID = 4 /*Error*/  
							SET @TRH_EndDate = GETUTCDATE()  
					   END  
  
					  DELETE FROM @t  
  
					  --Add TestRunHistory  
					  INSERT INTO Collect.TestRunHistory(TRH_ClientID, TRH_TST_ID, TRH_MOB_ID, TRH_RNR_ID, TRH_SCT_ID, TRH_TRS_ID, TRH_InsertDate, TRH_StartDate, TRH_EndDate, TRH_ErrorMessage,TRH_CTR_ID,TRH_SourceHash)  
					  OUTPUT inserted.TRH_ID INTO @t(id)  
					  VALUES(							@ClientId,		@TST_ID,	@MOB_ID,	1 /*Scheduled*/, @SCT_ID, @TRS_ID, GETUTCDATE(), @SCT_ProcessStartDate, @TRH_EndDate, @TRH_ErrorMessage,@CTR_ID,@TRH_SourceHash)  
					  SELECT @TRH_ID = id FROM @t  
				 END
  
		  COMMIT TRANSACTION  
		 END TRY  
		 BEGIN CATCH  
		  if @@TRANCOUNT > 0  
		   ROLLBACK TRANSACTION;  
  
		  THROW  
		 END CATCH  
	END
	ELSE
		raiserror('Unknown monitored object or MOB_ID is NULL',16,1)
END
GO
