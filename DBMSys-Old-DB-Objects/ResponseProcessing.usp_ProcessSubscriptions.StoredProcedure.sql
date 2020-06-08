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
/****** Object:  StoredProcedure [ResponseProcessing].[usp_ProcessSubscriptions]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ResponseProcessing].[usp_ProcessSubscriptions]
as
set nocount on
declare @ClientID int,
		@ESP_ID int,
		@LastHandledTimestamp binary(8),
		@LastTimestamp binary(8),
		@handle uniqueidentifier,
		@Message xml,
		@LRP_ID int,
		@ErrorMessage nvarchar(2000),
		@Info xml

delete ResponseProcessing.LaunchedResponseProcessing
where LRP_LRS_ID = 1
	and LRP_LaunchDate <= dateadd(second, -60, SYSDATETIME())
	and (select COUNT(*)
			from ResponseProcessing.EventSubscriptions
				inner join sys.dm_exec_requests on context_info = cast(ESP_ID as binary(4))
			) < (select cast(SET_Value as int)
					from Management.Settings
					where SET_Module = 'Response Processing'
						and SET_Key = 'Max Simultaneous Subscription Processes'
				)

update ResponseProcessing.LaunchedResponseProcessing
set LRP_LRS_ID = 4
where LRP_LRS_ID = 2
	and not exists (select *
					from sys.dm_exec_requests
					where context_info = cast(LRP_ESP_ID as binary(4))
					)

declare cSubscriptions cursor static forward_only for
	select ESP_ClientID, ESP_ID, SPH_LastHandledTimestamp, LastTimestamp
	from ResponseProcessing.EventSubscriptions
		outer apply (select top 1 SPH_StartDate, SPH_LastHandledTimestamp
						from ResponseProcessing.SubscriptionProcessingHistory
						where SPH_ESP_ID = ESP_ID
							and SPH_LastHandledTimestamp is not null
						order by SPH_ID desc) s
		cross apply (select top 1 TRE_Timestamp LastTimestamp
						from EventProcessing.TrappedEvents
						where TRE_MOV_ID = ESP_MOV_ID
							and (TRE_Timestamp > SPH_LastHandledTimestamp
									or SPH_LastHandledTimestamp is null)
							and (TRE_MOB_ID = ESP_MOB_ID
									or ESP_MOB_ID is null)
							and (TRE_EventInstanceName = ESP_EventInstanceName
									or ESP_EventInstanceName is null)
						order by TRE_Timestamp desc) t
	where ESP_IsActive = 1
		and (ESP_ProcessingInterval < datediff(minute, SPH_StartDate, sysdatetime())
				or SPH_StartDate is null)
		and not exists (select *
							from ResponseProcessing.LaunchedResponseProcessing
							where LRP_ESP_ID = ESP_ID
								and LRP_LRS_ID < 3)
	order by ESP_Priority

begin dialog conversation @handle
	from service srvRunResponseSend
	to service 'srvRunResponseReceive'
	on contract conRunResponse
	with encryption = off,
		lifetime = 3600

open cSubscriptions
fetch next from cSubscriptions into @ClientID, @ESP_ID, @LastHandledTimestamp, @LastTimestamp
while @@fetch_status = 0
begin
	begin try
		begin transaction
			insert into ResponseProcessing.LaunchedResponseProcessing(LRP_ClientID, LRP_ESP_ID, LRP_FromTimestamp, LRP_ToTimestamp, LRP_LRS_ID, LRP_LaunchDate)
			values(@ClientID, @ESP_ID, @LastHandledTimestamp, @LastTimestamp, 1, SYSDATETIME())

			set @LRP_ID = SCOPE_IDENTITY()

			select @Message = (select @LRP_ID LaunchedSubscriptionID for xml path(''))

			;send on conversation @handle
				message type msgRunResponse(@Message)
			
		commit transaction
	end try
	begin catch
		set @ErrorMessage = ERROR_MESSAGE()
		if @@TRANCOUNT > 0
			rollback
		set @Info = (select 'Subscription Processing Launcher' [@Process], @ESP_ID [@ESP_ID] for xml path('Info'))
		exec Internal.usp_LogError @Info, @ErrorMessage
	end catch
	fetch next from cSubscriptions into @ClientID, @ESP_ID, @LastHandledTimestamp, @LastTimestamp
end
close cSubscriptions
deallocate cSubscriptions

select @Message = (select null LaunchedSubscriptionID for xml path(''))
;send on conversation @handle
	message type msgRunResponse(@Message)

end conversation @handle
GO
