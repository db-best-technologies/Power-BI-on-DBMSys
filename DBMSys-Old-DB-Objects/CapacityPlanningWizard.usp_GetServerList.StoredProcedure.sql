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
/****** Object:  StoredProcedure [CapacityPlanningWizard].[usp_GetServerList]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [CapacityPlanningWizard].[usp_GetServerList]
as
set nocount on
select MOB_ID ID, MOB_Name [Server Name], iif(RFA_MOB_ID is null, 1, 0) [In Assessment]
from Inventory.MonitoredObjects
	left join Consolidation.RemovedFromAssessment on RFA_MOB_ID = MOB_ID
where MOB_PLT_ID = 2
	and MOB_OOS_ID < 2
GO
