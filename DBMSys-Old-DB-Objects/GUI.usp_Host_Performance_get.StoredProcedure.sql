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
/****** Object:  StoredProcedure [GUI].[usp_Host_Performance_get]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUI].[usp_Host_Performance_get]
--declare 
		@MOB_ID		int = null

as
set nocount on;
select 
		STO_MOB_ID
		,STO_TST_ID
from	Collect.SpecificTestObjects
join	Inventory.MonitoredObjects on MOB_ID = STO_MOB_ID
join	Management.ObjectOperationalStatuses on MOB_OOS_ID = OOS_ID and (OOS_IsOperational = 1 or OOS_ID = 6)
where	STO_MOB_ID = ISNULL(@MOB_ID,STO_MOB_ID)
		and STO_IsActive = 1
GO
