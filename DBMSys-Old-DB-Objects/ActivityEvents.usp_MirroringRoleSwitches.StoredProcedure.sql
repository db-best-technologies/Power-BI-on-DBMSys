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
/****** Object:  StoredProcedure [ActivityEvents].[usp_MirroringRoleSwitches]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ActivityEvents].[usp_MirroringRoleSwitches]
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
select @MostRecentTimestamp = max(MRS_Timestamp)
from Activity.MirroringRoleSwitches
where MRS_DateRecorded < DATEADD(minute, -1, sysdatetime())

if @MostRecentTimestamp = @LastTimeStamp and @InLastMinutes is null
	return

select @SQL =
';with RawRoleSwitches as
		(select MRS_MOB_ID, MRS_MRD_GUID, MRS_DateRecorded, MRS_Timestamp, ROW_NUMBER() over (partition by MRS_MRD_GUID order by MRS_DateRecorded desc) rn,
				MRS_Current_MRL_ID
			from Activity.MirroringRoleSwitches
			where MRS_DateRecorded < DATEADD(minute, -1, sysdatetime())
				and ' + case when @InLastMinutes is null
							then 'MRS_Timestamp > @LastTimeStamp and MRS_Timestamp <= @MostRecentTimestamp'
							else 'MRS_DateRecorded > dateadd(minute, -@InLastMinutes, sysdatetime())'
						end
				+ isnull(char(13)+char(10) + ' and ' + EventProcessing.fn_ParseEventFilter(@PossibleFilters, @FilterDefinition) + char(13)+char(10), '')
			+ ')
		, AggRoleSwitches as
		(select MRD_MOB_ID F_MOB_ID, cast(MRS_MRD_GUID as varchar(100)) F_InstanceName, MRS_DateRecorded F_FirstEventDate,
				MRS_DateRecorded F_LastEventDate,
				1 F_EventCount, 0 F_HasSuccesfulRuns, MRS_Timestamp F_Timestamp, IDB_ID, IDB_Name,
				MRS_MOB_ID ReportFrom_MOB_ID,
				MRS_Current_MRL_ID CurrentRole,
				MRD_Partner_MOB_ID Other_MOB_ID, MRS_MRD_GUID
			from RawRoleSwitches
				inner join Inventory.MirroredDatabases on MRS_MRD_GUID = MRD_GUID
															and MRD_MOB_ID = MRS_MOB_ID
				inner join Inventory.InstanceDatabases on MRD_IDB_ID = IDB_ID
			where rn = 1)
select F_MOB_ID, F_InstanceName, F_FirstEventDate, F_LastEventDate, F_EventCount, F_HasSuccesfulRuns, F_Timestamp,
	''The mirroring session of the '' + IDB_Name + '' database between '' + p.MOB_Name + '' and '' + m.MOB_Name + '' had a role switch. ''
	+ ''The current principal instance is '' + p.MOB_Name + ''.'' F_Message,
	(select (select ''EDF_ID'' [@Name], cast(@Identifier as sql_variant) where @Identifier is not null for xml path(''Col''), type),
			(select ''~MonitoredObjectID'' [@ObjectType], p.MOB_ID [@ObjectID], ''Principal instance name'' [@Name], cast(p.MOB_Name as sql_variant)
				where p.MOB_ID is not null for xml path(''Col''), type),
			(select ''~MonitoredObjectID'' [@ObjectType], m.MOB_ID [@ObjectID], ''Mirror instance name'' [@Name], cast(m.MOB_Name as sql_variant)
				where m.MOB_ID is not null for xml path(''Col''), type),
			(select ''~DatabaseID'' [@ObjectType], IDB_ID [@ObjectID], ''Database name'' [@Name], cast(IDB_Name as sql_variant)
				where IDB_ID is not null for xml path(''Col''), type),
			(select ''Number of occurences'' [@Name], cast(F_EventCount as sql_variant) where F_EventCount is not null for xml path(''Col''), type),
			(select ''First occurence date'' [@Name], cast(F_FirstEventDate as sql_variant) where F_FirstEventDate is not null for xml path(''Col''), type),
			(select ''Last occurence date'' [@Name], cast(F_LastEventDate as sql_variant) where F_LastEventDate is not null for xml path(''Col''), type)
		for xml path(''Columns''), type) AlertEventData
from AggRoleSwitches
	inner join Inventory.MonitoredObjects p on p.MOB_ID = iif(CurrentRole = 1, ReportFrom_MOB_ID, Other_MOB_ID)
	left join Inventory.MonitoredObjects m on m.MOB_ID = iif(CurrentRole = 1, Other_MOB_ID, ReportFrom_MOB_ID)
	AND p.MOB_OOS_ID = 1
	AND m.MOB_OOS_ID = 1'

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
