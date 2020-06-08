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
/****** Object:  StoredProcedure [CapacityPlanningWizard].[usp_GetParticipatingAndExcludedServers]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [CapacityPlanningWizard].[usp_GetParticipatingAndExcludedServers]
	@ShowExcluded bit = 1,
	@ShowMissingData bit = 1,
	@ShowParticipatingServers bit = 1
as
set nocount on

;with Srv as
		(select MOB_ID ID, MOB_Name [Server Name], EXP_Reason [Exclusion Reason]
			from Consolidation.Exceptions
				inner join Inventory.MonitoredObjects on MOB_ID = EXP_MOB_ID
			where EXP_EXT_ID = 1
				and @ShowMissingData = 1
			union
			select MOB_ID ID, MOB_Name [Server Name], '[Excluded]' [Exclusion Reason]
			from Consolidation.RemovedFromAssessment
				inner join Inventory.MonitoredObjects on MOB_ID = RFA_MOB_ID
			where @ShowExcluded = 1
			union
			select MOB_ID ID, MOB_Name [Server Name], null [Exclusion Reason]
			from Inventory.MonitoredObjects
				inner join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
			where PLT_PLC_ID = 2
				and MOB_OOS_ID < 2
				and not exists (select *
									from Consolidation.Exceptions
									where EXP_EXT_ID = 1
										and EXP_MOB_ID = MOB_ID)
				and not exists (select *
									from Consolidation.RemovedFromAssessment
									where RFA_MOB_ID = MOB_ID)
				and @ShowParticipatingServers = 1
		)
select ID, [Server Name], [Exclusion Reason]
from srv
order by iif([Exclusion Reason] is null, 1, 0), [Exclusion Reason]
GO
