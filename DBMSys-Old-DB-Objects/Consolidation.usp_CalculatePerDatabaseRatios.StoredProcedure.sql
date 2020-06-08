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
/****** Object:  StoredProcedure [Consolidation].[usp_CalculatePerDatabaseRatios]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Consolidation].[usp_CalculatePerDatabaseRatios]
as
if OBJECT_ID('tempdb..#PerDatabaseData') is not null
	drop table #PerDatabaseData
if OBJECT_ID('tempdb..#PerDatabaseDataByCounter') is not null
	drop table #PerDatabaseDataByCounter
truncate table Consolidation.PerDatabaseRatios

declare @Percentile decimal(10, 2)

select @Percentile = CAST(SET_Value as decimal(10, 2))
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Counter Percentile'

select distinct CRS_MOB_ID, CRS_InstanceID, CRS_CounterID,
	percentile_disc(@Percentile/100) within group (order by CRS_Value) over(partition by CRS_MOB_ID, CRS_InstanceID, CRS_CounterID) Value
into #PerDatabaseData
from PerformanceData.CounterResults
where CRS_SystemID = 3
	and CRS_CounterID in (71, 72, 86, 87)
	and CRS_MOB_ID in (select BBD_Database_MOB_ID from Consolidation.BreakByDatabase)

select BBD_Server_MOB_ID, IDB_ID,
	max(case when CRS_CounterID = 71 then Value else 0.0001 end) CPU,
	max(case when CRS_CounterID = 72 then Value else 0.0001 end) Memory,
	max(case when CRS_CounterID = 86 then Value else 0.0001 end) IOph,
	max(case when CRS_CounterID = 87 then Value else 0.0001 end) MBph
into #PerDatabaseDataByCounter
from #PerDatabaseData
	inner join PerformanceData.CounterInstances on CIN_ID = CRS_InstanceID
	inner join Inventory.InstanceDatabases on IDB_MOB_ID = CRS_MOB_ID
												and ((CRS_CounterID in (86, 87)
														and CIN_Name like '(' + IDB_Name + ')%')
													or (CRS_CounterID in (71, 72)
														and CIN_Name = IDB_Name)
													)
	inner join Consolidation.BreakByDatabase on BBD_Database_MOB_ID = IDB_MOB_ID
where IDB_Name not in ('master', 'model', 'tempdb', 'msdb', 'distribution')
group by BBD_Server_MOB_ID, IDB_ID

insert into Consolidation.PerDatabaseRatios
select BBD_Server_MOB_ID, IDB_ID,
	CPU/SUM(CPU) over(partition by BBD_Server_MOB_ID) CPURatio,
	Memory/SUM(Memory) over(partition by BBD_Server_MOB_ID) MemoryRatio,
	IOph/SUM(IOph) over(partition by BBD_Server_MOB_ID) IOphRatio,
	MBph/SUM(MBph) over(partition by BBD_Server_MOB_ID) MBphRatio
from #PerDatabaseDataByCounter
GO
