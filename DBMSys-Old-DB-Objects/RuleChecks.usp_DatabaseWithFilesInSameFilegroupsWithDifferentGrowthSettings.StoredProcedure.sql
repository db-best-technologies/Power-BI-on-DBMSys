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
/****** Object:  StoredProcedure [RuleChecks].[usp_DatabaseWithFilesInSameFilegroupsWithDifferentGrowthSettings]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_DatabaseWithFilesInSameFilegroupsWithDifferentGrowthSettings]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

select @ClientID, @PRR_ID, IDB_MOB_ID, IDB_ID, IDB_Name, DFG_ID, DFG_Name, FileCount
from Inventory.InstanceDatabases
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = IDB_MOB_ID
	inner join Inventory.DatabaseFileGroups on DFG_IDB_ID = IDB_ID
	cross apply (select COUNT(*) FileCount
					from Inventory.DatabaseFiles
					where DBF_MOB_ID = DFG_MOB_ID
						and DBF_IDB_ID = DFG_IDB_ID
						and DBF_DFG_ID = DFG_ID) f
where FileCount > 1
	and (select COUNT(*)
		from (select 1 a
				from Inventory.DatabaseFiles
				where DBF_MOB_ID = DFG_MOB_ID
						and DBF_IDB_ID = DFG_IDB_ID
						and DBF_DFG_ID = DFG_ID
				group by DBF_GrowthMB, DBF_GrowthPercent) t) = 1
GO
