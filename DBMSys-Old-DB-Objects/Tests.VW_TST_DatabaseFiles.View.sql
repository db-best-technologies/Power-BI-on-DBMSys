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
/****** Object:  View [Tests].[VW_TST_DatabaseFiles]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_DatabaseFiles]
as
select top 0 CAST(null as nvarchar(128)) DatabaseName,
			CAST(null as int) [file_id],
			CAST(null as nvarchar(128)) [FileName],
			CAST(null as nvarchar(60)) type_desc,
			CAST(null as nvarchar(260)) physical_name,
			CAST(null as nvarchar(60)) state_desc,
			CAST(null as int) SizeMB,
			CAST(null as int) SpaceUsedMB,
			CAST(null as int) UsedPercentage,
			CAST(null as int) MaxSizeMB,
			CAST(null as int) GrowthMB,
			CAST(null as int) GrowthPercent,
			CAST(null as bit) is_read_only,
			CAST(null as nvarchar(128)) FileGroupName,
			CAST(null as bit) CurrentSecondary,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_DatabaseFiles]    Script Date: 6/8/2020 1:15:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_DatabaseFiles] on [Tests].[VW_TST_DatabaseFiles]
	instead of insert
as
set nocount on

declare @MOB_ID int,
		@StartDate datetime2(3),
		@CounterDate datetime2(3),
		@OS_MOB_ID int

SELECT 
		* 
INTO	#Inserted 
FROM	inserted

create clustered index #IDX_#Inserted###FileName ON #Inserted([FileName])
create index #IDX_#Inserted###DatabaseName ON #Inserted(DatabaseName,FileGroupName,type_desc,state_desc,physical_name)

select top 1 @MOB_ID = TRH_MOB_ID,
				@StartDate = TRH_StartDate,
				@CounterDate = TRH_StartDate,
				@OS_MOB_ID = WIN.MOB_ID
from #Inserted
	inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID
	inner join Inventory.MonitoredObjects DB on TRH_MOB_ID = DB.MOB_ID
	inner join Inventory.DatabaseInstanceDetails on DID_DFO_ID = DB.MOB_Entity_ID
	left join (Inventory.OSServers JOIN Inventory.MonitoredObjects WIN ON OSS_MOB_ID = WIN.MOB_ID) on WIN.MOB_PLT_ID = 2
												and DID_OSS_ID = OSS_ID--WIN.MOB_Entity_ID

insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Instance, DatabaseName, Value, [Status], Metadata_TRH_ID, Metadata_ClientID)
select 'Database Files' Category, GNC_CounterName CounterName, physical_name Instance, DatabaseName,
		case GNC_CounterName
			when 'Size (MB)' then SizeMB
			when 'Space Used (MB)' then SpaceUsedMB
			when 'Used Percentage' then isnull(UsedPercentage, case when SpaceUsedMB = 0
																		then 0
																	when SizeMB = 0
																		then 100
																	else SpaceUsedMB*100/SizeMB
																end)
		end Value, null [Status], Metadata_TRH_ID, Metadata_ClientID
from #Inserted
	cross join (select GNC_CounterName, GNC_CSY_ID, GNC_ID
				from PerformanceData.GeneralCounters
				where GNC_CategoryName = 'Database Files') g
where CurrentSecondary is null

merge Inventory.DatabaseFileGroups d
	using (select distinct IDB_ID, FileGroupName, Metadata_ClientID, Metadata_TRH_ID
			from #Inserted
				left join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
																and DatabaseName = IDB_Name
			where FileGroupName is not null) s
		on DFG_MOB_ID = @MOB_ID
			and DFG_IDB_ID = IDB_ID
			and DFG_Name = FileGroupName
	when not matched then insert(DFG_ClientID, DFG_MOB_ID, DFG_IDB_ID, DFG_Name, DFG_FGT_ID, DFG_InsertDate, DFG_LastSeenDate, DFG_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IDB_ID, FileGroupName, 1, @StartDate, @StartDate, Metadata_TRH_ID);

merge Inventory.DatabaseFiles d
	using (select Metadata_ClientID, IDB_ID, DFG_ID, [file_id], [FileName], physical_name, DSK_ID, DFT_ID, DFS_ID, MaxSizeMB, GrowthMB,
					GrowthPercent, is_read_only, Metadata_TRH_ID, CurrentSecondary
			from #Inserted
				left join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
															and DatabaseName = IDB_Name
				left join Inventory.DatabaseFileGroups on DFG_MOB_ID = @MOB_ID
															and DFG_IDB_ID = IDB_ID
															and DFG_Name = FileGroupName
				left join Inventory.DatabaseFileTypes on type_desc = upper(DFT_Name)
				left join Inventory.DatabaseFileStates on state_desc = DFS_Name
				outer apply (select top 1 DSK_ID
								from Inventory.Disks
								where DSK_MOB_ID = @OS_MOB_ID
									and physical_name like DSK_Path + '%'
								order by len(DSK_Path) desc) k) s
				on DBF_MOB_ID = @MOB_ID
					and (DBF_IDB_ID = IDB_ID
							or (DBF_IDB_ID is null
								and IDB_ID is null)
						)
					and DBF_Name = [FileName]
	when matched then update set
								DBF_DFG_ID = iif(CurrentSecondary = 1, DBF_DFG_ID, DFG_ID),
								DBF_FileID = [file_id],
								DBF_FileName = physical_name,
								DBF_DSK_ID = DSK_ID,
								DBF_DFT_ID = DFT_ID,
								DBF_DFS_ID = DFS_ID,
								DBF_MaxSizeMB = MaxSizeMB,
								DBF_GrowthMB = GrowthMB,
								DBF_GrowthPercent = GrowthPercent,
								DBF_IsReadOnly = is_read_only,
								DBF_LastSeenDate = @StartDate,
								DBF_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(DBF_ClientID, DBF_MOB_ID, DBF_IDB_ID, DBF_DFG_ID, DBF_FileID, DBF_Name, DBF_FileName, DBF_DSK_ID,
									DBF_DFT_ID, DBF_DFS_ID, DBF_MaxSizeMB, DBF_GrowthMB, DBF_GrowthPercent, DBF_IsReadOnly,
									DBF_InsertDate, DBF_LastSeenDate, DBF_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IDB_ID, DFG_ID, [file_id], [FileName], physical_name, DSK_ID,
									DFT_ID, DFS_ID, MaxSizeMB, GrowthMB, GrowthPercent, is_read_only, @StartDate, @StartDate, Metadata_TRH_ID);
GO
