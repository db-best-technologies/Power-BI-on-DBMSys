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
/****** Object:  StoredProcedure [RuleChecks].[usp_HyperthreadingIsDisabled]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--				MODIFY STORED PROCEDURES
--**********************************************************************************************************
CREATE procedure [RuleChecks].[usp_HyperthreadingIsDisabled]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

select distinct @ClientID, @PRR_ID, PRS_MOB_ID
from Inventory.Processors
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = PRS_MOB_ID
where PRS_NumberOfCores = PRS_NumberOfLogicalProcessors
	and not exists (select *
						from Inventory.MonitoredObjects
							inner join Inventory.OSServers on OSS_MOB_ID = MOB_ID
							
						where MOB_PLT_ID = 2
							and MOB_ID = PRS_MOB_ID
							and OSS_IsVirtualServer = 1
							)
GO
