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
/****** Object:  StoredProcedure [RuleChecks].[usp_DatabaseWithAutogrowthEvents]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_DatabaseWithAutogrowthEvents]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

select @ClientID, @PRR_ID, IDB_MOB_ID, IDB_ID, IDB_Name, DBF_ID, DBF_FileName, AFC_Name, COUNT(*) cnt, min(AFS_ProcessStartTime) FirstDate, MAX(AFS_ProcessEndTime) LastDate,
	FileSize, SizeIn1Year, SizeIn2Years, SizeIn3Years
from Activity.AutoFileSizeChangeEvents
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = AFS_MOB_ID
	inner join Inventory.InstanceDatabases on IDB_ID = AFS_IDB_ID
	inner join Activity.AutoFileSizeChangeEventTypes on AFC_ID = AFS_AFC_ID
	inner join Inventory.DatabaseFiles on DBF_ID = AFS_DBF_ID
	outer apply RuleChecks.fn_PredictDataFileSize(DBF_ID, @FromDate, @ToDate, default) p
where AFS_ProcessEndTime between @FromDate and @ToDate
group by IDB_MOB_ID, IDB_ID, IDB_Name, DBF_ID, DBF_FileName, AFC_Name, AFS_DBF_ID, FileSize, SizeIn1Year, SizeIn2Years, SizeIn3Years
GO
