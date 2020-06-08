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
/****** Object:  StoredProcedure [RuleChecks].[usp_TableWithTooManyIndexesIndexCountLargerThanColumnCount]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_TableWithTooManyIndexesIndexCountLargerThanColumnCount]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

select @ClientID, @PRR_ID, PTP_MOB_ID, IDB_ID, IDB_Name, DSN_Name, DON_Name, PTP_ColumnCount, PTP_IndexCount
from Inventory.PossibleTableProblems
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = PTP_MOB_ID
	inner join Inventory.InstanceDatabases on IDB_ID = PTP_IDB_ID
	inner join Inventory.DatabaseSchemaNames on DSN_ID = PTP_DSN_ID
	inner join Inventory.DatabaseObjectNames on DON_ID = PTP_DON_ID
where PTP_IndexCount > PTP_ColumnCount
GO
