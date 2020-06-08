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
/****** Object:  UserDefinedFunction [Internal].[fn_Counter_TestRunsPerMinute]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Internal].[fn_Counter_TestRunsPerMinute](@LastHandledTimestamp binary(8),
														@MostRecentTimestamp binary(8),
														@CounterDateTime datetime2(3)) returns table
as
return with MinuteList as
				(select cast(convert(char(16), TRH_StartDate, 121) as datetime2(3)) MinuteValue
					from Collect.TestRunHistory
					where TRH_Timestamp > @LastHandledTimestamp
						and TRH_Timestamp <= @MostRecentTimestamp
						and TRH_TRS_ID < 4
					union
					select cast(convert(char(16), TRH_EndDate, 121) as datetime2(3)) MinuteValue
					from Collect.TestRunHistory
					where TRH_Timestamp > @LastHandledTimestamp
						and TRH_Timestamp <= @MostRecentTimestamp
						and TRH_TRS_ID < 4)
		select MinuteValue CounterDateTime, cast(null as varchar(900)) InstanceName, COUNT(*) Value,
				cast(null as varchar(100)) ResultStatus, cast(null as int) TRH_ID
		from MinuteList
			inner join Collect.TestRunHistory with (forceseek) on (TRH_StartDate >= MinuteValue and TRH_StartDate < DATEADD(MINUTE, 1, MinuteValue))
																	or (TRH_EndDate >= MinuteValue and TRH_EndDate < DATEADD(MINUTE, 1, MinuteValue))
		where TRH_Timestamp > @LastHandledTimestamp
			and TRH_Timestamp <= @MostRecentTimestamp
			and TRH_TRS_ID < 4
		group by MinuteValue
GO
