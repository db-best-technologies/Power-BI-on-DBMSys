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
/****** Object:  StoredProcedure [ActivityEvents].[usp_Internal_SubscriptionProcessingErrors]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ActivityEvents].[usp_Internal_SubscriptionProcessingErrors]
	@Identifier int,
	@EventDescription nvarchar(1000),
	@LastTimeStamp binary(8),
	@InLastMinutes int,
	@PossibleFilters xml,
	@FilterDefinition xml,
	@MostRecentTimestamp binary(8) output
as
set nocount on
declare @SQL nvarchar(max)

select @MostRecentTimestamp = max(SPH_Timestamp)
from ResponseProcessing.SubscriptionProcessingHistory

if @MostRecentTimestamp = @LastTimeStamp and @InLastMinutes is null
	return

select @SQL =
'select 0 F_MOB_ID, left(SPH_ErrorMessage, 850) F_InstanceName, MIN(SPH_StartDate) F_FirstEventDate,
	MAX(SPH_StartDate) F_LastEventDate, COUNT(*) F_EventCount, 0 F_HasSuccesfulRuns,
	max(SPH_Timestamp) F_Timestamp,
	''Event Description: '' + MOV_Description + char(13)+char(10)
		+ ''Response Type: '' + RSP_Name + char(13)+char(10)
		+ ''ESP_ID: '' + cast(ESP_ID as nvarchar(100)) + char(13)+char(10)
		+ ''Error Message: '' + SPH_ErrorMessage F_Message,
	(select @Identifier [@Identifier], @EventDescription [@EventDescription], COUNT(*) [@NumberOfOccurences],
			MIN(SPH_StartDate) [@FirstOccurenceDate], MAX(SPH_StartDate) [@LastOccurenceDate],
			ESP_ID [@SubscriptionID], RSP_Name [@ResponseType], MOV_Description [@MonitoredEventName],
			SPH_ErrorMessage [@ErrorMessage]
		for xml path(''Alert''), type) AlertEventData
from ResponseProcessing.SubscriptionProcessingHistory with (forceseek)
	inner join ResponseProcessing.EventSubscriptions on ESP_ID = SPH_ESP_ID
	inner join ResponseProcessing.ResponseTypes on RSP_ID = ESP_RSP_ID
	inner join EventProcessing.MonitoredEvents on MOV_ID = ESP_MOV_ID
where SPH_ErrorMessage is not null
	and '
	+ case when @InLastMinutes is null
			then 'SPH_Timestamp > @LastTimeStamp and SPH_Timestamp <= @MostRecentTimestamp'
			else 'SPH_StartDate > dateadd(minute, -@InLastMinutes, sysdatetime())'
		end + char(13)+char(10)
	+ isnull(' and ' + EventProcessing.fn_ParseEventFilter(@PossibleFilters, @FilterDefinition) + char(13)+char(10), '')
+ 'group by ESP_ID, RSP_Name, MOV_Description, SPH_ErrorMessage'
exec sp_executesql @SQL,
					N'@Identifier int,
						@EventDescription nvarchar(1000),
						@LastTimeStamp binary(8),
						@InLastMinutes int,
						@MostRecentTimestamp binary(8)',
					@Identifier = @Identifier,
					@EventDescription = @EventDescription,
					@LastTimeStamp = @LastTimeStamp,
					@InLastMinutes = @InLastMinutes,
					@MostRecentTimestamp = @MostRecentTimestamp
GO
