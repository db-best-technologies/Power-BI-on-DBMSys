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
/****** Object:  View [Tests].[VW_TST_SolarisNetworkStatsReceived]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_SolarisNetworkStatsReceived]
as
select top 0 CAST(null as varchar(200)) LINK,
			CAST(null as varchar(100)) IPKTS,
			CAST(null as varchar(100)) RBYTES,
			CAST(null as varchar(100)) IDROPS,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SolarisNetworkStatsReceived]    Script Date: 6/8/2020 1:16:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_SolarisNetworkStatsReceived] on [Tests].[VW_TST_SolarisNetworkStatsReceived]
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
from (select LINK InstanceName,
				case when IPKTS like '%T'
								then cast(replace(IPKTS, 'T', '') as decimal(15, 3))*1024*1024*1024*1024
							when IPKTS like '%G'
								then cast(replace(IPKTS, 'G', '') as decimal(15, 3))*1024*1024*1024
							when IPKTS like '%M'
								then cast(replace(IPKTS, 'M', '') as decimal(15, 3))*1024*1024
							when IPKTS like '%K'
								then cast(replace(IPKTS, 'K', '') as decimal(15, 3))*1024
							when IPKTS like '%B'
								then cast(replace(IPKTS, 'B', '') as decimal(15, 3))
							else IPKTS
						end [Packets received/sec],
				case when RBYTES like '%T'
								then cast(replace(RBYTES, 'T', '') as decimal(15, 3))*1024*1024*1024*1024
							when RBYTES like '%G'
								then cast(replace(RBYTES, 'G', '') as decimal(15, 3))*1024*1024*1024
							when RBYTES like '%M'
								then cast(replace(RBYTES, 'M', '') as decimal(15, 3))*1024*1024
							when RBYTES like '%K'
								then cast(replace(RBYTES, 'K', '') as decimal(15, 3))*1024
							when RBYTES like '%B'
								then cast(replace(RBYTES, 'B', '') as decimal(15, 3))
							else RBYTES
						end [Byets received/sec],
				case when IDROPS like '%T'
								then cast(replace(IDROPS, 'T', '') as decimal(15, 3))*1024*1024*1024*1024
							when IDROPS like '%G'
								then cast(replace(IDROPS, 'G', '') as decimal(15, 3))*1024*1024*1024
							when IDROPS like '%M'
								then cast(replace(IDROPS, 'M', '') as decimal(15, 3))*1024*1024
							when IDROPS like '%K'
								then cast(replace(IDROPS, 'K', '') as decimal(15, 3))*1024
							when IDROPS like '%B'
								then cast(replace(IDROPS, 'B', '') as decimal(15, 3))
							else IDROPS
						end [Received packets dropped/sec]
		from inserted) t
	unpivot (Value for CounterName in ([Packets received/sec], [Byets received/sec], [Received packets dropped/sec])) u
	inner join PerformanceData.GeneralCounters on GNC_CategoryName = 'Solaris Network'
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
						(Value - OCB_Value)/isnull(nullif(datediff(second, OCB_CollectionDate, @CollectionDate), 0), 1) Value
				from @NewValues
					inner join Collect.ObjectCounterBases on OCB_TST_ID = @TST_ID
															and OCB_MOB_ID = @MOB_ID
															and OCB_CSY_ID = SystemID
															and OCB_CounterID = CounterID
															and OCB_CIN_ID = InstanceID)
	insert into PerformanceData.CounterResults(CRS_ClientID, CRS_MOB_ID, CRS_TRH_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_DateTime, CRS_Value)
	select @ClientID, @MOB_ID, @TRH_ID, SystemID, CounterID, InstanceID, @CounterDate, Value
	from CombinedValues
	where Value is not null

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
