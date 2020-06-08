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
/****** Object:  StoredProcedure [GUI].[usp_HealthChecks_Add]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_HealthChecks_Add]
	@HCH_SCH_ID		int,
	@HCH_Name		nvarchar(255),
	@HCH_CreateDate	datetime2(3) = NULL,	-- If NULL then current date
	@HCH_IsEnabled	bit,
	@MOB_ID_List	[Inventory].[SystemHosts_List] readonly,
	@PKG_ID_List	GUI.PKG_ID_List readonly,	
	@HCH_ID			int	OUTPUT
AS
BEGIN
	INSERT INTO BusinessLogic.HealthChecks (HCH_SCH_ID, HCH_Name, HCH_CreateDate, HCH_IsEnabled, HCH_IsActive)
	VALUES (@HCH_SCH_ID, @HCH_Name, ISNULL(@HCH_CreateDate, getdate()), @HCH_IsEnabled, 1)

	SET @HCH_ID = SCOPE_IDENTITY();

	INSERT INTO [BusinessLogic].[HealthChecks_MonitoredObjects](HMO_HCH_ID, HMO_MOB_ID)
	SELECT @HCH_ID, [SHS_MOB_ID]
	FROM @MOB_ID_List

	INSERT INTO [BusinessLogic].[HealthCheck_Packages] (HCP_PKG_ID, HCP_HCH_ID)
	SELECT [PKG_ID], @HCH_ID
	FROM @PKG_ID_List

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

END
GO
