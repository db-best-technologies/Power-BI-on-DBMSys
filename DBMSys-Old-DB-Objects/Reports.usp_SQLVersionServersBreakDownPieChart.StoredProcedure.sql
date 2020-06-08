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
/****** Object:  StoredProcedure [Reports].[usp_SQLVersionServersBreakDownPieChart]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Reports].[usp_SQLVersionServersBreakDownPieChart]
as
set nocount on

select MOB_ID, PLY_Name [Caption]
from Inventory.MonitoredObjects
	inner join Inventory.Versions on VER_ID = MOB_VER_ID
	cross apply (select top 1 *
					from ExternalData.ProductLifeCycles
					where PLY_MinVersionNumber < VER_Number
					order by PLY_MinVersionNumber desc) v
where exists (select *
				from Management.PlatformTypes
				where PLT_ID = MOB_PLT_ID
					and PLT_PLC_ID = 1)
GO
