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
/****** Object:  StoredProcedure [CapacityPlanningWizard].[usp_GetCloudRegions]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [CapacityPlanningWizard].[usp_GetCloudRegions]
as
select distinct CLV_ShortName [Cloud Provider], CRG_ID [Region ID], CRG_Name [Region]
from Consolidation.CloudProviders
	inner join Consolidation.CloudRegions on CRG_CLV_ID = CLV_ID
where exists (select *
				from Consolidation.ServerPossibleHostTypes
					inner join Consolidation.HostTypes on HST_ID = SHT_HST_ID
				where CLV_ID = HST_CLV_ID)
	and exists (select *
					from Consolidation.CloudMachinePricing
					where CMP_CRG_ID = CRG_ID)
order by [Cloud Provider], [Region]
GO
