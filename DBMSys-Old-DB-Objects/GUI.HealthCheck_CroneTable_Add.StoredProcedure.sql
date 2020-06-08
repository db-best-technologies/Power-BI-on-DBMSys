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
/****** Object:  StoredProcedure [GUI].[HealthCheck_CroneTable_Add]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[HealthCheck_CroneTable_Add]
	@HCT_ID		int,
	@SCH_ID		int,			
	@Day_Freq	tinyint,		--	1 = Daily, 2 = Weekly, 3 = Monthly
	@Time_Freq	tinyint,		--	1 = Specific time, 2 = Every N minute or hour
	@Day		tinyint,		--	Every N day
	@Week		tinyint = NULL,	--  Every N week at certain @Day of week
	@Month		tinyint,		--  If @Day_Freq = 3 and @Week IS NULL then @Day of every @Month else @Day of @Week of every @Month
	@Minute		tinyint,		--	If @Time_Freq = 2 then minute if @Minute is not null or hour if @Hour is not null
	@Hour		tinyint	
AS
BEGIN
	DECLARE
		@Description	varchar(512),
		@First_Day		varchar(15)

	DECLARE @DayOfWeek TABLE
		(
			IntBit		tinyint,
			Day_Name	varchar(15)
		)

	INSERT INTO @DayOfWeek (IntBit, Day_Name)
	VALUES 
		(1, 'Monday'),
		(2, 'Tuesday'),
		(4, 'Wednesday'),
		(8, 'Thursday'),
		(16, 'Friday'),
		(32, 'Saturday'),
		(64, 'Sunday')


	IF @Day_Freq = 1 
	BEGIN
		SET @Description = 'Start daily, every '+cast(@Day AS varchar(3))+' day.'
	END
	
	IF @Day_Freq = 2 
	BEGIN
		SET @Description = 'Start weekly, every '+cast(@Week as varchar(3))+' week, on '+ 
			(
				SELECT Day_Name +', ' AS [data()]
				FROM @DayOfWeek
				WHERE IntBit & @Day > 0
				FOR XML PATH('')
			)

		SET @Description = SUBSTRING(@Description, 1, LEN(@Description)-1)
	END

	IF @Day_Freq = 3 
	BEGIN
		SET @Description = 'Start monthly, '
		IF @Week IS NULL 
			SET @Description = @Description + 'day '+cast(@Day AS varchar(3))+' of every '+ cast(@Month as varchar(3))+' month(s)'
		ELSE BEGIN
			SET @Description = 'The '+cast(@Day AS varchar(3))+' day of '+cast(@Week AS varchar(3))+' week of every '+cast(@Month AS varchar(3))+' month'
		END

	END

	---------------------------------------- Time settings -----------------------------------------------------------

	IF @Time_Freq = 1
	BEGIN
		SET @Description = @Description +' at '+CAST(@Hour AS varchar(2))+':'+CAST(@Minute AS varchar(2))+'.'
	END ELSE
	BEGIN
		IF @Hour is not null 
			SET @Description = @Description +' every '+CAST(@Hour AS varchar(2))+' hour.'
		ELSE
			SET @Description = @Description +' every '+CAST(@Minute AS varchar(2))+' minute.'
	END

	
	INSERT INTO [BusinessLogic].[HealthCheck_Cron_Table](
		HCT_HCH_ID, HCT_SCH_ID, HCT_Day_Freq, HCT_Time_Freq, HCT_Day, HCT_Week, HCT_Month, HCT_Minute, HCT_Hour, HCT_Description)
	VALUES (
		@HCT_ID, @SCH_ID, @Day_Freq, @Time_Freq, @Day, @Week, @Month, @Minute, @Hour, @Description)
END
GO
