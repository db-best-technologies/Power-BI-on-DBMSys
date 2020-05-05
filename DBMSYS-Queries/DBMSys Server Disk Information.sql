USE [DBMSYS_CityofTucson_City_of_Tucson]
GO

SELECT Consolidation.ParticipatingDatabaseServers.PDS_Database_MOB_ID AS MOB_ID_MonitoredObjects, Inventory.MonitoredObjects.MOB_Name AS [Server Name], Consolidation.ParticipatingDatabaseServers.PDS_Server_MOB_ID AS MOB_ID_DB_Details, Inventory.Disks.DSK_ID, Inventory.FileSystems.FST_Name, Inventory.Disks.DSK_Letter, Inventory.Disks.DSK_Path, 
         Inventory.Disks.DSK_IsClusteredResource, Inventory.Disks.DSK_TotalSpaceMB / 1024.0 AS [Total Disk Space Used (GB)], Inventory.Disks.DSK_BlockSize, Inventory.Disks.DSK_IsCompressed
FROM  Inventory.MonitoredObjects INNER JOIN
         Consolidation.ParticipatingDatabaseServers ON Inventory.MonitoredObjects.MOB_Entity_ID = Consolidation.ParticipatingDatabaseServers.PDS_Database_MOB_ID LEFT OUTER JOIN
         Inventory.Disks INNER JOIN
         Inventory.FileSystems ON Inventory.Disks.DSK_FST_ID = Inventory.FileSystems.FST_ID ON Consolidation.ParticipatingDatabaseServers.PDS_Server_MOB_ID = Inventory.Disks.DSK_MOB_ID
ORDER BY MOB_ID_MonitoredObjects, Inventory.Disks.DSK_Path