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
/****** Object:  UserDefinedFunction [dbo].[get_cpu_caption]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[get_cpu_caption](@value nvarchar(max)) returns nvarchar(max) as
begin
    declare @caption nvarchar(max) = @value;
    select @caption = replace(@caption, nchar(0174), '(R)')
    select @caption = replace(@caption, '(R)',  ' ')
    select @caption = replace(@caption, '(TM)', ' ')
    select @caption = replace(@caption, 'CPU', '')
    select @caption = replace(@caption, 'APU', '')
    select @caption = replace(@caption, 'Processor', '')
    select @caption = replace(replace(@caption, 'Dual-Core', ''), 'Dual Core', '')
    select @caption = replace(replace(@caption, 'Quad-Core', ''), 'Quad Core', '')
    select @caption = replace(replace(@caption, 'Six-Core', ''), 'Six Core', '')
    select @caption = replace(replace(@caption, 'Eight-Core', ''), 'Eight Core', '')
    select @caption = replace(@caption, 'Extreme', '')
    select @caption = rtrim(left(@caption, patindex('%@%', @caption) - 1)) where patindex('%@%', @caption) > 0
    select @caption = rtrim(left(@caption, patindex('% 0', @caption) - 1)) where patindex('% 0', @caption) > 0
    select @caption = replace(replace(replace(@caption, ' ', '<>'), '><', ''), '<>', ' ')
    select @caption = rtrim(ltrim(@caption))
    select @caption = 'Intel Xeon E3-1230' where @caption = 'Intel Xeon E31230'
    select @caption = replace(@caption, 'Intel ', '')
    return @caption
end
GO
