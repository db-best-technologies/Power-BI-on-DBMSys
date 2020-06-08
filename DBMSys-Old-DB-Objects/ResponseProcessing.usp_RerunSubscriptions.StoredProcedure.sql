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
/****** Object:  StoredProcedure [ResponseProcessing].[usp_RerunSubscriptions]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ResponseProcessing].[usp_RerunSubscriptions]
as
declare @SPH_ID int,
		@ReRunEvents ResponseProcessing.ttResponseEvents,
		@ErrorMessage nvarchar(max),
		@ClientID int,
		@ESP_ID int,
		@RerunMaxNumberOfTimes int,
		@RespondOnceForMultipleIdenticalEvents bit,
		@RGT_ID tinyint,
		@ProcedureName nvarchar(257),
		@Parameters xml,
		@Last_SPH_ID int

declare cSubscriptions cursor static forward_only for		
	select ESP_ClientID, ESP_ID, ESP_RerunMaxNumberOfTimes, ESP_RGT_ID, ESP_RespondOnceForMultipleIdenticalEvents,
		RSP_ProcedureName, ESP_Parameters, Last_SPH_ID
	from ResponseProcessing.EventSubscriptions
		inner join ResponseProcessing.ResponseTypes on ESP_RSP_ID = RSP_ID
		cross apply (select top 1 SPH_ID Last_SPH_ID, SPH_StartDate
						from ResponseProcessing.SubscriptionProcessingHistory
						where SPH_ESP_ID = ESP_ID
							and SPH_EndDate is not null
							and SPH_ErrorMessage is null
						order by SPH_ID desc) SPH
	where ESP_IsActive = 1
		and ESP_RerunEveryXSeconds < DATEDIFF(second, SPH_StartDate, GETDATE())
	order by ESP_Priority

open cSubscriptions

fetch next from cSubscriptions into @ClientID, @ESP_ID, @RerunMaxNumberOfTimes, @RespondOnceForMultipleIdenticalEvents,
									@RGT_ID, @ProcedureName, @Parameters, @Last_SPH_ID
while @@fetch_status = 0
begin
	;With RerunEvents as
			(select TRE_ID, MOV_Description, TRE_ClientID, TRE_IsClosed, TRE_MOB_ID, TRE_EventInstanceName, TRE_OpenDate, TRE_CloseDate,
						TRE_AlertMessage EventMessage,
									(select CAST(ed as xml)
										from (select TRE_AlertEventData ed
												where TRE_AlertEventData is not null
												) e
										for xml path(''), root('EventData'), type) AllEventData,
									ROW_NUMBER() over (partition by TRE_MOB_ID, TRE_EventInstanceName order by TRE_Timestamp desc) RowNum,
									SPD_RunCount, TRE_Timestamp
				from ResponseProcessing.SubscriptionProcessingHistoryDetailed
					inner join EventProcessing.TrappedEvents on TRE_ID = SPD_TRE_ID
					inner join EventProcessing.MonitoredEvents on MOV_ID = TRE_MOV_ID
				where SPD_SPH_ID = @Last_SPH_ID
					and (SPD_RunCount < @RerunMaxNumberOfTimes
								or @RerunMaxNumberOfTimes is null)
					and TRE_IsClosed = 0
			)
	insert into @ReRunEvents(TRE_ID, EventDescription, ClientID, IsClosed, MOB_ID, EventInstanceName, OpenDate, CloseDate, EventMessage,
							AllEventData, TimesProcessed, EventTimestamp)
	select TRE_ID, MOV_Description, TRE_ClientID, TRE_IsClosed, TRE_MOB_ID, TRE_EventInstanceName, TRE_OpenDate,
			TRE_CloseDate, EventMessage, AllEventData, SPD_RunCount, TRE_Timestamp
	from RerunEvents
	where RowNum = 1
			or @RespondOnceForMultipleIdenticalEvents = 0
	order by TRE_Timestamp

	if @@ROWCOUNT > 0
	begin
		insert into ResponseProcessing.SubscriptionProcessingHistory(SPH_ClientID, SPH_ESP_ID, SPH_IsRerun)
		values(@ClientID, @ESP_ID, 1)
		set @SPH_ID = SCOPE_IDENTITY()

		begin try
			exec ResponseProcessing.usp_RunResponse @SPH_ID = @SPH_ID,
														@ProcedureName = @ProcedureName,
														@Parameters = @Parameters,
														@RGT_ID = @RGT_ID,
														@NewEvents = @ReRunEvents,
														@IsClose = 0,
														@IsRerun = 0

			insert into ResponseProcessing.SubscriptionProcessingHistoryDetailed(SPD_ClientID, SPD_SPH_ID, SPD_TRE_ID, SPD_IsClosed, SPD_RunCount)
			select @ClientID, @SPH_ID, TRE_ID, IsClosed, TimesProcessed + 1
			from @ReRunEvents

			delete @ReRunEvents
		end try
		begin catch
			set @ErrorMessage = ERROR_MESSAGE()
		end catch

		update ResponseProcessing.SubscriptionProcessingHistory
		set SPH_EndDate = sysdatetime(),
			SPH_ErrorMessage = @ErrorMessage
		where SPH_ID = @SPH_ID
	end

	fetch next from cSubscriptions into @ClientID, @ESP_ID, @RerunMaxNumberOfTimes, @RespondOnceForMultipleIdenticalEvents,
										@RGT_ID, @ProcedureName, @Parameters, @Last_SPH_ID
end
close cSubscriptions
deallocate cSubscriptions
GO
