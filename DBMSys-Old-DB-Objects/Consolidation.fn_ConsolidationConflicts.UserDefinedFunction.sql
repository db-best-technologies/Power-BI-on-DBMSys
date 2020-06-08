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
/****** Object:  UserDefinedFunction [Consolidation].[fn_ConsolidationConflicts]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Consolidation].[fn_ConsolidationConflicts](@CLV_ID int) returns table
	as
return (with HostTypes as
				(select HST_ID
					from Consolidation.HostTypes
					where (HST_CLV_ID = @CLV_ID
							or (HST_CLV_ID is null
								and @CLV_ID is null)
							)
						and HST_IsConsolidation = 1
						and HST_IsSharingOS = 1
				)
			, AllDB as
				(select PDS_Server_MOB_ID O_OS_MOB_ID, PDS_Database_MOB_ID O_DB_MOB_ID, IDB_Name O_Name
					from Inventory.InstanceDatabases
						inner join Consolidation.ParticipatingDatabaseServers on PDS_Database_MOB_ID = IDB_MOB_ID
					where IDB_Name not in ('master', 'tempdb', 'model', 'msdb', 'distribution')
				)
			, AllJobs as
				(select PDS_Server_MOB_ID O_OS_MOB_ID, PDS_Database_MOB_ID O_DB_MOB_ID, IJB_Name O_Name
					from Inventory.InstanceJobs
						inner join Consolidation.ParticipatingDatabaseServers on PDS_Database_MOB_ID = IJB_MOB_ID
					where IJB_Name not in ('syspolicy_purge_history')
				)
			, AllLogins as
				(select PDS_Server_MOB_ID O_OS_MOB_ID, PDS_Database_MOB_ID O_DB_MOB_ID, INL_Name O_Name, INL_PasswordHash O_PasswordHash
					from Inventory.InstanceLogins
						inner join Consolidation.ParticipatingDatabaseServers on PDS_Database_MOB_ID = INL_MOB_ID
					where INL_PasswordHash is not null
						and INL_Name <> 'sa'
							and INL_Name not like '#%#'
							and INL_PasswordHash is not null
				)
			, ConsolidatedMachines as
				(select CLB_HST_ID CM_HST_ID, CLB_ID CM_BlockID, LBL_MOB_ID CM_MOB_ID, PSH_MOB_ID CM_Host_MOB_ID
					from Consolidation.ConsolidationBlocks with (forceseek)
						inner join Consolidation.ConsolidationBlocks_LoadBlocks with (index=IX_ConsolidationBlocks_LoadBlocks_CBL_CLB_ID#CBL_LBL_ID##CLB_DLR_ID) on CLB_ID = CBL_CLB_ID
						inner join Consolidation.LoadBlocks on LBL_ID = CBL_LBL_ID
						inner join Consolidation.PossibleHosts on PSH_ID = CLB_PSH_ID
					where CLB_HST_ID in (select HST_ID from HostTypes)
						and CBL_DLR_ID is null
						and CLB_DLR_ID is null
						and LBL_IDB_ID is null
				)
			, Conflicts as
				(select 'Databases with the same name' ConflictType, a.CM_HST_ID C_HST_ID, a.CM_BlockID C_BlockID, a.CM_Host_MOB_ID C_Host_MOB_ID,
						a.CM_MOB_ID C_OS_MOB_ID_A, oa.O_DB_MOB_ID C_DB_MOB_ID_A, b.CM_MOB_ID C_OS_MOB_ID_B, ob.O_DB_MOB_ID C_DB_MOB_ID_B, oa.O_Name C_ObjectName
					from ConsolidatedMachines a
						inner join AllDB oa on oa.O_OS_MOB_ID = a.CM_MOB_ID
						inner join ConsolidatedMachines b on b.CM_HST_ID = a.CM_HST_ID
																and b.CM_BlockID = a.CM_BlockID
																and b.CM_MOB_ID > a.CM_MOB_ID
						inner join AllDB ob on ob.O_OS_MOB_ID = b.CM_MOB_ID
												and ob.O_Name = oa.O_Name
					union all
					select 'Jobs with the same name' ConflictType, a.CM_HST_ID C_HST_ID, a.CM_BlockID C_BlockID, a.CM_Host_MOB_ID C_Host_MOB_ID, a.CM_MOB_ID C_OS_MOB_ID_A, oa.O_DB_MOB_ID C_DB_MOB_ID_A,
						b.CM_MOB_ID C_OS_MOB_ID_B, ob.O_DB_MOB_ID C_DB_MOB_ID_B, oa.O_Name C_ObjectName
					from ConsolidatedMachines a
						inner join AllJobs oa on oa.O_OS_MOB_ID = a.CM_MOB_ID
						inner join ConsolidatedMachines b on b.CM_HST_ID = a.CM_HST_ID
																and b.CM_BlockID = a.CM_BlockID
																and b.CM_MOB_ID > a.CM_MOB_ID
						inner join AllJobs ob on ob.O_OS_MOB_ID = b.CM_MOB_ID
												and ob.O_Name = oa.O_Name
					union all
					select 'Logins with the same name and a different password' ConflictType, a.CM_HST_ID C_HST_ID, a.CM_BlockID C_BlockID, a.CM_Host_MOB_ID C_Host_MOB_ID,
						a.CM_MOB_ID C_OS_MOB_ID_A, oa.O_DB_MOB_ID C_DB_MOB_ID_A, b.CM_MOB_ID C_OS_MOB_ID_B, ob.O_DB_MOB_ID C_DB_MOB_ID_B, oa.O_Name C_ObjectName
					from ConsolidatedMachines a
						inner join AllLogins oa on oa.O_OS_MOB_ID = a.CM_MOB_ID
						inner join ConsolidatedMachines b on b.CM_HST_ID = a.CM_HST_ID
																and b.CM_BlockID = a.CM_BlockID
																and b.CM_MOB_ID > a.CM_MOB_ID
						inner join AllLogins ob on ob.O_OS_MOB_ID = b.CM_MOB_ID
												and ob.O_Name = oa.O_Name
												and ob.O_PasswordHash <> oa.O_PasswordHash
				)

		select ConflictType, isnull(h.MOB_Name, cast(C_BlockID as varchar(100))) [Destination Server/BlockID], da.MOB_Name SourceInstance1, db.MOB_Name SourceInstance2,
			C_ObjectName ObjectName
		from Conflicts
			inner join Inventory.MonitoredObjects da on da.MOB_ID = C_DB_MOB_ID_A
			inner join Inventory.MonitoredObjects db on db.MOB_ID = C_DB_MOB_ID_B
			left join Inventory.MonitoredObjects h on h.MOB_ID = C_Host_MOB_ID
	)
GO
