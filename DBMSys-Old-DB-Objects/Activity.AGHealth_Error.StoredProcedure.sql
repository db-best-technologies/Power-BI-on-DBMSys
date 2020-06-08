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
/****** Object:  StoredProcedure [Activity].[AGHealth_Error]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Activity].[AGHealth_Error] 
--DECLARE
	@EventDescription nvarchar(1000)
as
set nocount on

select	h_all.AGH_MOB_ID F_MOB_ID
		,MOB_Name + '\' + h_all.AGH_ReplicaName + '\' + h_all.AGH_DatabaseName F_InstanceName
		,'Replica ' + h_all.AGH_ReplicaName + '\' + h_all.AGH_DatabaseName + ' is not healthy. '
		+ ISNULL(CHAR(10) + 'Replica name'					+': ' + /*h_all.AGH_ReplicaName	*/m.MOB_Name						,'')
		+ ISNULL(CHAR(10) + 'Database name'					+': ' + h_all.AGH_DatabaseName										,'')
		+ ISNULL(CHAR(10) + 'Replica role'					+': ' + h_all.AGH_ReplicaRoleDesc									,'')
		+ ISNULL(CHAR(10) + 'Synchronization state'			+': ' + h_all.AGH_SyncStateDesc										,'')
		+ ISNULL(CHAR(10) + 'Last hardened LSN delay '		+': ' + CONVERT(NVARCHAR(20),h_all.AGH_LastHardenedLSN,108)			,'')
		+ ISNULL(CHAR(10) + 'Last hardened LSN'				+': ' + CONVERT(NVARCHAR(20),h_all.AGH_LastHardenedTime,121)		,'')	
		+ ISNULL(CHAR(10) + 'Last log record was redone'	+': ' + CONVERT(NVARCHAR(20),h_all.AGH_LastRedoneTime,121)			,'')
		+ ISNULL(CHAR(10) + 'Log send queue size'			+': ' + CAST(h_all.AGH_LogSendQueueSize	AS NVARCHAR(50))			+'(KB)','')
		+ ISNULL(CHAR(10) + 'Log send rate'					+': ' + CAST(h_all.AGH_LogSendRate	AS NVARCHAR(50))				+'(KB/second)','')
		+ ISNULL(CHAR(10) + 'Redo queue size'				+': ' + CAST(h_all.AGH_RedoQueueSize	AS NVARCHAR(50))			+'(KB)','')
		+ ISNULL(CHAR(10) + 'Redo rate'						+': ' + CAST(h_all.AGH_RedoRate	AS NVARCHAR(50))					+'(KB/second)','')
		+ ISNULL(CHAR(10) + 'Filestream send rate'			+': ' + CAST(h_all.AGH_FilestreamSendRate	AS NVARCHAR(50))		+'(KB/second)','')
		+ ISNULL(CHAR(10) + 'Last seen date'				+': ' + CONVERT(NVARCHAR(20),h_all.AGH_LastSeenDate,121)			,'')	
		+ ISNULL(CHAR(10) + 'Primary replica name'			+': ' + relp_par.AGH_ReplicaName									,'')

		AS AlertMessage
		,(
			select	@EventDescription					[@EventDescription]
					,MOB_ID								[@MOB_ID]
					,MOB_Name							[@MOB_Name]
					,h_all.AGH_ReplicaName				[@ReplicaName]
					,h_all.AGH_DatabaseName				[@DatabaseName]
					,h_all.AGH_ReplicaRoleDesc			[@ReplicaRoleDesc]
					,h_all.AGH_SyncStateDesc			[@SyncStateDesc]
					,h_all.AGH_LastHardenedLSN			[@LastHardenedLSN]
					,h_all.AGH_LastHardenedTime			[@LastHardenedTime]	
					,h_all.AGH_LastRedoneTime			[@LastRedoneTime]
					,h_all.AGH_LogSendQueueSize			[@LogSendQueueSize]	
					,h_all.AGH_LogSendRate				[@LogSendRate]	
					,h_all.AGH_RedoQueueSize			[@RedoQueueSize]	
					,h_all.AGH_RedoRate					[@RedoRate]	
					,h_all.AGH_FilestreamSendRate		[@FilestreamSendRate]	
					,h_all.AGH_LastSeenDate				[@LastSeenDate]

					,relp_par.AGH_ReplicaName			[@Parent_ReplicaName]
					,relp_par.AGH_DatabaseName			[@Parent_DatabaseName]
					,relp_par.AGH_ReplicaRoleDesc		[@Parent_ReplicaRoleDesc]
					,relp_par.AGH_SyncStateDesc			[@Parent_SyncStateDesc]
					,relp_par.AGH_LastHardenedLSN		[@Parent_LastHardenedLSN]
					,relp_par.AGH_LastHardenedTime		[@Parent_LastHardenedTime]	
					,relp_par.AGH_LastRedoneTime		[@Parent_LastRedoneTime]
					,relp_par.AGH_LogSendQueueSize		[@Parent_LogSendQueueSize]	
					,relp_par.AGH_LogSendRate			[@Parent_LogSendRate]	
					,relp_par.AGH_RedoQueueSize			[@Parent_RedoQueueSize]	
					,relp_par.AGH_RedoRate				[@Parent_RedoRate]	
					,relp_par.AGH_FilestreamSendRate	[@Parent_FilestreamSendRate]
					,relp_par.AGH_LastSeenDate			[@Parent_LastSeenDate]

					
					for xml path('Alert'), root('Alerts'), type
		) AlertEventData

FROM	Inventory.AvailabilityGroupHealth h_all
join	Inventory.MonitoredObjects m on h_all.AGH_MOB_ID = m.MOB_ID
CROSS APPLY (
				SELECT	h_par.AGH_ID
						,m2.MOB_Name AS AGH_ReplicaName
						,h_par.AGH_DatabaseName			
						,h_par.AGH_ReplicaRoleDesc		
						,h_par.AGH_SyncStateDesc		
						,h_par.AGH_LastHardenedLSN		
						,h_par.AGH_LastHardenedTime		
						,h_par.AGH_LastRedoneTime		
						,h_par.AGH_LogSendQueueSize		
						,h_par.AGH_LogSendRate			
						,h_par.AGH_RedoQueueSize		
						,h_par.AGH_RedoRate				
						,h_par.AGH_FilestreamSendRate	
						,h_par.AGH_LastSeenDate			
				FROM	Inventory.AvailabilityGroupHealth h_par
				JOIN	Inventory.MonitoredObjects m2 on h_par.AGH_MOB_ID = m2.MOB_ID
				WHERE	h_par.AGH_GroupID				= h_all.AGH_GroupID	
						AND h_par.AGH_GroupDBID			= h_all.AGH_GroupDBID
						AND h_all.AGH_ReplicaRoleDesc	= 'SECONDARY' 
						AND h_par.AGH_ReplicaRoleDesc	= 'PRIMARY' 

			)relp_par
where	MOB_OOS_ID = 1 
		AND	h_all.AGH_SyncHealthDesc = 'NOT_HEALTHY'
		AND AGH_IsDeleted = 0
GO
