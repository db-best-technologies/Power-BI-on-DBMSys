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
/****** Object:  StoredProcedure [RuleChecks].[usp_FragmentedIndex]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_FragmentedIndex]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

select @ClientID, @PRR_ID, IDB_MOB_ID, IDB_ID, IDB_Name, DOT_DisplayName, DSN_Name, DON_Name, DIN_Name, IDT_Name, FRI_SizeMB, FRI_AvgPageSpaceUsedInPercent, FRI_AvgFragmentationInPercent,
	FRI_FillFactor
from Inventory.FragmentedIndexes
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = FRI_MOB_ID
	inner join Inventory.InstanceDatabases on IDB_ID = FRI_IDB_ID
	inner join Inventory.DatabaseObjectTypes on DOT_ID = FRI_DOT_ID
	inner join Inventory.DatabaseSchemaNames on DSN_ID = FRI_DSN_ID
	inner join Inventory.DatabaseObjectNames on DON_ID = FRI_DON_ID
	inner join Inventory.DatabaseIndexNames on DIN_ID = FRI_DIN_ID
	inner join Inventory.IndexTypes on IDT_ID = FRI_IDT_ID
GO
