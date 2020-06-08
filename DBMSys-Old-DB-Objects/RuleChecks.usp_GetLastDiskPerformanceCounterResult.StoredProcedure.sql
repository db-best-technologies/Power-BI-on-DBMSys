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
/****** Object:  StoredProcedure [RuleChecks].[usp_GetLastDiskPerformanceCounterResult]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_GetLastDiskPerformanceCounterResult]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int,
	@SystemID int,
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

select @ClientID, @PRR_ID, DSK_MOB_ID, DSK_ID, DSK_Path, DSK_TotalSpaceMB, cast(ResultValue as int)
from Inventory.Disks
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = DSK_MOB_ID
	cross apply RuleChecks.fn_GetLastPerformanceCounterValue(@FromDate, @ToDate, DSK_MOB_ID, @SystemID, @CounterID, DSK_Path, default, default, default)
where (ResultValue >= @LowerValue
		or @LowerValue is null)
	and (ResultValue <= @UpperValue
		or @UpperValue is null)
GO
