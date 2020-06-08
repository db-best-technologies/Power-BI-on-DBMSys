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
/****** Object:  StoredProcedure [CapacityPlanningWizard].[usp_LaunchStepProcessing]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [CapacityPlanningWizard].[usp_LaunchStepProcessing]
	@ProcessSteps CapacityPlanningWizard.RunProcessSteps readonly
as
set nocount on
declare	@ClientID int,
		@handle uniqueidentifier,
		@Message xml,
		@LSP_ID int,
		@SQL nvarchar(max)

if not exists (select * from CapacityPlanningWizard.LaunchedStepProcessingRequests where LSP_LaunchDate > dateadd(minute, -10, sysdatetime()))
begin
	set @SQL = concat('ALTER DATABASE ', quotename(db_name()), ' SET TRUSTWORTHY ON', char(13), char(10),
						'ALTER AUTHORIZATION ON DATABASE::', quotename(db_name()), ' TO sa', char(13), char(10),
						'ALTER DATABASE ', quotename(db_name()), ' SET NEW_BROKER WITH ROLLBACK IMMEDIATE')
	exec(@SQL)
end

select @ClientID = cast(SET_Value as int)
from Management.Settings
where SET_Module = 'Management'
	and SET_Key = 'Client ID'

insert into CapacityPlanningWizard.LaunchedStepProcessingRequests(LSP_ClientID, LSP_StepList)
select @ClientID, stuff((select concat(',', StepID)
							from @ProcessSteps
							order by StepID
							for xml path('')), 1, 1, '')
set @LSP_ID = SCOPE_IDENTITY()

begin dialog conversation @handle
from service srvRunProcessesSend
to service 'srvRunProcessesReceive'
on contract conRunProcesses
with encryption = off,
	lifetime = 3600

select @Message = (select @LSP_ID LaunchedStepProcessingRequestID for xml path(''))

begin try
	begin tran

	update CapacityPlanningWizard.LaunchedStepProcessingRequests
	set LSP_LaunchDate = SYSDATETIME()
	where LSP_ID = @LSP_ID

	;send on conversation @handle
		message type msgRunProcesses(@Message)

	commit tran
end try
begin catch
	if @@TRANCOUNT > 0
		rollback;
	throw;
end catch
	
end conversation @handle
GO
