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
/****** Object:  StoredProcedure [CapacityPlanningWizard].[usp_GetGroupRegionMapping]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [CapacityPlanningWizard].[usp_GetGroupRegionMapping]
as
set nocount on
declare @SQL nvarchar(max)

if object_id('tempdb..#Assignments') is not null
	drop table #Assignments

select CGR_ID GroupID, CGR_Name GroupName, CLV_ID ProviderID, CLV_ShortName ProviderName, CGG_CRG_ID AssignmentID
into #Assignments
from Consolidation.ConsolidationGroups
	cross join (select distinct HST_CLV_ID
					from Consolidation.ServerGrouping
						inner join Consolidation.ServerPossibleHostTypes on SHT_MOB_ID = SHT_MOB_ID
						inner join Consolidation.HostTypes on HST_ID = SHT_HST_ID
					where HST_IsCloud = 1
				) h
	inner join Consolidation.CloudProviders on CLV_ID = HST_CLV_ID
	left join (Consolidation.ConsolidationGroups_CloudRegions
				inner join Consolidation.CloudRegions on CRG_ID = CGG_CRG_ID
														) on CGG_CGR_ID = CGR_ID
															and CRG_CLV_ID = CLV_ID

set @SQL =
'select GroupID, GroupName'
	+ replace((select distinct ', (select top 1 AssignmentID [' + ProviderName + ']
								from #Assignments Assignment
								where Assignment.ProviderName = ''' + ProviderName + '''
									and a.GroupID = Assignment.GroupID) [' + ProviderName + ']'
					from #Assignments
					for xml path('')), '&#x0D;', char(13)) + '
from (select distinct GroupID, GroupName
		from #Assignments) a'
exec(@SQL)
GO
