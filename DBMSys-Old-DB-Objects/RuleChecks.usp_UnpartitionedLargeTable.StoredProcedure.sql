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
/****** Object:  StoredProcedure [RuleChecks].[usp_UnpartitionedLargeTable]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_UnpartitionedLargeTable]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

select @ClientID, @PRR_ID, TDT_MOB_ID, IDB_ID, IDB_Name, LEFT(TDT_TableName, CHARINDEX('.', TDT_TableName, 1) - 1) SchemaName,
	SUBSTRING(TDT_TableName, CHARINDEX('.', TDT_TableName, 1) + 1, 1000) TableName, TDT_NumberOfRows
from Inventory.TopDatabaseTables
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = TDT_MOB_ID
	inner join Inventory.InstanceDatabases on IDB_ID = TDT_IDB_ID
where TDT_NumberOfPartitions = 1
	and TDT_NumberOfRows > 50000000
GO
