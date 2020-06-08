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
/****** Object:  StoredProcedure [Consolidation].[usp_Reports_LimitingFeatures]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Consolidation].[usp_Reports_LimitingFeatures]
as
set nocount on
declare @IgnorePaaSLimitingFeatures varchar(4000)

select @IgnorePaaSLimitingFeatures = CAST(SET_Value as varchar(4000))
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Ignore PaaS limiting features'

select MOB_Name SQLInstanceName, OSS_Name MachineName, isnull(IDB_Name, '<Server-Wide>') DatabaseName, LFT_Name LimitingFeature
from Inventory.LimitingFeatureUsage
	inner join Inventory.MonitoredObjects on MOB_ID = LFU_MOB_ID
	inner join Inventory.DatabaseInstanceDetails on DID_DFO_ID = MOB_Entity_ID
	inner join Inventory.OSServers on OSS_ID = DID_OSS_ID
	left join Inventory.InstanceDatabases on IDB_ID = LFU_IDB_ID
	inner join Inventory.LimitingFeatureTypes on LFT_ID = LFU_LFT_ID
where (IDB_Name is null
		or IDB_Name not in ('master', 'model', 'tempdb', 'msdb')
	)
	and not exists (select *
						from Infra.fn_SplitString(@IgnorePaaSLimitingFeatures, ',')
						where Val = LFT_Name)
order by SQLInstanceName, DatabaseName
GO
