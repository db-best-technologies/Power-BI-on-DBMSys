USE [DBMSYS_CityofTucson_City_of_Tucson]
GO
SELECT TOP (20000) Inventory.ApplicationConnections.ACN_ClientID, Activity.ProgramNames.PGN_Name AS [Application Name], Inventory.MonitoredObjects.MOB_ID, Inventory.MonitoredObjects.MOB_Name AS [Server Name], Inventory.ApplicationConnections.ACN_IDB_ID, Inventory.InstanceDatabases.IDB_ID, Inventory.InstanceDatabases.IDB_Name AS [Database Name]
FROM  Inventory.ApplicationConnections INNER JOIN
         Inventory.MonitoredObjects ON Inventory.ApplicationConnections.ACN_MOB_ID = Inventory.MonitoredObjects.MOB_ID INNER JOIN
         Consolidation.ParticipatingDatabaseServers ON Inventory.MonitoredObjects.MOB_ID = Consolidation.ParticipatingDatabaseServers.PDS_Database_MOB_ID INNER JOIN
         Activity.ProgramNames ON Inventory.ApplicationConnections.ACN_PGN_ID = Activity.ProgramNames.PGN_ID INNER JOIN
         Inventory.InstanceDatabases ON Inventory.ApplicationConnections.ACN_IDB_ID = Inventory.InstanceDatabases.IDB_ID
WHERE (Activity.ProgramNames.PGN_Name <> '' AND Activity.ProgramNames.PGN_Name NOT LIKE ('%.Net SqlClient Data Provider'))
ORDER BY [Application Name], [Database Name], [Server Name]