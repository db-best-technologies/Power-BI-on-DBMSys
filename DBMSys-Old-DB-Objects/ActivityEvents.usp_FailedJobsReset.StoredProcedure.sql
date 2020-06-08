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
/****** Object:  StoredProcedure [ActivityEvents].[usp_FailedJobsReset]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ActivityEvents].[usp_FailedJobsReset]
	@Identifier int,
	@EventDescription nvarchar(1000),
	@LastTimeStamp binary(8),
	@InLastMinutes int,
	@PossibleFilters xml,
	@FilterDefinition xml
as
set nocount on
declare @SQL nvarchar(max)
select @SQL =
'select FLJ_MOB_ID F_MOB_ID, FLJ_JobName + ''\'' + FLJ_StepName F_InstanceName, FLJ_FirstSuccessDate F_FirstEventDate,
	FLJ_LastSuccessDate F_LastEventDate, FLJ_SuccessCount F_EventCount, FLJ_JobDeleted F_IsEventCompletelyClosed,
	FLJ_Timestamp F_Timestamp,
	case FLJ_JobDeleted
		when 0 then ''The '' + FLJ_StepName + '' step of the '' + FLJ_JobName + '' job ran successfuly at least ''
						+ CAST(FLJ_SuccessCount as varchar(10)) + '' time(s) since it has failed.''
		when 1 then ''The job or the step was deleted.''
	end F_Message,
	(select (select ''EDF_ID'' [@Name], cast(@Identifier as sql_variant) where @Identifier is not null for xml path(''Col''), type),
			(select ''~JobID'' [@ObjectType], IJB_ID [@ObjectID], ''Job name'' [@Name], cast(FLJ_JobName as sql_variant)
				where FLJ_JobName is not null for xml path(''Col''), type),
			(select ''~JobStepID'' [@ObjectType], IJS_ID [@ObjectID], ''Step name'' [@Name], cast(FLJ_StepName as sql_variant)
				where FLJ_StepName is not null for xml path(''Col''), type),
			(select ''Number of occurences'' [@Name], cast(FLJ_SuccessCount as sql_variant) where FLJ_SuccessCount is not null for xml path(''Col''), type),
			(select ''First occurence date'' [@Name], cast(FLJ_FirstSuccessDate as sql_variant) where FLJ_FirstSuccessDate is not null for xml path(''Col''), type),
			(select ''Last occurence date'' [@Name], cast(FLJ_LastSuccessDate as sql_variant) where FLJ_LastSuccessDate is not null for xml path(''Col''), type),
			(select ''Message'' [@Name], cast(case FLJ_JobDeleted
													when 0 then ''The '' + FLJ_StepName + '' step of the '' + FLJ_JobName + '' job ran successfuly at least ''
																	+ CAST(FLJ_SuccessCount as varchar(10)) + '' time(s) since it has failed.''
													when 1 then ''The job or the step was deleted.''
												end as varchar(8000)) for xml path(''Col''), type)
		for xml path(''Columns''), type) OKEventData
from Activity.FailedJobs with (forceseek)
	left join Inventory.InstanceJobs on IJB_MOB_ID = FLJ_MOB_ID
											and IJB_Name = FLJ_JobName
	left join Inventory.InstanceJobSteps on IJS_MOB_ID = FLJ_MOB_ID
											and IJS_IJB_ID = IJB_ID
											and IJS_Name = FLJ_StepName
where FLJ_IsClosed = 1
	and '
	+ case when @InLastMinutes is null
			then 'FLJ_Timestamp > @LastTimeStamp'
			else 'FLJ_LastSuccessDate > dateadd(minute, -@InLastMinutes, sysdatetime())'
		end
	+ isnull(char(13)+char(10) + ' and ' + EventProcessing.fn_ParseEventFilter(@PossibleFilters, @FilterDefinition), '')
exec sp_executesql @SQL,
					N'@Identifier int,
						@EventDescription nvarchar(1000),
						@LastTimeStamp binary(8),
						@InLastMinutes int',
					@Identifier = @Identifier,
					@EventDescription = @EventDescription,
					@LastTimeStamp = @LastTimeStamp,
					@InLastMinutes = @InLastMinutes
GO
