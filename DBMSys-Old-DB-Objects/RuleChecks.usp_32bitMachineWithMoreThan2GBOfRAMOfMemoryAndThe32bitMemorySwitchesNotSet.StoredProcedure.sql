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
/****** Object:  StoredProcedure [RuleChecks].[usp_32bitMachineWithMoreThan2GBOfRAMOfMemoryAndThe32bitMemorySwitchesNotSet]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [RuleChecks].[usp_32bitMachineWithMoreThan2GBOfRAMOfMemoryAndThe32bitMemorySwitchesNotSet]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

select @ClientID, @PRR_ID, MOB_ID, OSS_TotalPhysicalMemoryMB,
		case when OSS_IsPAEEnabled = 0
			then 'Yes'
			else 'No'
		end,
		case when OSS_MaxProcessMemorySizeMB < 3072
			then 'Yes'
			else 'No'
		end		
from Inventory.OSServers
	inner join Inventory.MonitoredObjects on MOB_PLT_ID = 2
											and MOB_ID = OSS_MOB_ID
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = MOB_ID
where OSS_Architecture = 32
	and ((OSS_TotalPhysicalMemoryMB >= 3072
				and OSS_MaxProcessMemorySizeMB < 3072)
			or (OSS_TotalPhysicalMemoryMB > 4096
				and OSS_IsPAEEnabled = 0)
		)
GO
