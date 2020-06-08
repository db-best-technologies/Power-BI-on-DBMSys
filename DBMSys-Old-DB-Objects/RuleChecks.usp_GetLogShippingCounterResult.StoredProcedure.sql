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
/****** Object:  StoredProcedure [RuleChecks].[usp_GetLogShippingCounterResult]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_GetLogShippingCounterResult]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int,
	@CounterID int
as
set nocount on
set transaction isolation level read uncommitted
declare @LowerValue decimal(18, 5),
		@UpperValue decimal(18, 5)

select @LowerValue = RTH_LowerValue,
	@UpperValue = RTH_UpperValue
from BusinessLogic.RuleThresholds
where RTH_ID = @RTH_ID

select @ClientID, @PRR_ID, s.MOB_ID, sd.IDB_ID, sd.IDB_Name, d.MOB_ID, d.MOB_Name, dd.IDB_ID, dd.IDB_Name, ResultValue
from Inventory.MonitoredObjects m
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = m.MOB_ID
	inner join Management.PlatformTypes on PLT_ID = m.MOB_PLT_ID
	inner join PerformanceData.CounterInstances on CIN_Name like '% (%) --> % (%)'
	cross apply RuleChecks.fn_GetLastPerformanceCounterValue(@FromDate, @ToDate, m.MOB_ID, 3, @CounterID, CIN_Name, default, default, default)
	cross apply (select parsename(ConvInstanceName, 4) SourceInstanceName,
						parsename(ConvInstanceName, 3) SourceDatabaseName,
						parsename(ConvInstanceName, 2) DestinationInstanceName,
						parsename(ConvInstanceName, 1) DestinationDatabaseName
					from (select replace(replace(replace(replace(replace(CIN_Name, '> ', '>'), ' ', '.'), '(', ''), ')', ''), '-->', '') ConvInstanceName) ci) ob
	inner join Inventory.MonitoredObjects s on s.MOB_PLT_ID = 1
												and s.MOB_Name = SourceInstanceName
	inner join Inventory.InstanceDatabases sd on sd.IDB_MOB_ID = s.MOB_ID
													and sd.IDB_Name = SourceDatabaseName
	inner join Inventory.MonitoredObjects d on d.MOB_PLT_ID = 1
												and d.MOB_Name = DestinationInstanceName
	inner join Inventory.InstanceDatabases dd on dd.IDB_MOB_ID = d.MOB_ID
													and dd.IDB_Name = DestinationDatabaseName
where PLT_PLC_ID = 1
	and (ResultValue >= @LowerValue
		or @LowerValue is null)
	and (ResultValue <= @UpperValue
		or @UpperValue is null)
GO
