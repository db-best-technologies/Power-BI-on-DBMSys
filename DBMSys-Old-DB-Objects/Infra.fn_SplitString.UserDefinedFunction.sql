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
/****** Object:  UserDefinedFunction [Infra].[fn_SplitString]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Infra].[fn_SplitString](@Str nvarchar(max),
									@Delimiter varchar(10) = ';') returns table
return select row_number() over (order by num) Id,
			substring(@Str, num, charindex(@Delimiter, @Str + @Delimiter, num) - num) Val
		from Infra.Numbers
		where num <= len(@Str) and substring(@Delimiter + @Str, num, len(@Delimiter)) = @Delimiter
GO
