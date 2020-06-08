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
/****** Object:  View [Tests].[VW_TST_SolarisNetworkStatsSent]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_SolarisNetworkStatsSent]
as
select top 0 CAST(null as varchar(200)) LINK,
			CAST(null as varchar(100)) OPKTS,
			CAST(null as varchar(100)) OBYTES,
			CAST(null as varchar(100)) ODROPS,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SolarisNetworkStatsSent]    Script Date: 6/8/2020 1:16:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_SolarisNetworkStatsSent] on [Tests].[VW_TST_SolarisNetworkStatsSent]
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
				case when OPKTS like '%T'
								then cast(replace(OPKTS, 'T', '') as decimal(15, 3))*1024*1024*1024*1024
							when OPKTS like '%G'
								then cast(replace(OPKTS, 'G', '') as decimal(15, 3))*1024*1024*1024
							when OPKTS like '%M'
								then cast(replace(OPKTS, 'M', '') as decimal(15, 3))*1024*1024
							when OPKTS like '%K'
								then cast(replace(OPKTS, 'K', '') as decimal(15, 3))*1024
							when OPKTS like '%B'
								then cast(replace(OPKTS, 'B', '') as decimal(15, 3))
							else OPKTS
						end [Packets sent/sec],
				case when OBYTES like '%T'
								then cast(replace(OBYTES, 'T', '') as decimal(15, 3))*1024*1024*1024*1024
							when OBYTES like '%G'
								then cast(replace(OBYTES, 'G', '') as decimal(15, 3))*1024*1024*1024
							when OBYTES like '%M'
								then cast(replace(OBYTES, 'M', '') as decimal(15, 3))*1024*1024
							when OBYTES like '%K'
								then cast(replace(OBYTES, 'K', '') as decimal(15, 3))*1024
							when OBYTES like '%B'
								then cast(replace(OBYTES, 'B', '') as decimal(15, 3))
							else OBYTES
						end [Byets sent/sec],
				case when ODROPS like '%T'
								then cast(replace(ODROPS, 'T', '') as decimal(15, 3))*1024*1024*1024*1024
							when ODROPS like '%G'
								then cast(replace(ODROPS, 'G', '') as decimal(15, 3))*1024*1024*1024
							when ODROPS like '%M'
								then cast(replace(ODROPS, 'M', '') as decimal(15, 3))*1024*1024
							when ODROPS like '%K'
								then cast(replace(ODROPS, 'K', '') as decimal(15, 3))*1024
							when ODROPS like '%B'
								then cast(replace(ODROPS, 'B', '') as decimal(15, 3))
							else ODROPS
						end [Sent packets dropped/sec]
		from inserted) t
	unpivot (Value for CounterName in ([Packets sent/sec], [Byets sent/sec], [Sent packets dropped/sec])) u
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
