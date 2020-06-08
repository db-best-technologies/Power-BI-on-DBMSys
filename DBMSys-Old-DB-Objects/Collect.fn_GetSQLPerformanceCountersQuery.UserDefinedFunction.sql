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
/****** Object:  UserDefinedFunction [Collect].[fn_GetSQLPerformanceCountersQuery]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [Collect].[fn_GetSQLPerformanceCountersQuery](@TST_ID int) returns nvarchar(max)
begin
	declare @Command nvarchar(max)
	set @Command =
			(select ';insert into @PerformanceCounters values(''' + PEC_CategoryName + ''', ''' + PEC_CounterName + ''')'
			from PerformanceData.PerformanceCounters 
			where PEC_TST_ID = @TST_ID
			for xml path(''))
	return @Command
end
GO
