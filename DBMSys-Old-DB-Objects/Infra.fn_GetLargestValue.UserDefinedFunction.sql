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
/****** Object:  UserDefinedFunction [Infra].[fn_GetLargestValue]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Infra].[fn_GetLargestValue](@Value1 int,
											@Value2 int,
											@Value3 int = null,
											@Value4 int = null,
											@Value5 int = null) returns int
as
begin
	declare @MaxValue int
	select @MaxValue = max(Val)
	from (values(@Value1),
				(@Value2),
				(@Value3),
				(@Value4),
				(@Value5)) t(Val)

	return @MaxValue
end
GO
