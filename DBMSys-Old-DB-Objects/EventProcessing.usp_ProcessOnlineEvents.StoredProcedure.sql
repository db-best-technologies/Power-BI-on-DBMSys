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
/****** Object:  StoredProcedure [EventProcessing].[usp_ProcessOnlineEvents]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [EventProcessing].[usp_ProcessOnlineEvents]
	@i_MEG_ID int = null,
	@i_MOV_ID int = null
as
set nocount on

UPDATE	EventProcessing.TrappedEvents
SET		TRE_IsClosed = 1
		,TRE_CloseDate = GETUTCDATE()
WHERE	TRE_IsClosed = 0
		AND NOT EXISTS (
					SELECT 
							* 
					FROM	Inventory.MonitoredObjects 
					WHERE	MOB_ID = TRE_MOB_ID
							AND MOB_OOS_ID IN (0,1)
				)

declare @ClientID int,
		@MOV_ID int,
		@EventDescription nvarchar(1000),
		@MEG_ID int,
		@EventLevel tinyint,
		@NecessaryEventDefinitions int,
		@EDF_ID int,
		@EFT_ID tinyint,
		@SystemID tinyint,
		@CounterID int,
		@CounterInstanceName varchar(900),
		@AutoResolveMinutes smallint,
		@InLastMinutes smallint,
		@FromNumberOfOccurrences int,
		@ToNumberOfOccurrences int,
		@Operator varchar(50),
		@AlertValue decimal(18, 5),
		@AlertStatus varchar(850),
		@OKFromNumberOfOccurrences int,
		@OKToNumberOfOccurrences int,
		@OKOperator varchar(50),
		@OKValue  decimal(18, 5),
		@OKStatus varchar(850),
		@CGT_ID tinyint,
		@ProcedureName nvarchar(257),
		@OKProcedureName nvarchar(257),
		@IgnoreInstanceName bit,
		@Top int,
		@CounterSystemName varchar(100),
		@CounterCategoryName nvarchar(128),
		@CounterName nvarchar(128),
		@FilterDefinition xml,
		@PossibleFilters xml,
		@EventFilter nvarchar(max),
		@PRC_ID int,
		@LastTimestamp binary(8),
		@MostRecentTimestamp binary(8),
		@AlertSQL nvarchar(max),
		@OKSQL nvarchar(max),
		@ErrorMessage nvarchar(max),
		@SpecificCasesMaxCount int

declare @LastTimestamps table(L_EDF_ID int not null,
								L_Timestamp binary(8))
declare @EscalatedEvents table(MOB_ID int,
								EventInstanceName varchar(850),
								MEG_ID int,
								EventLevel tinyint)

if OBJECT_ID('tempdb..#CounterInput') is not null
	drop table #CounterInput

create table #CounterInput(MOB_ID int,
		InstanceName varchar(850),
		CounterDateTime datetime2(3),
		CounterValue decimal(18, 5),
		CounterStatus varchar(100),
		ErrorMessage nvarchar(2000),
		ValueSum decimal(38, 5))

if OBJECT_ID('tempdb..#CounterInputCalc') is not null
	drop table #CounterInputCalc

create table #CounterInputCalc(MOB_ID int,
		InstanceName varchar(850),
		CounterDateTime datetime2(3),
		CounterValue decimal(18, 5),
		CounterStatus varchar(100),
		ErrorMessage nvarchar(2000))

if OBJECT_ID('tempdb..#CounterInputOKCalc') is not null
	drop table #CounterInputOKCalc

create table #CounterInputOKCalc(MOB_ID int,
		InstanceName varchar(850),
		CounterDateTime datetime2(3),
		CounterValue decimal(18, 5),
		CounterStatus varchar(100))

if OBJECT_ID('tempdb..#NewEvents') is not null
	drop table #NewEvents
create table #NewEvents(F_MOB_ID int,
		F_InstanceName nvarchar(1000),
		F_FirstEventDate datetime,
		F_LastEventDate datetime,
		F_EventCount int,
		F_HasSuccesfulRuns bit,
		F_Timestamp binary(8),
		F_Message nvarchar(max),
		F_AlertEventData xml)

if OBJECT_ID('tempdb..#NewOKEvents') is not null
	drop table #NewOKEvents
create table #NewOKEvents(F_MOB_ID int,
		F_InstanceName nvarchar(1000),
		F_FirstEventDate datetime,
		F_LastEventDate datetime,
		F_EventCount int,
		F_IsEventCompletelyClosed bit,
		F_Timestamp binary(8),
		F_Message nvarchar(max),
		F_OKEventData xml)

if OBJECT_ID('tempdb..#NewEventsCalc') is not null
	drop table #NewEventsCalc
create table #NewEventsCalc
		(F_EDF_ID int,
		F_MOB_ID int,
		F_InstanceName nvarchar(1000),
		F_FirstEventDate datetime2(3),
		F_LastEventDate datetime2(3),
		F_EventCount int,
		F_Timestamp binary(8),
		F_Message nvarchar(max),
		F_AlertEventData xml,
		F_AutoResolveMinutes smallint)

if OBJECT_ID('tempdb..#NewOKEventsCalc') is not null
	drop table #NewOKEventsCalc
create table #NewOKEventsCalc
		(F_EDF_ID int,
		F_MOB_ID int,
		F_InstanceName nvarchar(1000),
		F_FirstOKEventDate datetime2(3),
		F_LastOKEventDate datetime2(3),
		F_OKEventCount int,
		F_IsEventCompletelyClosed bit,
		F_Timestamp binary(8),
		F_Message nvarchar(max),
		F_OKEventData xml)
	
select @ClientID = cast(SET_Value as int)
from Management.Settings
where SET_Module = 'Management'
	and SET_Key = 'Client ID'

declare cMonitoredEvents cursor static forward_only for
	select MOV_ID, MOV_Description, MOV_MEG_ID, MOV_Level, count(*) NecessaryEventDefinitions
	from EventProcessing.MonitoredEvents
		inner join EventProcessing.EventDefinitions on EDF_MOV_ID = MOV_ID
		cross apply (select cast(convert(char(11), sysdatetime(), 121) + MOV_FromHour as datetime) FromHour,
						cast(convert(char(11), sysdatetime(), 121) + MOV_ToHour as datetime) ToHourToday,
						cast(convert(char(11), dateadd(day, 1, sysdatetime()), 121) + MOV_ToHour as datetime) ToHourTomorrow
					) h
	where MOV_IsActive = 1
		and (MOV_MEG_ID = @i_MEG_ID
				or @i_MEG_ID is null)
		and (MOV_ID = @i_MOV_ID
				or @i_MOV_ID is null)
		and (MOV_Weekdays is null
				or MOV_Weekdays like '%' + cast(datepart(weekday, sysdatetime()) as char(1)) + '%')
		and (MOV_FromHour is null
				or MOV_ToHour is null
				or (FromHour < ToHourToday
						and sysdatetime() between FromHour and ToHourToday)
				or (FromHour > ToHourToday
						and sysdatetime() between FromHour and ToHourTomorrow))
	group by MOV_ID, MOV_Description, MOV_MEG_ID, MOV_Level
	order by MOV_MEG_ID, MOV_Level desc

open cMonitoredEvents
fetch next from cMonitoredEvents into @MOV_ID, @EventDescription, @MEG_ID, @EventLevel, @NecessaryEventDefinitions
while @@fetch_status = 0
begin
	insert into EventProcessing.ProcessCycles(PRC_ClientID, PRC_MOV_ID, PRC_StartDate)
	values(@ClientID, @MOV_ID, sysdatetime())

	set @PRC_ID = SCOPE_IDENTITY()

	begin try
		if @MEG_ID is not null
		begin
			insert into @EscalatedEvents(MOB_ID, EventInstanceName, MEG_ID, EventLevel)
			select TRE_MOB_ID, TRE_EventInstanceName, TRE_MEG_ID, TRE_Level
			from EventProcessing.TrappedEvents
			where TRE_IsClosed = 0
				and TRE_MEG_ID = @MEG_ID
				and TRE_Level > @EventLevel

			update EventProcessing.EventDefinitionStatuses
			set EDS_IsClosed = 1,
				EDS_Last_PRC_ID = @PRC_ID,
				EDS_TEC_ID = 3,
				EDS_OKMessage = 'The event has escalated.'
			from EventProcessing.EventDefinitions
			where EDS_EDF_ID = EDF_ID
				and EDF_MOV_ID = @MOV_ID
				and EDS_IsClosed = 0
				and exists (select *
							from @EscalatedEvents
							where MOB_ID = EDS_MOB_ID
								and (EventInstanceName = EDS_EventInstanceName
										or (EventInstanceName is null
											and EDS_EventInstanceName is null)
									)
							)
		end

		declare cEventDefintions cursor static forward_only for
			select EDF_ID, EDF_EFT_ID, COC_SystemID, COC_CounterID, COC_InstanceName, EDF_AutoResolveMinutes,
				EDF_InLastMinutes, EDF_FromNumberOfOccurrences, EDF_ToNumberOfOccurrences, a.ORT_Operator, COC_Value, COC_Status,
				EDF_OKFromNumberOfOccurrences, EDF_OKToNumberOfOccurrences, o.ORT_Operator, COC_OKValue, COC_OKStatus, COC_CGT_ID,
				ACT_ProcedureName, ACT_OKProcedureName, ACC_FilterDefinition, ACT_PossibleFilters, EDF_IgnoreInstanceName
			from EventProcessing.EventDefinitions
				left join EventProcessing.CounterConditions on EDF_EFT_ID = 1
																and EDF_ID = COC_EDF_ID
				left join EventProcessing.ActivityConditions on EDF_EFT_ID = 2
																and EDF_ID = ACC_EDF_ID
				left join EventProcessing.ActivityConditionTypes on ACC_ACT_ID = ACT_ID
				left join EventProcessing.OperatorTypes a on COC_ORT_ID = a.ORT_ID
				left join EventProcessing.OperatorTypes o on COC_OK_ORT_ID = o.ORT_ID
			where EDF_MOV_ID = @MOV_ID

		open cEventDefintions
		fetch next from cEventDefintions into @EDF_ID, @EFT_ID, @SystemID, @CounterID, @CounterInstanceName, @AutoResolveMinutes, @InLastMinutes,
												@FromNumberOfOccurrences, @ToNumberOfOccurrences, @Operator, @AlertValue, @AlertStatus, @OKFromNumberOfOccurrences,
												@OKToNumberOfOccurrences, @OKOperator, @OKValue, @OKStatus, @CGT_ID, @ProcedureName, @OKProcedureName, @FilterDefinition,
												@PossibleFilters, @IgnoreInstanceName
		while @@fetch_status = 0
		begin

			select @AlertSQL = null,
					@OKSQL = null
			if @EFT_ID = 1
			begin
				select @CounterSystemName = CSY_Name,
						@CounterCategoryName = CategoryName,
						@CounterName = CounterName
				from PerformanceData.VW_Counters
					inner join PerformanceData.CounterSystems on SystemID = CSY_ID
				where SystemID = @SystemID
					and CounterID = @CounterID

				if @InLastMinutes is not null
					insert into #CounterInput(MOB_ID, InstanceName, CounterDateTime, CounterValue, CounterStatus, ErrorMessage, ValueSum)
					select CRS_MOB_ID, case when @IgnoreInstanceName = 0 then CIN_Name end InstanceName, CRS_DateTime, CRS_Value, CRT_Name, TRH_ErrorMessage,
							case when @CGT_ID = 2
									then SUM(CRS_Value) over (partition by CRS_MOB_ID,
																	case when @IgnoreInstanceName = 1
																			then CIN_Name
																		end)
								end SumCounter
					from PerformanceData.CounterResults
						left join PerformanceData.CounterInstances on CRS_InstanceID = CIN_ID
						left join PerformanceData.CounterResultStatuses on CRS_CRT_ID = CRT_ID
						left join Collect.TestRunHistory on CRS_TRH_ID = TRH_ID
						LEFT JOIN Inventory.MonitoredObjects ON TRH_MOB_ID = MOB_ID AND MOB_OOS_ID IN (0,1)
					where CRS_SystemID = @SystemID
						and CRS_CounterID = @CounterID
						and (CIN_Name = @CounterInstanceName or @CounterInstanceName is null)
						and CRS_DateTime >= DATEADD(minute, -@InLastMinutes, sysdatetime())
				else
				begin
					set @SpecificCasesMaxCount = null

					select @SpecificCasesMaxCount = MAX(Infra.fn_GetLargestValue(EDC_FromNumberOfOccurrences, EDC_ToNumberOfOccurrences, EDC_OKFromNumberOfOccurrences, EDC_OKToNumberOfOccurrences, null))
					from EventProcessing.EventDefinitionSpecificCases
					where EDC_EDF_ID = @EDF_ID
					
					set @Top = Infra.fn_GetLargestValue(@FromNumberOfOccurrences, @ToNumberOfOccurrences, @OKFromNumberOfOccurrences, @OKToNumberOfOccurrences, @SpecificCasesMaxCount)

					insert into #CounterInput(MOB_ID, InstanceName, CounterDateTime, CounterValue, CounterStatus, ErrorMessage, ValueSum)
					select CRS_MOB_ID, case when @IgnoreInstanceName = 0 then CIN_Name end InstanceName, CRS_DateTime, CRS_Value, CRT_Name, TRH_ErrorMessage,
							case when @CGT_ID = 2
									then SUM(CRS_Value) over (partition by CRS_MOB_ID,
																	case when @IgnoreInstanceName = 1
																			then CIN_Name
																		end)
								end SumCounter
					from Inventory.MonitoredObjects
						cross apply (select CRS_ClientID, CRS_MOB_ID, CIN_Name, CRS_DateTime, CRS_Value, CRT_Name,  TRH_ErrorMessage,
											ROW_NUMBER() over (partition by CRS_ClientID, CRS_MOB_ID, CIN_Name order by CRS_ID desc) rn
										from PerformanceData.CounterResults with (nolock, forceseek, index=IX_CounterResults_CRS_MOB_ID#CRS_SystemID#CRS_CounterID#CRS_InstanceID#CRS_IDB_ID##CRS_ID#CRS_TRH_ID#CRS_Value#CRS_CRT_ID)
											left join PerformanceData.CounterInstances on CRS_InstanceID = CIN_ID
											left join PerformanceData.CounterResultStatuses on CRS_CRT_ID = CRT_ID
											left join Collect.TestRunHistory on CRS_TRH_ID = TRH_ID
										where CRS_MOB_ID = MOB_ID
											and CRS_SystemID = @SystemID
											and CRS_CounterID = @CounterID
											and (CIN_Name = @CounterInstanceName or @CounterInstanceName is null)
											and CRS_DateTime >= DATEADD(hour, -2, sysdatetime())
									) p
					where	rn <= @Top
							AND MOB_OOS_ID IN (0,1)
				end

				set @AlertSQL =
							'select '
							+ case @CGT_ID
									when 1 then 'MOB_ID, InstanceName, CounterDateTime, CounterValue, CounterStatus, ErrorMessage'
									when 2 then 'MOB_ID, InstanceName, CounterDateTime, ValueSum, CounterStatus, ErrorMessage'
								end + char(13)+char(10)
							+ 'from #CounterInput' + char(13)+char(10)
							+ 'where 1 = 1' + 
							+ case when @AlertValue is not null
									then char(13)+char(10) + '	and ' + case @CGT_ID
																			when 1 then 'CounterValue'
																			when 2 then 'ValueSum'
																	end + @Operator + ' ' + CAST(@AlertValue as nvarchar(100))
									else ''
								end
							+ case when @AlertStatus is not null
									then char(13)+char(10) + '	and CounterStatus ' + @Operator + ' ''' + CAST(@AlertStatus as nvarchar(100)) + ''''
									else ''
								end

				insert into #CounterInputCalc(MOB_ID, InstanceName, CounterDateTime, CounterValue, CounterStatus, ErrorMessage)
				exec(@AlertSQL)

				if @@ROWCOUNT > 0
					insert into #NewEventsCalc(F_EDF_ID, F_MOB_ID, F_InstanceName, F_FirstEventDate, F_LastEventDate,
												F_EventCount, F_Message, F_AlertEventData, F_AutoResolveMinutes)
					select @EDF_ID, c.MOB_ID,
						InstanceName, min(CounterDateTime), max(CounterDateTime),
						case @CGT_ID
							when 1 then count(*)
							when 2 then avg(CounterValue)
						end,
						'Counter System Name: ' + @CounterSystemName + char(13)+char(10)
						+ 'Counter Category Name: ' + @CounterCategoryName + char(13)+char(10)
						+ 'Counter Name: ' + @CounterName + char(13)+char(10)
						+ isnull('Instance Name: ' + InstanceName + char(13)+char(10), '')
						+ isnull('Test Error Message: ' + max(ErrorMessage) + char(13)+char(10), '')
						+ 'Number of Occurrences: ' + cast(case @CGT_ID
																when 1 then count(*)
																when 2 then avg(CounterValue)
															end as nvarchar(10)) + char(13)+char(10)
						+ case when @AlertValue is not null
								then 'Event(s) Encountered: Value ' + @Operator + ' ' + CAST(@AlertValue as nvarchar(100)) + char(13)+char(10)
									+ case when min(CounterValue) = max(CounterValue)
											then 'Value: ' + cast(min(CounterValue) as nvarchar(20))
											else 'Min. Value: ' + cast(min(CounterValue) as nvarchar(20)) + char(13)+char(10)
												+ 'Max. Value: ' + cast(max(CounterValue) as nvarchar(20))
										end + char(13)+char(10)
								else ''
							end
						+ case when @AlertStatus is not null
								then 'Event(s) Encountered: Status ' + @Operator + ' ' + CAST(@AlertStatus as nvarchar(100)) + char(13)+char(10)
									+ 'Status(es): ' + stuff((select distinct ', ' + CounterStatus
																from #CounterInputCalc c1
																where c.MOB_ID = c1.MOB_ID
																	and (c.InstanceName = c1.InstanceName
																			or (c.InstanceName is null
																					and c1.InstanceName is null))
																for xml path('')), 1, 2, '') + char(13)+char(10)
								else ''
							end
						+ 'First Occurrence: ' + convert(char(19), min(CounterDateTime), 121) + char(13)+char(10)
						+ 'Last Occurrence: ' + convert(char(19), max(CounterDateTime), 121),
							(select (select 'EDF_ID' [@Name], cast(@EDF_ID as sql_variant) where @EDF_ID is not null for xml path('Col'), type),
								(select 'Counter system name' [@Name], cast(@CounterSystemName as sql_variant) where @CounterSystemName is not null for xml path('Col'), type),
								(select 'Counter category name' [@Name], cast(@CounterCategoryName as sql_variant) where @CounterCategoryName is not null for xml path('Col'), type),
								(select 'Counter name' [@Name], cast(@CounterName as sql_variant) where @CounterName is not null for xml path('Col'), type),
								(select 'Counter instance name' [@Name], cast(InstanceName as sql_variant) where InstanceName is not null for xml path('Col'), type),
								(select 'Test Run error message' [@Name], cast(max(ErrorMessage) as sql_variant) where max(ErrorMessage) is not null for xml path('Col'), type),
								(select 'Number of occurences' [@Name], cast(count(CounterValue) as sql_variant) where count(CounterValue) is not null for xml path('Col'), type),
								(select 'Min value' [@Name], cast(min(CounterValue) as sql_variant) where min(CounterValue) is not null for xml path('Col'), type),
								(select 'Max value' [@Name], cast(max(CounterValue) as sql_variant) where max(CounterValue) is not null for xml path('Col'), type),
								(select 'Statuses' [@Name], cast(stuff((select distinct ', ' + CounterStatus
																from #CounterInputCalc c1
																where c.MOB_ID = c1.MOB_ID
																	and (c.InstanceName = c1.InstanceName
																			or (c.InstanceName is null
																					and c1.InstanceName is null))
																for xml path('')), 1, 2, '') as varchar(8000)) where cast(stuff((select distinct ', ' + CounterStatus
																from #CounterInputCalc c1
																where c.MOB_ID = c1.MOB_ID
																	and (c.InstanceName = c1.InstanceName
																			or (c.InstanceName is null
																					and c1.InstanceName is null))
																for xml path('')), 1, 2, '') as varchar(8000)) is not null for xml path('Col'), type),
								(select 'First occurence date' [@Name], cast(min(CounterDateTime) as sql_variant) where min(CounterDateTime) is not null for xml path('Col'), type),
								(select 'Last occurence date' [@Name], cast(max(CounterDateTime) as sql_variant) where max(CounterDateTime) is not null for xml path('Col'), type)
							for xml path('Columns'), type)/* + ' MOB_OOS_ID = ' + CAST(MOB_OOS_ID AS NVARCHAR(10))*/ AlertEventData ,
						@AutoResolveMinutes
					from #CounterInputCalc c
						inner join Inventory.MonitoredObjects m on c.MOB_ID = m.MOB_ID
					where not exists (select *
										from @EscalatedEvents e
										where e.MOB_ID = c.MOB_ID
											and (e.EventInstanceName = c.InstanceName
													or (e.EventInstanceName is null
															and c.InstanceName is null)
												)
										)
					group by c.MOB_ID, MOB_Name, InstanceName

				if @OKOperator is not null
				begin
					set @OKSQL =
								'select '
								+ case @CGT_ID
										when 1 then 'MOB_ID, InstanceName, CounterDateTime, CounterValue, CounterStatus'
										when 2 then 'distinct MOB_ID, InstanceName, CounterDateTime, ValueSum, CounterStatus'
									end + char(13)+char(10)
								+ 'from #CounterInput' + char(13)+char(10)
								+ 'where 1 = 1' + 
								+ case when @AlertValue is not null
										then char(13)+char(10) + '	and ' + case @CGT_ID
																				when 1 then 'CounterValue'
																				when 2 then 'ValueSum'
																		end + @OKOperator + ' ' + CAST(@OKValue as nvarchar(100))
										else ''
									end
								+ case when @AlertStatus is not null
										then char(13)+char(10) + '	and CounterStatus ' + @OKOperator + ' ''' + CAST(@OKStatus as nvarchar(100)) + ''''
										else ''
									end

					insert into #CounterInputOKCalc(MOB_ID, InstanceName, CounterDateTime, CounterValue, CounterStatus)
					exec(@OKSQL)
				end
				else
				begin
					if @AutoResolveMinutes is null
					begin
						insert into #CounterInputOKCalc
						select EDS_MOB_ID, EDS_EventInstanceName, sysdatetime(), 0, null
						from EventDefinitionStatuses
						where EDS_EDF_ID = @EDF_ID
							and not exists (select *
												from #CounterInputCalc
												where MOB_ID = EDS_MOB_ID
													and (InstanceName = EDS_EventInstanceName
															or (InstanceName is null and EDS_EventInstanceName is null)
														)
												)
					end
				end

				insert into #NewOKEventsCalc(F_EDF_ID, F_MOB_ID, F_InstanceName, F_FirstOKEventDate, F_LastOKEventDate, F_OKEventCount,
											F_IsEventCompletelyClosed, F_Message, F_OKEventData)
				select @EDF_ID, MOB_ID,
					InstanceName, min(CounterDateTime), max(CounterDateTime),
					case @CGT_ID
							when 1 then count(*)
							when 2 then avg(CounterValue)
						end, 0,
					'Counter System Name: ' + @CounterSystemName + char(13)+char(10)
					+ 'Counter Category Name: ' + @CounterCategoryName + char(13)+char(10)
					+ 'Counter Name: ' + @CounterName + char(13)+char(10)
					+ isnull('Instance Name: ' + InstanceName + char(13)+char(10), '')
					+ case when @AutoResolveMinutes is null and @OKOperator is null
						then 'Message: No new occurences'
								+ case when @InLastMinutes is not null
										then ' in the past ' + CAST(@InLastMinutes as varchar(10)) + ' minutes.'
										else ''
									end
						else 'Number of Occurrences: ' + cast(case @CGT_ID
																	when 1 then count(*)
																	when 2 then avg(CounterValue)
																end as nvarchar(10)) + char(13)+char(10)
							+ case when @OKValue is not null
									then 'Event(s) Encountered: Value ' + @OKOperator + ' ' + CAST(@OKValue as nvarchar(100)) + char(13)+char(10)
										+ 'Min. Value: ' + cast(min(CounterValue) as nvarchar(20)) + char(13)+char(10)
										+ 'Max. Value: ' + cast(max(CounterValue) as nvarchar(20)) + char(13)+char(10)
									else ''
								end
							+ case when @OKStatus is not null
									then 'Event(s) Encountered: Status ' + @OKOperator + ' ' + CAST(@OKStatus as nvarchar(100)) + char(13)+char(10)
										+ 'Status(es): ' + stuff((select distinct ', ' + CounterStatus
																	from #CounterInputOKCalc c1
																	where c.MOB_ID = c1.MOB_ID
																		and (c.InstanceName = c1.InstanceName
																				or (c.InstanceName is null
																						and c1.InstanceName is null))
																	for xml path('')), 1, 2, '') + char(13)+char(10)
									else ''
								end
							+ 'First Occurrence: ' + convert(char(19), min(CounterDateTime), 121) + char(13)+char(10)
							+ 'Last Occurrence: ' + convert(char(19), max(CounterDateTime), 121)
					end,
						(select (select 'EDF_ID' [@Name], cast(@EDF_ID as sql_variant) where @EDF_ID is not null for xml path('Col'), type),
								(select 'Number of occurences' [@Name], cast(count(CounterValue) as sql_variant) where count(CounterValue) is not null for xml path('Col'), type),
								(select 'Min value' [@Name], cast(min(CounterValue) as sql_variant) where min(CounterValue) is not null for xml path('Col'), type),
								(select 'Max value' [@Name], cast(max(CounterValue) as sql_variant) where max(CounterValue) is not null for xml path('Col'), type),
								(select 'Statuses' [@Name], cast(stuff((select distinct ', ' + CounterStatus
																from #CounterInputCalc c1
																where c.MOB_ID = c1.MOB_ID
																	and (c.InstanceName = c1.InstanceName
																			or (c.InstanceName is null
																					and c1.InstanceName is null))
																for xml path('')), 1, 2, '') as varchar(8000)) where stuff((select distinct ', ' + CounterStatus
																from #CounterInputCalc c1
																where c.MOB_ID = c1.MOB_ID
																	and (c.InstanceName = c1.InstanceName
																			or (c.InstanceName is null
																					and c1.InstanceName is null))
																for xml path('')), 1, 2, '') is not null for xml path('Col'), type),
								(select 'First occurence date' [@Name], cast(min(CounterDateTime) as sql_variant) where min(CounterDateTime) is not null for xml path('Col'), type),
								(select 'Last occurence date' [@Name], cast(max(CounterDateTime) as sql_variant) where max(CounterDateTime) is not null for xml path('Col'), type),
								(select 'Message' [@Name], cast(case when @AutoResolveMinutes is null and @OKOperator is null
																				then 'No new occurences'
																						+ case when @InLastMinutes is not null
																								then ' in the past ' + CAST(@InLastMinutes as varchar(10)) + ' minutes.'
																								else ''
																						end
																			end as sql_variant) where case when @AutoResolveMinutes is null and @OKOperator is null
																				then 'No new occurences'
																						+ case when @InLastMinutes is not null
																								then ' in the past ' + CAST(@InLastMinutes as varchar(10)) + ' minutes.'
																								else ''
																						end
																			end is not null for xml path('Col'), type)
						for xml path('Columns'), type) OKEventData
				from #CounterInputOKCalc c
				where not exists (select *
									from @EscalatedEvents e
									where e.MOB_ID = c.MOB_ID
										and (e.EventInstanceName = c.InstanceName
												or (e.EventInstanceName is null
														and c.InstanceName is null)
											)
								)
				group by MOB_ID, InstanceName

				if @InLastMinutes is not null
					delete f
					from #NewEventsCalc f
					where exists (select *
									from #NewOKEventsCalc o
									where o.F_EDF_ID = f.F_EDF_ID
											and o.F_MOB_ID = f.F_MOB_ID
											and (o.F_InstanceName = f.F_InstanceName
															or (o.F_InstanceName is null
																	and f.F_InstanceName is null)
															)
											and o.F_LastOKEventDate > f.F_LastEventDate
								)
							and exists (select *
											from EventProcessing.TrappedEvents
											where TRE_MOV_ID = @MOV_ID
												and TRE_IsClosed = 1
												and TRE_CloseDate > dateadd(minute, -@InLastMinutes, sysdatetime()))

				truncate table #CounterInput
				truncate table #CounterInputCalc
				truncate table #CounterInputOKCalc
			end
			else
			begin
				select @LastTimestamp = AOL_LastTimestamp
				from EventProcessing.ActivityObjectLastValues
				where AOL_EDF_ID = @EDF_ID

				if @LastTimeStamp is null
					set @LastTimeStamp = 0
				set @AlertSQL = 'exec ' + @ProcedureName + ' @Identifier = @Identifier,
															@EventDescription = @EventDescription,
															@LastTimeStamp = @LastTimeStamp,
															@InLastMinutes = @InLastMinutes,
															@PossibleFilters = @PossibleFilters,
															@FilterDefinition = @FilterDefinition,
															@MostRecentTimestamp = @MostRecentTimestamp output'
															
				insert into #NewEvents(F_MOB_ID, F_InstanceName, F_FirstEventDate, F_LastEventDate, F_EventCount, F_HasSuccesfulRuns, F_Timestamp, F_Message, F_AlertEventData)
				exec sp_executesql @AlertSQL,
									N'@Identifier int,
										@EventDescription nvarchar(1000),
										@LastTimeStamp binary(8),
										@InLastMinutes int,
										@PossibleFilters xml,
										@FilterDefinition xml,
										@MostRecentTimestamp binary(8) output',
									@Identifier = @EDF_ID,
									@EventDescription = @EventDescription,
									@LastTimeStamp = @LastTimeStamp,
									@InLastMinutes = @InLastMinutes,
									@PossibleFilters = @PossibleFilters,
									@FilterDefinition = @FilterDefinition,
									@MostRecentTimestamp = @MostRecentTimestamp output

				if @@ROWCOUNT > 0
					with UniqueInstances as
							(select F_MOB_ID, F_InstanceName, sum(F_EventCount) F_EventCount,
								min(F_FirstEventDate) F_FirstEventDate, max(F_LastEventDate) F_LastEventDate
							from #NewEvents
							where not exists (select *
												from @EscalatedEvents
												where MOB_ID = F_MOB_ID
													and (@IgnoreInstanceName = 1
															or EventInstanceName = F_InstanceName
															or (EventInstanceName is null
																	and F_InstanceName is null)
															)
												)
							group by F_MOB_ID, F_InstanceName
							)
					insert into #NewEventsCalc(F_EDF_ID, F_MOB_ID, F_InstanceName, F_FirstEventDate, F_LastEventDate, F_EventCount,
												F_Timestamp, F_Message, F_AlertEventData, F_AutoResolveMinutes)
					select @EDF_ID F_EDF_ID, F_MOB_ID, case when @IgnoreInstanceName = 0 then F_InstanceName end F_InstanceName,
								min(F_FirstEventDate) F_FirstEventDate, max(F_LastEventDate) F_LastEventDate,
								sum(F_EventCount) F_EventCount, max(F_Timestamp) F_Timestamp, max(F_Message) F_Message,
								cast(max(cast(F_AlertEventData as nvarchar(max))) as xml), @AutoResolveMinutes F_AutoResolveMinutes
					from UniqueInstances u
						cross apply (select top 1 F_Timestamp, F_Message, F_HasSuccesfulRuns, F_AlertEventData
										from #NewEvents n
										where u.F_MOB_ID = n.F_MOB_ID
											and (u.F_InstanceName = n.F_InstanceName
													or (u.F_InstanceName is null
															and n.F_InstanceName is null)
												)
										order by F_Timestamp desc) n
					where (datediff(minute, F_LastEventDate, SYSDATETIME()) < @InLastMinutes
							or (@InLastMinutes is null
									and (F_HasSuccesfulRuns = 0
											or (not exists (select *
																from EventProcessing.EventDefinitionStatuses
																where EDS_EDF_ID = @EDF_ID
																	and EDS_MOB_ID = F_MOB_ID)))))
					group by F_MOB_ID, case when @IgnoreInstanceName = 0 then F_InstanceName end

				if @MostRecentTimestamp is not null
					insert into @LastTimestamps(L_EDF_ID, L_Timestamp)
					values(@EDF_ID, @MostRecentTimestamp)
				
				set @OKSQL = 'exec ' + @OKProcedureName + ' @Identifier = @Identifier,
															@EventDescription = @EventDescription,
															@LastTimeStamp = @LastTimeStamp,
															@InLastMinutes = @InLastMinutes,
															@PossibleFilters = @PossibleFilters,
															@FilterDefinition = @FilterDefinition'
				insert into #NewOKEvents(F_MOB_ID, F_InstanceName, F_FirstEventDate, F_LastEventDate, F_EventCount,
											F_IsEventCompletelyClosed, F_Timestamp, F_Message, F_OKEventData)
				exec sp_executesql @OKSQL,
									N'@Identifier int,
										@EventDescription nvarchar(1000),
										@LastTimeStamp binary(8),
										@InLastMinutes int,
										@PossibleFilters xml,
										@FilterDefinition xml',
									@Identifier = @EDF_ID,
									@EventDescription = @EventDescription,
									@LastTimeStamp = @LastTimeStamp,
									@InLastMinutes = @InLastMinutes,
									@PossibleFilters = @PossibleFilters,
									@FilterDefinition = @FilterDefinition

				if @@ROWCOUNT > 0
					with UniqueInstances as
							(select F_MOB_ID, F_InstanceName, sum(F_EventCount) F_EventCount,
								min(F_FirstEventDate) F_FirstEventDate, max(F_LastEventDate) F_LastEventDate
							from #NewOKEvents
							where not exists (select *
												from @EscalatedEvents
												where MOB_ID = F_MOB_ID
													and (@IgnoreInstanceName = 1
															or EventInstanceName = F_InstanceName
															or (EventInstanceName is null
																	and F_InstanceName is null)
														)
											)
							group by F_MOB_ID, F_InstanceName
							)
					insert into #NewOKEventsCalc(F_EDF_ID, F_MOB_ID, F_InstanceName, F_FirstOKEventDate, F_LastOKEventDate, F_OKEventCount,
												F_IsEventCompletelyClosed, F_Timestamp, F_Message, F_OKEventData)
					select @EDF_ID F_EDF_ID, F_MOB_ID, case when @IgnoreInstanceName = 0 then F_InstanceName end F_InstanceName,
							min(F_FirstEventDate) F_FirstEventDate, max(F_LastEventDate) F_LastEventDate, sum(F_EventCount) F_EventCount,
							max(cast(F_IsEventCompletelyClosed as int)) F_IsEventCompletelyClosed, max(F_Timestamp) F_Timestamp, max(F_Message) F_Message,
							cast(max(cast(F_OKEventData as nvarchar(max))) as xml) F_OKEventData
					from UniqueInstances u
						cross apply (select top 1 F_Timestamp, F_IsEventCompletelyClosed, F_Message, F_OKEventData
										from #NewOKEvents n
										where u.F_MOB_ID = n.F_MOB_ID
											and (u.F_InstanceName = n.F_InstanceName
										or (u.F_InstanceName is null
															and n.F_InstanceName is null)
												)
										order by F_Timestamp desc) n
					group by F_MOB_ID, case when @IgnoreInstanceName = 0 then F_InstanceName end

				truncate table #NewEvents
				truncate table #NewOKEvents
			end

			fetch next from cEventDefintions into @EDF_ID, @EFT_ID, @SystemID, @CounterID, @CounterInstanceName, @AutoResolveMinutes, @InLastMinutes,
												@FromNumberOfOccurrences, @ToNumberOfOccurrences, @Operator, @AlertValue, @AlertStatus, @OKFromNumberOfOccurrences,
												@OKToNumberOfOccurrences, @OKOperator, @OKValue, @OKStatus, @CGT_ID, @ProcedureName, @OKProcedureName, @FilterDefinition,
												@PossibleFilters, @IgnoreInstanceName
		end
		close cEventDefintions
		deallocate cEventDefintions

		delete #NewEventsCalc
		where exists (select *
						from EventProcessing.EventIncludeExclude
						where EIE_MOV_ID = @MOV_ID
							and EIE_IsInclude = 0
							and (EIE_MOB_ID = F_MOB_ID
									or EIE_MOB_ID is null)
							and (EIE_InstanceName = F_InstanceName
									or (EIE_UseLikeForInstanceName = 1
											and F_InstanceName like '%' + EIE_InstanceName + '%')
									or EIE_InstanceName is null
								)
					)

		if exists (select *
					from EventProcessing.EventIncludeExclude
					where EIE_MOV_ID = @MOV_ID
						and EIE_IsInclude = 1)
			delete #NewEventsCalc
			where not exists (select *
								from EventProcessing.EventIncludeExclude
								where EIE_MOV_ID = @MOV_ID
									and EIE_IsInclude = 1
									and (EIE_MOB_ID = F_MOB_ID
											or EIE_MOB_ID is null)
									and (EIE_InstanceName = F_InstanceName
											or (EIE_UseLikeForInstanceName = 1
													and F_InstanceName like '%' + EIE_InstanceName + '%')
											or EIE_InstanceName is null
										)
							)

			delete n
			from #NewEventsCalc n
				inner join EventProcessing.EventDefinitions on F_EDF_ID = EDF_ID
				outer apply (select top 1 EDC_FromNumberOfOccurrences, EDC_ToNumberOfOccurrences, EDC_IgnoreInstance
								from EventProcessing.EventDefinitionSpecificCases
								where F_EDF_ID = EDC_EDF_ID
									and (F_MOB_ID = EDC_MOB_ID
											or EDC_MOB_ID is null)
									and (F_InstanceName like EDC_EventInstanceName
											or EDC_EventInstanceName is null)
								order by EDC_ProcessingOrder
							) e
			where F_EventCount < coalesce(EDC_FromNumberOfOccurrences, EDF_FromNumberOfOccurrences , 1)
						or (isnull(EDC_ToNumberOfOccurrences, EDF_ToNumberOfOccurrences) is not null
								and F_EventCount > isnull(EDC_ToNumberOfOccurrences, EDF_ToNumberOfOccurrences))
						or (EDC_IgnoreInstance = 1)

			delete n
			from #NewOKEventsCalc n
				inner join EventProcessing.EventDefinitions on F_EDF_ID = EDF_ID
				outer apply (select top 1 EDC_OKFromNumberOfOccurrences, EDC_OKToNumberOfOccurrences, EDC_IgnoreInstance
								from EventProcessing.EventDefinitionSpecificCases
								where F_EDF_ID = EDC_EDF_ID
									and (F_MOB_ID = EDC_MOB_ID
											or EDC_MOB_ID is null)
									and (F_InstanceName like EDC_EventInstanceName
											or EDC_EventInstanceName is null)
								order by EDC_ProcessingOrder
							) e
			where (F_OKEventCount < coalesce(EDC_OKFromNumberOfOccurrences, EDF_OKFromNumberOfOccurrences , 1)
						or (isnull(EDC_OKToNumberOfOccurrences, EDF_OKToNumberOfOccurrences) is not null
								and F_OKEventCount > isnull(EDC_OKToNumberOfOccurrences, EDF_OKToNumberOfOccurrences))
					)
					and (F_IsEventCompletelyClosed = 0
							or F_IsEventCompletelyClosed is null)
					or (EDC_IgnoreInstance = 1)

		begin transaction

			merge EventProcessing.ActivityObjectLastValues d
				using @LastTimestamps s
					on L_EDF_ID = AOL_EDF_ID
				when matched then update set
										AOL_LastTimestamp = L_TimeStamp,
										AOL_Last_PRC_ID = @PRC_ID
				when not matched then insert(AOL_EDF_ID, AOL_LastTimestamp, AOL_Last_PRC_ID)
										values(L_EDF_ID, L_TimeStamp, @PRC_ID);

			delete EventProcessing.EventDefinitionStatuses
			from EventProcessing.EventDefinitions
			where EDS_EDF_ID = EDF_ID
				and EDS_IsClosed = 1
				and EDF_MOV_ID = @MOV_ID
				and EDS_Last_PRC_ID < @PRC_ID

			merge EventProcessing.EventDefinitionStatuses d
				using #NewEventsCalc s
					on F_EDF_ID = EDS_EDF_ID
						and F_MOB_ID = EDS_MOB_ID
						and (F_InstanceName = EDS_EventInstanceName
								or (F_InstanceName is null
										and EDS_EventInstanceName is null))
				when matched then update set
										EDS_LastEventDate = F_LastEventDate,
										EDS_EventCount = F_EventCount,
										EDS_IsClosed = 0,
										EDS_Last_PRC_ID = @PRC_ID,
										EDS_Timestamp = F_Timestamp,
										EDS_Message = F_Message,
										EDS_OKMessage = null
				when not matched then insert(EDS_ClientID, EDS_EDF_ID, EDS_MOB_ID, EDS_EventInstanceName, EDS_FirstEventDate, EDS_LastEventDate,
											EDS_EventCount, EDS_IsClosed, EDS_IsOpenAndShut, EDS_Open_PRC_ID, EDS_Last_PRC_ID,
											EDS_Timestamp, EDS_Message, EDS_OKMessage, EDS_AlertEventData, EDS_AutoResolveAtDate)
										values(@ClientID, F_EDF_ID, F_MOB_ID, F_InstanceName, F_FirstEventDate, F_LastEventDate, F_EventCount,
												0, 0, @PRC_ID, @PRC_ID, F_Timestamp, F_Message, null, F_AlertEventData,
												dateadd(minute, F_AutoResolveMinutes, sysdatetime()));

			update EventProcessing.EventDefinitionStatuses
			set EDS_IsClosed = 1,
				EDS_IsOpenAndShut = case EDS_Open_PRC_ID
											when @PRC_ID then 1
											else 0
										end,
				EDS_FirstOKEventDate = F_FirstOKEventDate,
				EDS_LastOKEventDate = F_LastOKEventDate,
				EDS_OKEventCount = F_OKEventCount,
				EDS_OK_PRC_ID = @PRC_ID,
				EDS_OKTimestamp = F_Timestamp,
				EDS_OKMessage = F_Message,
				EDS_OKEventData = F_OKEventData,
				EDS_TEC_ID = 1
			from #NewOKEventsCalc
			where F_EDF_ID = EDS_EDF_ID
						and F_MOB_ID = EDS_MOB_ID
						and (F_InstanceName = EDS_EventInstanceName
								or (F_InstanceName is null
										and EDS_EventInstanceName is null))
						and (F_LastOKEventDate >= EDS_LastEventDate
								or F_IsEventCompletelyClosed = 1)

			update EventProcessing.EventDefinitionStatuses
			set EDS_IsClosed = 1,
				EDS_Last_PRC_ID = @PRC_ID,
				EDS_TEC_ID = 2
			from EventProcessing.EventDefinitions
			where EDS_EDF_ID = EDF_ID
				and EDF_MOV_ID = @MOV_ID
				and EDS_AutoResolveAtDate <= SYSDATETIME()

			;with ActiveEventDefinitionStatuses as
				(select EDS_ClientID, EDS_MOB_ID, EDS_EventInstanceName,
							max(cast(EDS_IsOpenAndShut as int)) IsOpenAndShut,
							case when sum(case when EDS_IsClosed = 1 then 0 else 1 end) = @NecessaryEventDefinitions
								then 1
								else 0
							end IsEnoughOpenEvents,
							max(EDS_TEC_ID) TEC_ID,
							replace(replace(replace(stuff(replace(
									(select char(13)+char(10) + char(13)+char(10) + EDS_Message
										from EventProcessing.EventDefinitionStatuses e1
											inner join EventProcessing.EventDefinitions ed1 on e1.EDS_EDF_ID = ed1.EDF_ID
										where ed1.EDF_MOV_ID = @MOV_ID
											and e1.EDS_MOB_ID = e.EDS_MOB_ID
											and (e1.EDS_EventInstanceName = e.EDS_EventInstanceName
													or (e1.EDS_EventInstanceName is null
															and e.EDS_EventInstanceName is null)
												)
										for xml path(''))
									, '&#x0D;', CHAR(13)), 1, 2, ''), '&gt;', '>'), '&lt;', '<'), '&amp;', '>') AlertMessage,
							replace(replace(replace(stuff(replace(
									(select char(13)+char(10) + char(13)+char(10) + EDS_OKMessage
										from EventProcessing.EventDefinitionStatuses e1
											inner join EventProcessing.EventDefinitions ed1 on e1.EDS_EDF_ID = ed1.EDF_ID
										where ed1.EDF_MOV_ID = @MOV_ID
											and e1.EDS_MOB_ID = e.EDS_MOB_ID
											and (e1.EDS_EventInstanceName = e.EDS_EventInstanceName
													or (e1.EDS_EventInstanceName is null
															and e.EDS_EventInstanceName is null)
												)
										for xml path(''))
									, '&#x0D;', CHAR(13)), 1, 2, ''), '&gt;', '>'), '&lt;', '<'), '&amp;', '>') OKMessage,
							(select cast(EDS_AlertEventData as xml)
								from (select EDS_AlertEventData
										from EventProcessing.EventDefinitionStatuses e1
											inner join EventProcessing.EventDefinitions ed1 on e1.EDS_EDF_ID = ed1.EDF_ID
										where ed1.EDF_MOV_ID = @MOV_ID
											and e1.EDS_AlertEventData is not null
											and e1.EDS_MOB_ID = e.EDS_MOB_ID
											and (e1.EDS_EventInstanceName = e.EDS_EventInstanceName
													or (e1.EDS_EventInstanceName is null
															and e.EDS_EventInstanceName is null)
												)
										) [Row]
								for xml path(''), root('Rows')) AlertEventData,
							(select cast(EDS_OKEventData as xml)
								from (select e1.EDS_OKEventData
										from EventProcessing.EventDefinitionStatuses e1
											inner join EventProcessing.EventDefinitions ed1 on e1.EDS_EDF_ID = ed1.EDF_ID
										where ed1.EDF_MOV_ID = @MOV_ID
											and e1.EDS_OKEventData is not null
											and e1.EDS_MOB_ID = e.EDS_MOB_ID
											and (e1.EDS_EventInstanceName = e.EDS_EventInstanceName
													or (e1.EDS_EventInstanceName is null
															and e.EDS_EventInstanceName is null)
												)
										) [Row]
								for xml path(''), root('Rows')) OKEventData
					from EventProcessing.EventDefinitionStatuses e
						inner join EventProcessing.EventDefinitions ed on EDS_EDF_ID = EDF_ID
					where EDF_MOV_ID = @MOV_ID
					group by EDS_ClientID, EDS_MOB_ID, EDS_EventInstanceName
					having count(*) = @NecessaryEventDefinitions)
			merge EventProcessing.TrappedEvents d
				using ActiveEventDefinitionStatuses s
					on TRE_MOV_ID = @MOV_ID
						and TRE_MOB_ID = EDS_MOB_ID
						and (TRE_EventInstanceName = EDS_EventInstanceName
								or (TRE_EventInstanceName is null and EDS_EventInstanceName is null)
							)
						and TRE_IsClosed = 0
				when matched and IsEnoughOpenEvents = 0 then update set
																TRE_IsClosed = 1,
																TRE_CloseDate = sysdatetime(),
																TRE_OKMessage = OKMessage,
																TRE_OKEventData = OKEventData,
																TRE_TEC_ID = TEC_ID
				when not matched then insert (TRE_ClientID, TRE_MOB_ID, TRE_MOV_ID, TRE_MEG_ID, TRE_Level, TRE_IsClosed, TRE_IsOpenAndShut, TRE_EventInstanceName,
												TRE_OpenDate, TRE_CloseDate, TRE_AlertMessage, TRE_OKMessage, TRE_AlertEventData, TRE_OKEventData, TRE_TEC_ID)
									values(EDS_ClientID, EDS_MOB_ID, @MOV_ID, @MEG_ID, @EventLevel, case when IsEnoughOpenEvents = 0 then 1 else 0 end, IsOpenAndShut, EDS_EventInstanceName,
											sysdatetime(), case when IsEnoughOpenEvents = 0 then sysdatetime() else null end, AlertMessage, OKMessage, AlertEventData, OKEventData, TEC_ID)
				when not matched by source and TRE_MOV_ID = @MOV_ID
												and TRE_IsClosed = 0 then update set
																TRE_IsClosed = 1,
																TRE_CloseDate = sysdatetime(),
																TRE_OKMessage = 'Event Closed',
																TRE_OKEventData = null,
																TRE_TEC_ID = 5;
		commit transaction
		delete @LastTimestamps
		set @ErrorMessage = null
	end try
	begin catch
		set @ErrorMessage = ERROR_MESSAGE()
		if @@TRANCOUNT > 0
			rollback
		begin try
			close cEventDefintions
			deallocate cEventDefintions
		end try
		begin catch
		end catch
	end catch
	
	update EventProcessing.ProcessCycles
	set PRC_EndDate = SYSDATETIME(),
		PRC_ErrorMessage = @ErrorMessage
	where PRC_ID = @PRC_ID

	if @MEG_ID is not null
		delete @EscalatedEvents
	truncate table #NewEventsCalc
	truncate table #NewOKEventsCalc

	fetch next from cMonitoredEvents into @MOV_ID, @EventDescription, @MEG_ID, @EventLevel, @NecessaryEventDefinitions
end
close cMonitoredEvents
deallocate cMonitoredEvents
GO
