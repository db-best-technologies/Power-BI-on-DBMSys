/****** Script for SelectTopNRows command from SSMS  ******/
USE [DBMSYS_CityofTucson_City_of_Tucson]
GO

SELECT DISTINCT NA_M.MOB_Name AS [Original Server Host], NA_R.AGR_Name, NA_R.AGR_EndpointURL, NA_R.AGR_HealthCheckTimeout
FROM            Inventory.AvailabilityGroupReplicas AS NA_R INNER JOIN
                         Inventory.MonitoredObjects AS NA_M ON NA_R.AGR_MOB_ID = NA_M.MOB_ID