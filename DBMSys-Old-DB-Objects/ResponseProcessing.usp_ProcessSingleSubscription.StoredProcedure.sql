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
/****** Object:  StoredProcedure [ResponseProcessing].[usp_ProcessSingleSubscription]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ResponseProcessing].[usp_ProcessSingleSubscription]
	@ClientID int,
	@ESP_ID int,
	@LastHandledTimestamp binary(8),
	@LastTimestamp binary(8)
as
set nocount on
declare @MOV_ID int,
	@ProcedureName nvarchar(257),
	@Parameters xml,
	@EST_ID tinyint,
	@IncludeOpenAndShut bit,
	@MOB_ID int,
	@EventInstanceName varchar(850),
	@RGT_ID tinyint,
	@RespondOnceForMultipleIdenticalEvents bit,
	@SPH_ID int,
	@NewEvents ResponseProcessing.ttResponseEvents,
	@ErrorMessage nvarchar(max)

select @MOV_ID = ESP_MOV_ID,
	@ProcedureName = RSP_ProcedureName,
	@Parameters = ESP_Parameters,
	@EST_ID = ESP_EST_ID,
	@IncludeOpenAndShut = ESP_IncludeOpenAndShut,
	@MOB_ID = ESP_MOB_ID,
	@EventInstanceName = ESP_EventInstanceName,
	@RGT_ID = ESP_RGT_ID,
	@RespondOnceForMultipleIdenticalEvents = ESP_RespondOnceForMultipleIdenticalEvents
from ResponseProcessing.EventSubscriptions
	inner join ResponseProcessing.ResponseTypes on ESP_RSP_ID = RSP_ID
where ESP_ID = @ESP_ID

insert into ResponseProcessing.SubscriptionProcessingHistory(SPH_ClientID, SPH_ESP_ID, SPH_IsRerun)
values(@ClientID, @ESP_ID, 0)
set @SPH_ID = SCOPE_IDENTITY()

begin try
	if @EST_ID & 1 = 1
	begin
		;with NewEvents as
			(select TRE_ID, MOV_Description, TRE_ClientID, TRE_IsClosed, TRE_MOB_ID, TRE_EventInstanceName, TRE_OpenDate, TRE_CloseDate,
					case when TRE_IsClosed = 1
						then 'The following event was open and then resolved:' + CHAR(13)+CHAR(10)
						else ''
					end
					+ TRE_AlertMessage
					+ case when TRE_IsClosed = 1
						then CHAR(13)+CHAR(10) + isnull('Resolution Reason: ' + TEC_Name, '')
								+ isnull(CHAR(13)+CHAR(10) + 'Resolution Message: ' + TRE_OKMessage, '')
						else ''
					end EventMessage,
					(select CAST(ed as xml)
						from (select TRE_AlertEventData ed
								where TRE_AlertEventData is not null
								union all
								select TRE_OKEventData
								where TRE_OKEventData is not null
								) e
						for xml path(''), root('EventData'), type) AllEventData,
					ROW_NUMBER() over (partition by TRE_MOB_ID, TRE_EventInstanceName order by TRE_Timestamp desc) RowNum,
					TRE_Timestamp
				from EventProcessing.MonitoredEvents
					inner join EventProcessing.TrappedEvents on TRE_MOV_ID = MOV_ID
					left join EventProcessing.TrappedEventCloseReasons on TRE_TEC_ID = TEC_ID
				where MOV_ID = @MOV_ID
					and MOV_IsActive = 1
					and (TRE_Timestamp > @LastHandledTimestamp
							or @LastHandledTimestamp is null)
					and TRE_Timestamp <= @LastTimestamp
					and (TRE_MOB_ID = @MOB_ID
							or @MOB_ID is null)
					and (TRE_EventInstanceName = @EventInstanceName
							or @EventInstanceName is null)
					and (TRE_IsClosed = 0
							or (@IncludeOpenAndShut = 1
									and not exists (select *
														from ResponseProcessing.SubscriptionProcessingHistoryDetailed
														where SPD_TRE_ID = TRE_ID
													)
								)
						)
			)
		insert into @NewEvents(TRE_ID, EventDescription, ClientID, IsClosed, MOB_ID, EventInstanceName, OpenDate, CloseDate, EventMessage,
								AllEventData, TimesProcessed, EventTimestamp)
		select TRE_ID, MOV_Description, TRE_ClientID, TRE_IsClosed, TRE_MOB_ID, TRE_EventInstanceName, TRE_OpenDate,
				TRE_CloseDate, EventMessage, AllEventData, 0 TimesProcessed, TRE_Timestamp
		from NewEvents
		where RowNum = 1
				or @RespondOnceForMultipleIdenticalEvents = 0
		order by TRE_Timestamp

		if @@ROWCOUNT > 0
		begin
			exec ResponseProcessing.usp_RunResponse @SPH_ID = @SPH_ID,
														@ProcedureName = @ProcedureName,
														@Parameters = @Parameters,
														@RGT_ID = @RGT_ID,
														@NewEvents = @NewEvents,
														@IsClose = 0,
														@IsRerun = 0

			insert into ResponseProcessing.SubscriptionProcessingHistoryDetailed(SPD_ClientID, SPD_SPH_ID, SPD_TRE_ID, SPD_IsClosed, SPD_RunCount)
			select @ClientID, @SPH_ID, TRE_ID, IsClosed, TimesProcessed + 1
			from @NewEvents

			delete @NewEvents
		end
	end

	if @EST_ID & 2 = 2
	begin
		;with NewEvents as
			(select TRE_ID, MOV_Description, TRE_ClientID, TRE_IsClosed, TRE_MOB_ID, TRE_EventInstanceName, TRE_OpenDate, TRE_CloseDate,
					case when TRE_IsClosed = 1
						then 'The following event was open and then resolved:' + CHAR(13)+CHAR(10)
						else ''
					end
					+ TRE_AlertMessage
					+ case when TRE_IsClosed = 1
						then CHAR(13)+CHAR(10) + isnull('Resolution Reason: ' + TEC_Name, '')
								+ isnull(CHAR(13)+CHAR(10) + 'Resolution Message: ' + TRE_OKMessage, '')
						else ''
					end EventMessage,
					(select CAST(ed as xml)
						from (select TRE_AlertEventData ed
								where TRE_AlertEventData is not null
								union all
								select TRE_OKEventData
								where TRE_OKEventData is not null
								) e
						for xml path(''), root('EventData'), type) AllEventData,
					ROW_NUMBER() over (partition by TRE_MOB_ID, TRE_EventInstanceName order by TRE_Timestamp desc) RowNum,
					0 RunCount, TRE_Timestamp
				from EventProcessing.MonitoredEvents
					inner join EventProcessing.TrappedEvents on TRE_MOV_ID = MOV_ID
					inner join EventProcessing.TrappedEventCloseReasons on TRE_TEC_ID = TEC_ID
				where MOV_ID = @MOV_ID
					and MOV_IsActive = 1
					and (TRE_Timestamp > @LastHandledTimestamp
							or @LastHandledTimestamp is null)
					and TRE_Timestamp <= @LastTimestamp
					and (TRE_MOB_ID = @MOB_ID
							or @MOB_ID is null)
					and (TRE_EventInstanceName = @EventInstanceName
							or @EventInstanceName is null)
					and TRE_IsClosed = 1
					and exists (select *
								from ResponseProcessing.SubscriptionProcessingHistoryDetailed
								where TRE_ID = SPD_TRE_ID
									and SPD_IsClosed = 0)
			)
		insert into @NewEvents(TRE_ID, EventDescription, ClientID, IsClosed, MOB_ID, EventInstanceName, OpenDate,
								CloseDate, EventMessage, AllEventData, TimesProcessed, EventTimestamp)
		select TRE_ID, MOV_Description, TRE_ClientID, TRE_IsClosed, TRE_MOB_ID, TRE_EventInstanceName, TRE_OpenDate,
				TRE_CloseDate, EventMessage, AllEventData, RunCount, TRE_Timestamp
		from NewEvents
		where RowNum = 1
				or @RespondOnceForMultipleIdenticalEvents = 0
		order by TRE_Timestamp

		if @@ROWCOUNT > 0
		begin
			exec ResponseProcessing.usp_RunResponse @SPH_ID = @SPH_ID,
													@ProcedureName = @ProcedureName,
													@Parameters = @Parameters,
													@RGT_ID = @RGT_ID,
													@NewEvents = @NewEvents,
													@IsClose = 1,
													@IsRerun = 0

			insert into ResponseProcessing.SubscriptionProcessingHistoryDetailed(SPD_ClientID, SPD_SPH_ID, SPD_TRE_ID, SPD_IsClosed, SPD_RunCount)
			select @ClientID, @SPH_ID, TRE_ID, IsClosed, TimesProcessed + 1
			from @NewEvents
		end
	end

	IF @EST_ID = 0
	BEGIN
		;with NewEvents as
			(select TRE_ID, MOV_Description, TRE_ClientID, TRE_IsClosed, TRE_MOB_ID, TRE_EventInstanceName, TRE_OpenDate, TRE_CloseDate,
					case when TRE_IsClosed = 1
						then 'The following event was open and then resolved:' + CHAR(13)+CHAR(10)
						else ''
					end
					+ TRE_AlertMessage
					+ case when TRE_IsClosed = 1
						then CHAR(13)+CHAR(10) + isnull('Resolution Reason: ' + TEC_Name, '')
								+ isnull(CHAR(13)+CHAR(10) + 'Resolution Message: ' + TRE_OKMessage, '')
						else ''
					end EventMessage,
					(select CAST(ed as xml)
						from (select TRE_AlertEventData ed
								where TRE_AlertEventData is not null
								union all
								select TRE_OKEventData
								where TRE_OKEventData is not null
								) e
						for xml path(''), root('EventData'), type) AllEventData,
					ROW_NUMBER() over (partition by TRE_MOB_ID, TRE_EventInstanceName order by TRE_Timestamp desc) RowNum,
					TRE_Timestamp
				from EventProcessing.MonitoredEvents
					inner join EventProcessing.TrappedEvents on TRE_MOV_ID = MOV_ID
					left join EventProcessing.TrappedEventCloseReasons on TRE_TEC_ID = TEC_ID
				where MOV_ID = @MOV_ID
					and MOV_IsActive = 1
					and (TRE_Timestamp > @LastHandledTimestamp
							or @LastHandledTimestamp is null)
					and TRE_Timestamp <= @LastTimestamp
					and (TRE_MOB_ID = @MOB_ID
							or @MOB_ID is null)
					and (TRE_EventInstanceName = @EventInstanceName
							or @EventInstanceName is null)
					and (TRE_IsClosed = 0
							or (@IncludeOpenAndShut = 1
									and not exists (select *
														from ResponseProcessing.SubscriptionProcessingHistoryDetailed
														where SPD_TRE_ID = TRE_ID
													)
								)
						)
			)
		insert into @NewEvents(TRE_ID, EventDescription, ClientID, IsClosed, MOB_ID, EventInstanceName, OpenDate, CloseDate, EventMessage,
								AllEventData, TimesProcessed, EventTimestamp)
		select TRE_ID, MOV_Description, TRE_ClientID, TRE_IsClosed, TRE_MOB_ID, TRE_EventInstanceName, TRE_OpenDate,
				TRE_CloseDate, EventMessage, AllEventData, 0 TimesProcessed, TRE_Timestamp
		from NewEvents
		where RowNum = 1
				or @RespondOnceForMultipleIdenticalEvents = 0
		order by TRE_Timestamp

		if @@ROWCOUNT > 0
		begin
			exec ResponseProcessing.usp_RunResponse		@SPH_ID = @SPH_ID,
														@ProcedureName = @ProcedureName,
														@Parameters = @Parameters,
														@RGT_ID = @RGT_ID,
														@NewEvents = @NewEvents,
														@IsClose = 0,
														@IsRerun = 0,
														@IsCustomReport = 1

			insert into ResponseProcessing.SubscriptionProcessingHistoryDetailed(SPD_ClientID, SPD_SPH_ID, SPD_TRE_ID, SPD_IsClosed, SPD_RunCount)
			select @ClientID, @SPH_ID, TRE_ID, IsClosed, TimesProcessed + 1
			from @NewEvents

			delete @NewEvents
		END
	END
end try
begin catch
	set @ErrorMessage = ERROR_MESSAGE()
end catch

update ResponseProcessing.SubscriptionProcessingHistory
set SPH_EndDate = sysdatetime(),
	SPH_LastHandledTimestamp = case when @ErrorMessage is null
									then @LastTimestamp
								end,
	SPH_ErrorMessage = @ErrorMessage
where SPH_ID = @SPH_ID
GO
