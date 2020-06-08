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
/****** Object:  StoredProcedure [Reports].[usp_InstallationAgeBreakDownPieChart]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_InstallationAgeBreakDownPieChart]
as
set nocount on

select MOB_ID, isnull(cast(datepart(year, OSS_InstallDate) as varchar(10)), 'N/A') [Caption]
from Inventory.OSServers
       inner join Inventory.MonitoredObjects on MOB_ID = OSS_MOB_ID
where exists (select *
                           from Management.PlatformTypes
                           where PLT_ID = MOB_PLT_ID
                                  and PLT_PLC_ID = 2)
GO
