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
/****** Object:  StoredProcedure [RuleChecks].[usp_DuplicateIndex]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_DuplicateIndex]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

select @ClientID, @PRR_ID, IDB_MOB_ID, IDB_ID, IDB_Name, DSN_Name, DON_Name, n1.DIN_Name, t1.IDT_Name, cast(SIX_IndexColumns as varchar(8000)) SIX_IndexColumns,
	cast(SIX_IncludedColumns as varchar(8000)) SIX_IncludedColumns, cast(SIX_IndexFilter as varchar(8000)) SIX_IndexFilter,
	n2.DIN_Name, t2.IDT_Name, cast(SIX_SimilarIndexColumns as varchar(8000)) SIX_SimilarIndexColumns, cast(SIX_SimilarIndexIncludedColumns as varchar(8000)) SIX_SimilarIndexIncludedColumns
from Inventory.SimilarIndexes
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = SIX_MOB_ID
	inner join Inventory.InstanceDatabases on IDB_ID = SIX_IDB_ID
	inner join Inventory.DatabaseSchemaNames on DSN_ID = SIX_DSN_ID
	inner join Inventory.DatabaseObjectNames on DON_ID = SIX_DON_ID
	inner join Inventory.DatabaseIndexNames n1 on n1.DIN_ID = SIX_DIN_ID
	inner join Inventory.IndexTypes t1 on t1.IDT_ID = SIX_IDT_ID
	inner join Inventory.DatabaseIndexNames n2 on n2.DIN_ID = SIX_Similar_DIN_ID
	inner join Inventory.IndexTypes t2 on t2.IDT_ID = SIX_Similar_IDT_ID
GO
