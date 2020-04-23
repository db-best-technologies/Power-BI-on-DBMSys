/****** Script for SelectTopNRows command from SSMS  ******/
USE [DBMSYS_InternationalPaper_International_Paper]
GO

SELECT LEFT(MOB.MOB_Name,CHARINDEX('.',MOB.MOB_Name)-1) AS [OriginalHostName], EDT.EDT_Name, VER.VER_Name,OSS.OSS_IsClusterNode, OSS.OSS_IsVirtualServer, OSS.OSS_IsHypervisorPresent, OSS.OSS_NumberOfProcessors, 'NA' AS Domain
FROM  Inventory.Editions AS EDT INNER JOIN
         Inventory.MonitoredObjects AS MOB ON EDT.EDT_ID = MOB.MOB_Engine_EDT_ID INNER JOIN
         Inventory.Versions AS VER ON MOB.MOB_VER_ID = VER.VER_ID LEFT OUTER JOIN
         Consolidation.RemovedFromAssessment AS RFA ON MOB.MOB_ID = RFA.RFA_MOB_ID INNER JOIN
		 Inventory.OSServers AS OSS ON MOB.MOB_OOS_ID = OSS.OSS_ID 

WHERE (RFA.RFA_MOB_ID IS NULL) AND EDT.EDT_Name like '%Windows%'
UNION
SELECT EMOB.MOB_Name AS [OriginalHostName], EEDT.EDT_Name, EVER.VER_Name,EOSS.OSS_IsClusterNode, EOSS.OSS_IsVirtualServer, EOSS.OSS_IsHypervisorPresent, EOSS.OSS_NumberOfProcessors, 'EMEA' AS Domain
FROM  DBMSYS_InternationalPaper_International_Paper_Emea.Inventory.Editions AS EEDT INNER JOIN
         DBMSYS_InternationalPaper_International_Paper_Emea.Inventory.MonitoredObjects AS EMOB ON EEDT.EDT_ID = EMOB.MOB_Engine_EDT_ID INNER JOIN
         DBMSYS_InternationalPaper_International_Paper_Emea.Inventory.Versions AS EVER ON EMOB.MOB_VER_ID = EVER.VER_ID LEFT OUTER JOIN
         DBMSYS_InternationalPaper_International_Paper_Emea.Consolidation.RemovedFromAssessment AS ERFA ON EMOB.MOB_ID = ERFA.RFA_MOB_ID INNER JOIN
		 Inventory.OSServers AS EOSS ON EMOB.MOB_OOS_ID = EOSS.OSS_ID 
WHERE (ERFA.RFA_MOB_ID IS NULL) AND EEDT.EDT_Name like '%Windows%'
