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
/****** Object:  StoredProcedure [CapacityPlanningWizard].[usp_SetAssessmentTypes]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [CapacityPlanningWizard].[usp_SetAssessmentTypes]
	@GroupAssignment CapacityPlanningWizard.GroupAssignment readonly
as
set nocount on

truncate table Consolidation.ServerPossibleHostTypes

insert into Consolidation.ServerPossibleHostTypes
select SGR_MOB_ID, AssignmentID, HST_ExclusivityGroupID
from @GroupAssignment
	inner join Consolidation.ServerGrouping on SGR_CGR_ID = GroupID
	inner join Consolidation.HostTypes on HST_ID = AssignmentID

IF EXISTS (SELECT * FROM Consolidation.ServerPossibleHostTypes JOIN Consolidation.HostTypes ON HST_ID = SHT_HST_ID WHERE HST_IsCloud = 1)
	EXEC Consolidation.usp_UpdateAllCloudPricing
GO
