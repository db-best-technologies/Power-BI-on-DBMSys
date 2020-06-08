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
/****** Object:  StoredProcedure [Consolidation].[usp_RedFlags]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Consolidation].[usp_RedFlags]
as
if OBJECT_ID('tempdb..#CounterResultsForSimpleRedFlags') is not null
	drop table #CounterResultsForSimpleRedFlags
if OBJECT_ID('tempdb..#Combinations') is not null
	drop table #Combinations

truncate table Consolidation.RedFlagsOverThresholdCounters
truncate table Consolidation.RedFlagsByResourceType

;With Input as
		(select RFL_PCG_ID, RFL_SystemID, RFL_CounterID, 
				iif(CRS_MOB_ID = PPH_Primary_Server_MOB_ID, PPH_Server_MOB_ID, PPH_Database_MOB_ID) CRS_MOB_ID,
				CRS_InstanceID, CRS_DateTime, RFL_DiffSign, RFL_Value,
				ROW_NUMBER() over (partition by RFL_SystemID, RFL_CounterID, iif(CRS_MOB_ID = PPH_Primary_Server_MOB_ID, PPH_Server_MOB_ID, PPH_Database_MOB_ID),
												CRS_InstanceID order by CRS_DateTime) rn,
				case when RFL_IsIncremental = 0
					then CRS_Value
					else CRS_Value - LAG(CRS_Value ,1 , CRS_Value) over(partition by RFL_SystemID, RFL_CounterID,
																					iif(CRS_MOB_ID = PPH_Primary_Server_MOB_ID, PPH_Server_MOB_ID, PPH_Database_MOB_ID), CRS_InstanceID order by CRS_DateTime)
				end/case RFL_DivideBy
						when '%CoreCount%' then CoreCount
						else 1
					end Value
			from Consolidation.RedFlags
				cross join Consolidation.ParticipatingServersPrimaryHistory
				inner join PerformanceData.CounterResults on CRS_MOB_ID in (PPH_Primary_Server_MOB_ID, PPH_Primary_Database_MOB_ID)
																and CRS_SystemID =  RFL_SystemID
																and CRS_CounterID = RFL_CounterID
																and CRS_DateTime >= PPH_StartDate
																and CRS_DateTime < PPH_EndDate
				cross apply (select sum(CPF_CPUCount) CoreCount
								from Consolidation.CPUFactoring
								where CPF_MOB_ID = PPH_Primary_Server_MOB_ID
								) c
			where RFL_Value is not null
				and RFL_IsActive = 1
		)
select *,
		case when (RFL_DiffSign = '<' and Value < RFL_Value)
										or (RFL_DiffSign = '>' and Value > RFL_Value)
						then 1
						else 0
					end IsOverThreshold
into #CounterResultsForSimpleRedFlags
from Input
where [Value] > 0

create clustered index IX_#CounterResultsForSimpleRedFlags on #CounterResultsForSimpleRedFlags(RFL_SystemID, RFL_CounterID, CRS_MOB_ID, CRS_InstanceID, IsOverThreshold)
create index IX_#CounterResultsForSimpleRedFlags_1 on #CounterResultsForSimpleRedFlags(CRS_MOB_ID, RFL_PCG_ID, IsOverThreshold) include(CRS_DateTime)

select distinct CRS_MOB_ID, CRS_InstanceID
into #Combinations
from #CounterResultsForSimpleRedFlags
where RFL_SystemID = 3 and RFL_CounterID = 88

insert into #CounterResultsForSimpleRedFlags
select 3, 3, 88, CRS_MOB_ID, CRS_InstanceID, cast(convert(char(14), TRH_StartDate, 121) + '00' as datetime) CollectionDate, '>', 20, 0, 0, 0
from #Combinations c
	inner join Collect.TestRunHistory on TRH_MOB_ID = CRS_MOB_ID
										and TRH_TST_ID = 26
										and TRH_TRS_ID = 3
where not exists (select *
					from #CounterResultsForSimpleRedFlags r
					where c.CRS_MOB_ID = r.CRS_MOB_ID
						and c.CRS_InstanceID = r.CRS_InstanceID
						and cast(convert(char(14), TRH_StartDate, 121) + '00' as datetime) = CRS_DateTime)

;with Input as
		(select RFL_PCG_ID RC_PCG_ID, RFL_SystemID RC_SystemID, RFL_CounterID RC_CounterID, CRS_MOB_ID RC_MOB_ID, CRS_InstanceID RC_InstanceID, RFL_DiffSign RC_DiffSign, RFL_Value RC_Value,
							min(Value) MinValue, avg(Value) AvgValue, max(Value) MaxValue, count(*) SamplesCollected, COUNT(distinct DATEPART(day, CRS_DateTime)) DaysSampled,
							cast(sum(IsOverThreshold)*100./COUNT(*) as decimal(10, 2)) PercentOverThreshold
			from #CounterResultsForSimpleRedFlags
			where not (RFL_SystemID = 3 and RFL_CounterID = 88)
			group by RFL_PCG_ID, RFL_SystemID, RFL_CounterID, CRS_MOB_ID, CRS_InstanceID, RFL_DiffSign, RFL_Value
			having sum(IsOverThreshold)*100./COUNT(*) >= 10
				and COUNT(distinct DATEPART(day, CRS_DateTime)) > 5
		)
insert into Consolidation.RedFlagsOverThresholdCounters
select *,
		isnull('{' + stuff((select case when PrevHour + 1 = Hr and NextHour - 1 = Hr then ''
									when NextHour - 1 = Hr then ', ' + CAST(Hr as varchar(10)) + '-'
									when PrevHour + 1 = Hr then cast(Hr as varchar(10))
									else ', ' + cast(Hr as varchar(10))
								end
							from (select Hr,
											LAG(Hr ,1) over(order by Hr) PrevHour,
											LEAD(Hr ,1) over(order by Hr) NextHour
									from (select DATEPART(hour, CRS_DateTime) Hr
											from #CounterResultsForSimpleRedFlags
											where CRS_MOB_ID = RC_MOB_ID
												and RFL_PCG_ID = RC_PCG_ID
												and IsOverThreshold = 1
											group by DATEPART(hour, CRS_DateTime)
											having COUNT(distinct DATEPART(day, CRS_DateTime)) > avg(DaysSampled)*.3
												and COUNT(distinct DATEPART(day, CRS_DateTime)) > 5
											) t
									) t
							for xml path('')), 1, 2, '') + '}', '') HoursWithMoreThanThan30PercentRecurrence
from Input
group by RC_PCG_ID, RC_SystemID, RC_CounterID, RC_MOB_ID, RC_InstanceID, RC_DiffSign, RC_Value, MinValue, AvgValue, MaxValue, SamplesCollected, DaysSampled, PercentOverThreshold

insert into Consolidation.RedFlagsByResourceType
select RFC_MOB_ID, RFC_PCG_ID, avg(RFC_DaysSampled) [Days Sampled],
	cast(avg(RFC_PercentOverThreshold) as decimal(10, 2)) [Percent Over Threshold],
	isnull('{' + stuff((select case when PrevHour + 1 = Hr and NextHour - 1 = Hr then ''
								when NextHour - 1 = Hr then ', ' + CAST(Hr as varchar(10)) + '-'
								when PrevHour + 1 = Hr then cast(Hr as varchar(10))
								else ', ' + cast(Hr as varchar(10))
							end
				from (select Hr,
								LAG(Hr ,1) over(order by Hr) PrevHour,
								LEAD(Hr ,1) over(order by Hr) NextHour
						from (select DATEPART(hour, CRS_DateTime) Hr
								from #CounterResultsForSimpleRedFlags
								where CRS_MOB_ID = RFC_MOB_ID
									and RFL_PCG_ID = RFC_PCG_ID
									and IsOverThreshold = 1
								group by DATEPART(hour, CRS_DateTime)
								having COUNT(distinct DATEPART(day, CRS_DateTime)) > avg(RFC_DaysSampled)*.3
									and COUNT(distinct DATEPART(day, CRS_DateTime)) > 5
								) t
						) t
				for xml path('')), 1, 2, '') + '}', '') [Hours With More Than 30% Recurrence]
from Consolidation.RedFlagsOverThresholdCounters
group by RFC_MOB_ID, RFC_PCG_ID
GO
