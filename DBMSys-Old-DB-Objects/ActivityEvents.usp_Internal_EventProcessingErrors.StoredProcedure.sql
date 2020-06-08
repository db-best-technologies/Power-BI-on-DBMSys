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
/****** Object:  StoredProcedure [ActivityEvents].[usp_Internal_EventProcessingErrors]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ActivityEvents].[usp_Internal_EventProcessingErrors]
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

select @MostRecentTimestamp = max(PRC_Timestamp)
from EventProcessing.ProcessCycles

if @MostRecentTimestamp = @LastTimeStamp and @InLastMinutes is null
	return

select @SQL =
'select 0 F_MOB_ID, left(PRC_ErrorMessage, 850) F_InstanceName, MIN(PRC_StartDate) F_FirstEventDate,
	MAX(PRC_StartDate) F_LastEventDate, COUNT(*) F_EventCount, 0 F_HasSuccesfulRuns,
	max(PRC_Timestamp) F_Timestamp,
	''Failed Event: '' + MOV_Description + char(13)+char(10)
		+ ''Error Message: '' + PRC_ErrorMessage F_Message,
	(select @Identifier [@Identifier], @EventDescription [@EventDescription], COUNT(*) [@NumberOfOccurences],
			MIN(PRC_StartDate) [@FirstOccurenceDate], MAX(PRC_StartDate) [@LastOccurenceDate],
			MOV_Description [@MonitoredEventName], PRC_ErrorMessage [@ErrorMessage]
		for xml path(''Alert''), type) AlertEventData
from EventProcessing.ProcessCycles with (forceseek)
	inner join EventProcessing.MonitoredEvents on MOV_ID = PRC_MOV_ID
where PRC_ErrorMessage is not null
	and '
	+ case when @InLastMinutes is null
			then 'PRC_Timestamp > @LastTimeStamp and PRC_Timestamp <= @MostRecentTimestamp'
			else 'PRC_StartDate > dateadd(minute, -@InLastMinutes, sysdatetime())'
		end + char(13)+char(10)
	+ isnull(' and ' + EventProcessing.fn_ParseEventFilter(@PossibleFilters, @FilterDefinition) + char(13)+char(10), '')
+ 'group by MOV_Description, PRC_ErrorMessage'
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
