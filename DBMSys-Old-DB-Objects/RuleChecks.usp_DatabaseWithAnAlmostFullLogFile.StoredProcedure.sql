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
/****** Object:  StoredProcedure [RuleChecks].[usp_DatabaseWithAnAlmostFullLogFile]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_DatabaseWithAnAlmostFullLogFile]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

declare @UpperValue decimal(10, 2),
		@LowerValue decimal(10, 2)

select @UpperValue = RTH_UpperValue,
		@LowerValue = RTH_LowerValue

from BusinessLogic.RuleThresholds
where RTH_ID = @RTH_ID

select @ClientID, @PRR_ID, IDB_MOB_ID, IDB_ID, IDB_Name, DBF_Name, fs.ResultValue FileSize, ufs.ResultValue UsedFileSize, LRW_Name
from Inventory.InstanceDatabases
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = IDB_MOB_ID
	inner join Inventory.DatabaseFiles on DBF_MOB_ID = IDB_MOB_ID
											and DBF_IDB_ID = IDB_ID
	inner join Inventory.LogReuseWaitReasons on LRW_ID = IDB_LRW_ID
	cross apply RuleChecks.fn_GetLastPerformanceCounterValue(@FromDate, @ToDate, DBF_MOB_ID, 3, 41, DBF_FileName, DBF_IDB_ID, default, default) fs
	cross apply RuleChecks.fn_GetLastPerformanceCounterValue(@FromDate, @ToDate, DBF_MOB_ID, 3, 42, DBF_FileName, DBF_IDB_ID, default, default) ufs
where DBF_DFT_ID = 0
	and (ufs.ResultValue*100./fs.ResultValue >= @LowerValue
			or @LowerValue is null)
	and (ufs.ResultValue*100./fs.ResultValue <= @UpperValue
			or @UpperValue is null)
GO
