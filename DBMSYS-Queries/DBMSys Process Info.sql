USE [DBMSYS_CityofTucson_City_of_Tucson]
GO

SELECT Inventory.Processors.PRS_ID, Inventory.Processors.PRS_ClientID, Inventory.Processors.PRS_MOB_ID, Inventory.Processors.PRS_PAC_ID, Inventory.ProcessorArchitecture.PAC_Name, Inventory.Processors.PRS_PAV_ID, Inventory.ProcessorAvailability.PAV_Name, Inventory.Processors.PRS_PCA_ID, Inventory.ProcessorCaptions.PCA_Caption, 
         Inventory.Processors.PRS_PCS_ID, Inventory.ProcessorStatuses.PCS_Name, Inventory.Processors.PRS_CurrentClockSpeed, Inventory.Processors.PRS_CurrentVoltage, Inventory.Processors.PRS_DataWidth, Inventory.Processors.PRS_DeviceID, Inventory.Processors.PRS_L2CacheSize, Inventory.Processors.PRS_L3CacheSize, Inventory.Processors.PRS_PMN_ID, 
         Inventory.ProcessorManufacturers.PMN_Name, Inventory.Processors.PRS_MaxClockSpeed, Inventory.Processors.PRS_PSN_ID, Inventory.Processors.PRS_NumberOfCores, Inventory.Processors.PRS_NumberOfLogicalProcessors, Inventory.Processors.PRS_POS_ID, Inventory.Processors.PRS_InsertDate, Inventory.Processors.PRS_LastSeenDate, 
         Inventory.Processors.PRS_Last_TRH_ID
FROM  Inventory.Processors INNER JOIN
         Inventory.ProcessorArchitecture ON Inventory.Processors.PRS_PAC_ID = Inventory.ProcessorArchitecture.PAC_ID INNER JOIN
         Inventory.ProcessorAvailability ON Inventory.Processors.PRS_PAV_ID = Inventory.ProcessorAvailability.PAV_ID INNER JOIN
         Inventory.ProcessorCaptions ON Inventory.Processors.PRS_PCA_ID = Inventory.ProcessorCaptions.PCA_ID INNER JOIN
         Inventory.ProcessorStatuses ON Inventory.Processors.PRS_PCS_ID = Inventory.ProcessorStatuses.PCS_ID INNER JOIN
         Inventory.ProcessorManufacturers ON Inventory.Processors.PRS_PMN_ID = Inventory.ProcessorManufacturers.PMN_ID
ORDER BY Inventory.Processors.PRS_MOB_ID