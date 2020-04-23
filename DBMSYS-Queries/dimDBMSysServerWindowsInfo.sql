/****** Script for SelectTopNRows command from SSMS  ******/
USE [DBMSYS_InternationalPaper_International_Paper]
GO

SELECT TOP (1000) MOB.MOB_ID, PLT.PLT_Name, OSS.OSS_Name, OSS.OSS_IsClusterNode, OSS.OSS_IsVirtualServer, OSS.OSS_IsHypervisorPresent, OSS.OSS_NumberOfLogicalProcessors, OSS.OSS_NumberOfProcessors, VER.VER_Name, VER.VER_PLT_ID
FROM  Inventory.MonitoredObjects AS MOB INNER JOIN
         Management.PlatformTypes AS PLT ON MOB.MOB_PLT_ID = PLT.PLT_ID INNER JOIN
         Inventory.OSServers AS OSS ON MOB.MOB_OOS_ID = OSS.OSS_ID INNER JOIN
         Inventory.Versions AS VER ON MOB.MOB_VER_ID = VER.VER_ID
WHERE (PLT.PLT_Name = 'Microsoft Windows')