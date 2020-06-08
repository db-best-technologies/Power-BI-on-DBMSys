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
/****** Object:  StoredProcedure [Reports].[usp_FinancialAnalysisAssessmentScenariosFacts]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Reports].[usp_FinancialAnalysisAssessmentScenariosFacts]
as
set nocount on

;with AssessedScenarios as
		(select 0 HST_ID
			union all
			select distinct CLB_HST_ID HST_ID
			from Consolidation.ConsolidationBlocks
			union all
			select top 1 10 HST_ID
			from Consolidation.SingleDatabaseCloudLocations
		)
	, Facts as
		(select case HST_ID
						when 0 then 1
						when 5 then 2
						when 3 then 3
						when 10 then 4
						when 1 then 5
						when 2 then 5
						when 4 then 6
					end FactOrdinal,
				case HST_ID
						when 0 then 'Current state'
						when 5 then 'Move existing on premises servers to Azure VM’s without incorporating consolidation'
						when 3 then 'Move existing on premises servers to consolidated Azure VMs'
						when 10 then 'Move existing on premises databases to Azure SQL Databases (PaaS)'
						when 1 then 'Consolidate existing on premises servers on existing on premises servers'
						when 2 then 'Consolidate existing on premises servers on existing on premises servers'
						when 4 then 'Virtualize existing on premises servers onto new hosts on premises'
					end Scenario
			from AssessedScenarios
		)
select concat('Scenario ', row_number() over(order by FactOrdinal), ': ', Scenario) Fact
from Facts
order by FactOrdinal
GO
