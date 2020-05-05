USE [DBMSYS_CityofTucson_City_of_Tucson]
GO

SELECT        Inventory.MonitoredObjects.MOB_ID, Consolidation.ParticipatingDatabaseServers.PDS_Server_MOB_ID AS MOB_ID_DBDetails, Inventory.InstanceDatabases.IDB_ID, 
                         Inventory.MonitoredObjects.MOB_Name AS [Full Server Name], Inventory.DatabaseInstanceDetails.DID_Name AS [Server Instance Name], Inventory.InstanceDatabases.IDB_Name AS [Database Name], 
                         Inventory.InstanceDatabases.IDB_CompatibilityLevel, Consolidation.SingleDatabaseSizes.SDZ_SizeMB / 1024.0 AS [Database Size GB], 
                         Consolidation.SingleDatabaseSizes.SDZ_EstimatedYearlyGrowthMB AS [Estimated Yearly Growth MB], Consolidation.SingleDatabaseTransactions.SDT_TransactionsSec AS [Transactions Per Sec], 
                         Inventory.InstanceDatabases.IDB_AvgLogBackupInterval, Inventory.InstanceDatabases.IDB_AvgFullBackupInterval, Inventory.InstanceDatabases.IDB_LastFullBackupDate, 
                         Inventory.InstanceDatabases.IDB_LastLogBackupDate, Consolidation.SingleDatabaseTransactions.SDT_PercentOfServerActivity
FROM            Inventory.InstanceDatabases INNER JOIN
                         Consolidation.ParticipatingDatabaseServers INNER JOIN
                         Inventory.DatabaseInstanceDetails INNER JOIN
                         Inventory.MonitoredObjects ON Inventory.DatabaseInstanceDetails.DID_DFO_ID = Inventory.MonitoredObjects.MOB_Entity_ID ON 
                         Consolidation.ParticipatingDatabaseServers.PDS_Database_MOB_ID = Inventory.MonitoredObjects.MOB_ID ON Inventory.InstanceDatabases.IDB_MOB_ID = Inventory.MonitoredObjects.MOB_ID LEFT OUTER JOIN
                         Consolidation.SingleDatabaseSizes ON Inventory.InstanceDatabases.IDB_ID = Consolidation.SingleDatabaseSizes.SDZ_IDB_ID LEFT OUTER JOIN
                         Consolidation.SingleDatabaseTransactions ON Inventory.InstanceDatabases.IDB_ID = Consolidation.SingleDatabaseTransactions.SDT_IDB_ID
ORDER BY Inventory.MonitoredObjects.MOB_ID, Inventory.InstanceDatabases.IDB_ID
