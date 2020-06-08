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
/****** Object:  StoredProcedure [ResponseProcessing].[usp_ExtractBlackBoxInfo]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ResponseProcessing].[usp_ExtractBlackBoxInfo]
	@ESP_ID int,
	@MOB_ID int,
	@EventInstanceName varchar(850),
	@DateTime datetime2(3),
	@Blackboxes xml output
as
set nocount on
declare @MaxWaitTimeSeconds int,
		@l_MOB_ID int,
		@TST_ID int,
		@SCT_ID int,
		@WaitStart datetime2(3),
		@ProcedureName nvarchar(257),
		@Parameters xml,
		@SQL nvarchar(max),
		@Blackbox xml,
		@sBlackboxes nvarchar(max)

declare @BlackboxTestsToRun table(TST_ID int,
									IRL_ID tinyint,
									MaxWaitTimeSeconds int,
									AllowedBufferSeconds int)

if OBJECT_ID('tempdb..#SelectedMonitoredObjects') is not null
	drop table #SelectedMonitoredObjects

create table #SelectedMonitoredObjects(S_MOB_ID int not null,
										S_MOB_Name nvarchar(128) not null,
										S_PLT_ID tinyint not null,
										S_EventInstanceName varchar(850) null,
										S_TST_ID int,
										S_AllowedBufferSeconds int,
										S_SCT_ID int null,
										S_DateTime datetime2(3) null)

if exists (select *
			from ResponseProcessing.EventSubscriptions_BlackBoxeTypes
			where EBB_ESP_ID = @ESP_ID)
begin
	insert into @BlackboxTestsToRun
	select BTD_TST_ID, max(EBB_IRL_ID), min(EBB_MaxWaitTimeSeconds), min(BBT_AllowedBufferSeconds)
	from ResponseProcessing.EventSubscriptions_BlackBoxeTypes
		inner join ResponseProcessing.BlackBoxTypes on BBT_ID = EBB_BBT_ID
		left join ResponseProcessing.BlackBoxTypeTestDependencies on EBB_BBT_ID = BTD_BBT_ID
	where EBB_ESP_ID = @ESP_ID
	group by BTD_TST_ID

	;with RelatedInstances as
			(select PCR_Child_MOB_ID I_MOB_ID, TST_ID I_TST_ID, AllowedBufferSeconds I_AllowedBufferSeconds
				from Inventory.ParentChildRelationships
					cross join @BlackboxTestsToRun
				where PCR_Parent_MOB_ID = @MOB_ID
					and ((IRL_ID = 0 and 1 = 0)
							or (IRL_ID = 1 and PCR_IsCurrentParent = 1)
							or IRL_ID = 2
						)
				union
				select PCR_Parent_MOB_ID I_MOB_ID, TST_ID I_TST_ID, AllowedBufferSeconds I_AllowedBufferSeconds
				from Inventory.ParentChildRelationships
					cross join @BlackboxTestsToRun
				where PCR_Child_MOB_ID = @MOB_ID
					and ((IRL_ID = 0 and 1 = 0)
							or (IRL_ID = 1 and PCR_IsCurrentParent = 1)
							or IRL_ID = 2
						)
				union
				select PCR_Child_MOB_ID I_MOB_ID, TST_ID I_TST_ID, AllowedBufferSeconds I_AllowedBufferSeconds
				from Inventory.ParentChildRelationships
					cross join @BlackboxTestsToRun
				where PCR_Parent_MOB_ID in (select PCR_Parent_MOB_ID
											from Inventory.ParentChildRelationships
											where PCR_Child_MOB_ID = @MOB_ID
												and PCR_IsCurrentParent = 1)
					and ((IRL_ID = 0 and 1 = 0)
							or (IRL_ID = 1 and PCR_IsCurrentParent = 1)
							or IRL_ID = 2
						)
				union
				select @MOB_ID I_MOB_ID, TST_ID I_TST_ID, AllowedBufferSeconds I_AllowedBufferSeconds
				from @BlackboxTestsToRun
			)
	insert into #SelectedMonitoredObjects(S_MOB_ID, S_MOB_Name, S_PLT_ID, S_EventInstanceName, S_TST_ID, S_AllowedBufferSeconds)
	select distinct I_MOB_ID, MOB_Name, MOB_PLT_ID, @EventInstanceName, I_TST_ID, I_AllowedBufferSeconds
	from RelatedInstances r
		inner join Inventory.MonitoredObjects on I_MOB_ID = MOB_ID
		outer apply Collect.fn_GetObjectTests(I_TST_ID) df
	where I_MOB_ID = df.MOB_ID
		or I_TST_ID is null

	if exists (select * from #SelectedMonitoredObjects where S_TST_ID is not null)
		select @MaxWaitTimeSeconds = MIN(MaxWaitTimeSeconds)
		from @BlackboxTestsToRun

		;with SelectedMonitoredObjects as
			(select S_MOB_ID, S_DateTime, TRH_StartDate StartDate
				from #SelectedMonitoredObjects
					cross apply (select top 1 TRH_StartDate
									from Collect.TestRunHistory
									where TRH_TST_ID = S_TST_ID
										and TRH_MOB_ID = S_MOB_ID
										and (TRH_StartDate between dateadd(second, -S_AllowedBufferSeconds, @DateTime)
																and dateadd(second, S_AllowedBufferSeconds, @DateTime)
												or TRH_StartDate > @DateTime and TRH_RNR_ID = 5)
									order by TRH_ID desc) t
			)
		update SelectedMonitoredObjects
		set S_DateTime = StartDate

		declare cNoRecentTest cursor static forward_only for
			select S_MOB_ID, S_TST_ID
			from #SelectedMonitoredObjects
				outer apply (select top 1 TRH_TRS_ID
								from Collect.Tests 
									inner join Collect.TestRunHistory on TRH_TST_ID = TST_DontRunIfErrorIn_TST_ID
								where TST_ID = S_TST_ID
									and TRH_MOB_ID = S_MOB_ID
									and TRH_EndDate is not null
								order by TRH_ID desc
							) t
			where S_DateTime is null
				and S_TST_ID is not null
				and (TRH_TRS_ID = 3
						or TRH_TRS_ID is null)

		open cNoRecentTest
		fetch next from cNoRecentTest into @l_MOB_ID, @TST_ID
		while @@fetch_status = 0
		begin
			exec Collect.usp_ScheduleTestManually @TST_ID = @TST_ID,
													@MOB_ID = @l_MOB_ID,
													@RNR_ID = 5,
													@SCT_ID = @SCT_ID output
			update #SelectedMonitoredObjects
			set S_SCT_ID = @SCT_ID
			where S_MOB_ID = @l_MOB_ID

			fetch next from cNoRecentTest into @l_MOB_ID, @TST_ID
		end
		close cNoRecentTest
		deallocate cNoRecentTest

		set @WaitStart = sysdatetime()
		while exists (select *
						from Collect.ScheduledTests
							inner join #SelectedMonitoredObjects on S_SCT_ID = SCT_ID
						where SCT_STS_ID < 4)
					and (@WaitStart > dateadd(second, -@MaxWaitTimeSeconds, sysdatetime())
							or @MaxWaitTimeSeconds is null)
			waitfor delay '00:00:00.2'

		update #SelectedMonitoredObjects
		set S_DateTime = TRH_StartDate
		from Collect.TestRunHistory
		where TRH_SCT_ID = S_SCT_ID
	end

set @sBlackboxes = '<Blackboxes>'

declare cBlackBoxes cursor static forward_only for
	select BBT_ProcedureName, EBB_Parameters
	from ResponseProcessing.EventSubscriptions_BlackBoxeTypes
		inner join ResponseProcessing.BlackBoxTypes on BBT_ID = EBB_BBT_ID
	where EBB_ESP_ID = @ESP_ID
	order by EBB_Priority

open cBlackBoxes
fetch next from cBlackBoxes into @ProcedureName, @Parameters
while @@fetch_status = 0
begin
	set @SQL = 'exec ' + @ProcedureName + ' @Parameters = @Parameters,' + CHAR(13)+CHAR(10)
				+ '							@BlackBox = @BlackBox output'
	exec sp_executesql @SQL,
						N'@Parameters xml,
							@Blackbox xml output',
						@Parameters = @Parameters,
						@Blackbox = @Blackbox output
	set @sBlackboxes += cast(@Blackbox as nvarchar(max))
	fetch next from cBlackBoxes into @ProcedureName, @Parameters
end
close cBlackBoxes
deallocate cBlackBoxes

set @Blackboxes = cast(@sBlackboxes + '</Blackboxes>' as xml)
GO
