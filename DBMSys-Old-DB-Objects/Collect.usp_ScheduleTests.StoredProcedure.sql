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
/****** Object:  StoredProcedure [Collect].[usp_ScheduleTests]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collect].[usp_ScheduleTests]
as
set nocount on
declare @SCT_ID int,
		@ClientID int,
		@UseExternalCollector bit,
		@DefaultConnectionTimeout int,
		@DefaultQueryTimeout int,
		@ErrorMessage nvarchar(2000),
		@Info xml,
		@RunningTests int,
		@RandomDelayMax int

if object_id('tempdb..#DisableMonitoredObjects') is not null
	drop table #DisableMonitoredObjects

select @ClientID = cast(SET_Value as int)
from Management.Settings
where SET_Module = 'Management'	and SET_Key = 'Client ID'

select @UseExternalCollector = cast(SET_Value as bit)
from Management.Settings
where SET_Module = 'Collect' and SET_Key = 'Use External Collector'

select @DefaultConnectionTimeout = cast(SET_Value as int)
from Management.Settings
where SET_Module = 'Collect' and SET_Key = 'Default Connection Timeout'

select @DefaultQueryTimeout = cast(SET_Value as int)
from Management.Settings
where SET_Module = 'Collect' and SET_Key = 'Default Query Timeout'

select @RandomDelayMax = cast(SET_Value as int)
from Management.Settings
where SET_Module = 'Collect' and SET_Key = 'Random Delay Maximum'

select @RandomDelayMax = isnull(@RandomDelayMax, 60 * 30)

if @UseExternalCollector = 0
begin
	--reset old launched tests that were not picked up for running
	declare @Processes table(ContextInfo int)
	insert into @Processes
	select distinct cast([context_info] as int)
	from sys.dm_exec_requests
	where context_info is not null
		and context_info <> 0x

	select @RunningTests = COUNT(*)
	from @Processes
	where exists (select *
					from Collect.ScheduledTests with (nolock, index=PK_ScheduledTests)
					where SCT_ID = ContextInfo
						and SCT_STS_ID < 4)

	if @RunningTests < (select cast(SET_Value as int)
							from Management.Settings
							where SET_Module = 'Collect'
								and SET_Key = 'Max Simultaneous Tests'
						)
		update Collect.ScheduledTests
		set SCT_STS_ID = 1,
			SCT_LaunchDate = null
		where SCT_STS_ID = 2
			and SCT_LaunchDate <= dateadd(second, -300, SYSDATETIME())

	--mark interrupted tests
	declare cInterrupted cursor static forward_only for
		select SCT_ID
		from Collect.ScheduledTests
		where SCT_STS_ID = 3
			and not exists
				(select *
				from sys.dm_exec_requests
				where context_info = cast(SCT_ID as binary(4)))
end
else
begin
	if (select count(*)
			from Collect.ScheduledTests with (nolock)
			where SCT_STS_ID = 3)
			< 
			(select cast(SET_Value as int)
				from Management.Settings
				where SET_Module = 'Collect'
					and SET_Key = 'Max Simultaneous Tests')
		update Collect.ScheduledTests
		set SCT_STS_ID = 1,
			SCT_LaunchDate = null
		where SCT_STS_ID = 2
			and SCT_LaunchDate <= dateadd(second, -600, SYSDATETIME())

	--mark interrupted tests
	declare cInterrupted cursor static forward_only for
		select SCT_ID
		from Collect.ScheduledTests
			inner join Collect.Tests on TST_ID = SCT_TST_ID
		where SCT_STS_ID = 3
			and datediff(second, SCT_ProcessStartDate, sysdatetime()) > isnull(TST_ConnectionTimeout, @DefaultConnectionTimeout) + isnull(TST_QueryTimeout, @DefaultQueryTimeout)
end

open cInterrupted

fetch next from cInterrupted into @SCT_ID
while @@fetch_status = 0
begin
	begin try
		begin transaction
			update Collect.ScheduledTests
			set SCT_STS_ID = 5
			where SCT_ID = @SCT_ID

			update Collect.TestRunHistory
			set TRH_EndDate = SYSDATETIME(),
				TRH_TRS_ID = 6
			from Collect.TestRunHistory with (forceseek)
			where TRH_SCT_ID = @SCT_ID
				and TRH_EndDate is null
		commit transaction
	end try
	begin catch
		set @ErrorMessage = ERROR_MESSAGE()
		if @@TRANCOUNT > 0
			rollback
		set @Info = (select 'Test Scheduler' [@Process], 'Fix Interrupted Scheudled Tests' [@Task], @SCT_ID [@SCT_ID] for xml path('Info'))
		exec Internal.usp_LogError @Info, @ErrorMessage
	end catch
	fetch next from cInterrupted into @SCT_ID
end
close cInterrupted
deallocate cInterrupted

--remove schedules deactivated tests
if exists (select *
				from Collect.ScheduledTests with (forceseek, nolock)
				where SCT_STS_ID = 1
					and exists (select *
									from Collect.Tests
									where TST_ID = SCT_TST_ID
										and TST_IsActive = 0)
			)
	update Collect.ScheduledTests
	set SCT_STS_ID = 7
	from Collect.Tests
	where SCT_TST_ID = TST_ID
		and SCT_STS_ID = 1
		and TST_IsActive = 0

select MOB_ID
into #DisableMonitoredObjects
from Inventory.MonitoredObjects
where MOB_OOS_ID not in (0, 1)

--remove schedules deactivated monitored objects
if exists (select *
				from Collect.ScheduledTests with (forceseek, nolock)
				where SCT_STS_ID = 1
					and exists (select *
									from #DisableMonitoredObjects
									where MOB_ID = SCT_MOB_ID)
			)
	update Collect.ScheduledTests
	set SCT_STS_ID = 8
	from #DisableMonitoredObjects
	where SCT_MOB_ID = MOB_ID
		and SCT_STS_ID = 1

--remove schedules for deleted test versions
if exists (select *
				from Collect.ScheduledTests with (forceseek, nolock)
				where SCT_STS_ID = 1
					and not exists (select *
									from Collect.TestVersions
									where SCT_TSV_ID = TSV_ID)
			)
	delete Collect.ScheduledTests
	where SCT_STS_ID in (1, 2)
		and not exists (select *
							from Collect.TestVersions
							where SCT_TSV_ID = TSV_ID)

;with Tests as
	(select TST_ID, TSV_ID, MOB_ID, TST_QRT_ID, TST_IntervalType, TST_IntervalPeriod, TST_RunFirstTimeImmediately, TST_MaxSuccessfulRuns
	from Collect.fn_GetObjectTests(default)
	where not exists (select *
						from Collect.ScheduledTests
						where SCT_TST_ID = TST_ID
							and SCT_MOB_ID = MOB_ID
							and SCT_STS_ID < 4)
	)
	, ToSchedule as
	(select TST_ID, TSV_ID, MOB_ID, NextRunDate,
			case when TRH_EndDate is null and TST_RunFirstTimeImmediately = 1
				then 2
				else 1
			end RNR_ID,
			TST_IntervalPeriodSec, TRH_EndDate LastRunDate
		from Tests
			outer apply (select top 1 TRH_EndDate
							from Collect.TestRunHistory with (forceseek)
								inner join Collect.RunningReasons on TRH_RNR_ID = RNR_ID
							where TRH_TST_ID = TST_ID
								and TRH_MOB_ID = MOB_ID
								and RNR_IgnoreForScheduledRuns = 0
								and TRH_TRS_ID in (3, 4)
							order by TRH_EndDate desc) t
			cross apply (
				select case TST_IntervalType
					when 's' then TST_IntervalPeriod 
					when 'm' then TST_IntervalPeriod * 60
					when 'h' then TST_IntervalPeriod * 60 * 60
					when 'd' then TST_IntervalPeriod * 60 * 60 * 24
				end as TST_IntervalPeriodSec) as TestIntervals
			cross apply Collect.fn_GetNextRunDateWrapper(
				TST_IntervalType, TST_IntervalPeriod, TRH_EndDate, TST_RunFirstTimeImmediately) n
			outer apply (select COUNT(*) SuccessfulRuns
							from Collect.TestRunHistory with (forceseek)
								inner join Collect.RunningReasons on TRH_RNR_ID = RNR_ID
							where TST_MaxSuccessfulRuns is not null
								and TRH_TST_ID = TST_ID
								and TRH_MOB_ID = MOB_ID
								and TRH_TRS_ID = 3) t1
		where TST_IntervalType is not null
			and (TST_MaxSuccessfulRuns is null
					or TST_MaxSuccessfulRuns > SuccessfulRuns)
	)
insert into Collect.ScheduledTests(
	SCT_TST_ID, SCT_TSV_ID, SCT_ClientID, SCT_MOB_ID,
	SCT_STS_ID, SCT_RNR_ID, SCT_DateToRun)
select
	TST_ID, TSV_ID, @ClientID, MOB_ID, 
	1 /*Scheduled*/, RNR_ID, 
	iif(LastRunDate is not null,
			dateadd(second, /* Limit randomization to 10% maximum. */
						cast(0.10 * rand(checksum(newid())) * TST_IntervalPeriodSec as int)
							% (@RandomDelayMax + 1),
							NextRunDate),
			NextRunDate)
from ToSchedule
GO
