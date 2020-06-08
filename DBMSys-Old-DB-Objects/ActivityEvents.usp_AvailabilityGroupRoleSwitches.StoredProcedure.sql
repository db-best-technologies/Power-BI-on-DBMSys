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
/****** Object:  StoredProcedure [ActivityEvents].[usp_AvailabilityGroupRoleSwitches]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ActivityEvents].[usp_AvailabilityGroupRoleSwitches]
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

select @MostRecentTimestamp = max(AGS_Timestamp)
from Activity.AvailabilityGroupRoleSwitches
where AGS_DateRecorded < DATEADD(minute, -1, sysdatetime())

if @MostRecentTimestamp = @LastTimeStamp and @InLastMinutes is null
	return

select @SQL =
'select AGS_MOB_ID F_MOB_ID, AGS_GroupName F_InstanceName, AGS_DateRecorded F_FirstEventDate, AGS_DateRecorded F_LastEventDate, 1 F_EventCount, 0 F_HasSuccesfulRuns, AGS_Timestamp F_Timestamp,
	''The '' + AGS_GroupName + '' Availability Group has failed over to '' + MOB_Name + ''.'' F_Message,
	(select (select ''EDF_ID'' [@Name], cast(@Identifier as sql_variant) where @Identifier is not null for xml path(''Col''), type),
			(select ''~MonitoredObjectID'' [@ObjectType], MOB_ID [@ObjectID], ''Principal instance name'' [@Name], cast(MOB_Name as sql_variant)
				for xml path(''Col''), type),
			(select ''~AvailabilityGroupID'' [@ObjectType], AGS_AGR_ID [@ObjectID], ''Availability group name'' [@Name], cast(AGS_GroupName as sql_variant)
				for xml path(''Col''), type),
			(select ''Number of occurences'' [@Name], cast(1 as sql_variant) for xml path(''Col''), type),
			(select ''First occurence date'' [@Name], cast(AGS_DateRecorded as sql_variant) for xml path(''Col''), type),
			(select ''Last occurence date'' [@Name], cast(AGS_DateRecorded as sql_variant) for xml path(''Col''), type)
		for xml path(''Columns''), type) AlertEventData
from Activity.AvailabilityGroupRoleSwitches
	inner join Inventory.MonitoredObjects on MOB_ID = AGS_MOB_ID
where AGS_DateRecorded < DATEADD(minute, -1, sysdatetime())
		AND MOB_OOS_ID = 1
				and ' + case when @InLastMinutes is null
							then 'AGS_Timestamp > @LastTimeStamp and AGS_Timestamp <= @MostRecentTimestamp'
							else 'AGS_DateRecorded > dateadd(minute, -@InLastMinutes, sysdatetime())'
						end
				+ isnull(char(13)+char(10) + ' and ' + EventProcessing.fn_ParseEventFilter(@PossibleFilters, @FilterDefinition) + char(13)+char(10), '')
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
