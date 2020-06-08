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
/****** Object:  UserDefinedFunction [dbo].[get_os_convert]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[get_os_convert](@value float, @from char(2), @to char(2)) returns float as
begin
declare @source float = @value
declare @middle float = case @from
    when 'kb' then @value / power(2, 10)
    when 'mb' then @value / power(2, 20)
    when 'gb' then @value / power(2, 30)
    when 'tb' then @value / power(2, 40)
    else 1 / 0 end
declare @target float = case @to
    when 'kb' then @value * power(2, 10)
    when 'mb' then @value * power(2, 20)
    when 'gb' then @value * power(2, 30)
    when 'tb' then @value * power(2, 40)
    else 1 / 0 end
return @target
end
GO
