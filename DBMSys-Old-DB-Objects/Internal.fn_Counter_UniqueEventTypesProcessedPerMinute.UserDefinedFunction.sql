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
/****** Object:  UserDefinedFunction [Internal].[fn_Counter_UniqueEventTypesProcessedPerMinute]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Internal].[fn_Counter_UniqueEventTypesProcessedPerMinute](@LastHandledTimestamp binary(8),
																		@MostRecentTimestamp binary(8),
																		@CounterDateTime datetime2(3)) returns table
return with MinuteList as
				(select cast(convert(char(16), PRC_StartDate, 121) as datetime2(3)) MinuteValue
					from EventProcessing.ProcessCycles
					where PRC_Timestamp > @LastHandledTimestamp
						and PRC_Timestamp <= @MostRecentTimestamp
					union
					select cast(convert(char(16), PRC_EndDate, 121) as datetime2(3)) MinuteValue
					from EventProcessing.ProcessCycles
					where PRC_Timestamp > @LastHandledTimestamp
						and PRC_Timestamp <= @MostRecentTimestamp)
		select MinuteValue CounterDateTime, cast(null as varchar(900)) InstanceName, COUNT(distinct PRC_MOV_ID) Value,
				cast(null as varchar(100)) ResultStatus, cast(null as int) TRH_ID
		from MinuteList
			inner join EventProcessing.ProcessCycles with (forceseek) on (PRC_StartDate >= MinuteValue and PRC_StartDate < DATEADD(MINUTE, 1, MinuteValue))
																	or (PRC_EndDate >= MinuteValue and PRC_EndDate < DATEADD(MINUTE, 1, MinuteValue))
		where PRC_Timestamp > @LastHandledTimestamp
			and PRC_Timestamp <= @MostRecentTimestamp
		group by MinuteValue
GO
