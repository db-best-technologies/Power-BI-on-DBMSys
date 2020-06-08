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
/****** Object:  UserDefinedFunction [Tests].[fn_TST_FailedJobs]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Tests].[fn_TST_FailedJobs](@TST_ID int,
								@MOB_ID int,
								@Command nvarchar(max)) returns nvarchar(max)
begin
	declare @OutputCommand nvarchar(max),
			@FailedJobs nvarchar(max)
	set @OutputCommand = Collect.fn_InsertTestObjectLastValue(@TST_ID, @MOB_ID, @Command)
	
	select @FailedJobs = stuff((select js + ''
									from (select ',''' + FLJ_JobName + '\' + FLJ_StepName + '''' js
											from Activity.FailedJobs
											where FLJ_MOB_ID = @MOB_ID
												and FLJ_IsClosed = 0
											union
											select ',''' + EDS_EventInstanceName + '''' js
											from EventProcessing.EventDefinitionStatuses
												inner join EventProcessing.EventDefinitions on EDF_ID = EDS_EDF_ID
												inner join EventProcessing.ActivityConditions on ACC_EDF_ID = EDF_ID
												inner join EventProcessing.ActivityConditionTypes on ACT_ID = ACC_ACT_ID
											where ACT_Name = 'Failed Jobs'
												and EDS_MOB_ID = @MOB_ID
												and EDS_IsClosed = 0
												and exists (select *
															from EventProcessing.MonitoredEvents
																left join EventProcessing.MonitoredEventGroups on MEG_ID = MOV_MEG_ID
															where MOV_ID = EDF_MOV_ID
																and (MEG_ID = 1 or MEG_ID is null))
											) t
									for xml path('')), 1, 1, '')

	set @OutputCommand = replace(@OutputCommand, '%PREVIOUSLYFAILED%', isnull(@FailedJobs, ''''''))
	return @OutputCommand
end
GO
