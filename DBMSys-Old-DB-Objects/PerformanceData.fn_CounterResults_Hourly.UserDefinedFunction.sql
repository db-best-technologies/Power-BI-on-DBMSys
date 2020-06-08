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
/****** Object:  UserDefinedFunction [PerformanceData].[fn_CounterResults_Hourly]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [PerformanceData].[fn_CounterResults_Hourly](@StartDate datetime2(3),
															@EndDate datetime2(3)) returns table
as
return select MOB_Name ServerName, CSY_Name SystemName, CounterName, CIN_Name InstanceName, IDB_Name DatabaseName, CRS_DateTime SnapshotDate,
			case when IsAggregative	= 0 then CRS_MinValue end MinValue,
			case when IsAggregative	= 0 then CRS_AvgValue end AvgValue,
			case when IsAggregative	= 0 then CRS_MaxValue end MaxValue,
			case when IsAggregative	= 1 then CRS_SumValue end SumValue,
			IsAggregative,
			CategoryName + '\' + CounterName + isnull(' (' + nullif(ISNULL(IDB_Name, '')
										+ case when IDB_Name <> CIN_Name
												then '>'
												else ''
											end + isnull(nullif(CIN_Name, IDB_Name), ''), '')
									+ ')', '') DisplayCounterName,
			CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID
		from (select CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID, CRS_DateTime, CRS_MinValue, CRS_AvgValue, CRS_MaxValue, CRS_SumValue
				from PerformanceData.CounterResults_Hourly
				where CRS_DateTime >= @StartDate and CRS_DateTime < dateadd(day, 1, @EndDate)
				union all
				select CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID,
						cast(convert(char(14), CRS_DateTime, 121) + '00' as datetime2(3)) CRS_DateTime, MIN(CRS_Value), AVG(CRS_Value), MAX(CRS_Value), SUM(CRS_Value)
				from PerformanceData.CounterResults
				where CRS_DateTime
						>= dateadd(day, 1, isnull((select MAX(CRS_DateTime) from PerformanceData.CounterResults_Hourly), '20000101'))
						and CRS_DateTime >= @StartDate and CRS_DateTime < dateadd(day, 1, @EndDate)
				group by CRS_MOB_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID, CRS_IDB_ID, cast(convert(char(14), CRS_DateTime, 121) + '00' as datetime2(3))
				) t
			inner join PerformanceData.VW_Counters on SystemID = CRS_SystemID
												and CounterID = CRS_CounterID
			inner join PerformanceData.CounterSystems on CSY_ID = SystemID
			inner join Inventory.MonitoredObjects on MOB_ID = CRS_MOB_ID
			left join PerformanceData.CounterInstances on CIN_ID = CRS_InstanceID
			left join Inventory.InstanceDatabases on IDB_ID = CRS_IDB_ID
GO
