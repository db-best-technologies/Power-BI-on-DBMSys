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
/****** Object:  StoredProcedure [Consolidation].[usp_Reports_SingleDatabaseCloudLocation]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Consolidation].[usp_Reports_SingleDatabaseCloudLocation]
	@CLV_ID int
as
set nocount on
declare @HST_ID int

select @HST_ID = HST_ID
from Consolidation.HostTypes
where HST_CLV_ID = @CLV_ID
	and HST_IsPerSingleDatabase = 1

select 'Summary'
select CGR_Name GroupName, sum(TotalDatabases) TotalDatabases, sum(CloudWorthyDatabases) CloudWorthyDatabases, sum(TotalMonthlyPriceUSD) TotalMonthlyPriceUSD
from Consolidation.ConsolidationGroups
	inner join Consolidation.ServerGrouping on CGR_ID = SGR_CGR_ID
	cross apply (select count(*) TotalDatabases
					from Inventory.InstanceDatabases
					where exists (select * from Consolidation.ParticipatingDatabaseServers where PDS_Server_MOB_ID = SGR_MOB_ID and PDS_Database_MOB_ID = IDB_MOB_ID)
						and IDB_Name not in ('master', 'tempdb', 'model', 'msdb', 'distribution')) t
	outer apply (select count(*) CloudWorthyDatabases, isnull(cast(sum(SDC_MonthlyPrice) as decimal(15, 2)), 0) TotalMonthlyPriceUSD
					from Consolidation.SingleDatabaseCloudLocations
						inner join Consolidation.SingleDatabaseLoadBlocks on SDL_ID = SDC_SDL_ID
					where SDC_HST_ID = @HST_ID
						and SGR_MOB_ID = SDL_MOB_ID) c
group by CGR_Name
order by CloudWorthyDatabases desc, GroupName

select 'Details'
select CGR_Name GroupName, o.MOB_Name ServerName, d.MOB_Name SQLInstanceName, IDB_Name DatabaseName, CMG_Name + ' - ' + CMT_Name CloudMachineType, cast(SDC_MonthlyPrice as decimal(15, 2)) MonthlyPrice,
	SDL_DTUs DTUs, ceiling(SDL_SizeGB) SizeGB, SDT_PercentOfServerActivity [PercentOfServerActivity]
from Consolidation.SingleDatabaseCloudLocations
	inner join Consolidation.SingleDatabaseLoadBlocks on SDL_ID = SDC_SDL_ID
	inner join Inventory.MonitoredObjects o on o.MOB_ID = SDL_MOB_ID
	inner join Inventory.InstanceDatabases on IDB_ID = SDL_IDB_ID
	inner join Inventory.MonitoredObjects d on d.MOB_ID = IDB_MOB_ID
	inner join Consolidation.CloudMachineTypes on CMT_ID = SDC_CMT_ID
	inner join Consolidation.CloudMachineCategories on CMG_ID = CMT_CMG_ID
	inner join Consolidation.ServerGrouping on SGR_MOB_ID = SDL_MOB_ID
	inner join Consolidation.ConsolidationGroups on CGR_ID = SGR_CGR_ID
	inner join Consolidation.SingleDatabaseTransactions on SDT_MOB_ID = SGR_MOB_ID
															and SDT_IDB_ID = IDB_ID
where SDC_HST_ID = @HST_ID
order by GroupName, ServerName, SQLInstanceName, DatabaseName 

select 'Limiting features'
exec Consolidation.usp_Reports_LimitingFeatures
GO
