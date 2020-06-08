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
/****** Object:  StoredProcedure [CapacityPlanningWizard].[usp_RunProcessesWrapper]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [CapacityPlanningWizard].[usp_RunProcessesWrapper]
as
set nocount on
declare @handle uniqueidentifier,
		@Body xml,
		@MessageType nvarchar(128),
		@LSP_ID int,
		@ContextInfo binary(4),
		@ClientID int,
		@PackageID int
		
;receive top (1) @handle = conversation_handle,
				@Body = cast(message_body as xml),
				@MessageType = message_type_name
from qRunProcessesReceive

if @handle is not null
begin
	if @MessageType <> 'msgRunProcesses' return
	
	set @LSP_ID = @Body.value('LaunchedStepProcessingRequestID[1]', 'int')

	end conversation @handle with cleanup	
	
	if @LSP_ID is not null
	begin
		update CapacityPlanningWizard.LaunchedStepProcessingRequests
		set LSP_InterceptionDate = SYSDATETIME()
		where LSP_ID = @LSP_ID

		exec CapacityPlanningWizard.usp_RunProcessSteps @LSP_ID

		update CapacityPlanningWizard.LaunchedStepProcessingRequests
		set LSP_ProcessingEndDate = SYSDATETIME()
		where LSP_ID = @LSP_ID
	end
end
GO
