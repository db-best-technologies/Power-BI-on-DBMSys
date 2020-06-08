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
/****** Object:  StoredProcedure [CapacityPlanningWizard].[usp_RunProcessSteps]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [CapacityPlanningWizard].[usp_RunProcessSteps]
	@LSP_ID int
as
set nocount on

declare @StepID int,
		@ProcedureName nvarchar(257),
		@SQL nvarchar(max),
		@PRH_ID int,
		@ErrorMessage nvarchar(2000)

set @SQL =
	(select concat('kill ', session_id, ';')
		from CapacityPlanningWizard.fn_GetRunningProcesses()
		for xml path('')
	)
if @SQL is not null
	exec(@SQL)

declare cSteps cursor static forward_only for
	select PSP_ID, PSP_ProcedureName
	from CapacityPlanningWizard.LaunchedStepProcessingRequests
		cross apply Infra.fn_SplitString(LSP_StepList, ',') f
		inner join CapacityPlanningWizard.ProcessSteps on PSP_ID = cast(Val as int)
	where LSP_ID = @LSP_ID
	order by PSP_Ordinal

open cSteps
fetch next from cSteps into @StepID, @ProcedureName
while @@FETCH_STATUS = 0 and @ErrorMessage is null
begin
	set @SQL = 'exec ' + @ProcedureName
	insert into CapacityPlanningWizard.ProcessStepsRunHistory(PRH_PSP_ID, PRH_StartDate)
	values(@StepID, sysdatetime())

	set @PRH_ID = SCOPE_IDENTITY()

	begin try
		exec(@SQL)
	end try
	begin catch
		set @ErrorMessage = ERROR_MESSAGE()
	end catch

	update CapacityPlanningWizard.ProcessStepsRunHistory
	set PRH_EndDate = sysdatetime(),
		PRH_ErrorMessage = @ErrorMessage
	where PRH_ID = @PRH_ID

	fetch next from cSteps into @StepID, @ProcedureName
end
close cSteps
deallocate cSteps
GO
