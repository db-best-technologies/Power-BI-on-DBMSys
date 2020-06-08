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
/****** Object:  StoredProcedure [RuleChecks].[usp_DiskContainingMoreThanOneFileType]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_DiskContainingMoreThanOneFileType]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

select @ClientID, @PRR_ID, DSK_MOB_ID, DSK_ID, DSK_Path, ISNULL(HoldsData, 'No') HoldsData, ISNULL(HoldsLog, 'No') HoldsLog,
	ISNULL(HoldsBackup, 'No') HoldsBackup, ISNULL(HoldsTempdb, 'No') HoldsTempdb
from Inventory.Disks
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = DSK_MOB_ID
	outer apply (select distinct 'Yes' HoldsData, 1 IsData
					from Inventory.DatabaseFiles
					where DBF_DSK_ID = DSK_ID
						and DBF_DFT_ID = 0) d
	outer apply (select distinct 'Yes' HoldsLog, 1 IsLog
					from Inventory.DatabaseFiles
					where DBF_DSK_ID = DSK_ID
						and DBF_DFT_ID = 1) l					
	outer apply (select distinct 'Yes' HoldsBackup, 1 IsBackup
					from Inventory.BackupLocations
					where BKL_DSK_ID = DSK_ID) b	
	outer apply (select distinct 'Yes' HoldsTempdb, 1 IsTempdb
					from Inventory.DatabaseFiles
						inner join Inventory.InstanceDatabases on IDB_ID = DBF_IDB_ID
					where DBF_DSK_ID = DSK_ID
						and DBF_DFT_ID = 0
						and IDB_Name = 'tempdb') t
where ISNULL(IsData, 0) + ISNULL(IsLog, 0) + ISNULL(IsBackup, 0) + ISNULL(IsTempdb, 0) > 1
GO
