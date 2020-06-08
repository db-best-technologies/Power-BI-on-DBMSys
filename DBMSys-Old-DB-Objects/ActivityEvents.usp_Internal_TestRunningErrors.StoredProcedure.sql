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
/****** Object:  StoredProcedure [ActivityEvents].[usp_Internal_TestRunningErrors]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ActivityEvents].[usp_Internal_TestRunningErrors]
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

select @MostRecentTimestamp = max(TRH_Timestamp)
from Collect.TestRunHistory

if @MostRecentTimestamp = @LastTimeStamp and @InLastMinutes is null
	return

select @SQL =
'select MOB_ID F_MOB_ID, left(MOB_Name + ''\'' + TRH_ErrorMessage, 850) F_InstanceName, MIN(TRH_StartDate) F_FirstEventDate,
	MAX(TRH_StartDate) F_LastEventDate, COUNT(*) F_EventCount, 0 F_HasSuccesfulRuns,
	max(TRH_Timestamp) F_Timestamp,
	''Test Name: '' + TST_Name + char(13)+char(10)
		+ ''MOB Name: '' + MOB_Name + char(13)+char(10)
		+ ''Error Message: '' + TRH_ErrorMessage F_Message,
	(select @Identifier [@Identifier], @EventDescription [@EventDescription], COUNT(*) [@NumberOfOccurences],
			MIN(TRH_StartDate) [@FirstOccurenceDate], MAX(TRH_StartDate) [@LastOccurenceDate],
			TST_ID [@TestID], TST_Name [@TestName], MOB_ID [@MOB_ID], MOB_Name [@MOB_Name],
			TRH_ErrorMessage [@ErrorMessage]
		for xml path(''Alert''), type) AlertEventData
from Collect.TestRunHistory with (forceseek)
	inner join Collect.Tests on TST_ID = TRH_TST_ID
	inner join Inventory.MonitoredObjects on MOB_ID = TRH_MOB_ID
where TRH_ErrorMessage is not null
	AND MOB_OOS_ID = 1
	AND TRH_TRS_ID IN (4,6)
	and TRH_TST_ID not in (select distinct TST_DontRunIfErrorIn_TST_ID from Collect.Tests where TST_DontRunIfErrorIn_TST_ID is not null)
	and '
	+ case when @InLastMinutes is null
			then 'TRH_Timestamp > @LastTimeStamp and TRH_Timestamp <= @MostRecentTimestamp'
			else 'TRH_StartDate > dateadd(minute, -@InLastMinutes, sysdatetime())'
		end + char(13)+char(10)
	+ isnull(' and ' + EventProcessing.fn_ParseEventFilter(@PossibleFilters, @FilterDefinition) + char(13)+char(10), '')
+ 'group by TST_ID, TST_Name, MOB_ID, MOB_Name, TRH_ErrorMessage,TRH_ID'
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
