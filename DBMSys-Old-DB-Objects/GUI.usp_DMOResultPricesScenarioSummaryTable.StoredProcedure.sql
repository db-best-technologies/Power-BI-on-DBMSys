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
/****** Object:  StoredProcedure [GUI].[usp_DMOResultPricesScenarioSummaryTable]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUI].[usp_DMOResultPricesScenarioSummaryTable]
as
set nocount on

if OBJECT_ID('tempdb..#Summary') is not null
	drop table #Summary

create table #Summary
(
	Scenario	NVARCHAR(100)
	,SQL_Lic	NVARCHAR(30)
	,Oper_cost	NVARCHAR(30)
	,Total		NVARCHAR(30)
	,[Type] int 
)

insert into #Summary
exec Reports.usp_FinancialAnalysisScenarioSummaryTable 1

update h
set PRH_EndDate = PRH_StartDate,
	PRH_ErrorMessage = 'Interrupted'
from CapacityPlanningWizard.ProcessStepsRunHistory h
where PRH_EndDate is null
	and not exists (select *
						from CapacityPlanningWizard.fn_GetRunningProcesses()
						where PSP_ID = PRH_PSP_ID)

select 
		Scenario
		,REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(IIF(Left(SQL_Lic,1)='(','-' + SQL_Lic,SQL_Lic) ,0),'$',''),',',''),'(',''),')','')			as [SQL licenses]
		,REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(IIF(LEFT(Oper_cost,1) = '(','-' + Oper_cost,Oper_cost),0),'$',''),',',''),'(',''),')','')	as [HW/Operational cost]
		,REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(IIF(Left(Total,1)='(','-' +Total , Total),0),'$',''),',',''),'(',''),')','')				as [Total spend]
		,[Type]
		,c.Res as Last_Date
from	#Summary
cross apply GUI.fn_get_scenarios_last([Type])c
GO
