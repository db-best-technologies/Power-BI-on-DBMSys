USE DBMSYS_InternationalPaper_International_Paper
GO

/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) CMP.CMP_ID, CRG.CRG_Name, CMT.CMT_Name, CMT.CMT_CoreCount, CMT.CMT_CPUStrength, CMT.CMT_MemoryMB, CMT.CMT_NetworkSpeedDownloadMbit, CMT.CMT_NetworkSpeedUploadMbit, CMT.CMT_LocalSSDDriveGB, CMT.CMT_SupportsAutoScale, CMT.CMT_SupportLoadBalancing, CMT.CMT_SupportsRDMA, CMT.CMT_IsActive, 
         CMT.CMT_DTUs, CMT.CMT_MaxStorageGB, CMT.CMT_ECU, CMP.CMP_CRL_ID, CMP.CMP_OST_ID, CHE.CHE_Name, CHA.CHA_Name, CHE.CHE_IsFree, CMP.CMP_CPM_ID, CMP.CMP_UpfrontPaymnetUSD, CMP.CMP_MonthlyPaymentUSD, CMP.CMP_HourlyPaymentUSD, CMP.CMP_EffectiveHourlyPaymentUSD, CMP.CMP_Storage_BUL_ID, CMP.CMP_CTT_ID, CMP.CMP_CPT_ID, 
         Consolidation.CloudMachinePaymentModels.CPM_Name, Consolidation.CloudMachinePaymentModels.CPM_NumberOfMonths, Consolidation.CloudMachinePaymentModels.CPM_UpfrontType
FROM  Consolidation.CloudMachinePricing AS CMP INNER JOIN
         Consolidation.CloudRegions AS CRG ON CMP.CMP_CRG_ID = CRG.CRG_ID INNER JOIN
         Consolidation.CloudZones AS CLZ ON CRG.CRG_CLZ_ID = CLZ.CLZ_ID INNER JOIN
         Consolidation.CloudMachineTypes AS CMT ON CMP.CMP_CMT_ID = CMT.CMT_ID LEFT OUTER JOIN
         Consolidation.CloudMachinePaymentModels ON CMP.CMP_CPM_ID = Consolidation.CloudMachinePaymentModels.CPM_ID LEFT OUTER JOIN
         Consolidation.CloudHostedApplicationEditions AS CHE ON CMP.CMP_CHE_ID = CHE.CHE_ID
		 LEFT OUTER JOIN Consolidation.CloudHostedApplications AS CHA ON CMP.CMP_CHA_ID = CHA.CHA_ID
WHERE (CRG.CRG_Name = 'South Central US' OR
         CRG.CRG_Name = 'West Europe') 
ORDER BY CRG.CRG_Name, CMT.CMT_Name