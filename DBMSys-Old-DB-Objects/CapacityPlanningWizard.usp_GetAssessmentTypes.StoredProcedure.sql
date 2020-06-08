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
/****** Object:  StoredProcedure [CapacityPlanningWizard].[usp_GetAssessmentTypes]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [CapacityPlanningWizard].[usp_GetAssessmentTypes]
as
set nocount on

select HST_ID [ID], HST_Name [Assessment Type], HST_ExclusivityGroupID [Exclusivity Group]
from Consolidation.HostTypes
order by [ID]
GO
