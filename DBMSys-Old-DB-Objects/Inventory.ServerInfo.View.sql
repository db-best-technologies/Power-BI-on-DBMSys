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
/****** Object:  View [Inventory].[ServerInfo]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Inventory].[ServerInfo] 
AS
SELECT Inventory.MonitoredObjects.MOB_ID, Consolidation.ParticipatingDatabaseServers.PDS_Server_MOB_ID, LEFT(Inventory.Editions.EDT_Name, CHARINDEX(' ', REPLACE(Inventory.Editions.EDT_Name, ':', ' ') + ' ', CHARINDEX('Edition', Inventory.Editions.EDT_Name, 1)) - 1) AS [Server Edition], 
         Inventory.DatabaseInstanceDetails.DID_Name AS [Server\Instance], ISNULL(Inventory.DatabaseInstanceDetails.DID_InstanceName, 'Default') AS [Instance Name], Inventory.DatabaseInstanceDetails.DID_Architecture AS [Database Architecture], Inventory.MonitoredObjects.MOB_Name AS [Full Server Name], Inventory.Versions.VER_Name AS [SQL Version], 
         Inventory.Versions.VER_Full AS [SQL Build], Inventory.ProductLevels.PRL_Name AS [Product Level], Consolidation.ConsolidationGroups.CGR_Name, Inventory.DatabaseInstanceDetails.DID_NumberOfAvailableSchedulers AS [Available Schedulers], Inventory.OSServers.OSS_IsVirtualServer AS [Is Virtualized], Inventory.OSServers.OSS_Architecture AS [OS Architecture], 
         Inventory.OSServers.OSS_TotalPhysicalMemoryMB / 1024 AS [Total Physical Memory GB], Inventory.OSServers.OSS_NumberOfLogicalProcessors AS [Logical Cores Available], Inventory.OSServers.OSS_NumberOfProcessors AS [Number of CPUs], Inventory.MachineManufacturers.MMN_Name AS [Server Manufacturer], 
         Inventory.MachineManufacturerModels.MMD_Name AS [Server Model], Inventory.OSServers.OSS_TotalPhysicalMemoryMB, Inventory.OSServers.OSS_MaxProcessMemorySizeMB, Inventory.OSServers.OSS_IsHypervisorPresent, Inventory.OSServers.OSS_MOB_ID, Consolidation.CPUFactoring.CPF_CPUName, Consolidation.CPUFactoring.CPF_CPUFactor, 
         Consolidation.CPUFactoring.CPF_SingleCPUScore, Consolidation.CPUFactoring.CPF_CPUCount, Consolidation.CPUFactoring.CPF_IsVM, Consolidation.CPUFactoring.CPF_IsUsableCoreCountApplied
FROM  Inventory.MonitoredObjects INNER JOIN
         Inventory.DatabaseInstanceDetails ON Inventory.DatabaseInstanceDetails.DID_DFO_ID = Inventory.MonitoredObjects.MOB_Entity_ID INNER JOIN
         Inventory.Editions ON Inventory.Editions.EDT_ID = Inventory.DatabaseInstanceDetails.DID_EDT_ID INNER JOIN
         Inventory.Versions ON Inventory.MonitoredObjects.MOB_VER_ID = Inventory.Versions.VER_ID INNER JOIN
         Inventory.OSServers ON Inventory.MonitoredObjects.MOB_OOS_ID = Inventory.OSServers.OSS_ID INNER JOIN
         Inventory.OSProductTypes ON Inventory.OSServers.OSS_OPT_ID = Inventory.OSProductTypes.OPT_ID INNER JOIN
         Inventory.MachineManufacturers ON Inventory.OSServers.OSS_MMN_ID = Inventory.MachineManufacturers.MMN_ID INNER JOIN
         Inventory.MachineManufacturerModels ON Inventory.OSServers.OSS_MMD_ID = Inventory.MachineManufacturerModels.MMD_ID INNER JOIN
         Inventory.ProductLevels ON Inventory.DatabaseInstanceDetails.DID_PRL_ID = Inventory.ProductLevels.PRL_ID INNER JOIN
         Consolidation.ParticipatingDatabaseServers ON Inventory.MonitoredObjects.MOB_ID = Consolidation.ParticipatingDatabaseServers.PDS_Database_MOB_ID INNER JOIN
         Consolidation.ServerGrouping ON Consolidation.ParticipatingDatabaseServers.PDS_Server_MOB_ID = Consolidation.ServerGrouping.SGR_MOB_ID INNER JOIN
         Consolidation.ConsolidationGroups ON Consolidation.ServerGrouping.SGR_CGR_ID = Consolidation.ConsolidationGroups.CGR_ID INNER JOIN
         Consolidation.CPUFactoring ON Consolidation.ParticipatingDatabaseServers.PDS_Server_MOB_ID = Consolidation.CPUFactoring.CPF_MOB_ID
WHERE EXISTS
             (SELECT PLT_ID, PLT_PLC_ID, PLT_Name, PLT_MetaData
            FROM  Management.PlatformTypes
            WHERE (PLT_ID = Inventory.MonitoredObjects.MOB_PLT_ID) AND (PLT_PLC_ID = 1))
--ORDER BY [Logical Cores Available] DESC, [Full Server Name]

GO
