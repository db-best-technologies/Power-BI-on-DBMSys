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
/****** Object:  StoredProcedure [CapacityPlanningWizard].[usp_GetServerListForAzureCalculator]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [CapacityPlanningWizard].[usp_GetServerListForAzureCalculator]
as
set nocount on
truncate table DTUCalculator.TextData
truncate table DTUCalculator.PieChart
truncate table DTUCalculator.DTUGraph

select distinct PDS_Server_MOB_ID MOB_ID, Cores
from Consolidation.ParticipatingDatabaseServers
	cross apply (select sum(coalesce(PRS_NumberOfLogicalProcessors, PRS_NumberOfCores, 1)) Cores
			from Inventory.Processors
			where PRS_MOB_ID = PDS_Server_MOB_ID) p
where Cores is not null
	and exists (select *
					from Inventory.MonitoredObjects
					where MOB_ID = PDS_Database_MOB_ID
						and MOB_PLT_ID = 1)
GO
