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
/****** Object:  View [Tests].[VW_TST_LinuxStat]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_LinuxStat]
as
select top 0 CAST(null as varchar(100)) Column1, --CPU
			CAST(null as bigint) Column2, --User
			CAST(null as bigint) Column3, --Nice
			CAST(null as bigint) Column4, --System
			CAST(null as bigint) Column5, --Idle
			CAST(null as bigint) Column6, --IOWait
			CAST(null as bigint) Column7, --IRQ
			CAST(null as bigint) Column8, --SoftIRQ
			CAST(null as bigint) Column9, --Steal
			CAST(null as bigint) Column10, --Guest
			CAST(null as bigint) Column11, --GuestNice
			CAST(null as bigint) Metadata_TRH_ID,
			CAST(null as bigint) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_LinuxStat]    Script Date: 6/8/2020 1:16:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_LinuxStat] on [Tests].[VW_TST_LinuxStat]
	instead of insert
as
set nocount on

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
from (select isnull(nullif('CPU(' + substring(Column1, 4, 10) + ')', 'CPU()'), '_Total') InstanceName, Column2 [User %], Column3 [Nice %],
			Column4 [System %], Column5 [Idle %], Column6 [IO Wait %], Column7 [IRQ %], Column8 [Soft IRQ %], Column9 [Steal %],
			Column10 [Guest %], Column11 [Guest Nice %], Column5 + Column6 [Total Idle %],
			isnull(Column2, 0) + isnull(Column3, 0) + isnull(Column4, 0) + isnull(Column7, 0) + isnull(Column8, 0) + isnull(Column9, 0) + isnull(Column10, 0) + isnull(Column11, 0) [Busy %]
		from inserted
		where Column1 like 'cpu%') t
	unpivot (Value for CounterName in ([User %], [Nice %], [System %], [Idle %], [IO Wait %],
										[IRQ %], [Soft IRQ %], [Steal %], [Guest %], [Guest Nice %],
										[Total Idle %], [Busy %])) u
	inner join PerformanceData.GeneralCounters on GNC_CategoryName = 'CPU Stats'
													and GNC_CounterName = CounterName

merge PerformanceData.CounterInstances d
	using (select distinct InstanceName
			from @NewValues) s
		on InstanceName = CIN_Name
	when not matched then insert(CIN_ClientID, CIN_Name)
							values(@ClientID, InstanceName);

update @NewValues
set InstanceID  = CIN_ID
from PerformanceData.CounterInstances
where InstanceName = CIN_Name

if @CounterDate is not null
	with CombinedValues as
			(select CounterName, InstanceName, SystemID, CounterID, InstanceID,
						Value - OCB_Value Value
				from @NewValues
					inner join Collect.ObjectCounterBases on OCB_TST_ID = @TST_ID
															and OCB_MOB_ID = @MOB_ID
															and OCB_CSY_ID = SystemID
															and OCB_CounterID = CounterID
															and OCB_CIN_ID = InstanceID)
		, CalcValues as
			(select CounterName, InstanceName, SystemID, CounterID, InstanceID,
					Value*100/TotalTime Value
				from CombinedValues c
					cross apply (select SUM(c1.Value) TotalTime
									from CombinedValues c1
									where c.InstanceID = c1.InstanceID
										and c1.CounterName in ('Total Idle %', 'Busy %')
									having SUM(c1.Value) > 0) T
			)
	insert into PerformanceData.CounterResults(CRS_ClientID, CRS_MOB_ID, CRS_TRH_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_DateTime, CRS_Value)
	select @ClientID, @MOB_ID, @TRH_ID, SystemID, CounterID, InstanceID, @CounterDate, Value
	from CalcValues
	where Value is not null
		and (Value > 0
			or CounterName in ('Busy %', 'User %', 'System %')
			)

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
							OCB_Value = Value
	when not matched then insert (OCB_TST_ID, OCB_MOB_ID, OCB_CSY_ID, OCB_CounterID, OCB_CIN_ID, OCB_CollectionDate, OCB_Value, OCB_LastRestartDate)
							values(@TST_ID, @MOB_ID, SystemID, CounterID, InstanceID, @CollectionDate, Value, @LastRestartDate);
GO
