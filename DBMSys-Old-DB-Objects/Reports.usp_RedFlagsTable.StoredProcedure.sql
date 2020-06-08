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
/****** Object:  StoredProcedure [Reports].[usp_RedFlagsTable]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Reports].[usp_RedFlagsTable]
as
set nocount on

select PCG_Name + ' alerts' [Issue], format(count(*), '##,##0') [Servers]
from Consolidation.RedFlagsByResourceType
	inner join PerformanceData.PerformanceCounterGroups on PCG_ID = RFR_PCG_ID
group by PCG_Name
GO
