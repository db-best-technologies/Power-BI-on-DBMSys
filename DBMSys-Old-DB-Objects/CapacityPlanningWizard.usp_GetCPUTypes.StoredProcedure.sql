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
/****** Object:  StoredProcedure [CapacityPlanningWizard].[usp_GetCPUTypes]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [CapacityPlanningWizard].[usp_GetCPUTypes]
	@CPUMask varchar(100) = ''
as
set nocount on

select CPB_Name [CPU Name]
from ExternalData.CPUBenchmark
where CPB_Name like '%' + @CPUMask + '%'
order by CPB_Name
GO
