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
/****** Object:  View [Tests].[VW_TST_SQLWaits]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_SQLWaits]
as
select top 0 CAST(null as nvarchar(60)) wait_type,
			CAST(null as bigint) waiting_tasks_count,
			CAST(null as bigint) wait_time_sec,
			CAST(null as bigint) signal_wait_time_sec,
			CAST(null as datetime) LastRestartDate,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SQLWaits]    Script Date: 6/8/2020 1:16:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_SQLWaits] on [Tests].[VW_TST_SQLWaits]
	instead of insert
as
set nocount on
declare @MOB_ID int,
		@TST_ID int,
		@TRH_ID int,
		@ClientID int,
		@CounterDate datetime2(3),
		@CollectionDate datetime2(3),
		@LastCollectionDate datetime2(3)

declare @NewValues table(wait_type nvarchar(60),
							InstanceName nvarchar(100),
							SystemID tinyint,
							CounterID int,
							InstanceID int,
							Value bigint,
							LastRestartDate datetime)

select top 1 @MOB_ID = l.TRH_MOB_ID,
			@TST_ID = l.TRH_TST_ID,
			@TRH_ID = Metadata_TRH_ID,
			@ClientID = Metadata_ClientID,
			@CounterDate = StartDate,
			@CollectionDate = l.TRH_StartDate
from (select top 1 Metadata_TRH_ID, Metadata_ClientID
		from inserted) i
	inner join Collect.TestRunHistory l on Metadata_TRH_ID = l.TRH_ID
	outer apply (select top 1 s.TRH_StartDate StartDate
					from Collect.TestRunHistory s
					where l.TRH_MOB_ID = s.TRH_MOB_ID
							and l.TRH_TST_ID = s.TRH_TST_ID
							and s.TRH_ID < l.TRH_ID
					order by TRH_ID desc) s
	inner join Collect.Tests on l.TRH_TST_ID = TST_ID

;with ExistingWaitTypes as
		(select GNC_ID, GNC_PCG_ID, GNC_CSY_ID, GNC_CategoryName, GNC_CounterName, GNC_IsAggregative
			from PerformanceData.GeneralCounters
			where GNC_CSY_ID = 5
					and GNC_CategoryName = 'SQL Waits')
merge ExistingWaitTypes d
	using (select row_number() over (order by wait_type) + MaxID NextID,  wait_type
			from inserted
				cross join (select max(GNC_ID) MaxID from ExistingWaitTypes) m
			where not exists (select *
								from ExistingWaitTypes
								where wait_type = GNC_CounterName)
			) s
		on wait_type = GNC_CounterName
	when not matched then insert(GNC_ID, GNC_PCG_ID, GNC_CSY_ID, GNC_CategoryName, GNC_CounterName, GNC_IsAggregative)
							values(NextID, 0, 5, 'SQL Waits', wait_type, 1);

merge PerformanceData.CounterInstances d
	using (select InstanceName
			from (values('Waiting Tasks'),
						('Wait Time (Sec)'),
						('Signal Wait Time (Sec)'),
						('Percentage of Signal Wait')) i(InstanceName)) s
		on InstanceName = CIN_Name
	when not matched then insert(CIN_ClientID, CIN_Name)
							values(@ClientID, InstanceName);

;with NewValues as
		(select wait_type, InstanceName,
				max(case InstanceName
						when 'Waiting Tasks' then waiting_tasks_count
						when 'Wait Time (Sec)' then wait_time_sec
					end) Value, max(LastRestartDate) LastRestartDate
			from inserted
				cross join (select InstanceName
							from (values('Waiting Tasks'),
										('Wait Time (Sec)')) i(InstanceName)) i
			group by wait_type, InstanceName
			union all
			select wait_type, 'Signal Wait Time (Sec)' InstanceName, signal_wait_time_sec Value, LastRestartDate
			from inserted
			where wait_type = '_Total'
				and signal_wait_time_sec is not null
		)
insert into @NewValues
select wait_type, InstanceName, GNC_CSY_ID, GNC_ID, CIN_ID, Value, LastRestartDate
from NewValues
	inner join PerformanceData.GeneralCounters on GNC_CSY_ID = 5
												and GNC_CategoryName = 'SQL Waits'
												and GNC_CounterName = wait_type
	inner join PerformanceData.CounterInstances on CIN_Name = InstanceName

if @CounterDate is not null	and datediff(hour, @CounterDate, @CollectionDate) >= 1
	with CalcValues as
			(select wait_type, InstanceName, SystemID, CounterID, InstanceID,
						cast((Value - OCB_Value)/(DATEDIFF(minute, OCB_CollectionDate, @CollectionDate)/60.) as bigint) Value
				from @NewValues
					inner join Collect.ObjectCounterBases on OCB_TST_ID = @TST_ID
															and OCB_MOB_ID = @MOB_ID
															and OCB_CSY_ID = SystemID
															and OCB_CounterID = CounterID
															and OCB_CIN_ID = InstanceID
															and OCB_LastRestartDate = LastRestartDate
				where OCB_CollectionDate <= DATEADD(hour, -1, @CollectionDate))
		, SignalPercentCalc as
			(select SystemID, CounterID, sum(case when InstanceName = 'Signal Wait Time (Sec)' then Value end) SignalWaits,
					sum(case when InstanceName = 'Wait Time (Sec)' then Value end) AllWaits
				from CalcValues
				where wait_type = '_Total'
					and InstanceName in ('Wait Time (Sec)', 'Signal Wait Time (Sec)')
				group by SystemID, CounterID
			)
	insert into PerformanceData.CounterResults(CRS_ClientID, CRS_MOB_ID, CRS_TRH_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_DateTime, CRS_Value)
	select @ClientID, @MOB_ID, @TRH_ID, SystemID, CounterID, InstanceID, cast(convert(char(14), @CounterDate, 121) + '00' as datetime), Value
	from CalcValues
	where Value > 10
	union all
	select @ClientID, @MOB_ID, @TRH_ID, SystemID, CounterID, CIN_ID, cast(convert(char(14), @CounterDate, 121) + '00' as datetime), SignalWaits*100/AllWaits Value
	from SignalPercentCalc
		cross join (select CIN_ID from PerformanceData.CounterInstances where CIN_Name = 'Percentage of Signal Wait') i
	where AllWaits > 0

if @CounterDate is null	or datediff(hour, @CounterDate, @CollectionDate) >= 1
	merge Collect.ObjectCounterBases d
		using @NewValues s
			on OCB_TST_ID = @TST_ID
				and OCB_MOB_ID = @MOB_ID
				and OCB_CSY_ID = SystemID
				and OCB_CounterID = CounterID
				and OCB_CIN_ID = InstanceID
				and OCB_IDB_ID is null
		when matched then update set
							 OCB_CollectionDate = @CollectionDate,
								OCB_Value = Value,
								OCB_LastRestartDate = LastRestartDate
		when not matched then insert (OCB_TST_ID, OCB_MOB_ID, OCB_CSY_ID, OCB_CounterID, OCB_CIN_ID, OCB_CollectionDate, OCB_Value,
										OCB_LastRestartDate)
								values(@TST_ID, @MOB_ID, SystemID, CounterID, InstanceID, @CollectionDate, Value, LastRestartDate);
GO
