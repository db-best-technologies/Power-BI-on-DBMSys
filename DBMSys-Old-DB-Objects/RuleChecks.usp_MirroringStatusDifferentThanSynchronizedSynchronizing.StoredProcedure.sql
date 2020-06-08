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
/****** Object:  StoredProcedure [RuleChecks].[usp_MirroringStatusDifferentThanSynchronizedSynchronizing]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_MirroringStatusDifferentThanSynchronizedSynchronizing]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

select @ClientID, @PRR_ID, MRD_MOB_ID, IDB_ID, IDB_Name, s.MOB_ID, s.MOB_Name, MSL_Name, w.MOB_ID, w.MOB_Name, MST_Name
from Inventory.MirroredDatabases
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = MRD_MOB_ID
	inner join Inventory.InstanceDatabases on IDB_ID = MRD_IDB_ID
	inner join Inventory.MonitoredObjects s on s.MOB_ID = MRD_Partner_MOB_ID
	inner join Inventory.MirroringStates on MST_ID = MRD_MST_ID
	inner join Inventory.MirroringSafetyLevels on MSL_ID = MRD_MSL_ID
	left join Inventory.MonitoredObjects w on w.MOB_ID = MRD_Witness_MOB_ID
where MST_Name not in ('Synchronizing', 'Synchronized')
GO
