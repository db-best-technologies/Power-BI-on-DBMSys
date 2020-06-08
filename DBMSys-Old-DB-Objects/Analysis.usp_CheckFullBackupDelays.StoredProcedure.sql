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
/****** Object:  StoredProcedure [Analysis].[usp_CheckFullBackupDelays]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Analysis].[usp_CheckFullBackupDelays]
     @EventDescription nvarchar(1000)
as

set nocount on
declare @AllowedDelay int
select @AllowedDelay = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Analysis Events'
       and SET_Key = 'Minutes Since Last Full Backup For Event'

;with BackupOnSecondNodes as (
select 
 AGD0.AGD_MOB_ID             as AGD_MOB_ID_Current
,IDB0.IDB_ID                 as IDB_ID_Current
,IDB1.IDB_LastFullBackupDate as IDB_LastFullBackupDate_New
from [Inventory].[AvailabilityGroupReplicatedDatabases] AGD0
inner join Inventory.InstanceDatabases IDB0 on AGD0.AGD_IDB_ID = IDB0.IDB_ID
inner join [Inventory].[AvailabilityGroupReplicatedDatabases] AGD1 on AGD0.AGD_GroupID = AGD1.AGD_GroupID and AGD0.AGD_ReplicaID <> AGD1.AGD_ReplicaID
inner join Inventory.InstanceDatabases IDB1 on AGD1.AGD_IDB_ID = IDB1.IDB_ID and IDB0.IDB_Name = IDB1.IDB_Name
WHERE	IDB0.IDB_IsDeleted = 0
		AND IDB1.IDB_IsDeleted = 0
)

select IDB_MOB_ID MOB_ID, IDB_Name InstanceName,
       isnull('The last full backup of the ' + quotename(IDB_Name) + ' database happened at ' + CONVERT(char(19), IDB_LastFullBackupDate, 121)
       + ', which is ' + cast(datediff(minute, IDB_LastFullBackupDate, sysdatetime()) as varchar(10)) + ' minutes ago',
       'There is no record of a full backup for the ' + quotename(IDB_Name) + ' database ever occurring') AlertMessage,
       (select @EventDescription [@EventDescription], MOB_ID [@MOB_ID], MOB_Name [@MOB_Name], IDB_Name [@DatabaseName],
                     IDB_LastFullBackupDate [@LastFullBackupDate], datediff(minute, IDB_LastFullBackupDate, sysdatetime()) [@MinutesSinceLastFullBackup]
              for xml path('Alert'), root('Alerts'), type) AlertEventData
       
from Inventory.InstanceDatabases 
       inner join Inventory.RecoveryModels on RCM_ID = IDB_RCM_ID
       inner join Inventory.InstanceDatabaseStates on IDS_ID = IDB_IDS_ID
       inner join Inventory.MonitoredObjects  on MOB_ID = IDB_MOB_ID
       outer apply (select top 1 * from BackupOnSecondNodes where AGD_MOB_ID_Current = IDB_MOB_ID and IDB_ID_Current = IDB_ID  order by IDB_LastFullBackupDate_New desc) t
where IDS_Name = 'ONLINE' --and IDB_Name ='SocialDB'
       and IDB_Name not in ('tempdb', 'ReportServerTempDB')
       and (IDB_LastFullBackupDate < DATEADD(minute, -@AllowedDelay, getdate()) or IDB_LastFullBackupDate is null)
       and (IDB_LastFullBackupDate_new < DATEADD(minute, -@AllowedDelay, getdate()) or IDB_LastFullBackupDate_new is null)
       and MOB_OOS_ID = 1
	   AND IDB_IsDeleted = 0
	   AND IDB_Source_IDB_ID is null
       and not exists (select AGD_IDB_ID, AGR_MOB_ID
                                  from Inventory.AvailabilityGroupReplicas
                                         inner join Inventory.AvailabilityGroupReplicatedDatabases on AGD_GroupID = AGR_GroupID
                                                                                                                                                and AGD_MOB_ID = AGR_MOB_ID
                                  where AGR_AGO_ID <> AGR_AGB_ID
                                         and AGD_IDB_ID = IDB_ID
                                  )
GO
