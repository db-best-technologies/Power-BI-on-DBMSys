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
/****** Object:  StoredProcedure [Reports].[usp_TotalCollectionServerCount]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_TotalCollectionServerCount]
as
set nocount on

declare @ConsiderClusterVirtualServerAsHost bit

select @ConsiderClusterVirtualServerAsHost = cast(SET_Value as bit)
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Consider Cluster Virtual Server As Host'

;with Input as
		(select count(*) TotalServers, ParticipatingServers
			from Inventory.MonitoredObjects
				cross join (select count(distinct PDS_Server_MOB_ID) ParticipatingServers
								from Consolidation.ParticipatingDatabaseServers
							) p
			where exists (select *
							from Management.PlatformTypes
							where PLT_ID = MOB_PLT_ID
								and PLT_PLC_ID = 2)
				and MOB_OOS_ID in (0, 1)
				and exists (select *
								from Inventory.OSServers
								where (OSS_MOB_ID = MOB_ID
										)
									and ((@ConsiderClusterVirtualServerAsHost = 0
											and OSS_IsVirtualServer = 0)
										or (@ConsiderClusterVirtualServerAsHost = 1
											and OSS_IsClusterNode = 0)
										)
							)
			group by ParticipatingServers
		)
select concat(format(ParticipatingServers, '##,##0'), ' servers (', format(TotalServers - ParticipatingServers, '##,##0'), ' of the total ', TotalServers, ' were eliminated due to missing data)') Value
from Input
GO
