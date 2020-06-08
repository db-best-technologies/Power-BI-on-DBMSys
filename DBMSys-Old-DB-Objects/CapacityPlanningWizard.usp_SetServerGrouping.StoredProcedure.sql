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
/****** Object:  StoredProcedure [CapacityPlanningWizard].[usp_SetServerGrouping]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [CapacityPlanningWizard].[usp_SetServerGrouping]
	@ServerGroups CapacityPlanningWizard.ServerGroups readonly
as
set nocount on

truncate table Consolidation.ConsolidationGroups
truncate table Consolidation.ServerGrouping

truncate table Consolidation.ConsolidationGroups_CloudRegions
truncate table Consolidation.ServerPossibleHostTypes

insert into Consolidation.ConsolidationGroups(CGR_ID, CGR_Name)
select row_number() over(order by GroupName), GroupName
from (select distinct GroupName
		from @ServerGroups) g

insert into Consolidation.ServerGrouping(SGR_MOB_ID, SGR_CGR_ID)
select MOB_ID, CGR_ID
from @ServerGroups
	inner join Inventory.MonitoredObjects on MOB_Name = ServerName
	inner join Consolidation.ConsolidationGroups on CGR_Name = GroupName
where exists (select *
				from Management.PlatformTypes
				where PLT_ID = MOB_PLT_ID
					and PLT_PLC_ID = 2)
	and exists (select *
				from Consolidation.ParticipatingDatabaseServers
				where PDS_Server_MOB_ID = MOB_ID)

delete from Consolidation.ConsolidationGroups 
where not exists(select * from Consolidation.ServerGrouping where SGR_CGR_ID = CGR_ID)
GO
