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
/****** Object:  StoredProcedure [Consolidation].[usp_AggregateDiskInfo]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Consolidation].[usp_AggregateDiskInfo]
	@ReturnResults bit = 1
as
BEGIN
	set nocount on
	if OBJECT_ID('tempdb..#BlockSizes') is not null
		drop table #BlockSizes
	if object_id('tempdb..#DataGrowth') is not null
		drop table #DataGrowth
	if object_id('tempdb..#DiskUsagePerFileType') is not null
		drop table #DiskUsagePerFileType
	if object_id('tempdb..#DiskSpace') is not null
		drop table #DiskSpace
	if object_id('tempdb..#YearlyGrowth') is not null
		drop table #YearlyGrowth
	if object_id('tempdb..#MissingData') is not null
		drop table #MissingData
	if object_id('tempdb..#Counters') is not null
		drop table #Counters

	create table #Counters
	(
		UCI_PLT_ID			int,
		UCI_SystemID		int,
		UCI_CounterID		int,
		UCI_DivideBy		decimal(18, 5),
		UCI_ConstantValue	decimal(18, 5),
		UCI_InstanceName	varchar(900)
	)

	create table #MissingData(Info varchar(100),
								M_MOB_ID int)

	truncate table Consolidation.DiskInfo
	truncate table Consolidation.BlockSizes
	truncate table Consolidation.SingleDatabaseSizes

	-- For Unified counters groups
	truncate table #Counters
	INSERT INTO #Counters(UCI_PLT_ID, UCI_SystemID, UCI_CounterID, UCI_DivideBy, UCI_ConstantValue)
	select UCI_PLT_ID, UCI_SystemID, UCI_CounterID, ISNULL(UCI_DivideBy, 1) AS UCI_DivideBy, UCI_ConstantValue
	from PerformanceData.UnifiedCounterImplementations
	where UCI_UFT_ID = 5 -- Space Used (MB) -- CounterID = 42
		and exists (select *
			from Management.PlatformTypes
			where PLT_ID = UCI_PLT_ID
				and PLT_PLC_ID = 1)

	select PDS_Server_MOB_ID, DBF_IDB_ID, DBF_ID, rn, CRS_DateTime, SUM(CRS_Value) AS CRS_Value
	into #DataGrowth
	from Inventory.DatabaseFiles
		inner join Consolidation.ParticipatingDatabaseServers on PDS_Database_MOB_ID = DBF_MOB_ID
		inner join PerformanceData.CounterInstances on CIN_Name = DBF_FileName
		-- For counters group
		inner join Inventory.MonitoredObjects o on o.MOB_ID = PDS_Database_MOB_ID
		inner join #Counters on UCI_PLT_ID = MOB_PLT_ID		
		outer apply (select CRS_DateTime, CRS_Value/UCI_DivideBy AS Value,
							row_number() over (order by CRS_DateTime) rn
						from PerformanceData.CounterResults with (forceseek)
						where CRS_MOB_ID = DBF_MOB_ID
								and CRS_SystemID = UCI_SystemID
								and CRS_CounterID = UCI_CounterID
								and CRS_InstanceID = CIN_ID) s
		CROSS APPLY (
						SELECT  ISNULL(UCI_ConstantValue, Value) AS CRS_Value
						WHERE ISNULL(UCI_ConstantValue, Value) IS NOT NULL
					) AS C
	where DBF_DFT_ID = 0
	GROUP BY
		PDS_Server_MOB_ID, DBF_IDB_ID, DBF_ID, rn, CRS_DateTime

	--create clustered index IX_#DataGrowth on #DataGrowth(PDS_Server_MOB_ID, DBF_ID, CRS_Value, rn)
    create clustered index IX_#DataGrowth2 on #DataGrowth(PDS_Server_MOB_ID, DBF_ID, rn, CRS_Value)

	;with GrowthPeriods as
			(select PDS_Server_MOB_ID, DBF_IDB_ID, CRS_DateTime FirstDate, CRS_Value FirstValue, LastDate, LastValue,
					row_number() over (partition by PDS_Server_MOB_ID, DBF_ID order by datediff(minute, CRS_DateTime, LastDate) desc) rn
				from #DataGrowth a
					cross apply (select top 1 CRS_DateTime LastDate, CRS_Value LastValue
									from #DataGrowth b
									where a.PDS_Server_MOB_ID = b.PDS_Server_MOB_ID
										and a.DBF_ID = b.DBF_ID
										and b.rn > a.rn
										and b.CRS_Value >= a.CRS_Value
									order by b.rn desc) b
			)
	select PDS_Server_MOB_ID YGR_MOB_ID, DBF_IDB_ID, cast(sum((LastValue - FirstValue)/(datediff(minute, FirstDate, LastDate)/1440.))*365 as int) YearlyGrowthMB,
		cast(avg(datediff(minute, FirstDate, LastDate)/1440.) as decimal(10, 2)) GrowthRateBasedOnDays
	into #YearlyGrowth
	from GrowthPeriods
		where rn = 1
	group by grouping sets(PDS_Server_MOB_ID, (PDS_Server_MOB_ID, DBF_IDB_ID))

	-- For Unified counters groups
	truncate table #Counters
	INSERT INTO #Counters (UCI_PLT_ID, UCI_SystemID, UCI_CounterID, UCI_DivideBy, UCI_ConstantValue)
	SELECT UCI_PLT_ID, UCI_SystemID, UCI_CounterID, ISNULL(UCI_DivideBy, 1) AS UCI_DivideBy, UCI_ConstantValue
	FROM PerformanceData.UnifiedCounterImplementations
	WHERE UCI_UFT_ID = 4 -- Size (MB), CounterID = 41
		and exists (select *
			from Management.PlatformTypes
			where PLT_ID = UCI_PLT_ID
				and PLT_PLC_ID = 1)

	select PDS_Server_MOB_ID, IDB_ID U_IDB_ID,
		case when IDB_Name = 'tempdb'
						then 1
						else 0
					end IsTempdb, DFT_Name, sum(CRS_Value) SizeMB
	into #DiskUsagePerFileType
	from Inventory.DatabaseFiles
		inner join Inventory.DatabaseFileTypes on DFT_ID = DBF_DFT_ID
		inner join Consolidation.ParticipatingDatabaseServers on PDS_Database_MOB_ID = DBF_MOB_ID
		inner join PerformanceData.CounterInstances on CIN_Name = DBF_FileName
		inner join Inventory.InstanceDatabases on IDB_ID = DBF_IDB_ID
		-- For counters group
		inner join Inventory.MonitoredObjects on MOB_ID = PDS_Database_MOB_ID
		inner join #Counters on UCI_PLT_ID = MOB_PLT_ID		-- Size (MB)
		outer apply (select top 1 CRS_Value/UCI_DivideBy AS Value
						from PerformanceData.CounterResults
						where CRS_MOB_ID = DBF_MOB_ID
								and CRS_SystemID = UCI_SystemID
								and CRS_CounterID = UCI_CounterID
								and CRS_InstanceID = CIN_ID
						order by CRS_DateTime desc) s
		CROSS APPLY (
						SELECT  ISNULL(UCI_ConstantValue, Value) AS CRS_Value
						WHERE ISNULL(UCI_ConstantValue, Value) IS NOT NULL
					) AS C
	group by grouping sets((PDS_Server_MOB_ID, DFT_Name, case when IDB_Name = 'tempdb'
												then 1
												else 0
											end),
							(PDS_Server_MOB_ID, DFT_Name, IDB_ID))

	insert into Consolidation.SingleDatabaseSizes
	select YGR_MOB_ID, DBF_IDB_ID, sum(SizeMB) SizeMB, iif(GrowthRateBasedOnDays < 20, 0, YearlyGrowthMB) YearlyGrowthMB
	from #YearlyGrowth
		inner join #DiskUsagePerFileType on PDS_Server_MOB_ID = YGR_MOB_ID
											and U_IDB_ID = DBF_IDB_ID
	group by YGR_MOB_ID, DBF_IDB_ID, YearlyGrowthMB, GrowthRateBasedOnDays

	select PDS_Server_MOB_ID, CAST(null as int) U_IDB_ID,
			MAX(case when IsTempdb = 0 and DFT_Name = 'Rows' then SizeMB else 0 end) DataFilesMB,
			MAX(case when IsTempdb = 0 and DFT_Name = 'Log' then SizeMB else 0 end) LogFilesMB,
			MAX(case when IsTempdb = 1 then SizeMB else 0 end) TempdbMB
	into #DiskSpace
	from #DiskUsagePerFileType
	where U_IDB_ID is null
	group by PDS_Server_MOB_ID
	union all
	select PDS_Server_MOB_ID, U_IDB_ID,
			MAX(case when DFT_Name = 'Rows' then SizeMB else 0 end) DataFilesMB,
			MAX(case when DFT_Name = 'Log' then SizeMB else 0 end) LogFilesMB,
			CAST(null as bigint) TempdbMB
	from #DiskUsagePerFileType
	where U_IDB_ID is not null
	group by PDS_Server_MOB_ID, U_IDB_ID

	-- For Unified counters groups
	truncate table #Counters
	INSERT INTO #Counters (UCI_PLT_ID, UCI_SystemID, UCI_CounterID, UCI_DivideBy, UCI_ConstantValue)
	SELECT UCI_PLT_ID, UCI_SystemID, UCI_CounterID, ISNULL(UCI_DivideBy, 1) AS UCI_DivideBy, UCI_ConstantValue
	FROM PerformanceData.UnifiedCounterImplementations
	WHERE UCI_UFT_ID = 3 -- Free Space (MB), CounterID = 27
		and exists (select *
			from Management.PlatformTypes
			where PLT_ID = UCI_PLT_ID
				and PLT_PLC_ID = 2)

	insert into Consolidation.DiskInfo
	select MOB_ID DI_MOB_ID, cast(null as int) IDB_ID, cast(sum(DSK_TotalSpaceMB - FreeMB) as bigint) DI_UsedSpace,
		cast(max(DataFilesMB) as bigint) DataFilesMB, cast(max(DataFilesMB) + max(YearlyGrowthMB)*3 as bigint) DataFilesMBIn3Years,
		cast(max(LogFilesMB) as bigint) LogFilesMB, cast(max(TempdbMB) as bigint) TempdbMB, max(YearlyGrowthMB) YearlyGrowthMB,
		sum(DataFreeSpaceMB) DataFreeSpaceMB, sum(DataFreeSpaceMB) - max(YearlyGrowthMB)*3 DataFreeSpaceMBIn3YearsYearly, sum(LogFreeSpaceMB) LogFreeSpaceMB,
		sum(FreeMB) - max(YearlyGrowthMB)*3 TotalFreeSpaceMB, FileTypeSeparation
	from Inventory.MonitoredObjects m
		cross apply (select MOB_ID V_MOB_ID 
						union all
						select CNM_VirtualServer_MOB_ID V_MOB_ID
						from Consolidation.ClusterNodesMapping
						where CNM_ClusterNode_MOB_ID = MOB_ID) c
		inner join Inventory.Disks on DSK_MOB_ID = V_MOB_ID
		-- For counters group
		inner join #Counters on UCI_PLT_ID = MOB_PLT_ID				-- Free Space (MB)
		left join #DiskSpace d on d.PDS_Server_MOB_ID = m.MOB_ID
										and d.U_IDB_ID is null
		outer apply (select iif(GrowthRateBasedOnDays < 20, 0, YearlyGrowthMB) YearlyGrowthMB
						from #YearlyGrowth y
						where YGR_MOB_ID = MOB_ID
								and y.DBF_IDB_ID is null) y
		outer apply (select case when MAX(FileTypes) = 1 then 1 else 0 end FileTypeSeparation
						from (select COUNT(distinct DBF_DFT_ID) FileTypes
								from Consolidation.ParticipatingDatabaseServers
									inner join Inventory.DatabaseFiles on DBF_MOB_ID = PDS_Database_MOB_ID
									inner join Inventory.InstanceDatabases on IDB_ID = DBF_IDB_ID
								where PDS_Server_MOB_ID = m.MOB_ID
									and IDB_Name not in ('master', 'tempdb', 'model', 'msdb', 'distribution')
								group by DBF_DSK_ID) d
					) fs
		outer apply (select top 1 CRS_Value/UCI_DivideBy AS _FreeMB
						from PerformanceData.CounterResults
							inner join PerformanceData.CounterInstances on CIN_ID = CRS_InstanceID
						where CRS_MOB_ID = V_MOB_ID
							and CRS_SystemID = UCI_SystemID
							and CRS_CounterID = UCI_CounterID
							and CIN_Name = DSK_InstanceName
						order by CRS_DateTime desc
					) r
		outer apply (select top 1 CRS_Value/UCI_DivideBy _DataFreeSpaceMB
						from PerformanceData.CounterResults
							inner join PerformanceData.CounterInstances on CIN_ID = CRS_InstanceID
							inner join Inventory.Disks on DSK_InstanceName = CIN_Name
						where CRS_MOB_ID = V_MOB_ID
							and CRS_SystemID = UCI_SystemID
							and CRS_CounterID = UCI_CounterID
							and CIN_Name = DSK_InstanceName
							and FileTypeSeparation = 1
							and exists (select *
											from Inventory.DatabaseFiles
											where DBF_DSK_ID = DSK_ID
												and DBF_DFT_ID = 0
										)
						order by CRS_DateTime desc
					) rd
		outer apply (select top 1 CRS_Value/UCI_DivideBy _LogFreeSpaceMB
						from PerformanceData.CounterResults
							inner join PerformanceData.CounterInstances on CIN_ID = CRS_InstanceID
							inner join Inventory.Disks on DSK_InstanceName = CIN_Name
						where CRS_MOB_ID = V_MOB_ID
							and CRS_SystemID = UCI_SystemID
							and CRS_CounterID = UCI_CounterID
							and CIN_Name = DSK_InstanceName
							and FileTypeSeparation = 1
							and exists (select *
											from Inventory.DatabaseFiles
											where DBF_DSK_ID = DSK_ID
												and DBF_DFT_ID = 0
										)
						order by CRS_DateTime desc
					) rl
		OUTER APPLY (
						SELECT  
							ISNULL(UCI_ConstantValue, _FreeMB) AS FreeMB
						WHERE ISNULL(UCI_ConstantValue, _FreeMB) IS NOT NULL
					) AS C1
		OUTER APPLY (
						SELECT  
							ISNULL(UCI_ConstantValue, _DataFreeSpaceMB) AS DataFreeSpaceMB
						WHERE ISNULL(UCI_ConstantValue, _DataFreeSpaceMB) IS NOT NULL
					) AS C2
		OUTER APPLY (
						SELECT  
							ISNULL(UCI_ConstantValue, _LogFreeSpaceMB) AS LogFreeSpaceMB
						WHERE ISNULL(UCI_ConstantValue, _LogFreeSpaceMB) IS NOT NULL
					) AS C3
	where 
		(FreeMB IS NOT NULL OR DataFreeSpaceMB IS NOT NULL OR LogFreeSpaceMB IS NOT NULL)
		and exists (select * from Consolidation.ParticipatingDatabaseServers p where p.PDS_Server_MOB_ID = m.MOB_ID)
		and (exists (select *
					from Inventory.DatabaseFiles
					where DBF_DSK_ID = DSK_ID)
				or exists (select *
							from Inventory.BackupLocations
							where BKL_DSK_ID = DSK_ID)
				or m.MOB_ID in (select PDS_Server_MOB_ID
									from Consolidation.ParticipatingDatabaseServers
									where PDS_Database_MOB_ID is null)
				or m.MOB_ID in (select PDS_Server_MOB_ID
									from Consolidation.ParticipatingDatabaseServers
										inner join Inventory.MonitoredObjects on PDS_Database_MOB_ID  = MOB_ID
																				and MOB_PLT_ID <> 1)
				or not exists (select *
									from Consolidation.ParticipatingDatabaseServers
										inner join Inventory.DatabaseFiles on DBF_MOB_ID = PDS_Database_MOB_ID
									where DBF_DSK_ID is not null
										and PDS_Server_MOB_ID = m.MOB_ID)
			)
	group by MOB_ID, FileTypeSeparation
	union all
	select MOB_ID DI_MOB_ID, IDB_ID, cast(null as bigint) UsedSpace,
		cast(DataFilesMB as bigint) DataFilesMB, cast(DataFilesMB + YearlyGrowthMB*3 as bigint) DataFilesMBIn3Years,
		cast(LogFilesMB as bigint) LogFilesMB, cast(null as bigint) TempdbMB, YearlyGrowthMB YearlyGrowthMB,
		cast(null as bigint) DataFreeSpaceMB, cast(null as bigint) DataFreeSpaceMBIn3YearsYearly, cast(null as bigint) LogFreeSpaceMB,
		cast(null as bigint) TotalFreeSpaceMB, cast(null as bit) FileTypeSeparation
	from Inventory.MonitoredObjects m
		inner join Consolidation.BreakByDatabase on BBD_Server_MOB_ID = m.MOB_ID
		inner join Inventory.InstanceDatabases on IDB_MOB_ID = BBD_Database_MOB_ID
		inner join #DiskSpace d on d.PDS_Server_MOB_ID = m.MOB_ID
										and d.U_IDB_ID = IDB_ID
		inner join #YearlyGrowth y on YGR_MOB_ID = MOB_ID
										and y.DBF_IDB_ID = IDB_ID
	where exists (select * from Consolidation.ParticipatingDatabaseServers p where p.PDS_Server_MOB_ID = m.MOB_ID)


	-- For Unified counters groups
	truncate table #Counters
	INSERT INTO #Counters (UCI_PLT_ID, UCI_SystemID, UCI_CounterID, UCI_DivideBy, UCI_ConstantValue)
	SELECT UCI_PLT_ID, UCI_SystemID, UCI_CounterID, ISNULL(UCI_DivideBy, 1) AS UCI_DivideBy, UCI_ConstantValue
	FROM PerformanceData.UnifiedCounterImplementations
	WHERE UCI_UFT_ID = 11 -- Avg. Block Size (bytes), CounterID = 19
		and exists (select *
			from Management.PlatformTypes
			where PLT_ID = UCI_PLT_ID
				and PLT_PLC_ID = 2)

	select MOB_ID BS_MOB_ID, DiskName, AvgBlockSize, MOB_PLT_ID	AS BS_MOB_PLT_ID, IsConstantUsed
	into #BlockSizes
	from Inventory.MonitoredObjects m
		-- For counters group
		inner join #Counters on UCI_PLT_ID = MOB_PLT_ID						-- Avg. Block Size (bytes)
		outer apply (select CIN_Name DiskName, avg(CRS_Value)/UCI_DivideBy Value
						from PerformanceData.CounterResults
							inner join PerformanceData.CounterInstances on CIN_ID = CRS_InstanceID
							cross apply (select MOB_ID V_MOB_ID 
											union all
											select CNM_VirtualServer_MOB_ID V_MOB_ID
											from Consolidation.ClusterNodesMapping
											where CNM_ClusterNode_MOB_ID = MOB_ID) c
						where CRS_MOB_ID = V_MOB_ID
							and CRS_SystemID = UCI_SystemID
							and CRS_CounterID = UCI_CounterID
							and CRS_Value > 0
							and CIN_Name not like '_Total%'
						group by CIN_Name
					) r
		CROSS APPLY (
						SELECT  ISNULL(UCI_ConstantValue, Value) AS AvgBlockSize,
							iif(UCI_ConstantValue is not null, 1, 0) IsConstantUsed
						WHERE ISNULL(UCI_ConstantValue, Value) IS NOT NULL
					) AS C
	where exists (select * from Consolidation.ParticipatingDatabaseServers where PDS_Server_MOB_ID = m.MOB_ID)

	-- For Unified counters groups
	truncate table #Counters
	INSERT INTO #Counters (UCI_PLT_ID, UCI_SystemID, UCI_CounterID, UCI_DivideBy, UCI_ConstantValue)
	SELECT UCI_PLT_ID, UCI_SystemID, UCI_CounterID, ISNULL(UCI_DivideBy, 1) AS UCI_DivideBy, UCI_ConstantValue
	FROM PerformanceData.UnifiedCounterImplementations
	WHERE UCI_UFT_ID = 8 -- Transfers/sec, CounterID = 22
		and exists (select *
			from Management.PlatformTypes
			where PLT_ID = UCI_PLT_ID
				and PLT_PLC_ID = 2)

	;with BlockSizes as
			(select BS_MOB_ID, DiskName,
					case when ABS(AvgBlockSize - 8*1024) < ABS(AvgBlockSize - 64*1024)
						then 8
						else 64
					end UsedBlockSize,
					Transfers
				from #BlockSizes
					cross apply (	select 
										avg(CRS_Value)/UCI_DivideBy Value,
										UCI_ConstantValue
									from (select BS_MOB_ID V_MOB_ID 
											union all
											select CNM_VirtualServer_MOB_ID V_MOB_ID
											from Consolidation.ClusterNodesMapping
											where CNM_ClusterNode_MOB_ID = BS_MOB_ID) c
										inner join PerformanceData.CounterResults on CRS_MOB_ID = V_MOB_ID
										inner join PerformanceData.CounterInstances on CIN_ID = CRS_InstanceID
										-- For counters group
										inner join #Counters on UCI_PLT_ID = BS_MOB_PLT_ID		-- Transfers/sec
										and CRS_SystemID = UCI_SystemID
										and CRS_CounterID = UCI_CounterID
										and CRS_Value > 0
										and CIN_Name = DiskName
									group by 
										CIN_Name, UCI_DivideBy, UCI_ConstantValue
								) r
					CROSS APPLY (
									SELECT  ISNULL(UCI_ConstantValue, Value) AS Transfers
									WHERE ISNULL(UCI_ConstantValue, Value) IS NOT NULL
								) AS C
			)
	insert into Consolidation.BlockSizes
	select BS_MOB_ID,
		case when SUM(case when UsedBlockSize = 8 then Transfers else 0 end) > SUM(case when UsedBlockSize = 64 then Transfers else 0 end)
			then 8
			else 64
		end DominantBlockSize
	from BlockSizes
	group by BS_MOB_ID

	insert into Consolidation.BlockSizes
	select BS_MOB_ID, AvgBlockSize
	from #BlockSizes
	where IsConstantUsed = 1
		and not exists (select *
							from Consolidation.BlockSizes
							where BSI_MOB_ID = BS_MOB_ID)

	insert into #MissingData
	select 'Missing Disk data' Info, SGR_MOB_ID
	from Consolidation.ServerGrouping
	except
	select 'Missing Disk data' Info, DSI_MOB_ID
	from Consolidation.DiskInfo

	insert into #MissingData
	select 'Missing Block Size data' Info, SGR_MOB_ID
	from Consolidation.ServerGrouping
	except
	select 'Missing Block Size data' Info, BSI_MOB_ID
	from Consolidation.BlockSizes

	if @ReturnResults = 1
		if exists (select * from #MissingData)
			select Info, MOB_ID, MOB_Name
			from #MissingData
				inner join Inventory.MonitoredObjects on MOB_ID = M_MOB_ID
		else
			select 'No missing data' Info
END
GO
