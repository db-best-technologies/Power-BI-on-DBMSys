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
/****** Object:  StoredProcedure [ActivityEvents].[usp_AutoFileSizeChangeEvents]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ActivityEvents].[usp_AutoFileSizeChangeEvents]
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

select @MostRecentTimestamp = max(AFS_Timestamp)
from Activity.AutoFileSizeChangeEvents

if @MostRecentTimestamp = @LastTimeStamp and @InLastMinutes is null
	return

select @SQL =
'select MOB_ID F_MOB_ID, IDB_Name + ''\'' + DBF_Name + '' ('' + AFC_Name + '' at '' + convert(char(23), AFS_ProcessStartTime, 121) + '')'' F_InstanceName,
	AFS_ProcessStartTime F_FirstEventDate, AFS_ProcessStartTime F_LastEventDate, 1 F_EventCount, 0 F_HasSuccesfulRuns, AFS_Timestamp F_Timestamp,
	AFC_Name + '' event reported for the '' + DBF_Name + '' file of the '' + IDB_Name + '' database'' + CHAR(13)+CHAR(10)
		+ ''Growth: '' + case AFS_ChangeInSizeMB
							when 0 then ''< 1''
							else cast(AFS_ChangeInSizeMB as varchar(100))
						end + ''MB'' + CHAR(13)+CHAR(10)
		+ ''Duration: '' + cast(AFS_DurationMS as varchar(100)) + ''ms'' F_Message,
	(select (select ''EDF_ID'' [@Name], cast(@Identifier as sql_variant) where @Identifier is not null for xml path(''Col''), type),
			(select ''~DatabaseID'' [@ObjectType], IDB_ID [@ObjectID], ''Database name'' [@Name], cast(IDB_Name as sql_variant)
				where IDB_ID is not null for xml path(''Col''), type),
			(select ''~DatabaseFileID'' [@ObjectType], DBF_ID [@ObjectID], ''Database file name'' [@Name], cast(DBF_Name as sql_variant)
				where DBF_ID is not null for xml path(''Col''), type),
			(select ''Event type'' [@Name], cast(AFC_Name as sql_variant) where AFC_Name is not null for xml path(''Col''), type),
			(select ''Event type'' [@Name], cast(AFC_Name as sql_variant) where AFC_Name is not null for xml path(''Col''), type),
			(select ''Size change (MB)'' [@Name], cast(AFS_ChangeInSizeMB as sql_variant) where AFS_ChangeInSizeMB is not null for xml path(''Col''), type),
			(select ''Duration (ms)'' [@Name], cast(AFS_DurationMS as sql_variant) where AFS_DurationMS is not null for xml path(''Col''), type),
			(select ''First occurence date'' [@Name], cast(AFS_ProcessStartTime as sql_variant) where AFS_ProcessStartTime is not null for xml path(''Col''), type)
		for xml path(''Alert''), type) AlertEventData
from Activity.AutoFileSizeChangeEvents with (forceseek)
	inner join Inventory.MonitoredObjects on MOB_ID = AFS_MOB_ID
	inner join Activity.AutoFileSizeChangeEventTypes on AFS_AFC_ID = AFC_ID
	inner join Inventory.InstanceDatabases on AFS_IDB_ID = IDB_ID
	inner join Inventory.DatabaseFiles on AFS_DBF_ID = DBF_ID
where MOB_OOS_ID = 1 AND '+ CHAR(10)
	+ case when @InLastMinutes is null
			then ' AFS_Timestamp > @LastTimeStamp and AFS_Timestamp <= @MostRecentTimestamp'
			else ' AFS_ProcessEndTime > dateadd(minute, -@InLastMinutes, sysdatetime())'
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
