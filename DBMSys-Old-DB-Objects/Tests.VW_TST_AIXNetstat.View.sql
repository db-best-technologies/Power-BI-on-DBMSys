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
/****** Object:  View [Tests].[VW_TST_AIXNetstat]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_AIXNetstat]
as
select top 0 CAST(null as nvarchar(max)) [Output],
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_AIXNetstat]    Script Date: 6/8/2020 1:15:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_AIXNetstat] on [Tests].[VW_TST_AIXNetstat]
	instead of insert
as
set nocount on
set transaction isolation level read uncommitted
declare @MOB_ID int,
		@TST_ID int,
		@CollectionDate datetime2(3),
		@CounterDate datetime2(3),
		@TRH_ID int,
		@ClientID int

declare @NewValues table(CounterName varchar(100),
							InstanceName varchar(100),
							SystemID tinyint,
							CounterID int,
							InstanceID int,
							Value bigint,
							StartDate datetime,
							IgnoreIfValueIsOrUnder int)

select @MOB_ID = TRH_MOB_ID,
		@TST_ID = TRH_TST_ID,
		@CollectionDate = TRH_StartDate,
		@CounterDate = StartDate,
		@TRH_ID = Metadata_TRH_ID,
		@ClientID = Metadata_ClientID
from (select top 1 Metadata_TRH_ID, Metadata_ClientID
		from inserted) i
	inner join Collect.TestRunHistory l on TRH_ID = Metadata_TRH_ID
	outer apply (select top 1 s.TRH_StartDate StartDate
					from Collect.TestRunHistory s
					where l.TRH_MOB_ID = s.TRH_MOB_ID
							and l.TRH_TST_ID = s.TRH_TST_ID
							and s.TRH_ID < l.TRH_ID
					order by TRH_ID desc) s

select Val
into #Interfaces
from inserted
	cross apply Infra.fn_SplitString([Output], 'ERNET STAT')
where Val like '%Elapsed Time:%Transmit Statistics%' --'%(%)%EtherChannel%Elapsed Time:%Transmit Statistics%'

;with Step1 as
		(select Val, substring(Val, charindex('(', Val, 1) + 1, charindex(')', Val, charindex('(', Val, 1)) - charindex('(', Val, 1) - 1) IntName
			from #Interfaces
		),
	Step2 as
		(select IntName, left(f.Val, charindex(': ', f.Val, 1) - 1) KeyName, substring(f.Val, charindex(': ', f.Val, 1) + 2, 1000) KeyValue
			from Step1 s
				cross apply Infra.fn_SplitString(replace(s.Val, '  ', CHAR(10) + 'Receive '), char(10)) f
			where f.Val like '%: %'
		)
select *
into #Stats
from Step2

delete #Stats
where KeyName not in ('Hardware Address', 'Elapsed Time', 'Packets', 'Receive Packets', 'Bytes', 'Receive Bytes',
					'Interrupts', 'Receive Interrupts', 'Transmit Errors', 'Receive Receive Errors', 'Packets Dropped',
					'Receive Packets Dropped', 'Receive Bad Packets', 'Max Packets on S/W Transmit Queue', 'S/W Transmit Queue Overflow',
					'Current S/W+H/W Transmit Queue Length', 'Adapter Reset Count')

update #Stats
set KeyName = replace(KeyName, 'Receive Receive', 'Receive')

update #Stats
set KeyName = 'Transmit ' + KeyName
where KeyName in ('Packets', 'Bytes', 'Interrupts', 'Packets Dropped')

update #Stats
set KeyName = replace(KeyName, '  ', ' ')
where KeyName like '%  %'

update #Stats
set KeyName = KeyName + '/sec'
where KeyName not in ('Max Packets on S/W Transmit Queue',
						'S/W Transmit Queue Overflow',
						'Current S/W+H/W Transmit Queue Length')

insert into @NewValues
select KeyName, IntName, GNC_CSY_ID, GNC_ID, null, KeyValue, StartDate, GNC_IgnoreIfValueIsOrUnder
from #Stats s
	cross apply (select dateadd(second, sum(case when f.Val like '%day%' then 60*40*24
														when f.Val like '%hour%' then 60*60
														when f.Val like '%minute%' then 60
														when f.Val like '%second%' then 1
													end * try_cast(left(f.Val, charindex(' ', f.Val, 1) - 1) as int)), getdate()) StartDate
					from #Stats s1
						cross apply Infra.fn_SplitString(s1.KeyValue, 's ') f
					where s1.IntName = s.IntName
						and s1.KeyName = 'Elapsed Time'
						and f.Val like '% %') s1
	inner join PerformanceData.GeneralCounters on GNC_CategoryName = 'AIX Network Interface'
													and GNC_CounterName = KeyName

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
	with CalcValues as
			(select CounterName, InstanceName, SystemID, CounterID, InstanceID,
					cast((Value - OCB_Value)/(DATEDIFF(second, OCB_CollectionDate, @CollectionDate)/60.) as bigint) Value, IgnoreIfValueIsOrUnder
				from @NewValues
					inner join Collect.ObjectCounterBases on OCB_TST_ID = @TST_ID
															and OCB_MOB_ID = @MOB_ID
															and OCB_CSY_ID = SystemID
															and OCB_CounterID = CounterID
															and OCB_CIN_ID = InstanceID
															and OCB_LastRestartDate = StartDate
				where CounterName like '%/sec'
				union all
				select CounterName, InstanceName, SystemID, CounterID, InstanceID, Value, IgnoreIfValueIsOrUnder
				from @NewValues
				where CounterName not like '%/sec'
			)
	insert into PerformanceData.CounterResults(CRS_ClientID, CRS_MOB_ID, CRS_TRH_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_DateTime, CRS_Value)
	select @ClientID, @MOB_ID, @TRH_ID, SystemID, CounterID, InstanceID, cast(convert(char(14), @CounterDate, 121) + '00' as datetime), Value
	from CalcValues
	where Value > IgnoreIfValueIsOrUnder
		or IgnoreIfValueIsOrUnder is null

merge Collect.ObjectCounterBases d
	using (select *
			from @NewValues
			where CounterName like '%/sec') s
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
							values(@TST_ID, @MOB_ID, SystemID, CounterID, InstanceID, @CollectionDate, Value, StartDate);
GO
