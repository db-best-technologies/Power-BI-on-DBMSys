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
/****** Object:  StoredProcedure [Analysis].[usp_CheckLogBackupDelays]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Analysis].[usp_CheckLogBackupDelays]
	@EventDescription nvarchar(1000)
as
set nocount on
declare @AllowedDelay int
select @AllowedDelay = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Analysis Events'
	and SET_Key = 'Minutes Since Last Log Backup For Event'

select IDB_MOB_ID MOB_ID, IDB_Name InstanceName,
	isnull('The last log backup of the ' + quotename(IDB_Name) + ' database happened at ' + CONVERT(char(19), IDB_LastLogBackupDate, 121)
	+ ', which is ' + cast(datediff(minute, IDB_LastLogBackupDate, sysdatetime()) as varchar(10)) + ' minutes ago',
	'The is no record of a log backup for the ' + quotename(IDB_Name) + ' database ever occurring.')
	+ case when LSI_ID is null then '' else ' The database is a part of a log shipping setup.' end
	+ case when MRD_ID is null then '' else ' The database is a part of a mirroring setup.' end AlertMessage,
	(select @EventDescription [@EventDescription], MOB_ID [@MOB_ID], MOB_Name [@MOB_Name], IDB_Name [@DatabaseName],
			IDB_LastLogBackupDate [@LastLogBackupDate], datediff(minute, IDB_LastLogBackupDate, sysdatetime()) [@MinutesSinceLastLogBackup]
		for xml path('Alert'), root('Alerts'), type) AlertEventData
from Inventory.InstanceDatabases
	inner join Inventory.RecoveryModels on RCM_ID = IDB_RCM_ID
	inner join Inventory.InstanceDatabaseStates on IDS_ID = IDB_IDS_ID
	inner join Inventory.MonitoredObjects on MOB_ID = IDB_MOB_ID
	outer apply (select top 1 LSI_ID
					from Inventory.LogShippingInstances
					where (LSI_Primary_MOB_ID = MOB_ID
							and LSI_Primary_IDB_ID = IDB_ID)
						or (LSI_Secondary_MOB_ID = MOB_ID
							and LSI_Secondary_IDB_ID = IDB_ID)
				) l
	outer apply (select top 1 MRD_ID
					from Inventory.MirroredDatabases
					where MRD_MOB_ID = MOB_ID
							and MRD_IDB_ID = IDB_ID
				) m
where RCM_Name <> 'SIMPLE'
	and IDS_Name = 'ONLINE'
	and IDB_Name not in ('model')
	and (IDB_LastLogBackupDate < DATEADD(minute, -@AllowedDelay, getdate()) or IDB_LastLogBackupDate is null)
	and MOB_OOS_ID = 1
	and not exists (select AGD_IDB_ID, AGR_MOB_ID
				from Inventory.AvailabilityGroupReplicas
					inner join Inventory.AvailabilityGroupReplicatedDatabases on AGD_GroupID = AGR_GroupID
																				and AGD_MOB_ID = AGR_MOB_ID
				where AGR_AGO_ID <> AGR_AGB_ID
					and AGD_IDB_ID = IDB_ID
				)
GO
