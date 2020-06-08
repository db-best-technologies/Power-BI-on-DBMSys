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
/****** Object:  StoredProcedure [RuleChecks].[usp_InstalledSQLComponentOnMachine]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_InstalledSQLComponentOnMachine]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

select @ClientID, @PRR_ID, OSR_MOB_ID, SMT_DisplayName, SUBSTRING(SNM_Name, CHARINDEX('$', SNM_Name + '$', 1) + 1, 100) InstanceName, SSM_Name, SST_Name
from Inventory.OperatingSystemServices
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = OSR_MOB_ID
	inner join Inventory.ServiceNames on SNM_ID = OSR_SNM_ID
	inner join Inventory.ServiceStartModes on SSM_ID = OSR_SSM_ID
	inner join Inventory.ServiceStates on SST_ID = OSR_SST_ID
	inner join Inventory.SQLComponentTypes on LEFT(SNM_Name + '$', CHARINDEX('$', SNM_Name + '$', 1) - 1) like SMT_ServiceName
GO
