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
/****** Object:  StoredProcedure [RuleChecks].[usp_UnrecommendedNumberOfTempdbDataFiles]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_UnrecommendedNumberOfTempdbDataFiles]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

;with CoreCount as
	(select MOB_ID, sum(Cores) Cores
		from Inventory.MonitoredObjects
			inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
			inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
																and PRM_MOB_ID = MOB_ID
			inner join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
			cross apply RuleChecks.fn_GetNumberOfCores(MOB_ID)
		where PLT_PLC_ID = 1
		group by MOB_ID
	)
	, FileCount as
	(select IDB_MOB_ID, COUNT(*) Files
		from Inventory.InstanceDatabases
			inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
			inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
																and PRM_MOB_ID = IDB_MOB_ID			
			inner join Inventory.DatabaseFiles on DBF_MOB_ID = IDB_MOB_ID
													and DBF_IDB_ID = IDB_ID
		where IDB_Name <> 'tempdb'
			and DBF_DFT_ID = 0
		group by IDB_MOB_ID
	)
select @ClientID, @PRR_ID, MOB_ID, Cores, Files
from CoreCount
	inner join FileCount on MOB_ID = IDB_MOB_ID
where (Cores <= 8
		and Files < Cores)
	or (Cores > 8
		and Files < 8)
	or Files > 8
GO
