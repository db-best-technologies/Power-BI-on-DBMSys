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
/****** Object:  StoredProcedure [GUI].[usp_GetDBMSysStatus]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [GUI].[usp_GetDBMSysStatus]
as
set nocount on
set transaction isolation level read uncommitted

select (select COUNT(*)
			from Inventory.MonitoredObjects
			where MOB_OOS_ID = 1) NumberOfMonitoredObjects,
		(select top 1 TRH_EndDate
			from Collect.TestRunHistory
			where TRH_TRS_ID > 2
			order by TRH_ID desc) LastCollectionDate,
		(select top 1 PKN_EndDate
			from BusinessLogic.PackageRuns
				inner join BusinessLogic.Packages on PKG_ID = PKN_PKG_ID
				inner join BusinessLogic.PackageTypes on PKT_ID = PKG_PKT_ID
			where PKT_Name = 'Health Check'
				and PKN_EndDate is not null
			order by PKN_ID desc) LastHealthCheckComplete
GO
