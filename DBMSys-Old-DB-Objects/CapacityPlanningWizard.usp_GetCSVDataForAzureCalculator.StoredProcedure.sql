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
/****** Object:  StoredProcedure [CapacityPlanningWizard].[usp_GetCSVDataForAzureCalculator]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [CapacityPlanningWizard].[usp_GetCSVDataForAzureCalculator]
as
set nocount on
if OBJECT_ID('tempdb..#Counters') is not null
	drop table #Counters
if OBJECT_ID('tempdb..#PerformanceData') is not null
	drop table #PerformanceData
if OBJECT_ID('tempdb..#ServerAndCounters') is not null
	drop table #ServerAndCounters

declare @Percentile decimal(10, 2)

select @Percentile = CAST(SET_Value as decimal(10, 2))
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Counter Percentile'

select SystemID, CounterID, CategoryName, CounterName
into #Counters
from PerformanceData.VW_Counters
where (CategoryName = 'Processor' and CounterName = '% Processor Time')
	or (CategoryName = 'Database Files IO' and CounterName = 'Reads/sec')
	or (CategoryName = 'Database Files IO' and CounterName = 'Writes/sec')
	or (CategoryName = 'Databases' and CounterName = 'Log Bytes Flushed/sec')

select PDS_Server_MOB_ID, PDS_Database_MOB_ID, SystemID, CounterID, CounterName
into #ServerAndCounters
from Consolidation.ParticipatingDatabaseServers
	cross join #Counters
where PDS_Database_MOB_ID is not null



;with PerformanceData as
		(select PDS_Server_MOB_ID MOB_ID, CRS_MOB_ID, CRS_DateTime, CounterName, sum(CRS_Value) Value
			from (select distinct PDS_Server_MOB_ID, SystemID, CounterID, CounterName
						from #ServerAndCounters
						where SystemID = 4) c
				inner join PerformanceData.CounterResults on CRS_MOB_ID = PDS_Server_MOB_ID
															and SystemID = CRS_SystemID
															and CounterID = CRS_CounterID
			group by PDS_Server_MOB_ID, CRS_MOB_ID, CRS_DateTime, CounterName
			union all
			select PDS_Server_MOB_ID MOB_ID, CRS_MOB_ID, CRS_DateTime, CounterName, sum(CRS_Value) Value
			from #ServerAndCounters
				inner join PerformanceData.CounterResults on CRS_MOB_ID = PDS_Database_MOB_ID
															and SystemID = CRS_SystemID
															and CounterID = CRS_CounterID
			where SystemID in (1, 3)
			group by PDS_Server_MOB_ID, CRS_MOB_ID, CRS_DateTime, CounterName

		)
	, CounterData as --Used in order to aggregate data from multiple hosted SQL instances into one value per 10 minutes
		(select MOB_ID, CounterName, cast(convert(char(15), CRS_DateTime, 121) + '0' as datetime) DT, avg(Value) Value
			from PerformanceData
			group by CounterName, MOB_ID, CRS_MOB_ID, cast(convert(char(15), CRS_DateTime, 121) + '0' as datetime)
		)
	, AggCounters as
		(select MOB_ID, CounterName, sum(Value) Value
			from CounterData
			group by MOB_ID, CounterName, DT
		)
	, Input as
		(select PDS_Server_MOB_ID MOB_ID, case CounterName
						when 'Log Bytes Flushed/sec' then 'logBytesFlushed'
						when '% Processor Time' then 'processorTime'
						when 'Reads/sec' then 'diskReads'
						when 'Writes/sec' then 'diskWrites'	
					end CounterName, Value
			from #Counters c
				cross apply (select distinct PDS_Server_MOB_ID
								from #ServerAndCounters) s
				cross apply (select top 1 cast(percentile_disc(@Percentile/100) within group (order by Value) over(partition by CounterName) as decimal(18, 2)) Value
								from AggCounters a
								where a.CounterName = c.CounterName
									and a.MOB_ID = PDS_Server_MOB_ID
								) r
		)
select MOB_ID, logBytesFlushed, processorTime, diskReads, diskWrites
from Input
	pivot (sum(Value) for CounterName in (logBytesFlushed, processorTime, diskReads, diskWrites)) p
GO
