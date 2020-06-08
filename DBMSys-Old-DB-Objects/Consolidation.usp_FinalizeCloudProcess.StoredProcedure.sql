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
/****** Object:  StoredProcedure [Consolidation].[usp_FinalizeCloudProcess]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Consolidation].[usp_FinalizeCloudProcess]
	@SlidingScale tinyint = 1, -- Between 0 and 5 -- Machines --> Price
	@ReturnResults bit = 1
as
BEGIN
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
		@DiskSizeCapPercentage int

	delete Consolidation.Exceptions where EXP_EXT_ID = 3

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

	declare @CPUBufferForCalculation decimal(10, 2) = 1 + @CPUBufferPercentage/100.,
			@MemoryBufferForCalculation decimal(10, 2) = 1 + @MemoryBufferPercentage/100.,
			@NetworkBufferForCalculation decimal(10, 2) = 1 + @NetworkBufferPercentage/100.,
			@DiskIOBufferForCalculation decimal(10, 2) = 1 + @DiskIOBufferPercentage/100.,
			@DiskSizeBufferForCalculation decimal(10, 2) = 1 + @DiskSizeBufferPercentage/100.,
			@CPUCapForCalculation decimal(10, 2) = @CPUCapPercentage/100.,
			@MemoryCapForCalculation decimal(10, 2) = @MemoryCapPercentage/100.,
			@NetworkCapForCalculation decimal(10, 2) = @NetworkCapPercentage/100.,
			@DiskIOCapForCalculation decimal(10, 2) = @DiskIOCapPercentage/100.,
			@DiskSizeCapForCalculation decimal(10, 2) = @DiskSizeCapPercentage/100.
	--Reset
	update Consolidation.ConsolidationBlocks_LoadBlocks
	set CBL_DLR_ID = null
	where CBL_DLR_ID in (4, 6)

	update Consolidation.ConsolidationBlocks
	set CLB_DLR_ID = null
	where CLB_DLR_ID in (4, 6)

	set nocount on
	if OBJECT_ID('tempdb..#BookedMachines') is not null
		drop table #BookedMachines

	create table #BookedMachines
		(HostType tinyint,
		BlockID int,
		SourceMachineID int)

	declare @Comb table(HostType tinyint,
						BlockID int,
						SourceMachineID int,
						BlockRank bigint,
						BlockMachines int)

	declare @Init bit = 1

	while @@ROWCOUNT > 0
		or @Init = 1
	begin
		if @Init = 1
			set @Init = 0

		;with Combinations as
				(select CLB_HST_ID HostType, CLB_ID BlockID, PSH_ID MachineID, CBL_LBL_ID SourceMachineID, PSH_PricePerMonthUSD + isnull(PSH_PricePerDisk, 0) Price,
						COUNT(*) over(partition by CLB_ID) BlockMachines
					from Consolidation.ConsolidationBlocks
						inner join Consolidation.ConsolidationBlocks_LoadBlocks on CBL_CLB_ID = CLB_ID
						inner join Consolidation.PossibleHosts on PSH_ID = CLB_PSH_ID
						inner join Consolidation.HostTypes on HST_ID = CLB_HST_ID
					where CLB_DLR_ID is null
						and CBL_DLR_ID is null
						and HST_IsCloud = 1
						and HST_IsConsolidation = 1
						and not exists (select *
											from #BookedMachines b
											where b.SourceMachineID = CBL_LBL_ID
												and b.HostType = CBL_HST_ID)
				)
			, Comb as
				(select *,
						row_number() over (partition by HostType, SourceMachineID order by power(BlockMachines, 5)*1./isnull(nullif(power(Price, @SlidingScale), 0), 1) desc, BlockID) BlockRank
					from Combinations
				)
		insert into @Comb
		select distinct HostType, BlockID, SourceMachineID, BlockRank, BlockMachines
		from Comb

		insert into #BookedMachines
		select HostType, BlockID, SourceMachineID
		from @Comb
		where BlockID in (select BlockID
							from @Comb
							where BlockRank = 1
							group by BlockID, BlockMachines
							having BlockMachines = COUNT(*)
						)
	
		delete @Comb
	end

	update Consolidation.ConsolidationBlocks_LoadBlocks
	set CBL_DLR_ID = 6
	from Consolidation.HostTypes
	where HST_ID = CBL_HST_ID
		and HST_IsCloud = 1
		and HST_IsConsolidation = 1
		and CBL_DLR_ID is null
		and not exists (select *
						from #BookedMachines
						where BlockID = CBL_CLB_ID
							and SourceMachineID = CBL_LBL_ID)

	update Consolidation.ConsolidationBlocks
	set CLB_DLR_ID = 4
	from Consolidation.HostTypes
	where HST_ID = CLB_HST_ID
		and HST_IsCloud = 1
		and HST_IsConsolidation = 1
		and CLB_DLR_ID is null
		and not exists (select *
							from Consolidation.ConsolidationBlocks_LoadBlocks
							where CBL_CLB_ID = CLB_ID
								and CBL_DLR_ID is null
						)

	update Consolidation.ConsolidationBlocks_LoadBlocks
	set CBL_DLR_ID = 4
	from Consolidation.HostTypes, Consolidation.ConsolidationBlocks_LoadBlocks
	where HST_ID = CBL_HST_ID
		and HST_IsCloud = 1
		and HST_IsConsolidation = 1
		and CBL_DLR_ID is null
		and not exists (select *
							from Consolidation.ConsolidationBlocks
							where CLB_ID = CBL_CLB_ID
								and CLB_DLR_ID is null
						)

	--Refitting
	;with Hosts as
			(select PSH_ID,
						PSH_HST_ID,
						PSH_CMT_ID,
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
						case when HST_IsLimitedByDisk = 1 then PSH_MaxDiskCount end DiskCount,
						PSH_OST_ID,
						PSH_PricePerMonthUSD,
						PSH_CRG_ID,
						PSH_CHE_ID,
						PSH_CMP_ID,
						PSH_PricePerDisk
				from Consolidation.PossibleHosts
					inner join Consolidation.HostTypes on HST_ID = PSH_HST_ID
					inner join Consolidation.CloudMachineTypes on CMT_ID = PSH_CMT_ID
				where HST_IsCloud = 1
					and HST_IsConsolidation = 1
			)
		, Blocks as
			(select CLB_HST_ID, CGG_CRG_ID, CLB_ID BlockID, CLB_PSH_ID, CLB_BasePricePerMonthUSD, CLB_DiskBlockSize, CLB_CGR_ID, CLB_OST_ID, CLB_CHA_ID, CLB_CHE_ID, PSH_CHE_ID Host_CHE_ID,
					sum(CBL_BufferedCPUStrength) BufferedCPUStrength,
					sum(CBL_BufferedMemoryMB) BufferedMemoryMB,
					sum(CBL_BufferedNetworkDownloadSpeedMbit) BufferedNetworkDownloadSpeedMbit,
					sum(CBL_BufferedNetworkUploadSpeedMbit) BufferedNetworkUploadSpeedMbit,
					sum(CBL_BufferedDiskSizeMB) BufferedDiskSizeMB,
					sum(CBL_BufferedIOPS) BufferedIOPS,
					sum(CBL_BufferedMBPerSec) BufferedMBPerSec,
					max(cast(LBL_HasSoftwareAssurance as int)) HasSoftwareAssurance,
					CLB_PricePerDisk
				from Consolidation.ConsolidationBlocks
					inner join Consolidation.ConsolidationBlocks_LoadBlocks on CBL_CLB_ID = CLB_ID
					inner join Consolidation.LoadBlocks on LBL_ID = CBL_LBL_ID
					inner join Consolidation.HostTypes on HST_ID = CLB_HST_ID
					inner join Consolidation.ConsolidationGroups_CloudRegions on CGG_CGR_ID = CLB_CGR_ID
					inner join Consolidation.PossibleHosts on PSH_ID = CLB_PSH_ID
				where HST_IsCloud = 1
					and HST_IsConsolidation = 1
					and CLB_DLR_ID is null
					and CBL_DLR_ID is null
				group by CLB_HST_ID, CGG_CRG_ID, CLB_ID, CLB_PSH_ID, CLB_BasePricePerMonthUSD, CLB_DiskBlockSize, CLB_CGR_ID, CLB_OST_ID, CLB_CHA_ID, CLB_CHE_ID, PSH_CHE_ID, CLB_PricePerDisk
			)
	update Consolidation.ConsolidationBlocks
	set CLB_PSH_ID = PSH_ID,
		CLB_CappedCPUStrength = CPUStrength,
		CLB_CappedMemoryMB = MemoryMB,
		CLB_CappedNetworkSpeedMbit = NetworkSpeedMbit,
		CLB_CappedDiskSizeMB = DiskSizeMB,
		CLB_CappedIOPS = case b.CLB_DiskBlockSize
								when 8 then MaxIOPS8KB
								when 64 then MaxIOPS64KB
							end,
		CLB_CappedMBPerSec = case b.CLB_DiskBlockSize
									when 8 then MaxMBPerSec8KB
									when 64 then MaxMBPerSec64KB
								end,
		CLB_BasePricePerMonthUSD = PSH_PricePerMonthUSD,
		CLB_BasePriceWithSQLLicensePerMonthUSD = PSH_PricePerMonthUSD,
		CLB_CMP_ID = PSH_CMP_ID,
		CLB_PricePerDisk = PSH_PricePerDisk
	from Blocks b
		cross apply (select top 1 *
						from Hosts
						where PSH_HST_ID = CLB_HST_ID
							and (PSH_OST_ID = CLB_OST_ID
									or (PSH_OST_ID is null
										and CLB_OST_ID is null)
								)
							and PSH_PricePerMonthUSD + PSH_PricePerDisk < CLB_BasePricePerMonthUSD + CLB_PricePerDisk
							and CPUStrength > BufferedCPUStrength
							and MemoryMB > BufferedMemoryMB
							and NetworkSpeedMbit > BufferedNetworkDownloadSpeedMbit*PSH_NetDownloadSpeedRatio + BufferedNetworkUploadSpeedMbit*PSH_NetUploadSpeedRatio
							and DiskSizeMB > BufferedDiskSizeMB
							and case b.CLB_DiskBlockSize
									when 8 then MaxIOPS8KB
									when 64 then MaxIOPS64KB
								end > BufferedIOPS
							and case b.CLB_DiskBlockSize
									when 8 then MaxMBPerSec8KB
									when 64 then MaxMBPerSec64KB
								end > BufferedMBPerSec
							and PSH_CRG_ID = CGG_CRG_ID
							and (Host_CHE_ID = PSH_CHE_ID
								or (Host_CHE_ID is null
									and PSH_CHE_ID is null)
								)
						order by PSH_PricePerMonthUSD, PSH_PricePerDisk
					) h
	where BlockID = CLB_ID

	insert into Consolidation.Exceptions
	select 3, LBL_MOB_ID, IDB_ID,
		isnull(Reasons, '') Reasons, P_HST_ID
	from Consolidation.LoadBlocks l
		left join Inventory.InstanceDatabases on IDB_ID = LBL_IDB_ID
		inner join Consolidation.ServerGrouping on SGR_MOB_ID = LBL_MOB_ID
		inner join Consolidation.ConsolidationGroups on CGR_ID = SGR_CGR_ID
		inner join Consolidation.ConsolidationGroups_CloudRegions on CGG_CGR_ID = CGR_ID
		cross apply (select P_HST_ID, Reasons
						from Consolidation.LoadBlocks r
							cross apply (select P_HST_ID, stuff(case when LBL_CPUStrength*@CPUBufferForCalculation > PSH_CPUStrength*@CPUCapForCalculation
																Then ', CPU Strength needed is ' + CAST(cast(PSH_CPUStrength*@CPUCapForCalculation*100/(LBL_CPUStrength*@CPUBufferForCalculation) as decimal(10, 2)) as varchar(100))
																			+ '% stronger than available'
																else ''
															end
															+ case when LBL_MemoryMB*@MemoryBufferForCalculation > PSH_MemoryMB*@MemoryCapForCalculation
																	Then ', Memory (MB) needed = ' + CAST(LBL_MemoryMB*@MemoryBufferForCalculation as varchar(100))
																			+ ' - Max Available = ' + CAST(PSH_MemoryMB*@MemoryCapForCalculation as varchar(100))
																	else ''
																end
															+ case when LBL_DiskSize*@DiskSizeBufferForCalculation > PSH_MaxDiskSizeMB*@DiskSizeCapForCalculation
																	Then ', Disk Size (MB) needed = ' + CAST(LBL_DiskSize*@DiskSizeBufferForCalculation as varchar(100))
																			+ ' - Max Available = ' + CAST(PSH_MaxDiskSizeMB*@DiskSizeCapForCalculation as varchar(100))
																	else ''
																end
															+ case when IOPs > MaxIOPs*@DiskIOCapForCalculation
																	Then ', Disk IOPS needed = ' + CAST(IOPs as varchar(100))
																			+ '@' + CAST(LBL_BlockSize as varchar(3)) + 'KB Block Size'
																			+ ' - Max Available = ' + CAST(MaxIOPs*@DiskIOCapForCalculation as varchar(100))
																	else ''
																end															
															+ case when MBPs > MaxMBPs*@DiskIOCapForCalculation
																	Then ', Disk MB/sec needed = ' + CAST(MBPs as varchar(100))
																			+ '@' + CAST(LBL_BlockSize as varchar(3)) + 'KB Block Size'
																			+ ' - Max Available = ' + CAST(MaxMBPs*@DiskIOCapForCalculation as varchar(100))
																	else ''
															+ case when (LBL_NetworkUsageDownloadMbit*PSH_NetDownloadSpeedRatio + LBL_NetworkUsageUploadMbit*PSH_NetUploadSpeedRatio)*@NetworkBufferForCalculation
																			> PSH_NetworkSpeedMbit*@NetworkCapForCalculation
																	Then ', Network bandwidth = ' + CAST((LBL_NetworkUsageDownloadMbit*PSH_NetDownloadSpeedRatio + LBL_NetworkUsageUploadMbit*PSH_NetUploadSpeedRatio)*@NetworkBufferForCalculation as varchar(100))
																			+ ' - Max Available = ' + CAST(PSH_NetworkSpeedMbit*@NetworkCapForCalculation as varchar(100))
																	else ''
																end
															end																													
															, 1, 2, '')
														Reasons
											from (select PSH_HST_ID P_HST_ID, max(PSH_CPUStrength) PSH_CPUStrength, max(PSH_MemoryMB) PSH_MemoryMB, max(PSH_MaxDiskCount) PSH_MaxDiskCount, max(PSH_MaxDiskSizeMB) PSH_MaxDiskSizeMB,
														max(PSH_NetworkSpeedMbit) PSH_NetworkSpeedMbit
													from Consolidation.PossibleHosts
														inner join Consolidation.HostTypes on HST_ID = PSH_HST_ID
														left join Consolidation.CloudMachinesDiskFactors c on CDF_BUL_ID = PSH_Storage_BUL_ID
																											and CDF_DiskCount = PSH_MaxDiskCount
																											and CDF_BlockSize = LBL_BlockSize
													where HST_IsCloud = 1
														and (PSH_OST_ID = LBL_OST_ID
															or (PSH_OST_ID is null
																and PSH_CHA_ID = LBL_CHA_ID
																)
															)
														and PSH_CRG_ID = CGG_CRG_ID
														and (PSH_CHE_ID = LBL_CHE_ID
															or PSH_CHE_ID is null)
													group by PSH_HST_ID
													) p
												cross apply (select top 1 PSH_NetDownloadSpeedRatio, PSH_NetUploadSpeedRatio
																from Consolidation.PossibleHosts p1
																where p1.PSH_HST_ID = P_HST_ID
																	and (p1.PSH_OST_ID = LBL_OST_ID
																		or (p1.PSH_OST_ID is null
																			and p1.PSH_CHA_ID = LBL_CHA_ID
																			)
																		)
																	and p1.PSH_CRG_ID = CGG_CRG_ID
																	and (p1.PSH_CHE_ID = LBL_CHE_ID
																		or p1.PSH_CHE_ID is null)
																	and p1.PSH_NetworkSpeedMbit = p.PSH_NetworkSpeedMbit) p1
												cross apply (select top 1 LBL_ReadsMBSec*ISNULL(CDF_ReadsMBFactor, 1) + LBL_WritesMBSec*ISNULL(CDF_WritesMBFactor, 1) IOPs,
																	case LBL_BlockSize
																			when 8 then PSH_MaxIOPS8KB
																			when 64 then PSH_MaxIOPS64KB
																		end MaxIOPs
																from Consolidation.PossibleHosts p2
																	left join Consolidation.CloudMachinesDiskFactors c on CDF_BUL_ID = p2.PSH_Storage_BUL_ID
																														and CDF_DiskCount = PSH_MaxDiskCount
																														and CDF_BlockSize = LBL_BlockSize
																where p2.PSH_HST_ID = P_HST_ID
																	and (p2.PSH_OST_ID = LBL_OST_ID
																		or (p2.PSH_OST_ID is null
																			and p2.PSH_CHA_ID = LBL_CHA_ID
																			)
																		)
																	and p2.PSH_CRG_ID = CGG_CRG_ID
																	and (p2.PSH_CHE_ID = LBL_CHE_ID
																		or p2.PSH_CHE_ID is null)
																order by MaxIOPs desc
																) p2
												cross apply (select top 1 LBL_ReadsMBSec*ISNULL(CDF_ReadsMBFactor, 1) + LBL_WritesMBSec*ISNULL(CDF_WritesMBFactor, 1) MBPs,
																	case LBL_BlockSize
																			when 8 then PSH_MaxMBPerSec8KB
																			when 64 then PSH_MaxMBPerSec64KB
																		end MaxMBPs
																from Consolidation.PossibleHosts p3
																	left join Consolidation.CloudMachinesDiskFactors c on CDF_BUL_ID = p3.PSH_Storage_BUL_ID
																														and CDF_DiskCount = PSH_MaxDiskCount
																														and CDF_BlockSize = LBL_BlockSize
																where p3.PSH_HST_ID = P_HST_ID
																	and (p3.PSH_OST_ID = LBL_OST_ID
																		or (p3.PSH_OST_ID is null
																			and p3.PSH_CHA_ID = LBL_CHA_ID
																			)
																		)
																	and p3.PSH_CRG_ID = CGG_CRG_ID
																	and (p3.PSH_CHE_ID = LBL_CHE_ID
																		or p3.PSH_CHE_ID is null)
																order by MaxMBPs desc
																) p3
											where (LBL_CPUStrength*@CPUBufferForCalculation > PSH_CPUStrength*@CPUCapForCalculation
														or LBL_MemoryMB*@MemoryBufferForCalculation > PSH_MemoryMB*@MemoryCapForCalculation
														or LBL_DiskSize*@DiskSizeBufferForCalculation > PSH_MaxDiskSizeMB*@DiskSizeCapForCalculation
														or IOPs > MaxIOPs*@DiskIOCapForCalculation
														or MBPs > MaxMBPs*@DiskIOCapForCalculation
														or (LBL_NetworkUsageDownloadMbit*PSH_NetDownloadSpeedRatio + LBL_NetworkUsageUploadMbit*PSH_NetUploadSpeedRatio)*@NetworkBufferForCalculation
																> PSH_NetworkSpeedMbit*@NetworkCapForCalculation
													)
											) p
						where r.LBL_ID = l.LBL_ID
					) r

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
				FROM	Consolidation.ServerPossibleHostTypes
				JOIN	Consolidation.HostTypes ON HST_ID = SHT_HST_ID
				WHERE	HST_CLV_ID = 5
				)
	BEGIN

		EXEC Consolidation.usp_Reports_AzureDBMILimitingFeatures 0
		
		DELETE FROM #DBMILFeature WHERE CanMoveToAzureDBMI = 1

		;WITH list AS 
		(
			SELECT 
					MOBID
					,CLVID
					,f.value AS Val
			FROM	#DBMILFeature
			CROSS APPLY string_split(Reason,',')f
		)
		
		INSERT INTO Consolidation.Exceptions
		SELECT	DISTINCT 
				3
				,MOBID
				,NULL
				,isnull(stuff((SELECT DISTINCT N', ' + l2.Val
						FROM list l2
					WHERE	l1.MOBID = l2.MOBID
							AND l1.CLVID = l2.CLVID
					ORDER BY 1
					FOR XML PATH(''), TYPE).value('.', 'nvarchar(4000)'),1,1,N''),N'') as reason
				,HST_ID
		FROM	list l1
		JOIN	Consolidation.ParticipatingDatabaseServers on PDS_Server_MOB_ID = MOBID
		JOIN	Consolidation.HostTypes ON HST_CLV_ID = CLVID
	END

	insert into Consolidation.Exceptions
	select 3, LBL_MOB_ID, LBL_IDB_ID, 'No hosting possibility for the given workload in this cloud platform', PSH_HST_ID
	from Consolidation.LoadBlocks
		inner join Consolidation.ServerGrouping on SGR_MOB_ID = LBL_MOB_ID
		inner join Consolidation.ConsolidationGroups on CGR_ID = SGR_CGR_ID
		inner join Consolidation.ConsolidationGroups_CloudRegions on CGG_CGR_ID = CGR_ID
		cross apply (select distinct PSH_HST_ID 
						from Consolidation.PossibleHosts
							inner join Consolidation.PossibleHostsConsolidationGroupAffinity on PSA_PSH_ID = PSH_ID
						where CGG_CRG_ID = PSH_CRG_ID
							and PSA_CGR_ID = CGR_ID) p
		inner join Consolidation.ServerPossibleHostTypes on SHT_MOB_ID = LBL_MOB_ID
													and SHT_HST_ID = PSH_HST_ID
	where not exists (select *
						from Consolidation.ConsolidationBlocks_LoadBlocks
						where CBL_LBL_ID = LBL_ID
							and CBL_HST_ID = PSH_HST_ID)
		and not exists (select *
						from Consolidation.Exceptions
						where EXP_MOB_ID = LBL_MOB_ID
							and EXP_EXT_ID = 3
							and EXP_HST_ID = PSH_HST_ID)

	if @ReturnResults = 1
		exec Consolidation.usp_GetPriceIndex
END
GO
