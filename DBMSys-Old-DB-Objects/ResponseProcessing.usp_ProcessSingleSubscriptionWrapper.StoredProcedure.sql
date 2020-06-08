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
/****** Object:  StoredProcedure [ResponseProcessing].[usp_ProcessSingleSubscriptionWrapper]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ResponseProcessing].[usp_ProcessSingleSubscriptionWrapper]
as
set nocount on
declare @handle uniqueidentifier,
		@Body xml,
		@MessageType nvarchar(128),
		@LRP_ID int,
		@ContextInfo binary(4),
		@ClientID int,
		@ESP_ID int,
		@FromTimestamp binary(8),
		@ToTimestamp binary(8)
		
;receive top (1) @handle = conversation_handle,
				@Body = cast(message_body as xml),
				@MessageType = message_type_name
from qRunResponseReceive

if @handle is not null
begin
	if @MessageType <> 'msgRunResponse' return
	
	set @LRP_ID = @Body.value('LaunchedSubscriptionID[1]', 'int')
	
	if @LRP_ID is not null
	begin
		update ResponseProcessing.LaunchedResponseProcessing
		set @ClientID = LRP_ClientID,
			@ESP_ID = LRP_ESP_ID,
			@FromTimestamp = LRP_FromTimestamp,
			@ToTimestamp = LRP_ToTimestamp,
			LRP_LRS_ID = 2,
			LRP_InterceptionDate = SYSDATETIME()
		where LRP_ID = @LRP_ID

		set @ContextInfo = cast(@ESP_ID as binary(4))
		set context_info @ContextInfo

		exec ResponseProcessing.usp_ProcessSingleSubscription @ClientID = @ClientID,
																@ESP_ID = @ESP_ID,
																@LastHandledTimestamp = @FromTimestamp,
																@LastTimestamp = @ToTimestamp
		
		update ResponseProcessing.LaunchedResponseProcessing
		set LRP_LRS_ID = 3,
			LRP_CompleteDate = SYSDATETIME()
		where LRP_ID = @LRP_ID

		set context_info 0x0
	end
	else
		end conversation @handle with cleanup	
end
GO
