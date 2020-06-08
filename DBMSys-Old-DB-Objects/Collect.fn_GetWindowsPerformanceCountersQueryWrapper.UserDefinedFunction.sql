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
/****** Object:  UserDefinedFunction [Collect].[fn_GetWindowsPerformanceCountersQueryWrapper]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [Collect].[fn_GetWindowsPerformanceCountersQueryWrapper](@TST_ID int,
																	@MOB_ID int,
																	@Command nvarchar(max)) returns nvarchar(max)
begin
	declare @OutputCommand nvarchar(max),
			@CustomInstances Collect.ttInstanceList
	set @OutputCommand = Collect.fn_GetWindowsPerformanceCountersQuery(@TST_ID, @CustomInstances)
	return @OutputCommand
end
GO
