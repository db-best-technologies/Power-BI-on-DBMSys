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
/****** Object:  StoredProcedure [DTUCalculator].[usp_Get_APIOutput_State]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [DTUCalculator].[usp_Get_APIOutput_State]
AS

if OBJECT_ID('tempdb..#MOBLIST') is not null
	drop table #MOBLIST

create table #MOBLIST
(
	MOBID	INT
	,CORE	INT
)

INSERT INTO #MOBLIST
exec CapacityPlanningWizard.usp_GetServerListForAzureCalculator

SELECT
		MOB_ID as AOS_MOB_ID
		,MOB_NAME
		,ISNULL(AOS_STATE,'Never ran') as AOS_STATE
FROM	Inventory.MonitoredObjects
join	#MOBLIST on MOB_ID = MOBID
left JOIN	DTUCalculator.APIOutput_State on MOB_ID = AOS_MOB_ID
GO
