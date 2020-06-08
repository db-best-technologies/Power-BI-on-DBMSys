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
/****** Object:  StoredProcedure [RuleChecks].[usp_DatabaseWithACollationDifferenceFromTheMasterOrTempdbDatabases]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_DatabaseWithACollationDifferenceFromTheMasterOrTempdbDatabases]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

select @ClientID, @PRR_ID, ud.IDB_MOB_ID, ud.IDB_ID, ud.IDB_Name, CLT_Name
from Inventory.InstanceDatabases ud
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = ud.IDB_MOB_ID
	inner join Inventory.InstanceDatabases m on ud.IDB_MOB_ID = m.IDB_MOB_ID
													and m.IDB_Name = 'master'
													and ud.IDB_CLT_ID <> m.IDB_CLT_ID
	inner join Inventory.InstanceDatabases t on ud.IDB_MOB_ID = t.IDB_MOB_ID
													and ud.IDB_CLT_ID <> t.IDB_CLT_ID
													and t.IDB_Name = 'tempdb'
	inner join Inventory.CollationTypes on ud.IDB_CLT_ID = CLT_ID
where ud.IDB_Name not in ('master', 'tempdb')
GO
