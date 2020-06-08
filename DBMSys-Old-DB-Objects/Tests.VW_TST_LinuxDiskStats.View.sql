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
/****** Object:  View [Tests].[VW_TST_LinuxDiskStats]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_LinuxDiskStats]
as
select top 0 CAST(null as int) Column1, --Major
			CAST(null as int) Column2, --Minor
			CAST(null as varchar(100)) Column3, --device name
			CAST(null as bigint) Column4, --Reads completed successfully
			CAST(null as bigint) Column5, --Reads merged
			CAST(null as bigint) Column6, --Sectors read
			CAST(null as bigint) Column7, --Time spent reading (ms)
			CAST(null as bigint) Column8, --Writes completed
			CAST(null as bigint) Column9, --Writes merged
			CAST(null as bigint) Column10, --Sectors written
			CAST(null as bigint) Column11, --Time spent writing (ms)
			CAST(null as bigint) Column12, --I/Os currently in progress
			CAST(null as bigint) Column13, --Time spent doing I/Os (ms)
			CAST(null as bigint) Column14, --Weighted time spent doing I/Os (ms)
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_LinuxDiskStats]    Script Date: 6/8/2020 1:16:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_LinuxDiskStats] on [Tests].[VW_TST_LinuxDiskStats]
	instead of insert
as
set nocount on
set transaction isolation level read uncommitted
declare @MOB_ID int,
		@TST_ID int,
		@CollectionDate datetime2(3),
		@CounterDate datetime2(3),
		@LastRestartDate datetime2(3),
		@TRH_ID int,
		@ClientID int

declare @NewValues table(CounterName varchar(100),
							InstanceName varchar(100),
							SystemID tinyint,
							CounterID int,
							InstanceID int,
							Value bigint)

select @MOB_ID = TRH_MOB_ID,
		@TST_ID = TRH_TST_ID,
		@CollectionDate = TRH_StartDate,
		@CounterDate = StartDate,
		@LastRestartDate = OSS_LastBootUpTime,
		@TRH_ID = Metadata_TRH_ID,
		@ClientID = Metadata_ClientID
from (select top 1 Metadata_TRH_ID, Metadata_ClientID
		from inserted) i
	inner join Collect.TestRunHistory l on TRH_ID = Metadata_TRH_ID
	inner join Inventory.OSServers on OSS_MOB_ID = TRH_MOB_ID
	outer apply (select top 1 s.TRH_StartDate StartDate
					from Collect.TestRunHistory s
					where l.TRH_MOB_ID = s.TRH_MOB_ID
							and l.TRH_TST_ID = s.TRH_TST_ID
							and s.TRH_ID < l.TRH_ID
					order by TRH_ID desc) s

insert into @NewValues
select CounterName, InstanceName, GNC_CSY_ID, GNC_ID, null, Value
from (select Column3 InstanceName, Column4 [Reads completed successfully/sec], Column5 [Reads merged/sec], Column6 [Sectors read/sec],
			Column7 [Time spent reading (ms)/sec], Column8 [Writes completed/sec], Column9 [Writes merged/sec], Column10 [Sectors written/sec],
			Column11 [Time spent writing (ms)/sec], Column12 [I/Os currently in progress/sec], Column13 [Time spent doing I/Os (ms)/sec],
			Column14 [Weighted time spent doing I/Os (ms)/sec]
		from inserted
		where Column3 not in ('sr0', 'fd0')
			and Column4 > 0
		) t
	unpivot (Value for CounterName in ([Reads completed successfully/sec], [Reads merged/sec], [Sectors read/sec], [Time spent reading (ms)/sec],
										[Writes completed/sec], [Writes merged/sec], [Sectors written/sec], [Time spent writing (ms)/sec], [I/Os currently in progress/sec],
										[Time spent doing I/Os (ms)/sec], [Weighted time spent doing I/Os (ms)/sec])) u
	inner join PerformanceData.GeneralCounters on GNC_CategoryName = 'Linux Drives'
													and GNC_CounterName = CounterName

merge PerformanceData.CounterInstances d
	using (select distinct InstanceName
			from @NewValues) s
		on InstanceName = CIN_Name
	when not matched then insert(CIN_ClientID, CIN_Name)
							values(@ClientID, InstanceName);

update @NewValues
set InstanceID = CIN_ID
from PerformanceData.CounterInstances
where InstanceName = CIN_Name

insert into PerformanceData.CounterResults(CRS_ClientID, CRS_MOB_ID, CRS_TRH_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_DateTime, CRS_Value)
select @ClientID, @MOB_ID, @TRH_ID, SystemID, CounterID, InstanceID, @CounterDate, Value
from @NewValues
where CounterName = 'I/Os currently in progress/sec'

if @CounterDate is not null
		and @CounterDate < @CollectionDate
	with CombinedValues as
			(select CounterName, InstanceName, SystemID, CounterID, InstanceID,
						(Value - OCB_Value)/isnull(nullif(datediff(second, OCB_CollectionDate, @CollectionDate), 0), 1) Value
				from @NewValues
					inner join Collect.ObjectCounterBases on OCB_TST_ID = @TST_ID
															and OCB_MOB_ID = @MOB_ID
															and OCB_CSY_ID = SystemID
															and OCB_CounterID = CounterID
															and OCB_CIN_ID = InstanceID)
		, CalcValues as
			(select CounterName, InstanceName, SystemID, CounterID, InstanceID, Value
				from CombinedValues c
				union all
				select 'Avg. Disk sec/Read' CounterName, InstanceName, GNC_CSY_ID, GNC_ID, InstanceID,
						ReadTime/iif((sum(case when CounterName like '%merge%' then -Value else Value end)) <> 0,
									(sum(case when CounterName like '%merge%' then -Value else Value end)), 
									1)/1000 Value
				from CombinedValues c
					inner join PerformanceData.GeneralCounters on GNC_CategoryName = 'Linux Drives'
																	and GNC_CounterName = 'Avg. Disk sec/Read'
					cross apply (select cast(Value as decimal(18, 5)) ReadTime
									from CombinedValues c1
									where c.InstanceID = c1.InstanceID
										and c1.CounterName = 'Time spent reading (ms)/sec'
										) c1
				where CounterName in ('Reads completed successfully/sec', 'Reads merged/sec')
				group by InstanceName, GNC_CSY_ID, GNC_ID, InstanceID, ReadTime
				union all
				select 'Avg. Disk sec/Write' CounterName, InstanceName, GNC_CSY_ID, GNC_ID, InstanceID,
						WriteTime/iif((sum(case when CounterName like '%merge%' then -Value else Value end)) <> 0,
									(sum(case when CounterName like '%merge%' then -Value else Value end)), 
									1)/1000 Value
				from CombinedValues c
					inner join PerformanceData.GeneralCounters on GNC_CategoryName = 'Linux Drives'
																	and GNC_CounterName = 'Avg. Disk sec/Write'
					cross apply (select cast(Value as decimal(18, 5)) WriteTime
									from CombinedValues c1
									where c.InstanceID = c1.InstanceID
										and c1.CounterName = 'Time spent writing (ms)/sec'
										) c1
				where CounterName in ('Writes completed/sec', 'Writes merged/sec')
				group by InstanceName, GNC_CSY_ID, GNC_ID, InstanceID, WriteTime
				union all
				select 'Avg. Disk sec/Transfer' CounterName, InstanceName, GNC_CSY_ID, GNC_ID, InstanceID,
						IOTime/iif((sum(case when CounterName like '%merge%' then -Value else Value end)) <> 0,
									(sum(case when CounterName like '%merge%' then -Value else Value end)), 
									1)/1000 Value
				from CombinedValues c
					inner join PerformanceData.GeneralCounters on GNC_CategoryName = 'Linux Drives'
																	and GNC_CounterName = 'Avg. Disk sec/Transfer'
					cross apply (select cast(Value as decimal(18, 5)) IOTime
									from CombinedValues c1
									where c.InstanceID = c1.InstanceID
										and c1.CounterName = 'Time spent doing I/Os (ms)/sec'
										) c1
				where CounterName in ('Reads completed successfully/sec', 'Reads merged/sec', 'Writes completed/sec', 'Writes merged/sec')
				group by InstanceName, GNC_CSY_ID, GNC_ID, InstanceID, IOTime				
				)
	insert into PerformanceData.CounterResults(CRS_ClientID, CRS_MOB_ID, CRS_TRH_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_DateTime, CRS_Value)
	select @ClientID, @MOB_ID, @TRH_ID, SystemID, CounterID, InstanceID, @CounterDate, Value
	from CalcValues
	
merge Collect.ObjectCounterBases d
	using (select *
			from @NewValues
			where CounterName <> 'I/Os currently in progress/sec') s
		on OCB_TST_ID = @TST_ID
			and OCB_MOB_ID = @MOB_ID
			and OCB_CSY_ID = SystemID
			and OCB_CounterID = CounterID
			and OCB_CIN_ID = InstanceID
			and OCB_IDB_ID is null
	when matched then update set
						 OCB_CollectionDate = @CollectionDate,
							OCB_Value = Value
	when not matched then insert (OCB_TST_ID, OCB_MOB_ID, OCB_CSY_ID, OCB_CounterID, OCB_CIN_ID, OCB_CollectionDate, OCB_Value, OCB_LastRestartDate)
							values(@TST_ID, @MOB_ID, SystemID, CounterID, InstanceID, @CollectionDate, Value, @LastRestartDate);
GO
