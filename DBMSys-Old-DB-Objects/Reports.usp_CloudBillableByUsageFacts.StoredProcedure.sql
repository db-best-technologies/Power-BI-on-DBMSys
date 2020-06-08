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
/****** Object:  StoredProcedure [Reports].[usp_CloudBillableByUsageFacts]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_CloudBillableByUsageFacts]
as
set nocount on

select concat(
	ItemType, iif(ItemType = 'Network usage', concat(' (', max(ItemLevelName), ')'), ''),
	' - ', format(sum(Units), '##,##0'), ' monthly units (',
	case ItemType
		when 'Network usage' then 'Gbit'
		when 'Storage space' then 'GB'
		when 'Storage transactions' then '100K IOPS'
	end, '), ',
	iif(min(isnull(AmountToPay, -1)) = -1, 'Consult cloud provider regarding price as usage is very high', concat(format(sum(AmountToPay)*36, 'C'), ' (', format(sum(AmountToPay), 'C'), ' per month)'))) Fact
from Consolidation.fn_Reports_BillableByUsageCostBreakdown(1,default)
where StorageRedundancyLevelRank = 1
group by ItemType
GO
