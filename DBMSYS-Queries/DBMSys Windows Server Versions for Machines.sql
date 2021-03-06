/****** Script for SelectTopNRows command from SSMS  ******/
USE [DBMSYS_CityofTucson_City_of_Tucson]
GO

SELECT MOB.MOB_Name AS [OriginalHostName], EDT.EDT_Name, VER.VER_Name,OSS.OSS_IsClusterNode, OSS.OSS_IsVirtualServer, OSS.OSS_IsHypervisorPresent, OSS.OSS_NumberOfProcessors, 'NA' AS Domain
FROM  Inventory.Editions AS EDT INNER JOIN
         Inventory.MonitoredObjects AS MOB ON EDT.EDT_ID = MOB.MOB_Engine_EDT_ID INNER JOIN
         Inventory.Versions AS VER ON MOB.MOB_VER_ID = VER.VER_ID LEFT OUTER JOIN
         Consolidation.RemovedFromAssessment AS RFA ON MOB.MOB_ID = RFA.RFA_MOB_ID INNER JOIN
		 Inventory.OSServers AS OSS ON MOB.MOB_OOS_ID = OSS.OSS_ID 
WHERE (RFA.RFA_MOB_ID IS NULL) AND EDT.EDT_Name like '%Windows%'