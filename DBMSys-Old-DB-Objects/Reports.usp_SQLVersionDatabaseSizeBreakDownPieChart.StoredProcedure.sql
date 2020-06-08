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
/****** Object:  StoredProcedure [Reports].[usp_SQLVersionDatabaseSizeBreakDownPieChart]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_SQLVersionDatabaseSizeBreakDownPieChart]
as
set nocount on
if object_id('tempdb..#Files') is not null
	drop table #Files
if object_id('tempdb..#Sizes') is not null
	drop table #Sizes

select MOB_ID, PLY_Name [Caption], CIN_ID
into #Files
from Inventory.MonitoredObjects
	inner join Inventory.Versions on VER_ID = MOB_VER_ID
	cross apply (select top 1 *
					from ExternalData.ProductLifeCycles
					where PLY_MinVersionNumber < VER_Number
					order by PLY_MinVersionNumber desc) v
	inner join Inventory.InstanceDatabases on IDB_MOB_ID = MOB_ID
	inner join Inventory.DatabaseFiles on DBF_DFT_ID <> 1
										and DBF_IDB_ID = IDB_ID
	inner join PerformanceData.CounterInstances on CIN_Name = DBF_FileName
where IDB_Name not in ('master', 'tempdb', 'model', 'msdb', 'distribution')

select MOB_ID, [Caption], cast(sum(SizeGB) as bigint) SizeGB
into #Sizes
from #Files
	cross apply (select top 1 cast(CRS_Value as bigint)/1024. SizeGB
					from PerformanceData.CounterResults with (forceseek)
					where CRS_MOB_ID = MOB_ID
						and CRS_SystemID = 3
						and CRS_CounterID = 41
						and CRS_InstanceID = CIN_ID
					order by CRS_DateTime desc) r
group by MOB_ID, [Caption]

select MOB_ID, [Caption]
from #Sizes
	cross apply (select *
					from Infra.Numbers
					where Num <= SizeGB/10) n
GO
