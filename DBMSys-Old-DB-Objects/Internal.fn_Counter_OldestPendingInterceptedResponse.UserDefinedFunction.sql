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
/****** Object:  UserDefinedFunction [Internal].[fn_Counter_OldestPendingInterceptedResponse]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Internal].[fn_Counter_OldestPendingInterceptedResponse](@LastHandledTimestamp binary(8),
																	@MostRecentTimestamp binary(8),
																	@CounterDateTime datetime2(3)) returns table
as
return select SYSDATETIME() CounterDateTime, CAST(null as varchar(900)) InstanceName, MIN(datediff(second, LRP_InterceptionDate, sysdatetime())) Value,
		CAST(null as varchar(100)) ResultStatus, cast(null as int) TRH_ID
		from ResponseProcessing.LaunchedResponseProcessing
		where LRP_LRS_ID = 2
		having COUNT(*) > 0
GO
