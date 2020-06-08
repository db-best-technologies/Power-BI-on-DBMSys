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
/****** Object:  StoredProcedure [GUI].[usp_HealthCheck_StartList_Add]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_HealthCheck_StartList_Add]
AS
BEGIN
	DECLARE
		@Current_Date	datetime2(3),
		@Current_Day	date,
		@Day_Of_Week	tinyint

	SET @Current_Date = getdate()
	SET @Current_Day = CAST(@Current_Date AS date)
	SET @Day_Of_Week = CASE
							WHEN @@DATEFIRST = 1 THEN DATEPART(dw, @Current_Date)
							ELSE @@DATEFIRST-8+DATEPART(dw, @Current_Date)
						END

	DECLARE @Res TABLE
	(
		HCH_ID			int,
		Is_Day			bit null,
		Is_Time			bit null,
		Last_Run		datetime2(3),
		Last_Run_Today	datetime2(3) null
	)


	DECLARE @A TABLE
	(
		HCT_HCH_ID		int,
		Date_Day		date,
		SLT_EndDate		datetime
	)

	INSERT INTO @A (HCT_HCH_ID, Date_Day, SLT_EndDate)
	SELECT A.HCT_HCH_ID, A.Date_Day, A.SLT_EndDate
	FROM
		(
			SELECT 
				CE.HCT_HCH_ID, 
				CAST(ST.SLT_EndDate AS date) AS Date_Day, 
				ST.SLT_EndDate,
				ROW_NUMBER() OVER (PARTITION BY CE.HCT_HCH_ID ORDER BY ST.SLT_EndDate DESC) AS Row_Num
			FROM 
				BusinessLogic.VW_Enabled_HealthCheck_Cron_Table AS CE
				LEFT JOIN BusinessLogic.SheduledTasks AS ST 
				ON ST.SLT_HCH_ID = CE.HCT_HCH_ID
		) AS A
	WHERE
		A.Row_Num < 3

	INSERT INTO @Res (HCH_ID, Last_Run, Last_Run_Today)
	SELECT 
		R.HCT_HCH_ID, MAX(M.Date_Day) AS Date_Day, MAX(R.SLT_EndDate) AS MAX_Run_Date
	FROM 
		@A AS R
		OUTER APPLY (
			SELECT R2.HCT_HCH_ID, MAX(R2.Date_Day) AS Date_Day
			FROM @A AS R2
			WHERE R2.HCT_HCH_ID = R.HCT_HCH_ID AND R2.Date_Day < R.Date_Day 
			GROUP BY R2.HCT_HCH_ID ) AS M
	GROUP BY
		R.HCT_HCH_ID

	--SELECT * FROM @Res


	-- Daily case
	UPDATE R 
	SET
		Is_Day = CASE WHEN DATEDIFF(dd, Last_Run, @Current_Date) >= CE.HCT_Day OR R.Last_Run IS NULL THEN 1 ELSE 0 END
	FROM
		@Res AS R
		INNER JOIN BusinessLogic.VW_Enabled_HealthCheck_Cron_Table AS CE
		ON R.HCH_ID = CE.HCT_HCH_ID
	WHERE
		CE.HCT_Day_Freq = 1	-- Daily


	-- Weekly case
	UPDATE R 
	SET
		Is_Day = CASE 
					WHEN ((DATEDIFF(ww, Last_Run, @Current_Date) >= CE.HCT_Week OR Last_Run IS NULL)
						AND POWER(2, @Day_Of_Week-1) & CE.HCT_Day > 0)
						OR R.Last_Run_Today IS NULL 
					THEN 1 ELSE 0 END
	FROM
		@Res AS R
		INNER JOIN BusinessLogic.VW_Enabled_HealthCheck_Cron_Table AS CE
		ON R.HCH_ID = CE.HCT_HCH_ID
	WHERE
		CE.HCT_Day_Freq = 2	-- Weekly

	-- Monthly case
	UPDATE R 
	SET
		Is_Day = CASE
					WHEN 
						(CE.HCT_Week IS NULL
						AND CE.HCT_Day >= DATEPART(dd, @Current_Date)
						AND DATEDIFF(mm, Last_Run, @Current_Date) >= CE.HCT_Month)
						OR
						(CE.HCT_Week IS NOT NULL
						AND POWER(2, @Day_Of_Week-1) & CE.HCT_Day > 0
						AND DATEDIFF(ww, Last_Run, @Current_Date) >= CE.HCT_Week 
						AND DATEDIFF(mm, Last_Run, @Current_Date) >= CE.HCT_Month)
						OR 
						R.Last_Run IS NULL
					THEN 1 ELSE 0 END
	FROM
		@Res AS R
		INNER JOIN BusinessLogic.VW_Enabled_HealthCheck_Cron_Table AS CE
		ON R.HCH_ID = CE.HCT_HCH_ID
	WHERE
		CE.HCT_Day_Freq = 3	-- Monthly


	----------------------------------------------------------------------------------------------------------------------------------------
	--		Define time

	-- Define the time: certain time
	UPDATE R 
	SET
		Is_Time = CASE 
					WHEN 
						DATEPART(Mi, @Current_Date) >= CE.HCT_Minute 
						AND DATEPART(hh, @Current_Date) >= CE.HCT_Hour 
						AND Is_Day = 1 
						AND (
								CAST(Last_Run_Today AS date) < CAST(@Current_Date AS date)
								OR Last_Run_Today IS NULL
							)
					THEN 1 ELSE 0 END
	FROM
		@Res AS R
		INNER JOIN BusinessLogic.VW_Enabled_HealthCheck_Cron_Table AS CE
		ON R.HCH_ID = CE.HCT_HCH_ID
	WHERE
		CE.HCT_Time_Freq = 1 -- Certain time


	-- Define the time: every N hour or N minute
	UPDATE R 
	SET
		Is_Time = CASE 
					WHEN 
						(CE.HCT_Minute IS NOT NULL AND DATEDIFF(Mi, Last_Run_Today, @Current_Date) >= CE.HCT_Minute) 
						OR
						(CE.HCT_Minute IS NULL AND DATEDIFF(Mi, Last_Run_Today, @Current_Date) >= CE.HCT_Hour * 60) 
						OR 
						R.Last_Run_Today IS NULL
					THEN 1 ELSE 0 END
	FROM
		@Res AS R
		INNER JOIN BusinessLogic.VW_Enabled_HealthCheck_Cron_Table AS CE
		ON R.HCH_ID = CE.HCT_HCH_ID
	WHERE
		CE.HCT_Time_Freq = 2 -- every N hour or N minute

	----------------------------------------------------------------------------------------------------------------------------------------
	--		Store result

	INSERT INTO [BusinessLogic].[SheduledTasks]	(SLT_HCH_ID, SLT_StartDate)
	SELECT HCH_ID, @Current_Date
	FROM @Res 
	WHERE Is_Day = 1 AND Is_Time = 1

	--SELECT * FROM @Res

END
GO
