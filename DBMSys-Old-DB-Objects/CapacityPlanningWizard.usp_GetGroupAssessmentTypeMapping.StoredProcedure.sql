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
/****** Object:  StoredProcedure [CapacityPlanningWizard].[usp_GetGroupAssessmentTypeMapping]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [CapacityPlanningWizard].[usp_GetGroupAssessmentTypeMapping]
as
set nocount on
declare @SQL nvarchar(max)

if object_id('tempdb..#Assignments') is not null
	drop table #Assignments

select CGR_ID GroupID, CGR_Name GroupName,
	(select distinct SHT_HST_ID AssignmentID
		from (select *
				from Consolidation.ServerGrouping
					inner join Consolidation.ServerPossibleHostTypes on SHT_MOB_ID = SGR_MOB_ID) Assignment
		where SGR_CGR_ID = CGR_ID
		for xml auto, root('Assignments'), type) Assignments
from Consolidation.ConsolidationGroups
order by GroupName
GO
