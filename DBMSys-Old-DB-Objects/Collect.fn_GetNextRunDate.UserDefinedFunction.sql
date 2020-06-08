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
/****** Object:  UserDefinedFunction [Collect].[fn_GetNextRunDate]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Collect].[fn_GetNextRunDate](
	@IntervalType char(1),
	@IntervalPeriod int,
	@LastRun datetime2(3))
returns table
as
return with
	LastRun as (
		select isnull(@LastRun, sysdatetime()) LastRunDate),
	NextRunCalc as (
		select
			LastRunDate,
			case @IntervalType
				when 's' then dateadd(second, @IntervalPeriod, LastRunDate)
				when 'm' then dateadd(minute, @IntervalPeriod, LastRunDate)
				when 'h' then dateadd(hour, @IntervalPeriod, LastRunDate)
				when 'd' then dateadd(day, @IntervalPeriod, LastRunDate)
			end NextRunDate
		from LastRun)
	select LastRunDate, NextRunDate
	from NextRunCalc
GO
