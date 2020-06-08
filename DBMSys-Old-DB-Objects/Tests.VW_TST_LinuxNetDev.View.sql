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
/****** Object:  View [Tests].[VW_TST_LinuxNetDev]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_LinuxNetDev]
as
select top 0 CAST(null as varchar(100)) Column1, --Interface
			CAST(null as bigint) Column2, --Receive bytes
			CAST(null as bigint) Column3, --Receive packets
			CAST(null as bigint) Column4, --Receive errors
			CAST(null as bigint) Column5, --Receive packets dropped
			CAST(null as bigint) Column6, --Receive fifo buffer errors
			CAST(null as bigint) Column7, --Receive packet framing errors
			CAST(null as bigint) Column8, --Receive compressed packets
			CAST(null as bigint) Column9, --Receive multicast frames
			CAST(null as bigint) Column10, --Transmit bytes
			CAST(null as bigint) Column11, --Transmit packets
			CAST(null as bigint) Column12, --Transmit errors
			CAST(null as bigint) Column13, --Transmit packets dropped
			CAST(null as bigint) Column14, --Transmit fifo buffer errors
			CAST(null as bigint) Column15, --Transmit collisions detected
			CAST(null as bigint) Column16, --Transmit carrier losses
			CAST(null as bigint) Column17, --Transmit compressed packets
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_LinuxNetDev]    Script Date: 6/8/2020 1:16:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_LinuxNetDev] on [Tests].[VW_TST_LinuxNetDev]
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
from (select replace(Column1, ':', '') InstanceName, Column2 [Bytes Received/sec], Column3 [Packets Received/sec], Column4 [Receive rrors], Column5 [Receive packets dropped],
			Column6 [Receive fifo buffer errors], Column7 [Receive packet framing errors], Column8 [Receive compressed packets], Column9 [Receive multicast frames],
			Column10 [Bytes Sent/sec], Column11 [Packets Sent/sec], Column12 [Transmit errors], Column13 [Transmit packets dropped], Column14 [Transmit fifo buffer errors],
			Column15 [Transmit collisions detected], Column16 [Transmit carrier losses], Column17 [Transmit compressed packets]
		from inserted) t
	unpivot (Value for CounterName in ([Bytes Received/sec], [Packets Received/sec], [Receive rrors], [Receive packets dropped], [Receive fifo buffer errors],
										[Receive packet framing errors], [Receive compressed packets], [Receive multicast frames], [Bytes Sent/sec], [Packets Sent/sec],
										[Transmit errors], [Transmit packets dropped], [Transmit fifo buffer errors], [Transmit collisions detected],
										[Transmit carrier losses], [Transmit compressed packets])) u
	inner join PerformanceData.GeneralCounters on GNC_CategoryName = 'Linux Network Interface'
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

if @CounterDate is not null
		and @CounterDate <= dateadd(second, -1, @CollectionDate)
	with CombinedValues as
			(select CounterName, InstanceName, SystemID, CounterID, InstanceID,
						cast(Value - OCB_Value as decimal(18, 5)) Value
				from @NewValues
					inner join Collect.ObjectCounterBases on OCB_TST_ID = @TST_ID
															and OCB_MOB_ID = @MOB_ID
															and OCB_CSY_ID = SystemID
															and OCB_CounterID = CounterID
															and OCB_CIN_ID = InstanceID)
		, CalcValues as
			(select CounterName, InstanceName, SystemID, CounterID, InstanceID, Value
				from CombinedValues c
				where CounterName not like '%/sec'
				union all
				select CounterName, InstanceName, SystemID, CounterID, InstanceID, Value/DATEDIFF(second, @CounterDate, @CollectionDate) Value
				from CombinedValues c
				where CounterName like '%/sec'			
			)
	insert into PerformanceData.CounterResults(CRS_ClientID, CRS_MOB_ID, CRS_TRH_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_DateTime, CRS_Value)
	select @ClientID, @MOB_ID, @TRH_ID, SystemID, CounterID, InstanceID, @CounterDate, Value
	from CalcValues

merge Collect.ObjectCounterBases d
	using (select *
			from @NewValues) s
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
