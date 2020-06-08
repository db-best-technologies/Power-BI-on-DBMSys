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
/****** Object:  StoredProcedure [Consolidation].[usp_Reports_SQLWaits]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Consolidation].[usp_Reports_SQLWaits]
as
declare @Percentile decimal(10, 2),
	@FromDay int,
	@ToDay int,
	@FromHour int,
	@ToHour int

if object_id('tempdb..#ServerWaits') is not null
	drop table #ServerWaits

select @Percentile = CAST(SET_Value as decimal(10, 2))
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Counter Percentile'

select @FromDay = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Calculate Workload From Week Day'

select @ToDay = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Calculate Workload To Week Day'

select @FromHour = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Calculate Workload From Day Hour'

select @ToHour = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Calculate Workload To Day Hour'

select PDS_Server_MOB_ID, GNC_CounterName WaitType, TotalWaitTime, WaitTimePerHour, cast(TotalWaitTime*100./sum(TotalWaitTime) over(partition by PDS_Server_MOB_ID) as decimal(10, 2)) PercentageOfAllWaits
into #ServerWaits
from Consolidation.ParticipatingDatabaseServers p
	cross join PerformanceData.GeneralCounters
	cross join PerformanceData.CounterInstances
	cross apply (select sum(TotalWaitTime) TotalWaitTime, sum(TotalWaitTime)/sum(SampleCount)/4 WaitTimePerHour
					from (select sum(cast(CRS_Value as bigint))*1000 TotalWaitTime, count(*) SampleCount
							from Consolidation.ParticipatingDatabaseServers p1
								inner join PerformanceData.CounterResults on CRS_MOB_ID = p1.PDS_Database_MOB_ID
							where p1.PDS_Server_MOB_ID = p.PDS_Server_MOB_ID
								and CRS_SystemID = GNC_CSY_ID
								and CRS_CounterID = GNC_ID
								and CRS_InstanceID = CIN_ID
								and (datepart(weekday, CRS_DateTime) between @FromDay and @ToDay or @FromDay is null or @ToDay is null)
								and (datepart(hour, CRS_DateTime) between @FromHour and @ToHour or @FromHour is null or @ToHour is null)
							group by p1.PDS_Database_MOB_ID
							) r
				) r
where GNC_CSY_ID = 5
	and CIN_Name = 'Wait Time (Sec)'
	and GNC_CounterName <> '_Total'
	and TotalWaitTime is not null

select MOB_Name ServerName, WaitType, TotalWaitTime, WaitTimePerHour, PercentageOfAllWaits
from Inventory.MonitoredObjects
	cross apply (select top 20 WaitType, TotalWaitTime, WaitTimePerHour, PercentageOfAllWaits
					from #ServerWaits
					where PDS_Server_MOB_ID = MOB_ID
					order by TotalWaitTime desc) w
where exists (select *
				from Consolidation.ParticipatingDatabaseServers
				where PDS_Server_MOB_ID = MOB_ID)
order by ServerName, PercentageOfAllWaits desc
GO
