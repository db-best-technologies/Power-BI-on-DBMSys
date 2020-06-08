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
/****** Object:  UserDefinedFunction [dbo].[get_os_release]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[get_os_release](@value nvarchar(max)) returns nvarchar(max) as
begin
declare @caption nvarchar(max) = (select dbo.get_os_caption(@value));
return case
    when @caption is null                   then 'RTM'
    when @caption like '%Service Pack 1%'   then 'SP1'
    when @caption like '%Service Pack 2%'   then 'SP2'
    when @caption like '%Service Pack 3%'   then 'SP3'
    when @caption like '%Service Pack 4%'   then 'SP4'
    else @caption end
end
GO
