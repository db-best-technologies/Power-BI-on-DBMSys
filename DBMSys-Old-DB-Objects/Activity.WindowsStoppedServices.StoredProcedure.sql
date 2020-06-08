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
/****** Object:  StoredProcedure [Activity].[WindowsStoppedServices]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Activity].[WindowsStoppedServices] --NULL
--DECLARE
	@EventDescription nvarchar(1000)
AS
SET NOCOUNT ON

SELECT 
		MOB_ID AS F_MOB_ID
		,MOB_Name + '\' + SNM_Name AS F_InstanceName
		,'Service ' + SNM_Name + ' on ' + MOB_Name + ' stopped' + ' at ' + CONVERT(NVARCHAR(30),OSR_LastSeenDate,121) + CHAR(10) + 
		ISNULL(' Service description: ' + SCD_Description + CHAR(10),'') + 
		'Service Start Modes: ' + SSM_Name --+ CHAR(10) + 

		
		as AlertMessage
		,(
			select	@EventDescription					[@EventDescription]
					,MOB_ID								[@MOB_ID]
					,MOB_Name							[@MOB_Name]
					,OSR_ID								[@OSR_ID]
					,SNM_Name							[@SNM_Name]
					,SCD_Description					[@SCD_Description]
					,OSR_LastSeenDate					[@OSR_LastSeenDate]
					,SSM_Name							[@SSM_Name]
					
					

					
					for xml path('Alert'), root('Alerts'), type
		) AlertEventData
		
FROM	Inventory.OperatingSystemServices 
JOIN	Inventory.ServiceNames ON SNM_ID = OSR_SNM_ID
JOIN	Inventory.ServiceStates ON SST_ID = OSR_SST_ID
JOIN	Inventory.MonitoredObjects ON OSR_MOB_ID = MOB_ID
JOIN	Management.PlatformTypes ON MOB_PLT_ID = PLT_ID
JOIN	Inventory.ServiceStartModes ON SSM_ID = OSR_SSM_ID
left JOIN	Inventory.ServiceDescriptions ON OSR_SDN_ID =  SCD_ID
WHERE	SST_Name <> 'Running'
		AND MOB_OOS_ID IN (0,1)
		--AND OSR_SSM_ID <> 2
		AND SSM_Name IN ('Auto','Manual')
		AND NOT exists (
						SELECT 
								*
						FROM	EventProcessing.EventIncludeExclude
						WHERE	EIE_MOV_ID = 35
								AND EIE_IsInclude = 0
								AND (
										EIE_MOB_ID = MOB_ID
										or EIE_MOB_ID is null
									)
								AND (
										EIE_InstanceName = SNM_Name
										OR (
												EIE_UseLikeForInstanceName = 1
												and SNM_Name like '%' + EIE_InstanceName + '%'
											)
										OR EIE_InstanceName is null
								)
					)
		AND (
				EXISTS (
						SELECT 
								*
						FROM	EventProcessing.EventIncludeExclude
						WHERE	EIE_MOV_ID = 35
								AND EIE_IsInclude = 1
								AND (
										EIE_MOB_ID = MOB_ID
										or EIE_MOB_ID is null
									)
								AND (
										EIE_InstanceName = SNM_Name
										OR (
												EIE_UseLikeForInstanceName = 1
												and SNM_Name like '%' + EIE_InstanceName + '%'
											)
										OR EIE_InstanceName is null
									)
						)
						OR 
						NOT EXISTS (SELECT * FROM EventProcessing.EventIncludeExclude WHERE EIE_MOV_ID = 35 AND EIE_IsInclude = 1)
			)
GO
