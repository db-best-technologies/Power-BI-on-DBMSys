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
/****** Object:  StoredProcedure [Analysis].[usp_DatabaseIsUnavailable]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Analysis].[usp_DatabaseIsUnavailable]
	@EventDescription nvarchar(1000)
as
set nocount on

select IDB_MOB_ID MOB_ID, IDB_Name InstanceName,
	'The state of the ' + IDB_Name + ' database is ' + IDS_Name AlertMessage,
	(select @EventDescription [@EventDescription], MOB_ID [@MOB_ID], MOB_Name [@MOB_Name], IDB_Name [@DatabaseName],
			IDS_Name [@DatabaseState]
		for xml path('Alert'), root('Alerts'), type) AlertEventData
from Inventory.InstanceDatabases
	inner join Inventory.InstanceDatabaseStates on IDS_ID = IDB_IDS_ID
	inner join Inventory.MonitoredObjects on MOB_ID = IDB_MOB_ID
where not exists (select *
					from Inventory.AvailabilityGroupReplicas
						inner join Inventory.AvailabilityGroupReplicatedDatabases on AGD_GroupID = AGR_GroupID
																					and AGD_MOB_ID = AGR_MOB_ID
					where AGR_AGO_ID <> 2
						and AGD_IDB_ID = IDB_ID
					)
	and IDS_Name not in ('ONLINE', 'RESTORING', 'OFFLINE')
	AND MOB_OOS_ID IN (0,1)
GO
