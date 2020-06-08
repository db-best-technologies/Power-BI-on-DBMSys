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
/****** Object:  UserDefinedFunction [Internal].[fn_Counter_EventProcessingRunTimes]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Internal].[fn_Counter_EventProcessingRunTimes](@LastHandledTimestamp binary(8),
															@MostRecentTimestamp binary(8),
															@CounterDateTime datetime2(3)) returns table
as
return select cast(convert(char(16), PRC_StartDate, 121) as datetime2(3)) CounterDateTime,
			MOV_Description InstanceName, AVG(datediff(millisecond, PRC_StartDate, PRC_EndDate)) Value,
			cast(null as varchar(100)) ResultStatus, cast(null as int) TRH_ID
		from EventProcessing.ProcessCycles
			inner join EventProcessing.MonitoredEvents on PRC_MOV_ID = MOV_ID
		where PRC_Timestamp > @LastHandledTimestamp
					and PRC_Timestamp <= @MostRecentTimestamp
			and PRC_EndDate is not null
			and PRC_ErrorMessage is null
		group by cast(convert(char(16), PRC_StartDate, 121) as datetime2(3)), MOV_Description
GO
