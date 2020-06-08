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
/****** Object:  StoredProcedure [ActivityEvents].[usp_FailedLogins]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ActivityEvents].[usp_FailedLogins]
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

select @MostRecentTimestamp = max(FLG_Timestamp)
from Activity.FailedLogins

if @MostRecentTimestamp = @LastTimeStamp and @InLastMinutes is null
	return

select @SQL =
'select FLG_MOB_ID F_MOB_ID, HSN_Name + ''\'' + isnull(LGN_Name, ''Non-existing'') F_InstanceName,
	min(FLG_FirstDate) F_FirstEventDate, max(FLG_LastDate) F_LastEventDate, sum(FLG_Count) F_EventCount, 0 F_HasSuccesfulRuns,
	max(FLG_Timestamp) F_Timestamp,
	''Login failure. '' + isnull(''Login Name: '' + LGN_Name, ''Non existing login'')	+ ''. From: '' + HSN_Name + ''.'' F_Message,
	(select (select ''EDF_ID'' [@Name], cast(@Identifier as sql_variant) where @Identifier is not null for xml path(''Col''), type),
			(select ''~LoginID'' [@ObjectType], INL_ID [@ObjectID], ''Login name'' [@Name], cast(isnull(LGN_Name, ''Non-existing'') as sql_variant) for xml path(''Col''), type),
			(select ''Location'' [@Name], cast(HSN_Name as sql_variant) where HSN_Name is not null for xml path(''Col''), type),
			(select ''Number of occurences'' [@Name], cast(sum(FLG_Count) as sql_variant) where sum(FLG_Count) is not null for xml path(''Col''), type),
			(select ''First occurence date'' [@Name], cast(min(FLG_FirstDate) as sql_variant) where min(FLG_FirstDate) is not null for xml path(''Col''), type),
			(select ''Last occurence date'' [@Name], cast(max(FLG_LastDate) as sql_variant) where max(FLG_LastDate) is not null for xml path(''Col''), type)
		for xml path(''Columns''), type) AlertEventData
from Activity.FailedLogins with (forceseek)
	inner join Inventory.MonitoredObjects on FLG_MOB_ID = MOB_ID
	left join Activity.LoginNames on LGN_ID = FLG_LGN_ID
												and FLG_IsUnknownLogin = 0
	inner join Activity.HostNames on HSN_ID = FLG_HSN_ID
	left join Inventory.InstanceLogins on INL_MOB_ID = FLG_MOB_ID
											and INL_Name = LGN_Name
where MOB_OOS_ID = 1 AND '
	+ case when @InLastMinutes is null
			then 'FLG_Timestamp > @LastTimeStamp and FLG_Timestamp <= @MostRecentTimestamp'
			else 'FLG_LastDate > dateadd(minute, -@InLastMinutes, sysdatetime())'
		end + char(13)+char(10)
	+ isnull(' and ' + EventProcessing.fn_ParseEventFilter(@PossibleFilters, @FilterDefinition) + char(13)+char(10), '')
	+ 'group by FLG_MOB_ID, HSN_Name, LGN_Name, MOB_Name, INL_ID'

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
