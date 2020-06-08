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
/****** Object:  UserDefinedFunction [Internal].[fn_ResponsesProcessedPerMinute]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Internal].[fn_ResponsesProcessedPerMinute](@LastHandledTimestamp binary(8),
														@MostRecentTimestamp binary(8),
														@CounterDateTime datetime2(3)) returns table
as
return with MinuteList as
				(select cast(convert(char(16), SPH_StartDate, 121) as datetime2(3)) MinuteValue
					from ResponseProcessing.SubscriptionProcessingHistory
					where SPH_Timestamp > @LastHandledTimestamp
						and SPH_Timestamp <= @MostRecentTimestamp
					union
					select cast(convert(char(16), SPH_EndDate, 121) as datetime2(3)) MinuteValue
					from ResponseProcessing.SubscriptionProcessingHistory
					where SPH_Timestamp > @LastHandledTimestamp
						and SPH_Timestamp <= @MostRecentTimestamp)
		select MinuteValue CounterDateTime, cast(null as varchar(900)) InstanceName, COUNT(*) Value,
				cast(null as varchar(100)) ResultStatus, cast(null as int) TRH_ID
		from MinuteList
			inner join ResponseProcessing.SubscriptionProcessingHistory with (forceseek) on (SPH_StartDate >= MinuteValue and SPH_StartDate < DATEADD(MINUTE, 1, MinuteValue))
																	or (SPH_EndDate >= MinuteValue and SPH_EndDate < DATEADD(MINUTE, 1, MinuteValue))
		where SPH_Timestamp > @LastHandledTimestamp
			and SPH_Timestamp <= @MostRecentTimestamp
			and SPH_ErrorMessage is null
		group by MinuteValue
GO
