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
/****** Object:  UserDefinedFunction [Collect].[fn_GetObjectTests]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Collect].[fn_GetObjectTests](@TST_ID int = null) returns table
as
return
	select TST_ID, TSV_ID, MOB_ID, TST_QRT_ID, isnull(STO_IntervalType, TST_IntervalType) TST_IntervalType, isnull(STO_IntervalPeriod, TST_IntervalPeriod) TST_IntervalPeriod,
			TST_RunFirstTimeImmediately, TST_MaxSuccessfulRuns
		from Collect.Tests
			inner join Collect.TestVersions on TST_ID = TSV_TST_ID
			inner join Inventory.MonitoredObjects on MOB_PLT_ID = TSV_PLT_ID
			left join Inventory.Versions on TSV_PLT_ID = VER_PLT_ID
											and MOB_VER_ID = VER_ID
											and (VER_Number >= TSV_MinVersion or TSV_MinVersion is null)
											and (VER_Number <= TSV_MaxVersion or TSV_MaxVersion is null)
			outer apply (select top 1 EDT_ID
							from Infra.fn_SplitString(TSV_Editions, ';')
								inner join Inventory.Editions on TSV_PLT_ID = EDT_PLT_ID
																and MOB_Engine_EDT_ID = EDT_ID
																and EDT_Name like '%' + Val + '%') e
			left join Collect.SpecificTestObjects on STO_TST_ID = TST_ID
													and STO_MOB_ID = MOB_ID
		where (TST_ID = @TST_ID or @TST_ID is null)
			and TST_IsActive = 1
			and ((TSV_MinVersion is null and TSV_MaxVersion is null) or VER_ID is not null)
			and (TSV_Editions is null or EDT_ID is not null)
			and (STO_IsExcluded = 0 or STO_ID is null)
			and MOB_OOS_ID in (0, 1)
GO
