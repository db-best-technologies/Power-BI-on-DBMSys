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
/****** Object:  StoredProcedure [RuleChecks].[usp_AvailabilityGroupDatabaseSynchronizationHealthStatusNotOnline]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_AvailabilityGroupDatabaseSynchronizationHealthStatusNotOnline]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

select @ClientID, @PRR_ID, AGR_MOB_ID, AGR_GroupID, AGR_Name, IDB_ID, IDB_Name, ASH_Name
from Inventory.AvailabilityGroupReplicatedDatabases
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = AGD_MOB_ID
	inner join Inventory.AvailabilityGroupReplicas on AGR_GroupID = AGD_GroupID
														and AGR_MOB_ID = AGD_MOB_ID
	inner join Inventory.InstanceDatabases on IDB_ID = AGD_IDB_ID
	inner join inventory.AvailabilityGroupSynchronizationHealthStatuses on ASH_ID = AGD_ASH_ID
where ASH_Name <> 'ONLINE'
GO
