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
/****** Object:  StoredProcedure [Reports].[usp_ExcludedFromVirtualizationAssessmentCount]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Reports].[usp_ExcludedFromVirtualizationAssessmentCount]
as
set nocount on

select count(*) Value
from Consolidation.LoadBlocks
where exists (select *
				from Consolidation.ServerPossibleHostTypes
				where SHT_MOB_ID = LBL_MOB_ID
					and SHT_HST_ID = 4)
	and not exists (select *
					from Consolidation.ConsolidationBlocks_LoadBlocks
					where CBL_HST_ID = 4
						and CBL_LBL_ID = LBL_ID)
GO
