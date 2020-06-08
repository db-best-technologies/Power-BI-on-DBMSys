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
/****** Object:  StoredProcedure [Reports].[usp_SQLEditionBreakDownPieChart]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Reports].[usp_SQLEditionBreakDownPieChart]
as
set nocount on

select MOB_ID, left(EDT_Name, charindex(' ', replace(EDT_Name, ':', ' ') + ' ', charindex('Edition', EDT_Name, 1)) - 1)  [Caption]
from Inventory.MonitoredObjects
	inner join Inventory.DatabaseInstanceDetails on DID_DFO_ID = MOB_Entity_ID
	inner join Inventory.Editions on EDT_ID = DID_EDT_ID
where exists (select *
				from Management.PlatformTypes
				where PLT_ID = MOB_PLT_ID
					and PLT_PLC_ID = 1)
GO
