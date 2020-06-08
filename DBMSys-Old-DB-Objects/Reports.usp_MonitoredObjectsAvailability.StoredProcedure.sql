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
/****** Object:  StoredProcedure [Reports].[usp_MonitoredObjectsAvailability]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_MonitoredObjectsAvailability]
	@FromDate date = null,
	@ToDate date = null
as
if @FromDate is null
	set @FromDate = CAST(dateadd(day, -1, sysdatetime()) as date)
if @ToDate is null
	set @ToDate = CAST(dateadd(day, -1, sysdatetime()) as date)

select @FromDate [From], @ToDate [To], MOB_Name [Object], PLT_Name [Platform],
	cast(Avail as varchar(10)) + '%' Availability
from Inventory.MonitoredObjects
	inner join Management.PlatformTypes on MOB_PLT_ID = PLT_ID
	cross apply (select cast(sum(case when CRT_Name in ('Successful', 'Success')
								then 1
								else 0
							end)*100./COUNT(*) as decimal(10, 2)) Avail
					from PerformanceData.CounterResults with (index=IX_CounterResults_CRS_MOB_ID#CRS_SystemID#CRS_CounterID##CRS_ID#CRS_TRH_ID#CRS_Value#CRS_CRT_ID#CRS_IDB_ID)
						inner join PerformanceData.CounterResultStatuses on CRS_CRT_ID = CRT_ID
					where CRS_MOB_ID = MOB_ID
						and CRS_SystemID = 3
						and CRS_CounterID in (1, 11)
						and cast(CRS_DateTime as date) between @FromDate and @ToDate
				) r
where MOB_OOS_ID = 1
order by Avail
GO
