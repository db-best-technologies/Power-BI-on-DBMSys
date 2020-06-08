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
/****** Object:  StoredProcedure [PerformanceData].[usp_AggregateResults]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [PerformanceData].[usp_AggregateResults]
as
set nocount on

declare @Max_CRS_ID bigint,
		@Last_CRS_ID bigint,
		@LastDate datetime2(3)

select @Max_CRS_ID = MAX(CRS_ID)
from PerformanceData.CounterResults

select @Last_CRS_ID = MAX(CRS_MaxSource_CRS_ID)
from PerformanceData.CounterResults_Hourly
if @Last_CRS_ID < @Max_CRS_ID
	or @Last_CRS_ID is null

if @Last_CRS_ID is not null or not exists (select * from PerformanceData.CounterResults_Hourly)
begin
	if @Last_CRS_ID is not null
		select @LastDate = CRS_DateTime
		from PerformanceData.CounterResults
		where CRS_ID = @Last_CRS_ID
	else
		select @LastDate = min(CRS_DateTime)
		from PerformanceData.CounterResults

	while @@ROWCOUNT > 0
		with D as
			(select top(100) CRS_ID
				from PerformanceData.CounterResults_Hourly with (forceseek)
				where CRS_DateTime >= cast(convert(char(14), @LastDate, 121) + '00' as datetime2(3))
			)
		delete D

	;with CounterRawData as
		(select CRS_ClientID, CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID,
					cast(convert(char(14), CRS_DateTime, 121) + '00' as datetime2(3)) ResultDateTime, CRT_Name,
					CRS_Value, IsAggregative,
					count(CRS_ID) over (partition by CRS_ClientID, CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID,
												cast(convert(char(14), CRS_DateTime, 121) + '00' as datetime2(3))) ResultCount,
					case when CRT_Name is not null
						then COUNT(*) over (partition by CRS_ClientID, CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID,
														cast(convert(char(14), CRS_DateTime, 121) + '00' as datetime2(3)), CRT_Name)
					end StatusCount, CRS_ID
			from PerformanceData.CounterResults
					inner join PerformanceData.VW_Counters on CRS_SystemID = SystemID
															and CRS_CounterID = CounterID
					left join PerformanceData.CounterResultStatuses on CRS_CRT_ID  = CRT_ID
				where CRS_DateTime >= @LastDate
		),
		CounterData as
			(select CRS_ClientID, CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID,
				ResultDateTime, CRT_Name, ResultCount, 
				case when IsAggregative = 0 then min(CRS_Value) end MinValue,
				case when IsAggregative = 0 then avg(CRS_Value) end AvgValue,
				case when IsAggregative = 0 then max(CRS_Value) end MaxValue,
				case when IsAggregative = 1 then sum(CRS_Value) end SumValue,
				case when CRT_Name is not null
					then RANK() over (partition by CRS_ClientID, CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID, ResultDateTime, CRT_Name
										order by StatusCount desc)
				end StatusRank, StatusCount, MAX(CRS_ID) Max_CRS_ID
			from CounterRawData
			group by CRS_ClientID, CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID, ResultDateTime, IsAggregative, CRT_Name, ResultCount, StatusCount
			)
	insert into PerformanceData.CounterResults_Hourly(CRS_ClientID, CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID, CRS_DateTime, CRS_ResultCount,
														CRS_MinValue, CRS_AvgValue, CRS_MaxValue, CRS_SumValue, CRS_DominantStatus, CRS_DominantStatusPercentage,
														CRS_SecondaryStatus, CRS_SecondaryStatusPercentage, CRS_MaxSource_CRS_ID)
	select CRS_ClientID, CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID, ResultDateTime, ResultCount,
		min(MinValue) MinValue, avg(AvgValue) AvgValue, max(MaxValue) MaxValue, sum(SumValue) SumValue,
		max(case when StatusRank = 1 then CRT_Name end) DominantStatus,
		max(case when StatusRank = 1 then StatusCount*100/ResultCount end) DominantStatusPercentage,
		max(case when StatusRank = 2 then CRT_Name end) SecondaryStatus,
		max(case when StatusRank = 2 then StatusCount*100/ResultCount end) SecondaryStatusPercentage, max(Max_CRS_ID) Max_CRS_ID
	from CounterData
	group by CRS_ClientID, CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID, ResultDateTime, ResultCount
	option (maxdop 3)
end

select @Last_CRS_ID = MAX(CRS_MaxSource_CRS_ID)
from PerformanceData.CounterResults_Daily

if @Last_CRS_ID < @Max_CRS_ID
	or @Last_CRS_ID is null
begin
	if @Last_CRS_ID is not null
		select @LastDate = CRS_DateTime
		from PerformanceData.CounterResults
		where CRS_ID = @Last_CRS_ID
	else
		select @LastDate = min(CRS_DateTime)
		from PerformanceData.CounterResults

	while @@ROWCOUNT > 0
		with D as
			(select top(100) CRS_ID
				from PerformanceData.CounterResults_Daily with (forceseek)
				where CRS_DateTime >= cast(@LastDate as date)
			)
		delete D

	;with CounterRawData as
		(select CRS_ClientID, CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID,
					cast(CRS_DateTime as date) ResultDateTime, CRT_Name,
					CRS_Value, IsAggregative,
					count(CRS_ID) over (partition by CRS_ClientID, CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID,
												cast(CRS_DateTime as date)) ResultCount,
					case when CRT_Name is not null
						then COUNT(*) over (partition by CRS_ClientID, CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID,
														cast(CRS_DateTime as date), CRT_Name)
					end StatusCount, CRS_ID
			from PerformanceData.CounterResults
					inner join PerformanceData.VW_Counters on CRS_SystemID = SystemID
															and CRS_CounterID = CounterID
					left join PerformanceData.CounterResultStatuses on CRS_CRT_ID  = CRT_ID
				where CRS_DateTime >= @LastDate
		),
		CounterData as
			(select CRS_ClientID, CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID,
				ResultDateTime, CRT_Name, ResultCount, 
				case when IsAggregative = 0 then min(CRS_Value) end MinValue,
				case when IsAggregative = 0 then avg(CRS_Value) end AvgValue,
				case when IsAggregative = 0 then max(CRS_Value) end MaxValue,
				case when IsAggregative = 1 then sum(CRS_Value) end SumValue,
				case when CRT_Name is not null
					then RANK() over (partition by CRS_ClientID, CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID, ResultDateTime, CRT_Name
										order by StatusCount desc)
				end StatusRank, StatusCount, MAX(CRS_ID) Max_CRS_ID
			from CounterRawData
			group by CRS_ClientID, CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID, ResultDateTime, IsAggregative, CRT_Name, ResultCount, StatusCount
			)
	insert into PerformanceData.CounterResults_Daily(CRS_ClientID, CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID, CRS_DateTime, CRS_ResultCount,
														CRS_MinValue, CRS_AvgValue, CRS_MaxValue, CRS_SumValue, CRS_DominantStatus, CRS_DominantStatusPercentage,
														CRS_SecondaryStatus, CRS_SecondaryStatusPercentage, CRS_MaxSource_CRS_ID)
	select CRS_ClientID, CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID, ResultDateTime, ResultCount,
		min(MinValue) MinValue, avg(AvgValue) AvgValue, max(MaxValue) MaxValue, sum(SumValue) SumValue,
		max(case when StatusRank = 1 then CRT_Name end) DominantStatus,
		max(case when StatusRank = 1 then StatusCount*100/ResultCount end) DominantStatusPercentage,
		max(case when StatusRank = 2 then CRT_Name end) SecondaryStatus,
		max(case when StatusRank = 2 then StatusCount*100/ResultCount end) SecondaryStatusPercentage, max(Max_CRS_ID) Max_CRS_ID
	from CounterData
	group by CRS_ClientID, CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID, ResultDateTime, ResultCount
	option (maxdop 3)
end
GO
