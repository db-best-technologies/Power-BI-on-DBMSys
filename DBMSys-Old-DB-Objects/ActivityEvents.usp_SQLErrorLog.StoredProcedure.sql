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
/****** Object:  StoredProcedure [ActivityEvents].[usp_SQLErrorLog]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ActivityEvents].[usp_SQLErrorLog]
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

select @MostRecentTimestamp = max(SEL_Timestamp)
from Activity.SQLErrorLog

if @MostRecentTimestamp = @LastTimeStamp and @InLastMinutes is null
	return

select @SQL =
'select SEL_MOB_ID F_MOB_ID, left(SEL_ErrorMessage, 850) F_InstanceName, SEL_FirstErrorDate F_FirstEventDate,
	SEL_LastErrorDate F_LastEventDate, SEL_ErrorCount F_EventCount,
	0 F_HasSuccesfulRuns,
	SEL_Timestamp F_Timestamp,
	''Process Info: '' + SEL_ProcessInfo + CHAR(13)+CHAR(10)
	+ ''Error Message: '' + SEL_ErrorMessage F_Message,
	(select (select ''EDF_ID'' [@Name], cast(@Identifier as sql_variant) where @Identifier is not null for xml path(''Col''), type),
			(select ''Process info'' [@Name], cast(SEL_ProcessInfo as varchar(8000)) where SEL_ProcessInfo is not null for xml path(''Col''), type),
			(select ''Number of occurences'' [@Name], cast(SEL_ErrorCount as sql_variant) where SEL_ErrorCount is not null for xml path(''Col''), type),
			(select ''First occurence date'' [@Name], cast(SEL_FirstErrorDate as sql_variant) where SEL_FirstErrorDate is not null for xml path(''Col''), type),
			(select ''Last occurence date'' [@Name], cast(SEL_LastErrorDate as sql_variant) where SEL_LastErrorDate is not null for xml path(''Col''), type),
			(select ''Error message'' [@Name], cast(SEL_ErrorMessage as varchar(8000)) where SEL_ErrorMessage is not null for xml path(''Col''), type)
		for xml path(''Columns''), type) AlertEventData
from Activity.SQLErrorLog with (forceseek)
	inner join Inventory.MonitoredObjects on SEL_MOB_ID = MOB_ID
where MOB_OOS_ID = 1
		AND '
	+ case when @InLastMinutes is null
			then 'SEL_Timestamp > @LastTimeStamp and SEL_Timestamp <= @MostRecentTimestamp'
			else 'SEL_LastErrorDate > dateadd(minute, -@InLastMinutes, sysdatetime())'
		end
	+ isnull(char(13)+char(10) + ' and ' + EventProcessing.fn_ParseEventFilter(@PossibleFilters, @FilterDefinition), '')

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
