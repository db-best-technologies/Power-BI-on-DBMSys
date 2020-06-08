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
/****** Object:  StoredProcedure [Consolidation].[usp_CalculateWorkloads]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Consolidation].[usp_CalculateWorkloads]
--declare
	@ReturnResults bit = 1
as
BEGIN
	set nocount on
	if OBJECT_ID('tempdb..#NetUsage') is not null
		drop table #NetUsage
	if OBJECT_ID('tempdb..#FileReadsWrites') is not null
		drop table #FileReadsWrites
	if OBJECT_ID('tempdb..#FileReadsWritesMB') is not null
		drop table #FileReadsWritesMB
	if OBJECT_ID('tempdb..#DiskReadWriteOperations') is not null
		drop table #DiskReadWriteOperations
	if OBJECT_ID('tempdb..#DiskReadWriteMBps') is not null
		drop table #DiskReadWriteMBps
	if object_id('tempdb..#Counters') is not null
		drop table #Counters
	if object_id('tempdb..#MachinesAndCounters') is not null
		drop table #MachinesAndCounters
	if object_id('tempdb..#MissingData') is not null
		drop table #MissingData
	if object_id('tempdb..#CPUInfo') is not null
		drop table #CPUInfo

	create table #MissingData(Info varchar(100),
								M_MOB_ID int)

	create table #Counters
	(
		UCI_PLT_ID			int,
		IsRead				bit,
		UCI_SystemID		int,
		UCI_CounterID		int,
		UCI_DivideBy		decimal(18, 5),
		UCI_ConstantValue	decimal(18, 5),
		UCI_InstanceName	varchar(900) collate database_default
	)

	create table #MachinesAndCounters
	(
		OS_MOB_ID			int not null,
		MOB_ID				int not null,
		IsRead				bit null,
		SystemID			int not null,
		CounterID			int not null,
		InstanceID			int null,
		IDB_ID				int null,
		DBF_DFT_ID			int null,
		IsTempDB			bit null,
		IsSystemDB			bit null,
		UCI_DivideBy		decimal(18, 5) null,
		UCI_ConstantValue	decimal(18, 5) null,
		Startdate			datetime2(3) not null,
		EndDate				datetime2(3) not null,
	)

	truncate table Consolidation.CPUInfo
	truncate table Consolidation.MemoryInfo
	truncate table Consolidation.NetworkInfo
	truncate table Consolidation.DiskIOInfo
	truncate table Consolidation.DiskThroughputInfo
	truncate table Consolidation.SingleDatabaseTransactions

	declare 
		@IsIOBySQL bit,
		@Percentile decimal(10, 2),
		@ConsiderClusterirtualServerAsHost bit,
		@FromDay int,
		@ToDay int,
		@FromHour int,
		@ToHour int

	select @IsIOBySQL = CAST(SET_Value as bit)
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Is SQL IO used'

	select @Percentile = CAST(SET_Value as decimal(10, 2))
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Counter Percentile'

	select @ConsiderClusterirtualServerAsHost = CAST(SET_Value as bit)
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Consider Cluster Virtual Server As Host'

	select @FromDay = CAST(SET_Value as int)
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Calculate Workload From Week Day'

	select @ToDay = CAST(SET_Value as int)
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Calculate Workload To Week Day'

	select @FromHour = CAST(SET_Value as int)
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Calculate Workload From Day Hour'

	select @ToHour = CAST(SET_Value as int)
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Calculate Workload To Day Hour'

	if @ConsiderClusterirtualServerAsHost = 1
	begin
		--CPU from SQL 1/2
		truncate table #Counters
		INSERT INTO #Counters(UCI_PLT_ID, IsRead, UCI_SystemID, UCI_CounterID, UCI_DivideBy, UCI_ConstantValue)
		SELECT
			UCI_PLT_ID,
			UFT_IsRead AS IsRead,
			UCI_SystemID AS System_ID,
			UCI_CounterID AS Counter_ID,
			ISNULL(UCI_DivideBy, 1),
			UCI_ConstantValue
		FROM
			PerformanceData.UnifiedCounterImplementations
			INNER JOIN PerformanceData.UnifiedCounterTypes
			ON UCI_UFT_ID = UFT_ID
		WHERE
			UCI_UFT_ID = 1 -- % Processor Time, Counter_ID = 500
			and exists (select *
						from Management.PlatformTypes
						where PLT_ID = UCI_PLT_ID
							and PLT_PLC_ID = 1)

							
		--CPU from SQL 2/2
		;with ServerList as
				(	SELECT 
						PDS_Server_MOB_ID, d.MOB_PLT_ID
					from Consolidation.ParticipatingDatabaseServers
						inner join Inventory.MonitoredObjects s ON s.MOB_ID = PDS_Server_MOB_ID
						inner join Inventory.OSServers ON (OSS_MOB_ID = s.MOB_ID)
						inner join Inventory.MonitoredObjects d on d.MOB_ID = PDS_Database_MOB_ID
					WHERE
						OSS_IsVirtualServer = 1
				)
		insert into Consolidation.CPUInfo
		select CPF_MOB_ID CPU_MOB_ID, sum(CPF_CPUCount) CPUCount, sum(CPF_CPUFactor*CPF_SingleCPUScore) CPUStrength, sum(CPF_CPUFactor*CPF_SingleCPUScore)*sum(isnull(CPUUsage/100,1)) CPUUsage
		from ServerList
			inner join Consolidation.CPUFactoring on CPF_MOB_ID = PDS_Server_MOB_ID
			INNER JOIN #Counters AS C
				ON MOB_PLT_ID = UCI_PLT_ID
			cross apply (select top 1 percentile_disc(@Percentile/100) within group (order by CRS_Value) over(partition by CRS_MOB_ID) CPUUsage
							from Consolidation.ParticipatingServersPrimaryHistory
								inner join PerformanceData.CounterResults on CRS_MOB_ID = PPH_Primary_Database_MOB_ID
								left join PerformanceData.CounterInstances on CIN_ID = CRS_InstanceID
							where PPH_Server_MOB_ID = PDS_Server_MOB_ID
								and CRS_SystemID = UCI_SystemID
								and CRS_CounterID = UCI_CounterID
								and (datepart(weekday, CRS_DateTime) between @FromDay and @ToDay or @FromDay is null or @ToDay is null)
								and (datepart(hour, CRS_DateTime) between @FromHour and @ToHour or @FromHour is null or @ToHour is null)
								and CRS_DateTime >= PPH_StartDate
								and CRS_DateTime < PPH_EndDate
						) r
		where exists (select * from ServerList where PDS_Server_MOB_ID = CPF_MOB_ID)
				--and CPF_MOB_ID = 140
		group by CPF_MOB_ID

		--Memory from SQL 1/2
		truncate table #Counters
		INSERT INTO #Counters(UCI_PLT_ID, IsRead, UCI_SystemID, UCI_CounterID, UCI_DivideBy, UCI_ConstantValue)
		SELECT
			UCI_PLT_ID,
			UFT_IsRead AS IsRead,
			UCI_SystemID AS System_ID,
			UCI_CounterID AS Counter_ID,
			ISNULL(UCI_DivideBy, 1),
			UCI_ConstantValue
		FROM
			PerformanceData.UnifiedCounterImplementations
			INNER JOIN PerformanceData.UnifiedCounterTypes
			ON UCI_UFT_ID = UFT_ID
		WHERE
			UCI_UFT_ID = 2
			and exists (select *
						from Management.PlatformTypes
						where PLT_ID = UCI_PLT_ID
							and PLT_PLC_ID = 1)
	
		--Memory from SQL 2/2
		;with ServerList as
				(	SELECT 
						PDS_Server_MOB_ID, d.MOB_PLT_ID
					from Consolidation.ParticipatingDatabaseServers
						inner join Inventory.MonitoredObjects s ON s.MOB_ID = PDS_Server_MOB_ID
						inner join Inventory.OSServers ON (OSS_MOB_ID = s.MOB_ID)
						inner join Inventory.MonitoredObjects d on d.MOB_ID = PDS_Database_MOB_ID
					WHERE
						OSS_IsVirtualServer = 1
				)
		insert into Consolidation.MemoryInfo
		select PDS_Server_MOB_ID MEM_MOB_ID, sum(MaxKB/1024) TotalMemoryMB, sum(UsedKB/1024) MemoryUsage
		from ServerList
			INNER JOIN #Counters AS C
				ON MOB_PLT_ID = UCI_PLT_ID		
			cross apply (select top 1 percentile_disc(@Percentile/100) within group (order by CRS_Value desc) over(partition by CRS_MOB_ID)  UsedKB,
								max(CRS_Value) over(partition by CRS_MOB_ID)  MaxKB
							from Consolidation.ParticipatingServersPrimaryHistory
								inner join PerformanceData.CounterResults on CRS_MOB_ID = PPH_Primary_Database_MOB_ID
							where PPH_Server_MOB_ID = PDS_Server_MOB_ID
								and CRS_SystemID = UCI_SystemID
								and CRS_CounterID = UCI_CounterID
								and (datepart(weekday, CRS_DateTime) between @FromDay and @ToDay or @FromDay is null or @ToDay is null)
								and (datepart(hour, CRS_DateTime) between @FromHour and @ToHour or @FromHour is null or @ToHour is null)
								and CRS_DateTime >= PPH_StartDate
								and CRS_DateTime < PPH_EndDate
						) r
		group by PDS_Server_MOB_ID
	end

	--CPU from Windows 1/3
	truncate table #Counters
	INSERT INTO #Counters(UCI_PLT_ID, IsRead, UCI_SystemID, UCI_CounterID, UCI_DivideBy, UCI_ConstantValue, UCI_InstanceName)
	SELECT
		UCI_PLT_ID,
		UFT_IsRead AS IsRead,
		UCI_SystemID AS System_ID,
		UCI_CounterID AS Counter_ID,
		ISNULL(UCI_DivideBy, 1),
		UCI_ConstantValue,
		CASE
			WHEN UCI_SystemID = 4 AND UCI_CounterID = 1 THEN '_Total' ELSE NULL	-- Hardcode. Maybe the field in PerformanceData.UnifiedCounterImplementations table will be better.
		END AS UCI_InstanceName
	FROM
		PerformanceData.UnifiedCounterImplementations
		INNER JOIN PerformanceData.UnifiedCounterTypes
		ON UCI_UFT_ID = UFT_ID
	WHERE
		UCI_UFT_ID = 1 -- % Processor Time, Counter_ID = 1
		and exists (select *
				from Management.PlatformTypes
				where PLT_ID = UCI_PLT_ID
					and PLT_PLC_ID = 2)

	--CPU from Windows 2/3
	insert into #MachinesAndCounters(OS_MOB_ID, MOB_ID, SystemID, CounterID, InstanceID, UCI_DivideBy, UCI_ConstantValue, StartDate, EndDate)
	select MOB_ID, PPH_Primary_Server_MOB_ID, UCI_SystemID, UCI_CounterID, CIN_ID, UCI_DivideBy, UCI_ConstantValue, PPH_StartDate, PPH_EndDate
	from Inventory.MonitoredObjects
		inner join #Counters on UCI_PLT_ID = MOB_PLT_ID
		inner join Consolidation.ParticipatingServersPrimaryHistory on PPH_Server_MOB_ID = MOB_ID
		left join PerformanceData.CounterInstances on CIN_Name = UCI_InstanceName

	--CPU from Windows 3/3
	insert into Consolidation.CPUInfo
	select distinct CPF_MOB_ID CPU_MOB_ID, sum(CPF_CPUCount) CPUCount, sum(CPF_CPUFactor*CPF_SingleCPUScore) CPUStrength, sum(CPF_CPUFactor*CPF_SingleCPUScore)*CPUUsage/100 CPUUsage
	from Consolidation.CPUFactoring
		-- For counters group
		cross apply (select top 1 percentile_disc(@Percentile/100) within group (order by CRS_Value) over() CPUUsage
						from (select sum(CRS_Value)/count(distinct CIN_ID) CRS_Value
									from #MachinesAndCounters
										inner join PerformanceData.CounterResults on CRS_MOB_ID = OS_MOB_ID
										left join PerformanceData.CounterInstances on CIN_ID = CRS_InstanceID
									where OS_MOB_ID = CPF_MOB_ID
										and CRS_SystemID = SystemID
										and CRS_CounterID = CounterID
										and (CIN_ID = InstanceID
												or InstanceID is null)
										and (datepart(weekday, CRS_DateTime) between @FromDay and @ToDay or @FromDay is null or @ToDay is null)
										and (datepart(hour, CRS_DateTime) between @FromHour and @ToHour or @FromHour is null or @ToHour is null)
										and CRS_DateTime >= StartDate
										and CRS_DateTime < EndDate
								group by CRS_DateTime
								having sum(CRS_Value)/count(distinct CIN_ID) <= 100
							) p
					) r
	where exists (select * from Consolidation.ParticipatingDatabaseServers where PDS_Server_MOB_ID = CPF_MOB_ID)
		and not exists (select * from Consolidation.CPUInfo where CPI_MOB_ID = CPF_MOB_ID)
	group by CPF_MOB_ID, CPUUsage

	--Memory from Windows 1/2
	truncate table #Counters
	INSERT INTO #Counters(UCI_PLT_ID, IsRead, UCI_SystemID, UCI_CounterID, UCI_DivideBy, UCI_ConstantValue)
	SELECT
		UCI_PLT_ID,
		UFT_IsRead AS IsRead,
		UCI_SystemID AS System_ID,
		UCI_CounterID AS Counter_ID,
		ISNULL(UCI_DivideBy, 1),
		UCI_ConstantValue
	FROM
		PerformanceData.UnifiedCounterImplementations
		INNER JOIN PerformanceData.UnifiedCounterTypes
		ON UCI_UFT_ID = UFT_ID
	WHERE
		UCI_UFT_ID = 2 -- Available Mbytes, Counter_ID = 12
		and exists (select *
			from Management.PlatformTypes
			where PLT_ID = UCI_PLT_ID
				and PLT_PLC_ID = 2)

	--Memory from Windows 2/2
	insert into Consolidation.MemoryInfo
	select distinct MOB_ID MEM_MOB_ID, OSS_TotalPhysicalMemoryMB TotalMemoryMB, OSS_TotalPhysicalMemoryMB - FreeMB MemoryUsage
	from Inventory.MonitoredObjects m
		-- For counters group
		inner join #Counters on UCI_PLT_ID = MOB_PLT_ID				-- Available Mbytes
		inner join Inventory.OSServers on (OSS_MOB_ID = MOB_ID)
											and MOB_PLT_ID = UCI_PLT_ID
		outer apply (select top 1 percentile_disc(@Percentile/100) within group (order by CRS_Value desc) over(partition by CRS_MOB_ID) FreeMB
						from Consolidation.ParticipatingServersPrimaryHistory
								inner join PerformanceData.CounterResults on CRS_MOB_ID = PPH_Primary_Server_MOB_ID
						where PPH_Server_MOB_ID = MOB_ID
							and CRS_SystemID = UCI_SystemID
							and CRS_CounterID = UCI_CounterID
							and (datepart(weekday, CRS_DateTime) between @FromDay and @ToDay or @FromDay is null or @ToDay is null)
							and (datepart(hour, CRS_DateTime) between @FromHour and @ToHour or @FromHour is null or @ToHour is null)
							and CRS_DateTime >= PPH_StartDate
							and CRS_DateTime < PPH_EndDate
					) r
	where exists (select * from Consolidation.ParticipatingDatabaseServers where PDS_Server_MOB_ID = m.MOB_ID)
		and not exists (select * from Consolidation.MemoryInfo where MMI_MOB_ID = MOB_ID)

	--Memory fix bad counter data
	update Consolidation.MemoryInfo
	set MMI_MemoryUsage = MMI_TotalMemoryMB
	where MMI_MemoryUsage < 0

	--Network from Windows 1/3
	truncate table #Counters
	truncate table #MachinesAndCounters
	INSERT INTO #Counters(UCI_PLT_ID, IsRead, UCI_SystemID, UCI_CounterID, UCI_DivideBy, UCI_ConstantValue)
	SELECT
		UCI_PLT_ID,
		UFT_IsRead AS IsRead,
		UCI_SystemID AS System_ID,
		UCI_CounterID AS Counter_ID,
		ISNULL(UCI_DivideBy, 1),
		UCI_ConstantValue
	FROM
		PerformanceData.UnifiedCounterImplementations
		INNER JOIN PerformanceData.UnifiedCounterTypes
		ON UCI_UFT_ID = UFT_ID
	WHERE
		UCI_UFT_ID IN (12, 13)	-- Counter_ID in 85, 86, Counter Type in ('Bytes Received/sec', 'Bytes Sent/sec')
			and exists (select *
				from Management.PlatformTypes
				where PLT_ID = UCI_PLT_ID
					and PLT_PLC_ID = 2)

	;with Machines as
			(select distinct MOB_ID, MOB_PLT_ID
			from Consolidation.ParticipatingDatabaseServers
				inner join Inventory.MonitoredObjects on MOB_ID = PDS_Server_MOB_ID
			)
	insert into #MachinesAndCounters(OS_MOB_ID, MOB_ID, IsRead, SystemID, CounterID, UCI_DivideBy, UCI_ConstantValue, StartDate, EndDate)
	select MOB_ID, PPH_Primary_Server_MOB_ID, IsRead, UCI_SystemID, UCI_CounterID, UCI_DivideBy, UCI_ConstantValue, PPH_StartDate, PPH_EndDate
	from Machines 
		inner join #Counters on UCI_PLT_ID = MOB_PLT_ID
		inner join Consolidation.ParticipatingServersPrimaryHistory on PPH_Server_MOB_ID = MOB_ID

	--Network from Windows 2/3
	select MOB_ID Net_MOB_ID,
		sum(isnull(Upload, 0)) UploadBytes,
		sum(isnull(Download, 0)) DownloadBytes
	into #NetUsage
	from (select 
				OS_MOB_ID MOB_ID, CRS_DateTime, 
				iif(IsRead = 1, ISNULL(UCI_ConstantValue, CRS_Value/UCI_DivideBy), 0) AS Download, 
				iif(IsRead = 0, ISNULL(UCI_ConstantValue, CRS_Value/UCI_DivideBy), 0) AS Upload
			from #MachinesAndCounters
				inner join PerformanceData.CounterResults on CRS_MOB_ID = MOB_ID
															and CRS_SystemID = SystemID
															and CRS_CounterID = CounterID
															and (datepart(weekday, CRS_DateTime) between @FromDay and @ToDay or @FromDay is null or @ToDay is null)
															and (datepart(hour, CRS_DateTime) between @FromHour and @ToHour or @FromHour is null or @ToHour is null)
															and CRS_DateTime >= StartDate
															and CRS_DateTime < EndDate

		) r
	group by MOB_ID, CRS_DateTime

	--Network from Windows 3/3
	insert into Consolidation.NetworkInfo
	select distinct MOB_ID NET_MOB_ID, isnull(NetworkSpeedMbit, 10000) NetworkSpeedMbit,
		cast(UploadBytes/1024/1024.*8 as decimal(15, 6)) NetworkUsageUploadMbit,
		cast(DownloadBytes/1024/1024.*8 as decimal(15, 6)) NetworkUsageDownloadMbit,
		OutboundUsageAverage*60*60*24*31/1024/1024 AvgMonthlyNetworkOutboundIOMB,
		InboundUsageAverage*60*60*24*31/1024/1024 AvgMonthlyNetworkInboundIOMB
	from Inventory.MonitoredObjects m
		cross apply (select ceiling(SUM(cast(NIN_LinkSpeed/10000. as decimal(18, 5)))) NetworkSpeedMbit
						from Inventory.NetworkInterfaces
							inner join Inventory.IPAddresses on IPA_NIN_ID = NIN_ID
						where NIN_MOB_ID = MOB_ID
							and IPA_DefaultGateway  is not null) n
		cross apply (select top 1 percentile_disc(@Percentile/100) within group (order by UploadBytes) over() UploadBytes,
							percentile_disc(@Percentile/100) within group (order by DownloadBytes) over() DownloadBytes,
							avg(cast(UploadBytes as bigint)) over() OutboundUsageAverage,
							avg(cast(DownloadBytes as bigint)) over() InboundUsageAverage
						from #NetUsage
						where NET_MOB_ID = MOB_ID
					) r

	--Single-DB-load calculation 1/1
	-- There isn't CounterID = 28 in the PerformanceData.UnifiedCounterImplementations table. It's missed for now.
	insert into Consolidation.SingleDatabaseTransactions
	select distinct o.MOB_ID, IDB_ID, Transactions, cast(Transactions*100/(sum(Transactions) over(partition by o.MOB_Name) + 1) as decimal(10, 2)) TranSecPercentagte
	from Consolidation.ParticipatingDatabaseServers
		inner join Inventory.MonitoredObjects o on o.MOB_ID = PDS_Server_MOB_ID
		inner join Inventory.InstanceDatabases on IDB_MOB_ID = PDS_Database_MOB_ID
		inner join PerformanceData.CounterInstances on CIN_Name = IDB_Name
		outer apply (select top 1 percentile_disc(@Percentile/100) within group (order by CRS_Value) over(partition by CRS_MOB_ID) TransSec
						from PerformanceData.CounterResults
						where CRS_MOB_ID = PDS_Database_MOB_ID
							and CRS_SystemID = 1
							and CRS_CounterID = 28
							and CRS_InstanceID = CIN_ID
							and (datepart(weekday, CRS_DateTime) between @FromDay and @ToDay or @FromDay is null or @ToDay is null)
							and (datepart(hour, CRS_DateTime) between @FromHour and @ToHour or @FromHour is null or @ToHour is null)
					) p
		cross apply (select isnull(TransSec, 0) Transactions) p1
	where exists (select *
					from Consolidation.ServerPossibleHostTypes
					where SHT_HST_ID = 10
						and SHT_MOB_ID = PDS_Server_MOB_ID)

	if @IsIOBySQL = 1
	begin
		--IOPS from SQL 1/4
		truncate table #Counters
		truncate table #MachinesAndCounters
		INSERT INTO #Counters(UCI_PLT_ID, IsRead, UCI_SystemID, UCI_CounterID, UCI_DivideBy, UCI_ConstantValue)
		SELECT
			UCI_PLT_ID,
			UFT_IsRead AS IsRead,
			UCI_SystemID AS System_ID,
			UCI_CounterID AS Counter_ID,
			ISNULL(UCI_DivideBy, 1),
			UCI_ConstantValue
		FROM
			PerformanceData.UnifiedCounterImplementations
			INNER JOIN PerformanceData.UnifiedCounterTypes
			ON UCI_UFT_ID = UFT_ID
		WHERE
			UCI_UFT_ID IN (6, 7)	-- Counter_ID in 120, 123, Counter Type in ('Reads/sec', 'Writes/sec')
				and exists (select *
				from Management.PlatformTypes
				where PLT_ID = UCI_PLT_ID
					and PLT_PLC_ID = 1)

		--IOPS from SQL 2/4
		;with MachinesWithSQL as
				(select PDS_Database_MOB_ID MOB_ID, PDS_Server_MOB_ID OS_MOB_ID, MOB_PLT_ID
				from Consolidation.ParticipatingDatabaseServers
					inner join Inventory.MonitoredObjects on MOB_ID = PDS_Database_MOB_ID
				where PDS_Database_MOB_ID is not null)
		insert into #MachinesAndCounters(OS_MOB_ID, MOB_ID, IsRead, SystemID, CounterID, InstanceID, IDB_ID, DBF_DFT_ID, IsTempDB, IsSystemDB, UCI_DivideBy, UCI_ConstantValue, StartDate, EndDate)
		select OS_MOB_ID, PPH_Primary_Database_MOB_ID, IsRead, UCI_SystemID, UCI_CounterID, CIN_ID InstanceID, IDB_ID, DBF_DFT_ID,
			cast(case when IDB_Name = 'tempdb' then 1 else 0 end as bit) IsTempDB,
			cast(case when IDB_Name in ('master', 'tempdb', 'model', 'msdb') then 1 else 0 end as bit) IsSystemDB,
			UCI_DivideBy, UCI_ConstantValue, PPH_StartDate, PPH_EndDate
		from MachinesWithSQL
			inner join Consolidation.ParticipatingServersPrimaryHistory on PPH_Server_MOB_ID = OS_MOB_ID
			inner join #Counters on UCI_PLT_ID = MOB_PLT_ID
			inner join Inventory.InstanceDatabases on IDB_MOB_ID = PPH_Primary_Database_MOB_ID
			inner join Inventory.DatabaseFiles on DBF_MOB_ID = PPH_Primary_Database_MOB_ID
												and DBF_IDB_ID = IDB_ID
			inner join PerformanceData.CounterInstances on CIN_Name = '(' + IDB_Name + ') ' + DBF_FileName

		--IOPS from SQL 3/4
		select CRS_DateTime DT,
			OS_MOB_ID,
			sum(case when DBF_DFT_ID = 0 and IsTempDB = 0 then isnull(Reads, 0) else 0 end) DataFileReads,
			sum(case when DBF_DFT_ID = 0 and IsTempDB = 0 then isnull(Writes, 0) else 0 end) DataFileWrites,
			sum(case when DBF_DFT_ID = 0 and IsTempDB = 0 then isnull(Reads, 0) + isnull(Writes, 0) else 0 end) DataFileTransfers,
			sum(case when DBF_DFT_ID = 1 then isnull(Reads, 0) else 0 end) LogFileReads,
			sum(case when DBF_DFT_ID = 1 then isnull(Writes, 0) else 0 end) LogFileWrites,
			sum(case when DBF_DFT_ID = 1 then isnull(Reads, 0) + isnull(Writes, 0) else 0 end) LogFileTransfers,
			sum(case when DBF_DFT_ID = 0 and IsTempDB = 1 then isnull(Reads, 0) else 0 end) TempdbReads,
			sum(case when DBF_DFT_ID = 0 and IsTempDB = 1 then isnull(Writes, 0) else 0 end) TempdbWrites,
			sum(case when DBF_DFT_ID = 0 and IsTempDB = 1 then isnull(Reads, 0) + isnull(Writes, 0) else 0 end) TempdbTransfers,
			sum(case when DBF_DFT_ID > 1 then isnull(Reads, 0) else 0 end) OtherDatabaseFileReads,
			sum(case when DBF_DFT_ID > 1 then isnull(Writes, 0) else 0 end) OtherDatabaseFileWrites,
			sum(case when DBF_DFT_ID > 1 then isnull(Reads, 0) + isnull(Writes, 0) else 0 end) OtherDatabaseFileTransfers,
			sum(isnull(Reads, 0)) TotalFileReads,
			sum(isnull(Writes, 0)) TotalFileWrites,
			sum(isnull(Reads, 0) + isnull(Writes, 0)) TotalFileTransfers,
			max(case when DBF_DFT_ID = 0 and IsSystemDB = 0 then Reads + Writes else 0 end) DataMaxTransfers,
			max(case when DBF_DFT_ID = 1 and IsSystemDB = 0 then Reads + Writes else 0 end) LogMaxTransfers,
			max(case when IsSystemDB = 0 then Reads + Writes else 0 end) TotalMaxTransfers
		into #FileReadsWrites
		from
			(	select
					OS_MOB_ID, MOB_ID, CRS_DateTime, DBF_DFT_ID, IsTempDB, IsSystemDB, 
					iif(IsRead = 1, ISNULL(UCI_ConstantValue, CRS_Value/UCI_DivideBy), 0) AS Reads, 
					iif(IsRead = 0, ISNULL(UCI_ConstantValue, CRS_Value/UCI_DivideBy), 0) AS Writes
				from #MachinesAndCounters
					inner join PerformanceData.CounterResults with (forceseek) on CRS_MOB_ID = MOB_ID
																				and CRS_SystemID = SystemID
																				and CRS_CounterID = CounterID
																				and CRS_InstanceID = InstanceID
																				and (datepart(weekday, CRS_DateTime) between @FromDay and @ToDay or @FromDay is null or @ToDay is null)
																				and (datepart(hour, CRS_DateTime) between @FromHour and @ToHour or @FromHour is null or @ToHour is null)
																				and CRS_DateTime >= StartDate
																				and CRS_DateTime < EndDate
			) a
		group by CRS_DateTime, OS_MOB_ID

		--IOPS from SQL 4/4
		;with FileReadsWritesWithPercentile as
			(select *,
					percentile_disc(@Percentile/100) within group (order by TotalFileTransfers) over(partition by OS_MOB_ID) TotalFileTransfersPercentile,
					cast(avg(TotalFileTransfers) over (partition by OS_MOB_ID)*3600*24*31 as bigint) AvgMonthlyIOPS,
					max(DataMaxTransfers) over(partition by OS_MOB_ID) DataMaxTransfersA, max(LogMaxTransfers) over(partition by OS_MOB_ID) LogMaxTransfersA,
					max(TotalMaxTransfers) over(partition by OS_MOB_ID) TotalMaxTransfersA
				from #FileReadsWrites
			)
			, FileReadsWritesWithPercentile1 as
			(select *, ROW_NUMBER() over (partition by OS_MOB_ID order by DT desc) rn
				from FileReadsWritesWithPercentile
				where TotalFileTransfersPercentile = TotalFileTransfers
			)
		insert into Consolidation.DiskIOInfo
		select distinct OS_MOB_ID MOB_ID, DataFileReads, DataFileWrites, DataFileTransfers, LogFileReads, LogFileWrites, LogFileTransfers, TempdbReads,
			TempdbWrites, TempdbTransfers, OtherDatabaseFileReads, OtherDatabaseFileWrites, OtherDatabaseFileTransfers, TotalFileReads,
			TotalFileWrites, TotalFileTransfers, AvgMonthlyIOPS, DataMaxTransfersA, LogMaxTransfersA, TotalMaxTransfersA
		from FileReadsWritesWithPercentile1
		where rn = 1

		--IO Throughput from SQL 1/4
		truncate table #Counters
		truncate table #MachinesAndCounters
		INSERT INTO #Counters(UCI_PLT_ID, IsRead, UCI_SystemID, UCI_CounterID, UCI_DivideBy, UCI_ConstantValue)
		SELECT
			UCI_PLT_ID,
			UFT_IsRead AS IsRead,
			UCI_SystemID AS System_ID,
			UCI_CounterID AS Counter_ID,
			ISNULL(UCI_DivideBy, 1),
			UCI_ConstantValue
		FROM
			PerformanceData.UnifiedCounterImplementations
			INNER JOIN PerformanceData.UnifiedCounterTypes
			ON UCI_UFT_ID = UFT_ID
		WHERE
			UCI_UFT_ID IN (9, 10)	-- Counter_ID in 121, 124, Counter Type in ('Read Bytes/sec', 'Write Bytes/sec')
				and exists (select *
				from Management.PlatformTypes
				where PLT_ID = UCI_PLT_ID
					and PLT_PLC_ID = 1)

		--IO Throughput from SQL 2/4
		;with MachinesWithSQL as
				(select PDS_Database_MOB_ID MOB_ID, PDS_Server_MOB_ID OS_MOB_ID, MOB_PLT_ID
				from Consolidation.ParticipatingDatabaseServers
					inner join Inventory.MonitoredObjects on MOB_ID = PDS_Database_MOB_ID
				where PDS_Database_MOB_ID is not null)
		insert into #MachinesAndCounters (OS_MOB_ID, MOB_ID, IsRead, SystemID, CounterID, InstanceID, IDB_ID, DBF_DFT_ID, IsTempDB, IsSystemDB, UCI_DivideBy, UCI_ConstantValue, StartDate, EndDate)
		select distinct OS_MOB_ID, PPH_Primary_Database_MOB_ID, IsRead, UCI_SystemID, UCI_CounterID, CIN_ID InstanceID, IDB_ID, DBF_DFT_ID,
			cast(case when IDB_Name = 'tempdb' then 1 else 0 end as bit) IsTempDB,
			cast(case when IDB_Name in ('master', 'tempdb', 'model', 'msdb') then 1 else 0 end as bit) IsSystemDB,
			UCI_DivideBy, UCI_ConstantValue, PPH_StartDate, PPH_EndDate
		from MachinesWithSQL
			inner join Consolidation.ParticipatingServersPrimaryHistory on PPH_Server_MOB_ID = OS_MOB_ID
			inner join #Counters on UCI_PLT_ID = MOB_PLT_ID
			inner join Inventory.InstanceDatabases on IDB_MOB_ID = PPH_Primary_Database_MOB_ID
			inner join Inventory.DatabaseFiles on DBF_MOB_ID = PPH_Primary_Database_MOB_ID
												and DBF_IDB_ID = IDB_ID
			inner join PerformanceData.CounterInstances on CIN_Name = '(' + IDB_Name + ') ' + DBF_FileName

		--IO Throughput from SQL 3/4
		select CRS_DateTime DT,
			OS_MOB_ID,
			sum(case when DBF_DFT_ID = 0 and IsTempDB = 0 then isnull(Reads, 0) else 0 end) DataFileReadsMB,
			sum(case when DBF_DFT_ID = 0 and IsTempDB = 0 then isnull(Writes, 0) else 0 end) DataFileWritesMB,
			sum(case when DBF_DFT_ID = 0 and IsTempDB = 0 then isnull(Reads, 0) + isnull(Writes, 0) else 0 end) DataFileTransfersMB,
			sum(case when IsTempDB = 0 then isnull(Reads, 0) else 0 end) LogFileReadsMB,
			sum(case when IsTempDB = 0 then isnull(Writes, 0) else 0 end) LogFileWritesMB,
			sum(case when IsTempDB = 0 then isnull(Reads, 0) + isnull(Writes, 0) else 0 end) LogFileTransfersMB,
			sum(case when DBF_DFT_ID = 0 and IsTempDB = 1 then isnull(Reads, 0) else 0 end) TempdbReadsMB,
			sum(case when DBF_DFT_ID = 0 and IsTempDB = 1 then isnull(Writes, 0) else 0 end) TempdbWritesMB,
			sum(case when DBF_DFT_ID = 0 and IsTempDB = 1 then isnull(Reads, 0) + isnull(Writes, 0) else 0 end) TempdbTransfersMB,
			sum(case when DBF_DFT_ID > 1 then isnull(Reads, 0) else 0 end) OtherDatabaseFileReadsMB,
			sum(case when DBF_DFT_ID > 1 then isnull(Writes, 0) else 0 end) OtherDatabaseFileWritesMB,
			sum(case when DBF_DFT_ID > 1 then isnull(Reads, 0) + isnull(Writes, 0) else 0 end) OtherDatabaseFileTransfersMB,
			sum(isnull(Reads, 0)) TotalFileReadsMB,
			sum(isnull(Writes, 0)) TotalFileWritesMB,
			sum(isnull(Reads, 0) + isnull(Writes, 0)) TotalFileTransfersMB,
			max(case when DBF_DFT_ID = 0 and IsSystemDB = 0 then Reads + Writes else 0 end) DataMaxMBPerSec,
			max(case when DBF_DFT_ID = 1 and IsSystemDB = 0 then Reads + Writes else 0 end) LogMaxMBPerSec,
			max(case when IsSystemDB = 0 then Reads + Writes else 0 end) TotalMaxMBPerSec
		into #FileReadsWritesMB
		from
			(	select 
					OS_MOB_ID, MOB_ID, CRS_DateTime, DBF_DFT_ID, IsTempDB, IsSystemDB, 
					iif(IsRead = 1, ISNULL(UCI_ConstantValue, CRS_Value/UCI_DivideBy), 0)/1024/1024 AS Reads, 
					iif(IsRead = 0, ISNULL(UCI_ConstantValue, CRS_Value/UCI_DivideBy), 0)/1024/1024 AS Writes
				from #MachinesAndCounters
					inner join PerformanceData.CounterResults with (forceseek) on CRS_MOB_ID = MOB_ID
																				and CRS_SystemID = SystemID
																				and CRS_CounterID = CounterID
																				and CRS_InstanceID = InstanceID
																				and (datepart(weekday, CRS_DateTime) between @FromDay and @ToDay or @FromDay is null or @ToDay is null)
																				and (datepart(hour, CRS_DateTime) between @FromHour and @ToHour or @FromHour is null or @ToHour is null)
																				and CRS_DateTime >= StartDate
																				and CRS_DateTime < EndDate
			) a
		group by CRS_DateTime, OS_MOB_ID

		--IO Throughput from SQL 4/4
		;with FileReadsWritesMBWithPercentile as
			(select *,
					percentile_disc(@Percentile/100) within group (order by TotalFileTransfersMB) over(partition by OS_MOB_ID) TotalFileTransfersMBPercentile,
					cast(avg(TotalFileTransfersMB) over (partition by OS_MOB_ID)*3600*24*31 as bigint) AvgMonthlyMBs,
					max(DataMaxMBPerSec) over(partition by OS_MOB_ID) DataMaxMBPerSecA, max(LogMaxMBPerSec) over(partition by OS_MOB_ID) LogMaxMBPerSecA,
					max(TotalMaxMBPerSec) over(partition by OS_MOB_ID) TotalMaxMBPerSecA
				from #FileReadsWritesMB
			)
			, FileReadsWritesMBWithPercentile1 as
			(select *, ROW_NUMBER() over (partition by OS_MOB_ID order by DT desc) rn
				from FileReadsWritesMBWithPercentile
				where TotalFileTransfersMBPercentile = TotalFileTransfersMB
			)
		insert into Consolidation.DiskThroughputInfo
		select distinct OS_MOB_ID MOB_ID, DataFileReadsMB, DataFileWritesMB, DataFileTransfersMB, LogFileReadsMB, LogFileWritesMB, LogFileTransfersMB, TempdbReadsMB,
			TempdbWritesMB, TempdbTransfersMB, OtherDatabaseFileReadsMB, OtherDatabaseFileWritesMB, OtherDatabaseFileTransfersMB, TotalFileReadsMB,
			TotalFileWritesMB, TotalFileTransfersMB, AvgMonthlyMBs, DataMaxMBPerSecA, LogMaxMBPerSecA, TotalMaxMBPerSecA
		from FileReadsWritesMBWithPercentile1
		where rn = 1
	end

	--IOPS from Windows 1/4
	truncate table #Counters
	truncate table #MachinesAndCounters
	INSERT INTO #Counters(UCI_PLT_ID, IsRead, UCI_SystemID, UCI_CounterID, UCI_DivideBy, UCI_ConstantValue)
	SELECT
		UCI_PLT_ID,
		UFT_IsRead AS IsRead,
		UCI_SystemID AS System_ID,
		UCI_CounterID AS Counter_ID,
		ISNULL(UCI_DivideBy, 1),
		UCI_ConstantValue
	FROM
		PerformanceData.UnifiedCounterImplementations
		INNER JOIN PerformanceData.UnifiedCounterTypes
		ON UCI_UFT_ID = UFT_ID
	WHERE
		UCI_UFT_ID IN (6, 7)	-- Counter_ID in 21, 23, Counter Type in ('Reads/sec', 'Writes/sec')
			and exists (select *
				from Management.PlatformTypes
				where PLT_ID = UCI_PLT_ID
					and PLT_PLC_ID = 2)

	--IOPS from Windows 2/4
	;with Machines as
			(select distinct MOB_ID, MOB_PLT_ID
			from Consolidation.ParticipatingDatabaseServers
				inner join Inventory.MonitoredObjects on MOB_ID = PDS_Server_MOB_ID
			where PDS_Database_MOB_ID is null
				or @IsIOBySQL = 0
				or not exists (select * from Consolidation.DiskIOInfo where DII_MOB_ID = MOB_ID)
			)
	insert into #MachinesAndCounters(OS_MOB_ID, MOB_ID, IsRead, SystemID, CounterID, UCI_DivideBy, UCI_ConstantValue, StartDate, EndDate)
	select distinct MOB_ID, V_MOB_ID, IsRead, UCI_SystemID, UCI_CounterID, UCI_DivideBy, UCI_ConstantValue, PPH_StartDate, PPH_EndDate
	from Machines
		cross apply (select PPH_Primary_Server_MOB_ID V_MOB_ID, PPH_StartDate, PPH_EndDate
						from Consolidation.ParticipatingServersPrimaryHistory
						where PPH_Server_MOB_ID = MOB_ID
						union all
						select CNM_VirtualServer_MOB_ID V_MOB_ID, PPH_StartDate, PPH_EndDate
						from Consolidation.ClusterNodesMapping
							inner join Consolidation.ParticipatingServersPrimaryHistory on PPH_Server_MOB_ID = CNM_ClusterNode_MOB_ID
						where CNM_ClusterNode_MOB_ID = MOB_ID) c
		inner join #Counters on UCI_PLT_ID = MOB_PLT_ID
	where not exists (select * from Consolidation.DiskIOInfo where DII_MOB_ID = MOB_ID)

	--IOPS from Windows 3/4
	select CRS_DateTime DT,
		MOB_ID IO_MOB_ID,
		sum(isnull(Reads, 0)) Reads,
		sum(isnull(Writes, 0)) Writes,
		sum(isnull(Reads, 0) + isnull(Writes, 0)) IOps
	into #DiskReadWriteOperations
	from (select 
				MOB_ID, CRS_DateTime, 
				iif(IsRead = 1, ISNULL(UCI_ConstantValue, CRS_Value/UCI_DivideBy), 0) AS Reads, 
				iif(IsRead = 0, ISNULL(UCI_ConstantValue, CRS_Value/UCI_DivideBy), 0) AS Writes
			from #MachinesAndCounters
				inner join PerformanceData.CounterResults with (forceseek) on CRS_MOB_ID = MOB_ID 
																			and CRS_SystemID = SystemID
																			and CRS_CounterID = CounterID
																			and (datepart(weekday, CRS_DateTime) between @FromDay and @ToDay or @FromDay is null or @ToDay is null)
																			and (datepart(hour, CRS_DateTime) between @FromHour and @ToHour or @FromHour is null or @ToHour is null)
																			and CRS_DateTime >= StartDate
																			and CRS_DateTime < EndDate
		) a
	group by CRS_DateTime, MOB_ID

	--IOPS from Windows 4/4
	;with DiskReadWriteOperationsWithPercentile as
		(select *,
				percentile_disc(@Percentile/100) within group (order by IOps) over(partition by IO_MOB_ID) IOPsPercentile,
				cast(avg(IOps) over (partition by IO_MOB_ID)*3600*24*31 as bigint) AvgMonthlyIOps,
				max(Iops) over(partition by IO_MOB_ID) MaxIOps
			from #DiskReadWriteOperations
		)
		, DiskReadWriteOperationsWithPercentile1 as
		(select *, ROW_NUMBER() over (partition by IO_MOB_ID order by DT desc) rn
			from DiskReadWriteOperationsWithPercentile
			where IOPsPercentile = IOps
		)
	insert into Consolidation.DiskIOInfo(DII_MOB_ID, DII_TotalReads, DII_TotalWrites, DII_TotalTransfers, DII_AvgMonthlyIOPS, DII_TotalMaxTransfers)
	select distinct IO_MOB_ID, Reads, Writes, IOps, AvgMonthlyIOps, MaxIOps
	from DiskReadWriteOperationsWithPercentile1
	where rn = 1

	--IO Throughput from Windows 1/4
	truncate table #Counters
	truncate table #MachinesAndCounters
	INSERT INTO #Counters(UCI_PLT_ID, IsRead, UCI_SystemID, UCI_CounterID, UCI_DivideBy, UCI_ConstantValue)
	SELECT
		UCI_PLT_ID,
		UFT_IsRead AS IsRead,
		UCI_SystemID AS System_ID,
		UCI_CounterID AS Counter_ID,
		ISNULL(UCI_DivideBy, 1),
		UCI_ConstantValue
	FROM
		PerformanceData.UnifiedCounterImplementations
		INNER JOIN PerformanceData.UnifiedCounterTypes
		ON UCI_UFT_ID = UFT_ID
	WHERE
		UCI_UFT_ID IN (9, 10)	-- Counter_ID in 93, 94, Counter Type in ('Read Bytes/sec', 'Write Bytes/sec')
			and exists (select *
				from Management.PlatformTypes
				where PLT_ID = UCI_PLT_ID
					and PLT_PLC_ID = 2)

	--IO Throughput from Windows 2/4
	;with Machines as
			(select distinct MOB_ID, MOB_PLT_ID
			from Consolidation.ParticipatingDatabaseServers
				inner join Inventory.MonitoredObjects on MOB_ID = PDS_Server_MOB_ID
			where PDS_Database_MOB_ID is null
				or @IsIOBySQL = 0
				or not exists (select * from Consolidation.DiskThroughputInfo where DTI_MOB_ID = MOB_ID))
	insert into #MachinesAndCounters(OS_MOB_ID, MOB_ID, IsRead, SystemID, CounterID, UCI_DivideBy, UCI_ConstantValue, StartDate, EndDate)
	select distinct MOB_ID, V_MOB_ID, IsRead, UCI_SystemID, UCI_CounterID, UCI_DivideBy, UCI_ConstantValue, PPH_StartDate, PPH_EndDate
	from Machines 
		cross apply (select PPH_Primary_Server_MOB_ID V_MOB_ID, PPH_StartDate, PPH_EndDate
						from Consolidation.ParticipatingServersPrimaryHistory
						where PPH_Server_MOB_ID = MOB_ID
						union all
						select CNM_VirtualServer_MOB_ID V_MOB_ID, PPH_StartDate, PPH_EndDate
						from Consolidation.ClusterNodesMapping
							inner join Consolidation.ParticipatingServersPrimaryHistory on PPH_Server_MOB_ID = CNM_ClusterNode_MOB_ID
						where CNM_ClusterNode_MOB_ID = MOB_ID) c
		inner join #Counters on UCI_PLT_ID = MOB_PLT_ID
	where not exists (select * from Consolidation.DiskThroughputInfo where DTI_MOB_ID = MOB_ID)

	--IO Throughput from Windows 3/4
	select CRS_DateTime DT,
		MOB_ID MB_MOB_ID,
		sum(isnull(Reads, 0)) ReadMBps,
		sum(isnull(Writes, 0)) WriteMBps,
		sum(isnull(Reads, 0) + isnull(Writes, 0)) MBps
	into #DiskReadWriteMBps
	from (select 
				MOB_ID, CRS_DateTime, 
				iif(IsRead = 1, ISNULL(UCI_ConstantValue, CRS_Value/UCI_DivideBy), 0)/1024/1024 AS Reads, 
				iif(IsRead = 0, ISNULL(UCI_ConstantValue, CRS_Value/UCI_DivideBy), 0)/1024/1024 AS Writes
			from #MachinesAndCounters
				inner join PerformanceData.CounterResults with (forceseek) on CRS_MOB_ID = MOB_ID 
																			and CRS_SystemID = SystemID
																			and CRS_CounterID = CounterID
																			and (datepart(weekday, CRS_DateTime) between @FromDay and @ToDay or @FromDay is null or @ToDay is null)
																			and (datepart(hour, CRS_DateTime) between @FromHour and @ToHour or @FromHour is null or @ToHour is null)
																			and CRS_DateTime >= StartDate
																			and CRS_DateTime < EndDate
		) a
	group by CRS_DateTime, MOB_ID

	--IO Throughput from Windows 4/4
	;with DiskReadWriteMBpsWithPercentile as
		(select *,
				percentile_disc(@Percentile/100) within group (order by MBps) over(partition by MB_MOB_ID) MBpsPercentile,
				cast(avg(MBps) over (partition by MB_MOB_ID)*3600*24*31 as bigint) AvgMonthlyMBs,
				max(MBps) over(partition by MB_MOB_ID) MaxMBps
			from #DiskReadWriteMBps
		)
		, DiskReadWriteMBpsWithPercentile1 as
		(select *, ROW_NUMBER() over (partition by MB_MOB_ID order by DT desc) rn
			from DiskReadWriteMBpsWithPercentile
			where MBpsPercentile = MBps
		)
	insert into Consolidation.DiskThroughputInfo(DTI_MOB_ID, DTI_TotalReadsMB, DTI_TotalWritesMB, DTI_TotalTransfersMB, DTI_AvgMonthlyMBs, DTI_TotalMaxMBPs)
	select distinct MB_MOB_ID, ReadMBps, WriteMBps, MBpsPercentile, AvgMonthlyMBs, MaxMBps
	from DiskReadWriteMBpsWithPercentile1
	where rn = 1

	--Missing data
	insert into #MissingData
	select 'Missing CPU data' Info, SGR_MOB_ID
	from Consolidation.ServerGrouping
	except
	select 'Missing CPU data' Info, CPI_MOB_ID
	from Consolidation.CPUInfo

	insert into #MissingData
	select 'Missing Memory data' Info, SGR_MOB_ID
	from Consolidation.ServerGrouping
	except
	select 'Missing Memory data' Info, MMI_MOB_ID
	from Consolidation.MemoryInfo

	insert into #MissingData
	select 'Missing Network data' Info, SGR_MOB_ID
	from Consolidation.ServerGrouping
	except
	select 'Missing Network data' Info, NTI_MOB_ID
	from Consolidation.NetworkInfo

	insert into #MissingData
	select 'Missing IO data' Info, SGR_MOB_ID
	from Consolidation.ServerGrouping
	except
	select 'Missing IO data' Info, DII_MOB_ID
	from Consolidation.DiskIOInfo

	insert into #MissingData
	select 'Missing IO MBps data' Info, SGR_MOB_ID
	from Consolidation.ServerGrouping
	except
	select 'Missing IO MBps data' Info, DTI_MOB_ID
	from Consolidation.DiskThroughputInfo

	if @ReturnResults = 1
		if exists (select * from #MissingData)
			select Info, MOB_ID, MOB_Name
			from #MissingData
				inner join Inventory.MonitoredObjects on MOB_ID = M_MOB_ID
		else
			select 'No missing data' Info
END
GO
