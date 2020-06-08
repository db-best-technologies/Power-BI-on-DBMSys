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
/****** Object:  StoredProcedure [RuleChecks].[usp_LinkedServerConnectingWithSysadminLogin]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_LinkedServerConnectingWithSysadminLogin]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

select @ClientID, @PRR_ID, LNS_MOB_ID, LNS_ID, LNS_Name, MOB_ID, MOB_Name, INL_ID, INL_Name
from Inventory.LinkedServers
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = LNS_MOB_ID
	inner join Inventory.LinkedServerRemoteLogins on LSR_MOB_ID = LNS_MOB_ID
														and LSR_LNS_ID = LNS_ID
	inner join Inventory.MonitoredObjects on MOB_ID = LNS_DataSource_MOB_ID
	inner join Inventory.InstanceLogins on INL_ID = LSR_RemoteLogin_INL_ID
where INL_IsSysAdmin = 1
GO
