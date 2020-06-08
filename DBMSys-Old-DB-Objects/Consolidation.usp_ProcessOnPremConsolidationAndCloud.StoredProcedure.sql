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
/****** Object:  StoredProcedure [Consolidation].[usp_ProcessOnPremConsolidationAndCloud]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Consolidation].[usp_ProcessOnPremConsolidationAndCloud]
--DECLARE
	@IncludeCloud bit = 1,
	@IncludeOnPrem bit = 1,
	@OnPremCombinationsPerHost int = 1000,
	@CloudCombinationsPerHost int = 2000,
	@ConsiderGlobalPopularity bit = 0,
	@PrintOutput bit = 1
as
--BEGIN
	set nocount on

	declare @CPUBufferPercentage int,
			@MemoryBufferPercentage int,
			@NetworkBufferPercentage int,
			@DiskIOBufferPercentage int,
			@DiskSizeBufferPercentage int,
			@CPUCapPercentage int,
			@MemoryCapPercentage int,
			@NetworkCapPercentage int,
			@DiskIOCapPercentage int,
			@DiskSizeCapPercentage int,
			@AllowEditionUpgradingConsolidation bit

	select @CPUBufferPercentage = CAST(SET_Value as int)
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'CPU Buffer Percentage'

	select @MemoryBufferPercentage = CAST(SET_Value as int)
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Memory Buffer Percentage'

	select @NetworkBufferPercentage = CAST(SET_Value as int)
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Network Speed Buffer Percentage'

	select @DiskIOBufferPercentage = CAST(SET_Value as int)
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Disk IO Buffer Percentage'

	select @DiskSizeBufferPercentage = CAST(SET_Value as int)
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Disk Size Buffer Percentage'

	select @CPUCapPercentage = CAST(SET_Value as int)
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'CPU Cap Percentage'

	select @MemoryCapPercentage = CAST(SET_Value as int)
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Memory Cap Percentage'

	select @NetworkCapPercentage = CAST(SET_Value as int)
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Network Speed Cap Percentage'

	select @DiskIOCapPercentage = CAST(SET_Value as int)
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Disk IO Cap Percentage'

	select @DiskSizeCapPercentage = CAST(SET_Value as int)
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Disk Size Cap Percentage'

	select @AllowEditionUpgradingConsolidation = CAST(SET_Value as bit)
	from Management.Settings
	where SET_Module = 'Consolidation'
		and SET_Key = 'Allow Edition Upgrading Consolidation'

	if @IncludeCloud = 1
	begin
		delete Consolidation.ConsolidationBlocks
		where CLB_HST_ID in (select HST_ID from Consolidation.HostTypes where HST_IsCloud = 1 and HST_IsPerSingleDatabase = 0)
		delete Consolidation.ConsolidationBlocks_LoadBlocks
		where CBL_HST_ID in (select HST_ID from Consolidation.HostTypes where HST_IsCloud = 1 and HST_IsPerSingleDatabase = 0)
	end
	if @IncludeOnPrem = 1
	begin
		delete Consolidation.ConsolidationBlocks where CLB_HST_ID in (1, 2)
		delete Consolidation.ConsolidationBlocks_LoadBlocks where CBL_HST_ID in (1, 2)
	end

	if OBJECT_ID('tempdb..#LoadBlockPopularity') is not null
		drop table #LoadBlockPopularity

	create table #LoadBlockPopularity
		(HostTypeID tinyint,
		LoadBlockID int not null,
		Popularity int not null)

	create unique clustered index IX_#LoadBlockPopularity on #LoadBlockPopularity(HostTypeID, LoadBlockID)

	if object_id('tempdb..#LoadBlocks') is not null
		drop table #LoadBlocks

	declare @CPUBufferForCalculation decimal(10, 2) = 1 + @CPUBufferPercentage/100.,
			@MemoryBufferForCalculation decimal(10, 2) = 1 + @MemoryBufferPercentage/100.,
			@NetworkBufferForCalculation decimal(10, 2) = 1 + @NetworkBufferPercentage/100.,
			@DiskIOBufferForCalculation decimal(10, 2) = 1 + @DiskIOBufferPercentage/100.,
			@DiskSizeBufferForCalculation decimal(10, 2) = 1 + @DiskSizeBufferPercentage/100.,
			@CPUCapForCalculation decimal(10, 2) = @CPUCapPercentage/100.,
			@MemoryCapForCalculation decimal(10, 2) = @MemoryCapPercentage/100.,
			@NetworkCapForCalculation decimal(10, 2) = @NetworkCapPercentage/100.,
			@DiskIOCapForCalculation decimal(10, 2) = @DiskIOCapPercentage/100.,
			@DiskSizeCapForCalculation decimal(10, 2) = @DiskSizeCapPercentage/100.,
			@CombinationsPerHost int,
			@CLV_ID tinyint,
			@IsCloud bit,
			@PSH_ID int,
			@MOB_ID int,
			@HST_ID tinyint,
			@CHA_ID tinyint,
			@CombinationCount int,
			@CPUStrength int,
			@MemoryMB bigint,
			@NetworkSpeedMbit int,
			@NetDownloadSpeedRatio decimal(10, 6),
			@NetUploadSpeedRatio decimal(10, 6),
			@MaxDiskSizeMB bigint,
			@MaxIOPS8KB int,
			@MaxMBPerSec8KB int,
			@MaxIOPS64KB int,
			@MaxMBPerSec64KB int,
			@Storage_BUL_ID tinyint,
			@HostDiskCount int,
			@OST_ID tinyint,
			@PSH_CHA_ID tinyint,
			@PSH_CHE_ID tinyint,
			@CRG_ID smallint,
			@CMP_ID int,
			@IsConsolidation bit,
			@Price decimal(15, 3),
			@ReadsFactor decimal(10, 3),
			@WritesFactor decimal(10, 3),
			@ReadsMBFactor decimal(10, 3),
			@WritesMBFactor decimal(10, 3),
			@CLB_ID int,
			@CurrentCPUStrength int,
			@CurrentMemoryMB bigint,
			@CurrentNetworkSpeedMbit int,
			@CurrentDiskSizeMB bigint,
			@CurrentBlockSize int,
			@CurrentIOPS int,
			@CurrentMBPerSec int,
			@CurrentMachineCount int,
			@MachineCPUStrength int,
			@MachineMemoryMB bigint,
			@MachineNetworkDownloadSpeedMbit int,
			@MachineNetworkUploadSpeedMbit int,
			@MachineNetworkSpeedMbit int,
			@MachineDiskSizeMB bigint,
			@MachineIOPS int,
			@MachineMBPerSec int,
			@MachineAvgMonthlyIOPS bigint,
			@MachineAvgMonthlyNetworkOutboundIO bigint,
			@MachineAvgMonthlyNetworkInboundIO bigint,
			@LBL_ID int,
			@CGR_ID int,
			@CHE_ID tinyint,
			@Init bit,
			@Saturated bit,
			@LoadBlockCount int,
			@PricePerDisk decimal(17, 10)

	select @LoadBlockCount = count(*)
	from Consolidation.LoadBlocks

	if @ConsiderGlobalPopularity = 1
		insert into #LoadBlockPopularity
		select CLB_HST_ID, CBL_LBL_ID, COUNT(*)
		from Consolidation.ConsolidationBlocks_LoadBlocks
			inner join Consolidation.ConsolidationBlocks on CLB_ID = CBL_CLB_ID
		where CBL_DLR_ID is null
			and CLB_DLR_ID is null
		group by CLB_HST_ID, CBL_LBL_ID

	select l.*, a.*, CHE_IsFree,
		iif(exists (select *
					from Consolidation.PossibleHosts p1
					where p1.PSH_HST_ID = p.PSH_HST_ID
						and p1.PSH_CRG_ID = p.PSH_CRG_ID
						and p1.PSH_OST_ID = LBL_OST_ID
						and p1.PSH_CHE_ID = LBL_CHE_ID
						and (p1.PSH_CMT_ID = p.PSH_CMT_ID
								or p.PSH_CMT_ID is null)), 1, 0) ExistsHostWithApplication, PSH_HST_ID
	into #LoadBlocks
	from Consolidation.LoadBlocks l
		cross apply (select distinct PSA_PSH_ID
						from Consolidation.PossibleHostsConsolidationGroupAffinity
						where PSA_CGR_ID is null
								or PSA_CGR_ID = LBL_CGR_ID
					) a
		inner join Consolidation.PossibleHosts p on p.PSH_ID = PSA_PSH_ID
		left join Consolidation.CloudHostedApplicationEditions on CHE_ID = LBL_CHE_ID
	where (exists (select *
						from Consolidation.CloudHostedOSApplicationCompatibility
						where COA_OST_ID = PSH_OST_ID
							and (COA_CHA_ID = LBL_CHA_ID
								or LBL_CHA_ID is null
								)
					)
				or (PSH_OST_ID is null
					and PSH_CHA_ID = LBL_CHA_ID)
		)
		and (exists (select *
						from Consolidation.ConsolidationGroups_CloudRegions
							inner join Consolidation.CloudRegions with (index=PK_CloudRegions, forceseek) on CRG_ID = CGG_CRG_ID
						where CGG_CGR_ID = LBL_CGR_ID
							and CRG_ID = PSH_CRG_ID)
				or PSH_CRG_ID is null)
		and exists (select *
						from Consolidation.PossibleHosts
							inner join Consolidation.ServerPossibleHostTypes on SHT_HST_ID = PSH_HST_ID
						where PSH_ID = PSA_PSH_ID
							and SHT_MOB_ID = LBL_MOB_ID)
		and ((PSH_CPUStrength >= LBL_CPUStrength
					and PSH_MemoryMB >= LBL_MemoryMB)
				or PSH_MOB_ID = LBL_MOB_ID)
		and PSH_HST_ID in (select HST_ID
							from Consolidation.HostTypes
							where @IncludeCloud = 1
								and HST_IsCloud = 1
								and HST_IsPerSingleDatabase = 0
							union all
							select HST_ID
							from Consolidation.HostTypes
							where @IncludeOnPrem = 1
								and HST_ID in (1, 2)
							)

	create unique clustered index IX_#LoadBlocks on #LoadBlocks(PSA_PSH_ID, LBL_ID)

	IF OBJECT_ID('tempdb..#DBMILFeature') IS NOT NULL
		DROP TABLE #DBMILFeature

	CREATE TABLE #DBMILFeature
	(
		CGR_Name				NVARCHAR(255)
		,ServerName				NVARCHAR(255)
		,DatabaseInstanceName	NVARCHAR(255)
		,CanMoveToAzureDBMI		BIT
		,Reason					NVARCHAR(MAX)
		,MOBID					INT
		,CLVID					INT
	)

	
	IF EXISTS (
				SELECT 
						TOP 1 1 
				FROM	Consolidation.PossibleHosts 
				JOIN	Consolidation.HostTypes ON PSH_HST_ID = HST_ID 
				WHERE	HST_CLV_ID = 5
			)
	EXEC Consolidation.usp_Reports_AzureDBMILimitingFeatures 0

	DELETE FROM #DBMILFeature WHERE CanMoveToAzureDBMI = 1

	DELETE	FROM #LoadBlocks
	WHERE	EXISTS (
						SELECT 
										* 
								FROM	#DBMILFeature
								JOIN	Consolidation.ParticipatingDatabaseServers on PDS_Server_MOB_ID = MOBID
								JOIN	Consolidation.HostTypes ON HST_CLV_ID = CLVID
								WHERE	PDS_Server_MOB_ID = LBL_MOB_ID AND HST_ID = PSH_HST_ID
					)

	declare cPossibleHosts cursor static forward_only for
		select HST_CLV_ID,
				HST_IsCloud,
				PSH_ID,
				PSH_MOB_ID,
				PSH_HST_ID,
				PSH_OST_ID,
				PSH_CHA_ID,
				PSH_CHE_ID,
				PSH_CPUStrength*@CPUCapForCalculation CPUStrength,
				PSH_MemoryMB*@MemoryCapForCalculation MemoryMB,
				PSH_NetworkSpeedMbit*@NetworkCapForCalculation NetworkSpeedMbit,
				PSH_NetDownloadSpeedRatio,
				PSH_NetUploadSpeedRatio,
				case when HST_IsLimitedByDisk = 1 then PSH_MaxDiskSizeMB*@DiskSizeCapForCalculation end DiskSizeMB,
				case when HST_IsLimitedByDisk = 1 then PSH_MaxIOPS8KB*@DiskIOCapForCalculation end MaxIOPS8KB,
				case when HST_IsLimitedByDisk = 1 then PSH_MaxMBPerSec8KB*@DiskIOCapForCalculation end MaxMBPerSec8KB,
				case when HST_IsLimitedByDisk = 1 then PSH_MaxIOPS64KB*@DiskIOCapForCalculation end MaxIOPS64KB,
				case when HST_IsLimitedByDisk = 1 then PSH_MaxMBPerSec64KB*@DiskIOCapForCalculation end MaxMBPerSec64KB,
				case when HST_IsLimitedByDisk = 1 then PSH_Storage_BUL_ID end Storage_BUL_ID,
				case when HST_IsLimitedByDisk = 1 then PSH_MaxDiskCount end DiskCount,
				PSH_PricePerMonthUSD,
				PSH_CRG_ID,
				PSH_CMP_ID,
				HST_IsConsolidation,
				PSH_PricePerDisk
		from Consolidation.PossibleHosts
			inner join Consolidation.HostTypes on HST_ID = PSH_HST_ID
		where (HST_IsCloud = 0
					or @IncludeCloud = 1)
			and (HST_IsCloud = 1
					or @IncludeOnPrem = 1)
			and HST_IsSharingOS = 1
			and exists (select * from #LoadBlocks where PSA_PSH_ID = PSH_ID)
			
		
		order by PSH_PricePerMonthUSD

	open cPossibleHosts

	fetch next from cPossibleHosts into @CLV_ID, @IsCloud, @PSH_ID, @MOB_ID, @HST_ID, @OST_ID, @PSH_CHA_ID, @PSH_CHE_ID, @CPUStrength, @MemoryMB, @NetworkSpeedMbit,
										@NetDownloadSpeedRatio, @NetUploadSpeedRatio, @MaxDiskSizeMB, @MaxIOPS8KB, @MaxMBPerSec8KB, @MaxIOPS64KB,
										@MaxMBPerSec64KB, @Storage_BUL_ID, @HostDiskCount, @Price, @CRG_ID, @CMP_ID, @IsConsolidation, @PricePerDisk
	while @@FETCH_STATUS = 0
	begin
		select @CombinationCount = 0,
			@Saturated = 0,
			@CombinationsPerHost = case @IsConsolidation
										when 1 then
											case @IsCloud
												when 0 then @OnPremCombinationsPerHost
												when 1 then @CloudCombinationsPerHost
											end
										else @LoadBlockCount
									end
		if @ConsiderGlobalPopularity = 0
		begin
			truncate table #LoadBlockPopularity
		
			insert into #LoadBlockPopularity
			select CLB_HST_ID, CBL_LBL_ID, COUNT(*)
			from Consolidation.ConsolidationBlocks_LoadBlocks
				inner join Consolidation.ConsolidationBlocks on CLB_ID = CBL_CLB_ID
			where CBL_DLR_ID is null
				and CLB_DLR_ID is null
				and CLB_PSH_ID = @PSH_ID
			group by CLB_HST_ID, CBL_LBL_ID
		end



		while @CombinationCount < @CombinationsPerHost
			and @Saturated = 0
		begin
			select @CurrentCPUStrength = @CPUStrength,
					@CurrentMemoryMB = @MemoryMB,
					@CurrentNetworkSpeedMbit = @NetworkSpeedMbit,
					@CurrentDiskSizeMB = @MaxDiskSizeMB,
					@CurrentIOPS = null,
					@CurrentMBPerSec = null,
					@CGR_ID = null,
					@CHA_ID = @PSH_CHA_ID,
					@CHE_ID = @PSH_CHE_ID,
					@CurrentBlockSize = null,
					@CLB_ID = null,
					@Init = 1,
					@CurrentMachineCount = 0

			--Get first load block
			while (@LBL_ID is not null
					or @Init = 1)
				and (@CurrentMachineCount < 1
					or @IsConsolidation = 1)
			begin
				set @LBL_ID = null

				;with PossibleLoadBlocks as
					(select LBL_ID,
							LBL_CGR_ID CGR_ID,
							LBL_CHE_ID CHE_ID,
							LBL_CHA_ID CHA_ID,
							LBL_CPUStrength*@CPUBufferForCalculation CPUStrength,
							LBL_MemoryMB*@MemoryBufferForCalculation MemoryMB,
							LBL_NetworkUsageDownloadMbit*@NetworkBufferForCalculation NetworkDownloadSpeed,
							LBL_NetworkUsageUploadMbit*@NetworkBufferForCalculation NetworkUploadSpeed,
							(LBL_NetworkUsageDownloadMbit*@NetDownloadSpeedRatio + LBL_NetworkUsageUploadMbit*@NetUploadSpeedRatio)*@NetworkBufferForCalculation NetworkUsageMbit,
							LBL_DiskSize*@DiskSizeBufferForCalculation DiskSize,
							LBL_BlockSize DiskBlockSize,
							(LBL_ReadsSec*ISNULL(CDF_ReadsFactor, 1) + LBL_WritesSec*ISNULL(CDF_WritesFactor, 1))*@DiskIOBufferForCalculation IOPS,
							(LBL_ReadsMBSec*ISNULL(CDF_ReadsMBFactor, 1) + LBL_WritesMBSec*ISNULL(CDF_WritesMBFactor, 1))*@DiskIOBufferForCalculation MBPerSec,
							isnull(Popularity, 0) Popularity,
							LBL_MonthlyDiskIOPS AvgMonthlyIOPS,
							LBL_MonthlyNetworkOutboundMB AvgMonthlyNetworkOutboundIO,
							LBL_MonthlyNetworkInboundMB AvgMonthlyNetworkInboundIO
						from #LoadBlocks
							left join Consolidation.CloudMachinesDiskFactors on CDF_BUL_ID = @Storage_BUL_ID
																			and CDF_DiskCount = @HostDiskCount
																			and CDF_BlockSize = LBL_BlockSize
							left join #LoadBlockPopularity on HostTypeID = @HST_ID
																and LoadBlockID = LBL_ID
						where PSA_PSH_ID = @PSH_ID
							and (LBL_MOB_ID = @MOB_ID
									or @MOB_ID is null
									or @Init = 0)
							and not exists (select *
												from Consolidation.ConsolidationBlocks_LoadBlocks with (forceseek)
												where CBL_CLB_ID = @CLB_ID
													and CBL_LBL_ID = LBL_ID)
							and (LBL_BlockSize = @CurrentBlockSize
									or @CurrentBlockSize is null
								)
							and (LBL_CGR_ID = @CGR_ID
									or @CGR_ID is null
								)
							and (LBL_OST_ID = @OST_ID
									or (@OST_ID is null
											and LBL_CHA_ID = @PSH_CHA_ID
										)
								)
							and (LBL_CHA_ID = @PSH_CHA_ID
								or @PSH_CHA_ID is null)
							and (LBL_CHE_ID = @PSH_CHE_ID
									or LBL_CHE_ID = @CHE_ID
									or (@PSH_CHE_ID is null
										and @CHE_ID is null
										and (CHE_IsFree = 1
											or LBL_CHE_ID is null
											or (ExistsHostWithApplication = 0
												and @Init = 1
												)
											)
										)
									or (@AllowEditionUpgradingConsolidation = 1
											and LBL_CHE_ID < @CHE_ID
											and CHE_IsFree = 0)
									)
							and (@IsConsolidation = 1
									or not exists (select *
													from Consolidation.ConsolidationBlocks_LoadBlocks with (forceseek)
														inner join Consolidation.ConsolidationBlocks with (forceseek) on CLB_ID = CBL_CLB_ID
													where CBL_HST_ID = @HST_ID
														and CBL_LBL_ID = LBL_ID
														and CLB_BasePricePerMonthUSD <= @Price)
								)
					)
				select top 1 @LBL_ID = LBL_ID,
							@CGR_ID = isnull(@CGR_ID, CGR_ID),
							@CHE_ID = isnull(@CHE_ID, CHE_ID),
							@CHA_ID = isnull(@CHA_ID, CHA_ID),
							@CurrentCPUStrength -= CPUStrength,
							@CurrentMemoryMB -= MemoryMB,
							@CurrentNetworkSpeedMbit -= NetworkUsageMbit,
							@CurrentDiskSizeMB -= DiskSize,
							@CurrentBlockSize = isnull(@CurrentBlockSize, DiskBlockSize),
							@CurrentIOPS = ISNULL(@CurrentIOPS, case DiskBlockSize
																	when 8 then @MaxIOPS8KB
																	when 64 then @MaxIOPS64KB
																end) - IOPS,
							@CurrentMBPerSec = ISNULL(@CurrentMBPerSec, case DiskBlockSize
																			when 8 then @MaxMBPerSec8KB
																			when 64 then @MaxMBPerSec64KB
																		end) - MBPerSec,
							@MachineCPUStrength = CPUStrength,
							@MachineMemoryMB = MemoryMB,
							@MachineNetworkDownloadSpeedMbit = NetworkDownloadSpeed,
							@MachineNetworkUploadSpeedMbit = NetworkUploadSpeed,
							@MachineNetworkSpeedMbit = NetworkUsageMbit,
							@MachineDiskSizeMB = DiskSize,
							@MachineIOPS = IOPS,
							@MachineMBPerSec = MBPerSec,
							@MachineAvgMonthlyIOPS = AvgMonthlyIOPS,
							@MachineAvgMonthlyNetworkOutboundIO = AvgMonthlyNetworkOutboundIO,
							@MachineAvgMonthlyNetworkInboundIO = AvgMonthlyNetworkInboundIO
				from PossibleLoadBlocks
				where CPUStrength < @CurrentCPUStrength
					and MemoryMB < @CurrentMemoryMB
					and NetworkUsageMbit < @CurrentNetworkSpeedMbit
					and (DiskSize < @CurrentDiskSizeMB
							or @CurrentDiskSizeMB is null)
					and (IOPS < ISNULL(@CurrentIOPS, case DiskBlockSize
															when 8 then @MaxIOPS8KB
															when 64 then @MaxIOPS64KB
														end)
							or @MaxIOPS8KB is null)
					and (MBPerSec < ISNULL(@CurrentMBPerSec, case DiskBlockSize
																	when 8 then @MaxMBPerSec8KB
																	when 64 then @MaxMBPerSec64KB
																end)
							or @MaxMBPerSec8KB is null)
				order by Popularity, NEWID()

				if @Init = 1
					set @Init = 0

				if @LBL_ID is not null
				begin
					if @CLB_ID is null
					begin
						insert into Consolidation.ConsolidationBlocks(CLB_PSH_ID, CLB_OST_ID, CLB_CHA_ID, CLB_CGR_ID, CLB_CHE_ID, CLB_HST_ID, CLB_CappedCPUStrength, CLB_CappedMemoryMB, CLB_CappedNetworkSpeedMbit,
																		CLB_CappedDiskSizeMB, CLB_DiskBlockSize, CLB_CappedIOPS, CLB_CappedMBPerSec, CLB_BasePricePerMonthUSD, CLB_CMP_ID, CLB_PricePerDisk)
						values(@PSH_ID, @OST_ID, @CHA_ID, @CGR_ID, @CHE_ID, @HST_ID, @CPUStrength, @MemoryMB, @NetworkSpeedMbit, @MaxDiskSizeMB, @CurrentBlockSize,
								case @CurrentBlockSize
									when 8 then @MaxIOPS8KB
									when 64 then @MaxIOPS64KB
								end,
								case @CurrentBlockSize
									when 8 then @MaxMBPerSec8KB
									when 64 then @MaxMBPerSec64KB
								end, @Price, @CMP_ID, @PricePerDisk)

						set @CLB_ID = SCOPE_IDENTITY()
					end

					insert into Consolidation.ConsolidationBlocks_LoadBlocks(CBL_CLB_ID, CBL_LBL_ID, CBL_HST_ID, CBL_BufferedCPUStrength, CBL_BufferedMemoryMB,
																				CBL_BufferedNetworkDownloadSpeedMbit, CBL_BufferedNetworkUploadSpeedMbit, CBL_BufferedNetworkSpeedMbit,
																				CBL_BufferedDiskSizeMB, CBL_BufferedIOPS, CBL_BufferedMBPerSec, CBL_AvgMonthlyIOPS, CBL_AvgMonthlyNetworkOutboundMB,
																				CBL_AvgMonthlyNetworkInboundMB)
					values(@CLB_ID, @LBL_ID, @HST_ID, @MachineCPUStrength, @MachineMemoryMB, @MachineNetworkDownloadSpeedMbit, @MachineNetworkUploadSpeedMbit, @MachineNetworkSpeedMbit, @MachineDiskSizeMB,
							@MachineIOPS, @MachineMBPerSec, @MachineAvgMonthlyIOPS,	@MachineAvgMonthlyNetworkOutboundIO, @MachineAvgMonthlyNetworkInboundIO)
				
					merge #LoadBlockPopularity d
					using (select @HST_ID HST_ID, @LBL_ID LBL_ID)  s
						on HostTypeID = HST_ID
							and LoadBlockID = LBL_ID
						when matched then update set
												Popularity += 1
						when not matched then insert(HostTypeID, LoadBlockID, Popularity)
												values(HST_ID, LBL_ID, 1);
			
					set @CurrentMachineCount += 1
				end
		
			end
		
			if @CurrentMachineCount > 0
			begin
				set @CombinationCount += 1
				if @IsConsolidation = 1 and @IsCloud = 0 and @CurrentMachineCount = 1
					set @Saturated = 1
			end
			else
				set @Saturated = 1

		end
	
		if @PrintOutput = 1
			raiserror('@PSH_ID = %d, @CombinationCount = %d', 0, 0, @PSH_ID, @CombinationCount) with nowait
		fetch next from cPossibleHosts into @CLV_ID, @IsCloud, @PSH_ID, @MOB_ID, @HST_ID, @OST_ID, @PSH_CHA_ID, @PSH_CHE_ID, @CPUStrength, @MemoryMB, @NetworkSpeedMbit,
											@NetDownloadSpeedRatio, @NetUploadSpeedRatio, @MaxDiskSizeMB, @MaxIOPS8KB, @MaxMBPerSec8KB, @MaxIOPS64KB,
											@MaxMBPerSec64KB, @Storage_BUL_ID, @HostDiskCount, @Price, @CRG_ID, @CMP_ID, @IsConsolidation, @PricePerDisk
	end

	close cPossibleHosts
	deallocate cPossibleHosts

	--Eliminate Expensive Options for 1-to-1
	;with RankedBlocks as
			(select CLB_ID ID, ROW_NUMBER() over (partition by CLB_HST_ID, CBL_LBL_ID order by CLB_BasePricePerMonthUSD, CLB_PricePerDisk) rnk
				from Consolidation.ConsolidationBlocks
					inner join Consolidation.ConsolidationBlocks_LoadBlocks on CBL_CLB_ID = CLB_ID
					inner join Consolidation.HostTypes on HST_ID = CLB_HST_ID
				where HST_IsConsolidation = 0
					and HST_IsSharingOS = 1
			)
	update Consolidation.ConsolidationBlocks
	set CLB_DLR_ID = 1
	from RankedBlocks
	where CLB_ID = ID
		and rnk > 1

	if object_id('tempdb..#CB') is not null
		drop table #CB
	--Eliminate duplicate blocks
	select CLB_PSH_ID, CLB_ID, Sorted
	into #CB
	from Consolidation.ConsolidationBlocks e
		inner join Consolidation.HostTypes on HST_ID = CLB_HST_ID
		cross apply Consolidation.fn_OrderNumbers(CLB_ID, null) t
	where HST_IsConsolidation = 1
		and HST_IsSharingOS = 1

	create unique clustered index IX_#CB on #CB(CLB_PSH_ID, Sorted, CLB_ID)

	if object_id('tempdb..#DupCB') is not null
		drop table #DupCB

	select e.CLB_ID
	into #DupCB
	from #CB e
	where exists (select *
						from #CB e1 with (forceseek)
						where e1.CLB_PSH_ID = e.CLB_PSH_ID
							and e1.CLB_ID <> e.CLB_ID
							and (e1.Sorted like e.Sorted + ',%'
									or (e1.Sorted = e.Sorted
										and e1.CLB_ID < e.CLB_ID)
									)
					)
	create unique clustered index IX_#DupCB on #DupCB(CLB_ID)

	update e2
	set CLB_DLR_ID = 2
	from Consolidation.ConsolidationBlocks e2 with (forceseek)
	where exists (select *
					from #DupCB e
					where e.CLB_ID = e2.CLB_ID)
--END
GO
