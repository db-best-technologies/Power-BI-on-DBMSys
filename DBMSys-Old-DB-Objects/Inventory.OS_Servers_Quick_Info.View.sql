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
/****** Object:  View [Inventory].[OS_Servers_Quick_Info]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Inventory].[OS_Servers_Quick_Info] AS
SELECT        Inventory.OSServers.OSS_Name, Inventory.OSServers.OSS_PLT_ID, Inventory.OSServers.OSS_IsVirtualServer AS [Is Virtualized], 
                         Inventory.OSServers.OSS_NumberOfLogicalProcessors AS [# Logical Procs], Inventory.OSServers.OSS_NumberOfProcessors AS [# Procs], 
                         Inventory.OSServers.OSS_TotalPhysicalMemoryMB / 1024 AS [Total Physical Memory GB], Inventory.OSServers.OSS_Architecture AS [OS Architecture], Inventory.MachineManufacturers.MMN_Name AS [Server Manufacturer], 
                         Inventory.OSServers.OSS_TotalPhysicalMemoryMB / 1024 AS [Total Physical Memory (GB], Inventory.OSServers.OSS_MaxProcessMemorySizeMB, Inventory.OSServers.OSS_IsHypervisorPresent, 
                         Inventory.OSServers.OSS_MOB_ID, Inventory.OSServers.OSS_InstallDate, Inventory.OSServers.OSS_LastBootUpTime, Inventory.OSServers.OSS_IsAutomaticManagedPageFile, 
                         Inventory.OSServers.OSS_HugePageSizeMB / 1024 AS [Huge Page Size (GB)], Inventory.OSProductTypes.OPT_Name, Inventory.OSServers.OSS_IsClusterNode AS [Is Cluster Node]
FROM            Inventory.OSProductTypes INNER JOIN
                         Inventory.OSServers ON Inventory.OSProductTypes.OPT_ID = Inventory.OSServers.OSS_OPT_ID INNER JOIN
                         Inventory.MachineManufacturers ON Inventory.OSServers.OSS_MMN_ID = Inventory.MachineManufacturers.MMN_ID
GO
