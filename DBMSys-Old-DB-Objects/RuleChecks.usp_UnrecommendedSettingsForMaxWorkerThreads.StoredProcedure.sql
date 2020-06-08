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
/****** Object:  StoredProcedure [RuleChecks].[usp_UnrecommendedSettingsForMaxWorkerThreads]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [RuleChecks].[usp_UnrecommendedSettingsForMaxWorkerThreads]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

select @ClientID, @PRR_ID, ICF_MOB_ID, IdealValue, ICF_Value
from Inventory.InstanceConfigurations
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = ICF_MOB_ID
	inner join Inventory.InstanceConfigurationTypes on ICT_ID = ICF_ICT_ID
	inner join Inventory.MonitoredObjects d on ICF_MOB_ID = d.MOB_ID
	inner join Inventory.MonitoredObjects o on o.MOB_PLT_ID = 2
												and d.MOB_Name + '\' like o.MOB_Name + '\%'
	inner join Inventory.OSServers on OSS_MOB_ID = o.MOB_ID
	cross apply RuleChecks.fn_GetNumberOfCores(o.MOB_ID)
	cross apply (select (256 + case when Cores - 4 < 0
									then 0
									else Cores - 4
								end)*8*(cast(OSS_Architecture as int)/32) IdealValue) i
where ICT_Name = 'max worker threads'
	and (ICF_Value <> IdealValue
			and ICF_Value <> 0)
GO
