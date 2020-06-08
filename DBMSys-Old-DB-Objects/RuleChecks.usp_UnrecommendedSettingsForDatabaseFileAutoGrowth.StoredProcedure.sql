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
/****** Object:  StoredProcedure [RuleChecks].[usp_UnrecommendedSettingsForDatabaseFileAutoGrowth]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_UnrecommendedSettingsForDatabaseFileAutoGrowth]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

select @ClientID, @PRR_ID, DBF_MOB_ID, IDB_ID, IDB_Name, DBF_ID, DBF_Name, ResultValue,
	'In ' + case when DBF_GrowthPercent is not null
				then 'Percent'
				else 'Megabytes'
			end, isnull(cast(DBF_GrowthPercent as bigint), DBF_GrowthMB), AutoGrowthEvents, GrowthSizeMB
from Inventory.DatabaseFiles
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = DBF_MOB_ID
	inner join Inventory.InstanceDatabases on IDB_ID = DBF_IDB_ID
	cross apply RuleChecks.fn_GetLastPerformanceCounterValue(@FromDate, @ToDate, DBF_MOB_ID, 3, 41, DBF_FileName, DBF_IDB_ID, default, default) fs
	outer apply (select COUNT(*) AutoGrowthEvents, SUM(AFS_ChangeInSizeMB) GrowthSizeMB
					from Activity.AutoFileSizeChangeEvents
					where AFS_MOB_ID = DBF_MOB_ID
						and AFS_DBF_ID = DBF_ID
						and AFS_AFC_ID in (92, 93)
				) r
where AutoGrowthEvents > 5
	or DBF_GrowthPercent is not null
	or DBF_GrowthMB >= 10*1024
GO
