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
/****** Object:  StoredProcedure [Reports].[usp_CloudPaaSLayoutFacts]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Reports].[usp_CloudPaaSLayoutFacts]
as
set nocount on

;with Input as
		(select DatabaseCount MigratedDatabases, PriceFor3YearsUSD, TotalDatabaseCount, ConsideredDatabases
			from Reports.fn_GetCostForCloudDatabases()
				cross join (select count(*) TotalDatabaseCount
								from Inventory.InstanceDatabases
								where IDB_Name not in ('master', 'tempdb', 'model', 'msdb', 'distribution')
								) d
				cross join (select count(*) ConsideredDatabases
								from Consolidation.SingleDatabaseLoadBlocks
							) c
		)
	, Facts as
		(select concat(format(PriceFor3YearsUSD, 'C'), ' for 3 years (', format(PriceFor3YearsUSD/36, 'C'), ' per month) for ', format(MigratedDatabases, '##,##0'),
							' databases that can be migrated to Azure Azure SQL Database') Fact, 1 Rnk
			from Input
			union all
			select concat(format(TotalDatabaseCount, '##,##0'), ' databases evaluated') Fact, 2 Rnk
			from Input
			union all
			select concat(format(TotalDatabaseCount - ConsideredDatabases, '##,##0'), ' databases eliminated due to use of unsupported features') Fact, 3 Rnk
			from Input
			union all
			select concat(format(ConsideredDatabases - MigratedDatabases, '##,##0'), ' databases cannot be supported by the avaiable Azure SQL Database offerings') Fact, 4 Rnk
			from Input
		)
select Fact
from Facts
order by Rnk
GO
