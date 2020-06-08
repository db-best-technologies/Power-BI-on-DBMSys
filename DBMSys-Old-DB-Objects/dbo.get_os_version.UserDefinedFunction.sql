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
/****** Object:  UserDefinedFunction [dbo].[get_os_version]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[get_os_version](@value nvarchar(max)) returns nvarchar(max) as
begin
declare @caption nvarchar(max) = (select dbo.get_os_caption(@value));
return case
    when @caption like '%Windows %2016%'    then '2016'
    when @caption like '%Windows %2012 R2%' then '2012 R2'
    when @caption like '%Windows %2012%'    then '2012'
    when @caption like '%Windows %2008 R2%' then '2008 R2'
    when @caption like '%Windows %2008%'    then '2008'
    when @caption like '%Windows %2003 R2%' then '2003 R2'
    when @caption like '%Windows %2003%'    then '2003'
    when @caption like '%Windows %2000%'    then '2000'
    when @caption like '%Windows 10%'       then '10'
    when @caption like '%Windows 8%'        then '8'
    when @caption like '%Windows 7%'        then '7'
    when @caption like '%Windows Vista%'    then 'Vista'
    when @caption like '%Windows XP'        then 'XP'
    else @caption end
end
GO
