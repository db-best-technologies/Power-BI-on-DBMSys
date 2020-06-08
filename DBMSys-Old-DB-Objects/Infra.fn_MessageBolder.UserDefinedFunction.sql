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
/****** Object:  UserDefinedFunction [Infra].[fn_MessageBolder]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Infra].[fn_MessageBolder](@Message nvarchar(max)) returns table
as
return select stuff(replace(replace(replace(replace(
					(select char(13)+char(10) +
							case when Val like '%: %' and Id > 1
									then '<b>' + left(Val, charindex(': ', Val, 1)) + '</b>' + substring(Val, charindex(': ', Val, 1) + 1, LEN(Val))
								when Id = 1 then '<b>' + Val + '</b>'
								else Val
							end
					from infra.fn_SplitString(@Message, char(13)+char(10)) t
					where Id > 1 or ltrim(rtrim(Val)) <> char(13)
					for xml path(''))
					, '&lt;', '<'), '&gt;', '>'), '&amp;', '&'), '&#x0D;', char(13)), 1, 2, '') BoldMessage
GO
