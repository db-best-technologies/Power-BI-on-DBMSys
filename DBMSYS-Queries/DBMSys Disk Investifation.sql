USE [DBMSYS_CityofTucson_City_of_Tucson]
GO


/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) CMT.CMT_ID, CMT.CMT_CLV_ID, CMT.CMT_Name, CMT.CMT_CPUName, CMT.CMT_CoreCount, CMT.CMT_CPUStrength, CMT.CMT_MemoryMB, CMT.CMT_NetworkSpeedDownloadMbit, CMT.CMT_NetworkSpeedUploadMbit, CMT.CMT_LocalSSDDriveGB, CMT.CMT_SupportsAutoScale, CMT.CMT_SupportLoadBalancing, CMT.CMT_SupportsRDMA, CMT.CMT_IsActive, 
         CMT.CMT_ECU, CMT.CMT_CMG_ID, CMT.CMT_DTUs, CMT.CMT_MaxStorageGB
FROM  Consolidation.CloudMachineTypes AS CMT CROSS JOIN
         Consolidation.CloudStorageThroughput
WHERE (CMT.CMT_CLV_ID IN (1, 5, 4))
ORDER BY CMT.CMT_CLV_ID, CMT.CMT_Name

USE [DBMSYS_CityofTucson_City_of_Tucson]
GO

SELECT [CST_ID]
      ,[CST_BUL_ID]
      ,[CST_DiskCount]
      ,[CST_MaxIOPS8KB]
      ,[CST_MaxMBPerSec8KB]
      ,[CST_MaxIOPS64KB]
      ,[CST_MaxMBPerSec64KB]
  FROM [Consolidation].[CloudStorageThroughput]
GO



USE [DBMSYS_CityofTucson_City_of_Tucson]
GO
USE [DBMSYS_CityofTucson_City_of_Tucson]
GO

SELECT [CDF_ID]
      ,[CDF_BUL_ID]
      ,[CDF_DiskCount]
      ,[CDF_BlockSize]
      ,[CDF_ReadsFactor]
      ,[CDF_WritesFactor]
      ,[CDF_ReadsMBFactor]
      ,[CDF_WritesMBFactor]
  FROM [Consolidation].[CloudMachinesDiskFactors]
GO


SELECT [PSH_ID]
      ,[PSH_HST_ID]
      ,[PSH_MOB_ID]
      ,[PSH_CMT_ID]
      ,[PSH_VES_ID]
      ,[PSH_OST_ID]
      ,[PSH_CoreCount]
      ,[PSH_CPUStrength]
      ,[PSH_MemoryMB]
      ,[PSH_Storage_BUL_ID]
      ,[PSH_MaxDiskCount]
      ,[PSH_MaxDataFilesDiskSizeMB]
      ,[PSH_MaxLogFilesDiskSizeMB]
      ,[PSH_MaxDiskSizeMB]
      ,[PSH_MaxIOPS8KB]
      ,[PSH_MaxMBPerSec8KB]
      ,[PSH_MaxIOPS64KB]
      ,[PSH_MaxMBPerSec64KB]
      ,[PSH_DataFilesMaxIOPS]
      ,[PSH_LogFilesMaxIOPS]
      ,[PSH_TotalMaxIOPS]
      ,[PSH_DataFilesMaxMBPerSec]
      ,[PSH_LogFilesMaxMBPerSec]
      ,[PSH_TotalMaxMBPerSec]
      ,[PSH_NetworkSpeedMbit]
      ,[PSH_NetDownloadSpeedRatio]
      ,[PSH_NetUploadSpeedRatio]
      ,[PSH_PricePerMonthUSD]
      ,[PSH_SupportsAutoScale]
      ,[PSH_SupportLoadBalancing]
      ,[PSH_FileTypeSeparation]
      ,[PSH_CMP_ID]
      ,[PSH_CHE_ID]
      ,[PSH_CRG_ID]
      ,[PSH_IsVM]
      ,[PSH_PricePerDisk]
      ,[PSH_CHA_ID]
  FROM [Consolidation].[PossibleHosts]
GO



USE [DBMSYS_CityofTucson_City_of_Tucson]
GO

SELECT [CST_ID]
      ,[CST_BUL_ID]
      ,[CST_DiskCount]
      ,[CST_MaxIOPS8KB]
      ,[CST_MaxMBPerSec8KB]
      ,[CST_MaxIOPS64KB]
      ,[CST_MaxMBPerSec64KB]
  FROM [Consolidation].[CloudStorageThroughput]
GO



SELECT TOP (1000) [BUL_ID]
      ,[BUL_CLV_ID]
      ,[BUL_BUI_ID]
      ,[BUL_Name]
      ,[BUL_UnitName]
      ,[BUL_Limitations]
      ,[BUL_IsActive]
      ,[BUL_BUR_ID]
  FROM [DBMSYS_CityofTucson_City_of_Tucson].[Consolidation].[BillableByUsageItemLevels]
  WHERE (BUL_CLV_ID IN ( 1,5,4)) AND [BUL_BUI_ID] = 2

  USE [DBMSYS_CityofTucson_City_of_Tucson]
GO

USE [DBMSYS_CityofTucson_City_of_Tucson]
GO

SELECT [BUI_ID]
      ,[BUI_Name]
  FROM [Consolidation].[BillableByUsageItems]
GO

USE [DBMSYS_CityofTucson_City_of_Tucson]
GO

SELECT [CSO_ID]
      ,[CSO_CRG_ID]
      ,[CSO_CMT_ID]
      ,[CSO_HourlyPriceUSD]
  FROM [Consolidation].[CloudStorageOptimizationPrices]
GO

