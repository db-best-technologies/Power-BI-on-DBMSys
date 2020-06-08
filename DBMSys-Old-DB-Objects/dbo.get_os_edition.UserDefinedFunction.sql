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
/****** Object:  UserDefinedFunction [dbo].[get_os_edition]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[get_os_edition](@value nvarchar(max)) returns nvarchar(max) as
begin
declare @caption nvarchar(max) = (select dbo.get_os_caption(@value));
return case
    when @caption like 'Windows Server%Standard'        then 'Standard'
    when @caption like 'Windows Server%Enterprise'      then 'Enterprise'
    when @caption like 'Windows Server%Datacenter'      then 'Datacenter'
    when @caption like 'Windows Server%Web'             then 'Web'
    when @caption like 'Windows Server%Essentials'      then 'Essentials'
    when @caption like 'Windows 2000 Server'            then 'Standard'
    when @caption like 'Windows 2000 Advanced Server'   then 'Advanced'
    when @caption like 'Windows 2000 Datacenter Server' then 'Datacenter'
    when @caption like 'Windows%Enterprise%'            then 'Enterprise'
    when @caption like 'Windows%Professional%'          then 'Professional'
    when @caption like 'Windows%Home%'                  then 'Home'
    else @caption end
end
GO
