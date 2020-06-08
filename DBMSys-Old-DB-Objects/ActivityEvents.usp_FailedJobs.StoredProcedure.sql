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
/****** Object:  StoredProcedure [ActivityEvents].[usp_FailedJobs]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ActivityEvents].[usp_FailedJobs]
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

select @MostRecentTimestamp = max(FLJ_Timestamp)
from Activity.FailedJobs

if @MostRecentTimestamp = @LastTimeStamp and @InLastMinutes is null
	return

select @SQL =
'select FLJ_MOB_ID F_MOB_ID, FLJ_JobName + ''\'' + FLJ_StepName F_InstanceName, FLJ_FirstFailureDate F_FirstEventDate,
	FLJ_LastFailureDate F_LastEventDate, FLJ_FailureCount F_EventCount,
	case when FLJ_SuccessCount = 0 or FLJ_SuccessCount is null then 0 else 1 end F_HasSuccesfulRuns,
	FLJ_Timestamp F_Timestamp,
	''Step '' + FLJ_StepName + '' of job '' + FLJ_JobName + '' failed ''
			+ case when FLJ_FirstFailureDate = FLJ_LastFailureDate
				then ''at '' + convert(char(19), FLJ_FirstFailureDate, 121)
						+ '' with the error:''
				else cast(FLJ_FailureCount as varchar(10)) + '' times between ''
					+ convert(char(19), FLJ_FirstFailureDate, 121) + '' and ''
					+ convert(char(19), FLJ_LastFailureDate, 121)
					+ ''. The last error was: ''
			end + FLJ_LastErrorMessage F_Message,
	(select (select ''EDF_ID'' [@Name], cast(@Identifier as sql_variant) where @Identifier is not null for xml path(''Col''), type),
			(select ''~JobID'' [@ObjectType], IJB_ID [@ObjectID], ''Job name'' [@Name], cast(FLJ_JobName as sql_variant)
				where FLJ_JobName is not null for xml path(''Col''), type),
			(select ''~JobStepID'' [@ObjectType], IJS_ID [@ObjectID], ''Step name'' [@Name], cast(FLJ_StepName as sql_variant)
				where FLJ_StepName is not null for xml path(''Col''), type),
			(select ''Number of occurences'' [@Name], cast(FLJ_FailureCount as sql_variant) where FLJ_FailureCount is not null for xml path(''Col''), type),
			(select ''First occurence date'' [@Name], cast(FLJ_FirstFailureDate as sql_variant) where FLJ_FirstFailureDate is not null for xml path(''Col''), type),
			(select ''Last occurence date'' [@Name], cast(FLJ_LastFailureDate as sql_variant) where FLJ_LastFailureDate is not null for xml path(''Col''), type),
			(select ''Error message'' [@Name], cast(FLJ_LastErrorMessage as varchar(8000)) where FLJ_LastErrorMessage is not null for xml path(''Col''), type)
		for xml path(''Columns''), type) AlertEventData
from Activity.FailedJobs with (forceseek)
	inner join Inventory.MonitoredObjects on FLJ_MOB_ID = MOB_ID
	left join Inventory.InstanceJobs on IJB_MOB_ID = FLJ_MOB_ID
											and IJB_Name = FLJ_JobName
	left join Inventory.InstanceJobSteps on IJS_MOB_ID = FLJ_MOB_ID
											and IJS_IJB_ID = IJB_ID
											and IJS_Name = FLJ_StepName
where MOB_OOS_ID = 1 AND '
	+ case when @InLastMinutes is null
			then 'FLJ_Timestamp > @LastTimeStamp and FLJ_Timestamp <= @MostRecentTimestamp'
			else 'FLJ_LastFailureDate > dateadd(minute, -@InLastMinutes, sysdatetime())'
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
