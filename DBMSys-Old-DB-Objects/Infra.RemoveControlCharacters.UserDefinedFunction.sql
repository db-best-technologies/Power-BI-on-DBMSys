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
/****** Object:  UserDefinedFunction [Infra].[RemoveControlCharacters]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Infra].[RemoveControlCharacters](@InputString nvarchar(max)) returns table
as return select replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
				replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(case when @InputString <> ''
																											then iif(right(@InputString, 1) = char(0), left(@InputString, len(@InputString) - 1), @InputString)
																											else ''
																										end
				, char(1), ''), char(2), ''), char(3), ''), char(4), ''), char(5), ''), char(6), ''), char(7), ''), char(8), ''), char(11), '')
				, char(12), ''), char(14), ''), char(15), ''), char(16), ''), char(17), ''), char(18), ''), char(19), ''), char(20), ''), char(21), ''), char(22), '')
				, char(23), ''), char(24), ''), char(25), ''), char(26), ''), char(27), ''), char(28), ''), char(29), ''), char(30), ''), char(31), '') Val
GO
