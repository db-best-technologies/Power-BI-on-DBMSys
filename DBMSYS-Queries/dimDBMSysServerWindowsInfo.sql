/****** Script for SelectTopNRows command from SSMS  ******/
USE [DBMSYS_CityofTucson_City_of_Tucson]
GO

SELECT TOP (1000) MOB.MOB_ID, 
				  PLT.PLT_Name, 
				  OSS.OSS_Name, 
				  OSS.OSS_IsClusterNode, 
				  OSS.OSS_IsVirtualServer, 
				  OSS.OSS_IsHypervisorPresent, 
				  OSS.OSS_NumberOfLogicalProcessors, 
				  OSS.OSS_NumberOfProcessors, 
				  VER.VER_Name, 
				  VER.VER_PLT_ID 
FROM    --Inventory.DatabaseInstanceDetails 
		--INNER JOIN 
		Inventory.OSServers AS OSS 
			--ON Inventory.DatabaseInstanceDetails.DID_OSS_ID = OSS.OSS_ID 
		INNER JOIN Inventory.MonitoredObjects AS MOB 
			ON OSS.OSS_ID = MOB.MOB_OOS_ID 
		INNER JOIN  Management.PlatformTypes AS PLT 
			ON MOB.MOB_PLT_ID = PLT.PLT_ID 
		INNER JOIN Inventory.Versions AS VER 
			ON MOB.MOB_VER_ID = VER.VER_ID 
WHERE (PLT.PLT_Name = 'Microsoft Windows')
