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
/****** Object:  StoredProcedure [Reports].[usp_CurrentEnvironmentHardwareAgeVariability]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_CurrentEnvironmentHardwareAgeVariability]
as
set nocount on

;with Results as
	(select min(datediff(year, OSS_InstallDate, getdate())) MinValue,
			max(datediff(year, OSS_InstallDate, getdate())) MaxValue,
			sum(iif(datediff(year, OSS_InstallDate, getdate()) > 5, 1, 0))*100/count(*) VeryOldCPUPercentage
		from Inventory.OSServers
			inner join Inventory.MonitoredObjects on MOB_ID = OSS_MOB_ID
		where exists (select *
						from Consolidation.ParticipatingDatabaseServers
						where PDS_Server_MOB_ID = MOB_ID)
			and exists (select *
							from Management.PlatformTypes
							where PLT_ID = MOB_PLT_ID
								and PLT_PLC_ID = 2)
	)
select top 1
		case when MaxValue - MinValue < 3 then 'The hardware age* in the assessed environment is rather unified'
			else 'There is a wide range of hardware age* in the assessed environment'
		end [Value]
from Results
GO
