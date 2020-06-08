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
/****** Object:  StoredProcedure [Collect].[usp_TestRunWrapper]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collect].[usp_TestRunWrapper]
as
set nocount on
declare @handle uniqueidentifier,
		@Body xml,
		@MessageType nvarchar(128),
		@SCT_ID int,
		@ContextInfo binary(4)

;receive top (1) @handle = conversation_handle,
				@Body = cast(message_body as xml),
				@MessageType = message_type_name
FROM qRunScheduledTestReceive

if @handle is not null
begin
	if @MessageType <> 'msgRunScheduledTest' return
	
	set @SCT_ID = @Body.value('ScheduleID[1]', 'int')
	
	if @SCT_ID is not null
	begin
		set @ContextInfo = cast(@SCT_ID as binary(4))
		set context_info @ContextInfo

		exec Collect.usp_RunSingleTest @SCT_ID = @SCT_ID
		
		set context_info 0x0
	end
	else
		end conversation @handle with cleanup	
end
GO
