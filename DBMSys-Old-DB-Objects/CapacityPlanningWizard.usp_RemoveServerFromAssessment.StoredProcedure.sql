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
/****** Object:  StoredProcedure [CapacityPlanningWizard].[usp_RemoveServerFromAssessment]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [CapacityPlanningWizard].[usp_RemoveServerFromAssessment]
	@MOB_ID int
as
set nocount on
merge Consolidation.RemovedFromAssessment d
	using (select @MOB_ID MOB_ID) s
		on MOB_ID = RFA_MOB_ID
	when not matched then insert(RFA_MOB_ID)
							values(@MOB_ID);
GO
