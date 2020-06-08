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
/****** Object:  StoredProcedure [ActivityEvents].[usp_Internal_ErrorLog]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ActivityEvents].[usp_Internal_ErrorLog]
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

select @MostRecentTimestamp = max(ERL_Timestamp)
from Internal.ErrorLog

if @MostRecentTimestamp = @LastTimeStamp and @InLastMinutes is null
	return

select @SQL =
'select 0 F_MOB_ID, left(ERL_ErrorMessage, 850) F_InstanceName, MIN(ERL_DateTime) F_FirstEventDate,
	MAX(ERL_DateTime) F_LastEventDate, COUNT(*) F_EventCount, 0 F_HasSuccesfulRuns,
	max(ERL_Timestamp) F_Timestamp, ERL_ErrorMessage + ''Info = '' + cast(ERL_Info as nvarchar(max)) F_Message,
	(select @Identifier [@Identifier], @EventDescription [@EventDescription], COUNT(*) [@NumberOfOccurences],
			MIN(ERL_DateTime) [@FirstOccurenceDate], MAX(ERL_DateTime) [@LastOccurenceDate],
			ERL_ErrorMessage [@ErrorMessage],
			cast(cast(ERL_Info as nvarchar(max)) as xml)
		for xml path(''Alert''), type) AlertEventData
from Internal.ErrorLog with (forceseek)
where '
	+ case when @InLastMinutes is null
			then 'ERL_Timestamp > @LastTimeStamp and ERL_Timestamp <= @MostRecentTimestamp'
			else 'ERL_DateTime > dateadd(minute, -@InLastMinutes, sysdatetime())'
		end + char(13)+char(10)
	+ isnull(' and ' + EventProcessing.fn_ParseEventFilter(@PossibleFilters, @FilterDefinition) + char(13)+char(10), '')
+ 'group by ERL_ErrorMessage, cast(ERL_Info as nvarchar(max))'
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
