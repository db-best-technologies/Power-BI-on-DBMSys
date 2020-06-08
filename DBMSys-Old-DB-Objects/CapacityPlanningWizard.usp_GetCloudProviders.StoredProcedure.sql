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
/****** Object:  StoredProcedure [CapacityPlanningWizard].[usp_GetCloudProviders]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [CapacityPlanningWizard].[usp_GetCloudProviders]
	@ShowType tinyint -- 1 = Multi database providers, 2 = Single database providers
as
select distinct CLV_ID ID, CLV_ShortName [Cloud Provider]
from Consolidation.CloudProviders
	inner join Consolidation.HostTypes on HST_CLV_ID = CLV_ID
where exists (select *
				from Consolidation.ServerPossibleHostTypes
				where HST_ID = SHT_HST_ID)
	and ((@ShowType = 1
			and HST_IsPerSingleDatabase = 0)
		or (@ShowType = 2
			and HST_IsPerSingleDatabase = 1)
		)
GO
