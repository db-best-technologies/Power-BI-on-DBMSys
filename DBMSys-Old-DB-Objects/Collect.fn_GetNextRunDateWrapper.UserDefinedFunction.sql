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
/****** Object:  UserDefinedFunction [Collect].[fn_GetNextRunDateWrapper]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Collect].[fn_GetNextRunDateWrapper](@IntervalType char(1),
													@IntervalPeriod int,
													@LastRun datetime2(3),
													@RunImmediately bit) returns table
as
return select LastRunDate,
				case when @RunImmediately = 0 or @LastRun is not null
					then case when NextRunDate >= sysdatetime()
								then NextRunDate
								else (select n1.NextRunDate
										from Collect.fn_GetNextRunDate(@IntervalType, @IntervalPeriod, null) n1)
							end
					else cast(sysdatetime() as datetime2(3))
				end NextRunDate
		from Collect.fn_GetNextRunDate(@IntervalType, @IntervalPeriod, @LastRun) n
GO
