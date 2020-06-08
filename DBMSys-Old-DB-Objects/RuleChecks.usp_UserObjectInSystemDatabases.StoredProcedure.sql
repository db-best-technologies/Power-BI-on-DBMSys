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
/****** Object:  StoredProcedure [RuleChecks].[usp_UserObjectInSystemDatabases]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_UserObjectInSystemDatabases]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

select @ClientID, @PRR_ID, UOS_MOB_ID, IDB_ID, IDB_Name, DOT_DisplayName, DSN_Name, DON_Name
from Inventory.UserObjectsInSystemDatabases
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = UOS_MOB_ID
	inner join Inventory.InstanceDatabases on IDB_ID = UOS_IDB_ID
	inner join Inventory.DatabaseSchemaNames on DSN_ID = UOS_DSN_ID
	inner join Inventory.DatabaseObjectTypes on DOT_ID = UOS_DOT_ID
	inner join Inventory.DatabaseObjectNames on DON_ID = UOS_DON_ID
GO
