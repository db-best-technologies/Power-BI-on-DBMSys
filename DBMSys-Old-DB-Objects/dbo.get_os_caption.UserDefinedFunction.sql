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
/****** Object:  UserDefinedFunction [dbo].[get_os_caption]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[get_os_caption](@value nvarchar(max)) returns nvarchar(max) as
begin
    declare @caption nvarchar(max) = @value;
    select @caption = replace(@caption, nchar(0x00AE), ''); -- ®
    select @caption = replace(@caption, '(R)',  '');
    select @caption = replace(@caption, '(TM)', '');
    select @caption = replace(@caption, 'x64', '');
    select @caption = replace(@caption, 'Edition', '');
    select @caption = replace(@caption, 'Microsoft', '');
    select @caption = replace(@caption, ',', '');
    select @caption = ltrim(rtrim(@caption))
    return @caption
end
GO
