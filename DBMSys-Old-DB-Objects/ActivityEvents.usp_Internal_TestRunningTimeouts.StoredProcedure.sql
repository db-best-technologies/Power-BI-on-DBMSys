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
/****** Object:  StoredProcedure [ActivityEvents].[usp_Internal_TestRunningTimeouts]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ActivityEvents].[usp_Internal_TestRunningTimeouts]
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
'select MOB_ID F_MOB_ID, TST_Name + ''\'' + MOB_Name F_InstanceName, MIN(TRH_StartDate) F_FirstEventDate,
	MAX(TRH_StartDate) F_LastEventDate, COUNT(*) F_EventCount, 0 F_HasSuccesfulRuns,
	max(TRH_Timestamp) F_Timestamp,
	''The '''''' + TST_Name + '''''' test has timed out on '''''' + MOB_Name + '''''''' + char(13)+char(10)
	+ ''Running time: '' + cast(cast(max(DATEDIFF(millisecond, TRH_StartDate, TRH_EndDate)/1000.) as decimal(10, 3)) as nvarchar(100)) + '' seconds'' + char(13)+char(10)
	+ isnull(''Connection Timeout: '' + cast(TST_ConnectionTimeout as nvarchar(10)) + '' seconds'' + char(13)+char(10), '''')
	+ isnull(''Query Timeout: '' + cast(TST_QueryTimeout as nvarchar(10)) + '' seconds'', '''') F_Message,
	(select @Identifier [@Identifier], @EventDescription [@EventDescription], COUNT(*) [@NumberOfOccurences],
			MIN(TRH_StartDate) [@FirstOccurenceDate], MAX(TRH_StartDate) [@LastOccurenceDate],
			TST_ID [@TestID], TST_Name [@TestName], MOB_ID [@MOB_ID], MOB_Name [@MOB_Name],
			TST_ConnectionTimeout [@ConnectionTimeout], TST_QueryTimeout [@QueryTimeout],
			max(DATEDIFF(second, TRH_StartDate, TRH_EndDate)) [@MaxTestRunTimeSec],
			''Timeout expired'' [@ErrorMessage]
		for xml path(''Alert''), type) AlertEventData
from Collect.Tests
	inner join Collect.TestRunHistory t with (forceseek) on TST_ID = TRH_TST_ID
	inner join Inventory.MonitoredObjects on TRH_MOB_ID = MOB_ID
	outer apply (select t1.TRH_TRS_ID TRS_ID
					from Collect.TestRunHistory t1
					where t1.TRH_MOB_ID = t.TRH_MOB_ID
						and t1.TRH_TST_ID = TST_DontRunIfErrorIn_TST_ID
						and t1.TRH_EndDate is not null
						and t1.TRH_StartDate between dateadd(minute, -1, t.TRH_StartDate)
									and dateadd(minute, 1, t.TRH_StartDate)) t1
where MOB_OOS_ID = 1 AND TST_Name <> ''Database Instance Simple Query Response Time''
	and ((TST_ConnectionTimeout is not null and TST_ConnectionTimeout > 0)
			or (TST_QueryTimeout is not null and TST_QueryTimeout > 0)
		)
	and isnull(TST_ConnectionTimeout, 0) + ISNULL(TST_QueryTimeout, 0) <= DATEDIFF(second, TRH_StartDate, TRH_EndDate)
	and ' + case when @InLastMinutes is null
				then 'TRH_Timestamp > @LastTimeStamp and TRH_Timestamp <= @MostRecentTimestamp'
				else 'TRH_StartDate > dateadd(minute, -@InLastMinutes, sysdatetime())'
			end + char(13)+char(10)
	+ isnull(' and ' + EventProcessing.fn_ParseEventFilter(@PossibleFilters, @FilterDefinition) + char(13)+char(10), '')
+ 'group by TST_ID, TST_Name, MOB_ID, MOB_Name, TST_ConnectionTimeout, TST_QueryTimeout
having max(TRS_ID) = 3'

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
