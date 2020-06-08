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
/****** Object:  StoredProcedure [RuleChecks].[usp_ReplicationError]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_ReplicationError]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

select @ClientID, @PRR_ID, RPE_MOB_ID, IDB_ID, IDB_Name, TRP_ID, TRP_Name, TRB_Subscriber_MOB_ID, TRB_SubscriberServerName, TRB_Subscriber_IDB_ID,
	TRB_SubscriberDatabaseName, RAT_Name, cast(RPE_ErrorMessage as varchar(8000)), COUNT(*), min(RPE_FirstFailureDate), max(RPE_LastFailureDate)
from Activity.ReplicationErrors
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = RPE_MOB_ID
	inner join Inventory.TransactionalReplicationPublications on TRP_ID = RPE_TRP_ID
	inner join Inventory.InstanceDatabases on IDB_ID = TRP_IDB_ID
	left join Inventory.TransactionalReplicationSubscriptions on TRB_ID = RPE_TRB_ID
	inner join Inventory.ReplicationAgentTypes on RAT_ID = RPE_RAT_ID
where RPE_LastFailureDate between @FromDate and @ToDate
group by RPE_MOB_ID, IDB_ID, IDB_Name, TRP_ID, TRP_Name, TRB_Subscriber_MOB_ID, TRB_SubscriberServerName, TRB_Subscriber_IDB_ID,
	TRB_SubscriberDatabaseName, RAT_Name, cast(RPE_ErrorMessage as varchar(8000))
GO
