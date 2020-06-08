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
/****** Object:  StoredProcedure [RuleChecks].[usp_ExistingOldDatabaseSnapshot]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_ExistingOldDatabaseSnapshot]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted
declare @LastDate datetime
set @LastDate = RuleChecks.fn_GetLastDate()

select @ClientID, @PRR_ID, s.IDB_MOB_ID, s.IDB_ID, s.IDB_Name, d.IDB_ID, d.IDB_Name, s.IDB_CreateDate
from Inventory.InstanceDatabases s
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = s.IDB_MOB_ID
	inner join Inventory.InstanceDatabases d on s.IDB_Source_IDB_ID = d.IDB_ID
where s.IDB_Source_IDB_ID is not null
	and s.IDB_CreateDate < DATEADD(day, -7, @LastDate)
GO
