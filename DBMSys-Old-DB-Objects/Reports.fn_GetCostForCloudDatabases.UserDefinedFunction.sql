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
/****** Object:  UserDefinedFunction [Reports].[fn_GetCostForCloudDatabases]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [Reports].[fn_GetCostForCloudDatabases]() returns table
as
return (select count(*) DatabaseCount, sum(SDC_MonthlyPrice)*36 PriceFor3YearsUSD
			from Consolidation.SingleDatabaseCloudLocations
			where SDC_HST_ID = 10
			having count(*) > 0
		)
GO
