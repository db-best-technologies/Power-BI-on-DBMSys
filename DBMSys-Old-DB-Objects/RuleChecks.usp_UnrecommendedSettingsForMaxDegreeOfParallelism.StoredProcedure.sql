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
/****** Object:  StoredProcedure [RuleChecks].[usp_UnrecommendedSettingsForMaxDegreeOfParallelism]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_UnrecommendedSettingsForMaxDegreeOfParallelism]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

select @ClientID, @PRR_ID, ICF_MOB_ID, sum(Cores), ICF_Value
from Inventory.InstanceConfigurations
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = ICF_MOB_ID
	inner join Inventory.InstanceConfigurationTypes on ICT_ID = ICF_ICT_ID
	cross apply RuleChecks.fn_GetNumberOfCores(ICF_MOB_ID)
where ICT_Name = 'max degree of parallelism'
group by ICF_MOB_ID, ICF_Value
having SUM(Cores) > 4
	and (ICF_Value = 0
			or ICF_Value > SUM(Cores))
GO
