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
/****** Object:  StoredProcedure [RuleChecks].[usp_MirroringSendLatency]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_MirroringSendLatency]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

declare @LowerValue decimal(18, 5),
		@UpperValue decimal(18, 5)

select @LowerValue = RTH_LowerValue,
	@UpperValue = RTH_UpperValue
from BusinessLogic.RuleThresholds
where RTH_ID = @RTH_ID

select @ClientID, @PRR_ID, MRD_MOB_ID, IDB_ID, IDB_Name, MOB_ID, MOB_Name, isnull(cast(sqs.ResultValue/1024. as decimal(10, 2)), 0),
	isnull(cast(sr.ResultValue/1024./1024 as decimal(10, 2)), 0)
from Inventory.MirroredDatabases
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = MRD_MOB_ID
	inner join Inventory.MonitoredObjects on MOB_ID = MRD_Partner_MOB_ID
	inner join Inventory.InstanceDatabases pd on IDB_ID = MRD_IDB_ID
	cross apply RuleChecks.fn_GetLastPerformanceCounterValue(@FromDate, @ToDate, MRD_MOB_ID, 1, 32, IDB_Name, default, default, default) sqs
	outer apply RuleChecks.fn_GetLastPerformanceCounterValue(@FromDate, @ToDate, MRD_MOB_ID, 1, 32, IDB_Name, default, default, default) sr
where MRD_Partner_MOB_ID is not null
	and (sqs.ResultValue/1024. >= @LowerValue
		or @LowerValue is null)
	and (sqs.ResultValue/1024. <= @UpperValue
		or @UpperValue is null)
GO
