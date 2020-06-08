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
/****** Object:  UserDefinedFunction [Collect].[fn_CalculateDateOffset]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Collect].[fn_CalculateDateOffset](@IntervalType char(1),
												@Offset int,
												@BaseDate datetime) returns table
as
return 	select case @IntervalType
				when 's' then DATEADD(second, @Offset, @BaseDate)
				when 'm' then DATEADD(minute, @Offset, @BaseDate)
				when 'h' then DATEADD(hour, @Offset, @BaseDate)
				when 'd' then DATEADD(day, @Offset, @BaseDate)
			end CalculatedDate
GO
