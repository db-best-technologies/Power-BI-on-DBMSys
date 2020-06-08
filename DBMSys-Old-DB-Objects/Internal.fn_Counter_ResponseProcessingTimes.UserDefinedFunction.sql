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
/****** Object:  UserDefinedFunction [Internal].[fn_Counter_ResponseProcessingTimes]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Internal].[fn_Counter_ResponseProcessingTimes](@LastHandledTimestamp binary(8),
													@MostRecentTimestamp binary(8),
													@CounterDateTime datetime2(3)) returns table
as
return select SPH_StartDate CounterDateTime, RSP_Name InstanceName, datediff(millisecond, SPH_StartDate, SPH_EndDate) Value,
		CAST(null as varchar(100)) ResultStatus, cast(null as int) TRH_ID
		from ResponseProcessing.SubscriptionProcessingHistory
			inner join ResponseProcessing.EventSubscriptions on SPH_ESP_ID = ESP_ID
			inner join ResponseProcessing.ResponseTypes on ESP_RSP_ID = RSP_ID
		where SPH_Timestamp > @LastHandledTimestamp
			and SPH_Timestamp <= @MostRecentTimestamp
			and SPH_ErrorMessage is null
GO
