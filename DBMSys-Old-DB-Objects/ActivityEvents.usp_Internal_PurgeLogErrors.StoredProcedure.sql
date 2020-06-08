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
/****** Object:  StoredProcedure [ActivityEvents].[usp_Internal_PurgeLogErrors]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ActivityEvents].[usp_Internal_PurgeLogErrors]
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

select @MostRecentTimestamp = max(PLG_Timestamp)
from RetentionManager.PurgeLog

if @MostRecentTimestamp = @LastTimeStamp and @InLastMinutes is null
	return

select @SQL =
'select 0 F_MOB_ID, left(PLG_ErrorMessage, 850) F_InstanceName, MIN(PLG_StartDate) F_FirstEventDate,
	MAX(PLG_StartDate) F_LastEventDate, COUNT(*) F_EventCount, 0 F_HasSuccesfulRuns,
	max(PLG_Timestamp) F_Timestamp,
	''Table Name: '' + TAS_TableName + char(13)+char(10)
		+ ''Error Message: '' + PLG_ErrorMessage F_Message,
	(select @Identifier [@Identifier], @EventDescription [@EventDescription], COUNT(*) [@NumberOfOccurences],
			MIN(PLG_StartDate) [@FirstOccurenceDate], MAX(PLG_StartDate) [@LastOccurenceDate],
			TAS_ID [@TaskID], TAS_TableName [@TableName], PLG_ErrorMessage [@ErrorMessage]
		for xml path(''Alert''), type) AlertEventData
from RetentionManager.PurgeLog /*with (forceseek)*/
	inner join RetentionManager.Tasks on PLG_TAS_ID = TAS_ID
where PLG_ErrorMessage is not null
	and '
	+ case when @InLastMinutes is null
			then 'PLG_Timestamp > @LastTimeStamp and PLG_Timestamp <= @MostRecentTimestamp'
			else 'PLG_StartDate > dateadd(minute, -@InLastMinutes, sysdatetime())'
		end + char(13)+char(10)
	+ isnull(' and ' + EventProcessing.fn_ParseEventFilter(@PossibleFilters, @FilterDefinition) + char(13)+char(10), '')
+ 'group by TAS_ID, TAS_TableName, PLG_ErrorMessage'
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
