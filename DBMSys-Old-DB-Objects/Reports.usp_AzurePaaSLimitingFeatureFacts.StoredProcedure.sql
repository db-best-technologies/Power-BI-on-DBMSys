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
/****** Object:  StoredProcedure [Reports].[usp_AzurePaaSLimitingFeatureFacts]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Reports].[usp_AzurePaaSLimitingFeatureFacts]
as
set nocount on

select concat(LFT_Name, isnull(IsIgnored, ''), ' - ', format(count(*), '##,##0'), ' ', max(iif(LFU_IDB_ID is null, 'server', 'database')), '(s)') Fact
from Inventory.LimitingFeatureUsage
	left join Inventory.InstanceDatabases on IDB_ID = LFU_IDB_ID
	inner join Inventory.LimitingFeatureTypes on LFT_ID = LFU_LFT_ID
	left join (select Val, ' (Ignored)' IsIgnored
				from Management.Settings
					cross apply Infra.fn_SplitString(cast(SET_Value as varchar(max)), ',')
				where SET_Module = 'Consolidation'
					and SET_Key = 'Ignore PaaS limiting features') i on Val = LFT_Name
where IDB_Name is null
	or IDB_Name not in ('master', 'model', 'tempdb', 'msdb')
group by LFT_Name, IsIgnored
order by IsIgnored, LFT_Name
GO
