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
/****** Object:  StoredProcedure [Reports].[usp_PredictSpaceShortage]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_PredictSpaceShortage]
	@PeriodToConsiderInDays int = 100,
	@AlertOnPercent int = 15
as
;with CounterResults as
		(select CRS_MOB_ID, CRS_InstanceID, CRS_DateTime, CRS_MinValue
			from PerformanceData.CounterResults_Daily
			where CRS_SystemID = 4
				and CRS_CounterID = 26
				and CRS_DateTime >= DATEADD(day, -@PeriodToConsiderInDays, sysdatetime())
				and DATEPART(weekday, CRS_DateTime) = 1
		)
	, Calc as
		(select a.CRS_MOB_ID, a.CRS_InstanceID, avg(a.CRS_MinValue - b.CRS_MinValue) WeeklyPercentDropRate, MAX(b.CRS_DateTime) LastDate
			from CounterResults a
				inner join CounterResults b on a.CRS_MOB_ID = b.CRS_MOB_ID
										and a.CRS_InstanceID = b.CRS_InstanceID
										and dateadd(day, 7, a.CRS_DateTime) = b.CRS_DateTime
			group by a.CRS_MOB_ID, a.CRS_InstanceID
		)
select MOB_Name ServerName, CIN_Name LogicalDisk, cast(WeeklyPercentDropRate as decimal(10, 4)) WeeklyPercentDropRate,
	cast((LastRecordedFreePercentage - @AlertOnPercent) / WeeklyPercentDropRate as decimal(10, 1)) WeeksLeft
from Calc a
	inner join Inventory.MonitoredObjects on MOB_ID = CRS_MOB_ID
	inner join PerformanceData.CounterInstances on CIN_ID = CRS_InstanceID
	cross apply (select top 1 CRS_Value LastRecordedFreePercentage
					from PerformanceData.CounterResults c
					where c.CRS_SystemID = 4
							and c.CRS_CounterID = 26
							and c.CRS_MOB_ID = a.CRS_MOB_ID
							and c.CRS_InstanceID = a.CRS_InstanceID
							and c.CRS_DateTime > LastDate
					order by CRS_DateTime desc) c
order by WeeksLeft
GO
