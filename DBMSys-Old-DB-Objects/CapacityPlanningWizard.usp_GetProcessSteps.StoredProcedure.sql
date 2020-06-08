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
/****** Object:  StoredProcedure [CapacityPlanningWizard].[usp_GetProcessSteps]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [CapacityPlanningWizard].[usp_GetProcessSteps]
as
set nocount on

if object_id('tempdb..#RunningProcesses') is not null
	drop table #RunningProcesses
create table #RunningProcesses
(
	session_id	int
	,PSP_ID		int
)

insert into #RunningProcesses
select * from CapacityPlanningWizard.fn_GetRunningProcesses()


if not exists (select *	from #RunningProcesses) and exists (select top 20 * from CapacityPlanningWizard.ProcessStepsRunHistory h where PRH_EndDate is null order by PRH_StartDate desc)
BEGIN
	WAITFOR DELAY '00:00:05'

	insert into #RunningProcesses
	select * from CapacityPlanningWizard.fn_GetRunningProcesses()

	if not exists (select *	from #RunningProcesses)
	BEGIN
		WAITFOR DELAY '00:00:05'			

		insert into #RunningProcesses
		select * from CapacityPlanningWizard.fn_GetRunningProcesses()
	END
END

update h
set PRH_EndDate = PRH_StartDate,
	PRH_ErrorMessage = 'Interrupted'
from CapacityPlanningWizard.ProcessStepsRunHistory h
where PRH_EndDate is null
	and not exists (select *
						from #RunningProcesses--CapacityPlanningWizard.fn_GetRunningProcesses()
						where PSP_ID = PRH_PSP_ID)

select PSP_ID [Step ID], PSP_Ordinal [Ordinal], PSP_Name [Step Name],
	case when PRH_StartDate is null then 'Never ran'
			when PRH_EndDate is null then 'In progress'
			when PRH_ErrorMessage is not null then 'Error [' + PRH_ErrorMessage + ']'
			else concat('Completed at ', convert(char(19), PRH_EndDate, 121))
		end [Status]
		,PRH_EndDate
from CapacityPlanningWizard.ProcessSteps
	outer apply (select top 1 PRH_StartDate, PRH_EndDate, PRH_ErrorMessage
					from CapacityPlanningWizard.ProcessStepsRunHistory
					where PRH_PSP_ID = PSP_ID
					order by PRH_ID desc) h
where PSP_IsActive = 1
order by [Ordinal]
GO
