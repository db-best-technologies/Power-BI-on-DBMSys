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
/****** Object:  StoredProcedure [Reports].[usp_CounterGraph_Dict_Servers]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_CounterGraph_Dict_Servers]
as
set nocount on
;with Srvs as
	(select MOB_ID, MOB_Name, PLT_Name
		from Inventory.MonitoredObjects
			inner join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
	union all
	select 0, 'Internal', cast(null as varchar(100))
	)
select MOB_ID ServerID, MOB_Name + isnull(' (' + PLT_Name + ')', '') ServerName
from Srvs
order by PLT_Name, MOB_Name
GO
