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
/****** Object:  StoredProcedure [GUI].[usp_HealthChecks_Edit]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_HealthChecks_Edit]
	@HCH_ID			int,
	@HCH_SCH_ID		int,
	@HCH_Name		nvarchar(255),
	@HCH_CreateDate	datetime2(3),
	@HCH_IsEnabled	bit,
	@MOB_ID_List	[Inventory].[SystemHosts_List] readonly,
	@PKG_ID_List	GUI.PKG_ID_List readonly
AS
BEGIN
	DECLARE
		@In_Tran	bit,
		@Error		int

	SET @In_Tran = 0
	SET @Error = 0

	IF @@TRANCOUNT > 0 SET @In_Tran = 1

	BEGIN TRAN

	BEGIN TRY
		-- Edit the Hat
		UPDATE BusinessLogic.HealthChecks
		SET
			HCH_SCH_ID = @HCH_SCH_ID,
			HCH_Name = @HCH_Name,
			HCH_IsEnabled = @HCH_IsEnabled,
			HCH_CreateDate = @HCH_CreateDate
		WHERE
			HCH_ID = @HCH_ID

		-- Delete unchecked Packages
		DELETE HP
		FROM 
			[BusinessLogic].[HealthCheck_Packages] AS HP
			LEFT JOIN @PKG_ID_List AS HPL
			ON HP.HCP_PKG_ID = HPL.PKG_ID
		WHERE
			HP.HCP_HCH_ID = @HCH_ID
			AND HPL.PKG_ID IS NULL

		-- Delete unchecked Monitored Objects
		DELETE HM
		FROM 
			[BusinessLogic].[HealthChecks_MonitoredObjects] AS HM
			LEFT JOIN @MOB_ID_List AS HML
			ON HM.HMO_MOB_ID = HML.SHS_MOB_ID
		WHERE
			HM.HMO_HCH_ID = @HCH_ID
			AND HML.SHS_MOB_ID IS NULL


		-- Insert checked packages
		INSERT INTO [BusinessLogic].[HealthCheck_Packages] (HCP_PKG_ID, HCP_HCH_ID)
		SELECT
			HPL.PKG_ID, @HCH_ID
		FROM
			@PKG_ID_List AS HPL
			LEFT JOIN [BusinessLogic].[HealthCheck_Packages] AS HP
			ON HP.HCP_PKG_ID = HPL.PKG_ID
			AND HP.HCP_HCH_ID = @HCH_ID
		WHERE
			HP.HCP_PKG_ID IS NULL
			

		-- Insert checked Monitored Objects
		INSERT INTO [BusinessLogic].[HealthChecks_MonitoredObjects](HMO_HCH_ID, HMO_MOB_ID)
		SELECT
			@HCH_ID, HML.SHS_MOB_ID
		FROM
			@MOB_ID_List AS HML
			LEFT JOIN [BusinessLogic].[HealthChecks_MonitoredObjects] AS HM
			ON HM.HMO_MOB_ID = HML.SHS_MOB_ID
			AND HM.HMO_HCH_ID = @HCH_ID
		WHERE
			HM.HMO_MOB_ID IS NULL

		-- Delete previous scheduler
		IF EXISTS (SELECT 1 FROM BusinessLogic.HealthCheck_Cron_Table WHERE HCT_HCH_ID = @HCH_ID)
			DELETE FROM BusinessLogic.HealthCheck_Cron_Table
			WHERE HCT_HCH_ID = @HCH_ID


		-- Append Scheduler for the new HC. Predefined values
		-- Once a day, at 2 AM.
		IF @HCH_SCH_ID = 1 -- daily
			EXEC GUI.HealthCheck_CroneTable_Add
				@HCT_ID		= @HCH_ID,
				@SCH_ID		= @HCH_SCH_ID,			
				@Day_Freq	= 1,		--	1 = Daily, 2 = Weekly, 3 = Monthly
				@Time_Freq	= 1,		--	1 = Specific time, 2 = Every N minute or hour
				@Day		= 1,		--	Every N day
				@Week		= 1,		--  Every N week at certain @Day of week
				@Month		= 1,		--  If @Day_Freq = 3 and @Week IS NULL then @Day of every @Month else @Day of @Week of every @Month
				@Minute		= 0,		--	If @Time_Freq = 2 then minute if @Minute is not null or hour if @Hour is not null
				@Hour		= 2	

		-- Every Monday at 2 AM.
		IF @HCH_SCH_ID = 2 -- weekly
			EXEC GUI.HealthCheck_CroneTable_Add
				@HCT_ID		= @HCH_ID,
				@SCH_ID		= @HCH_SCH_ID,			
				@Day_Freq	= 2,		--	1 = Daily, 2 = Weekly, 3 = Monthly
				@Time_Freq	= 1,		--	1 = Specific time, 2 = Every N minute or hour
				@Day		= 1,		--	Every Monday
				@Week		= 1,		--  Every N week at certain @Day of week
				@Month		= 1,		--  If @Day_Freq = 3 and @Week IS NULL then @Day of every @Month else @Day of @Week of every @Month
				@Minute		= 0,		--	If @Time_Freq = 2 then minute if @Minute is not null or hour if @Hour is not null
				@Hour		= 2	

		-- Every month on the 1-st day at 2 AM.
		IF @HCH_SCH_ID = 3 -- monthly
			EXEC GUI.HealthCheck_CroneTable_Add
				@HCT_ID		= @HCH_ID,
				@SCH_ID		= @HCH_SCH_ID,			
				@Day_Freq	= 3,		--	1 = Daily, 2 = Weekly, 3 = Monthly
				@Time_Freq	= 1,		--	1 = Specific time, 2 = Every N minute or hour
				@Day		= 1,		--	1-st day of month
				@Week		= NULL,		--  Every N week at certain @Day of week
				@Month		= 1,		--  If @Day_Freq = 3 and @Week IS NULL then @Day of every @Month else @Day of @Week of every @Month
				@Minute		= 0,		--	If @Time_Freq = 2 then minute if @Minute is not null or hour if @Hour is not null
				@Hour		= 2	

		IF @HCH_SCH_ID = 4 -- On Demand
		BEGIN
			IF not exists (SELECT 1 FROM BusinessLogic.SheduledTasks WHERE SLT_HCH_ID = @HCH_ID AND SLT_EndDate IS NULL)
			BEGIN
				INSERT INTO BusinessLogic.SheduledTasks(SLT_HCH_ID, SLT_StartDate)
				VALUES (@HCH_ID, @HCH_CreateDate)
			END
		END

		COMMIT TRAN
	END TRY
	BEGIN CATCH
		
		IF @In_Tran = 0 
		BEGIN
			
			ROLLBACK TRAN;
			THROW;
		END
		SET @Error = ERROR_NUMBER()

	END CATCH

	RETURN @Error

END
GO
