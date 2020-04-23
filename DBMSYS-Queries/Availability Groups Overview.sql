/****** Script for SelectTopNRows command from SSMS  ******/
SELECT DISTINCT NA_R.AGR_Name, NA_MD.AGA_Name, PC.AGN_Name AS Primary_Connection_Mode, RC.AGN_Name AS Secondary_Connection_Mode, SUBSTRING(NA_M.MOB_Name, 1, CHARINDEX('.', NA_M.MOB_Name, 1) - 1) AS [Original Host Name]
--, Inventory.InstanceDatabases.IDB_Name
FROM  Inventory.AvailabilityGroupReplicas AS NA_R INNER JOIN
         Inventory.MonitoredObjects AS NA_M ON NA_R.AGR_MOB_ID = NA_M.MOB_ID INNER JOIN
         Inventory.AvailabilityGroupReplicatedDatabases AS NA_D ON NA_M.MOB_ID = NA_D.AGD_MOB_ID INNER JOIN
         Inventory.InstanceDatabases ON NA_D.AGD_IDB_ID = Inventory.InstanceDatabases.IDB_ID INNER JOIN
         Inventory.AvailabilityGroupAvailabilityModes AS NA_MD ON NA_R.AGR_AGA_ID = NA_MD.AGA_ID INNER JOIN
         Inventory.AvailabilityGroupConnectionAllowance AS PC ON NA_R.AGR_Primary_AGN_ID = PC.AGN_ID INNER JOIN
         Inventory.AvailabilityGroupConnectionAllowance AS RC ON NA_R.AGR_Secondary_AGN_ID = RC.AGN_ID
UNION 
SELECT DISTINCT EMEA_R.AGR_Name, EMEA_MD.AGA_Name, EMEA_PC.AGN_Name AS Primary_Connection_Mode, EMEA_RC.AGN_Name AS Secondary_Connection_Mode
, EMEA_M.MOB_Name
--, SUBSTRING(EMEA_M.MOB_Name, 1, CHARINDEX('.', EMEA_M.MOB_Name, 1) - 1) AS [Original Host Name]
--, Inventory.InstanceDatabases.IDB_Name
FROM  DBMSYS_InternationalPaper_International_Paper_Emea.Inventory.AvailabilityGroupReplicas AS EMEA_R INNER JOIN
         DBMSYS_InternationalPaper_International_Paper_Emea.Inventory.MonitoredObjects AS EMEA_M ON EMEA_R.AGR_MOB_ID = EMEA_M.MOB_ID INNER JOIN
         DBMSYS_InternationalPaper_International_Paper_Emea.Inventory.AvailabilityGroupReplicatedDatabases AS EMEA_D ON EMEA_M.MOB_ID = EMEA_D.AGD_MOB_ID INNER JOIN
         DBMSYS_InternationalPaper_International_Paper_Emea.Inventory.InstanceDatabases ON EMEA_D.AGD_IDB_ID = DBMSYS_InternationalPaper_International_Paper_Emea.Inventory.InstanceDatabases.IDB_ID INNER JOIN
         DBMSYS_InternationalPaper_International_Paper_Emea.Inventory.AvailabilityGroupAvailabilityModes AS EMEA_MD ON EMEA_R.AGR_AGA_ID = EMEA_MD.AGA_ID INNER JOIN
         DBMSYS_InternationalPaper_International_Paper_Emea.Inventory.AvailabilityGroupConnectionAllowance AS EMEA_PC ON EMEA_R.AGR_Primary_AGN_ID = EMEA_PC.AGN_ID INNER JOIN
         DBMSYS_InternationalPaper_International_Paper_Emea.Inventory.AvailabilityGroupConnectionAllowance AS EMEA_RC ON EMEA_R.AGR_Secondary_AGN_ID = EMEA_RC.AGN_ID

