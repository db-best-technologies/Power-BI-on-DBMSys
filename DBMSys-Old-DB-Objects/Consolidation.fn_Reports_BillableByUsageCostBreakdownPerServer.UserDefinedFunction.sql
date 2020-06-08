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
/****** Object:  UserDefinedFunction [Consolidation].[fn_Reports_BillableByUsageCostBreakdownPerServer]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [Consolidation].[fn_Reports_BillableByUsageCostBreakdownPerServer](@MOB_ID int, @CLV_ID tinyint, @StorageRedundancyLevelName varchar(100)) returns table
as
return (with Pricing as
				(select ItemType, ItemLevel, FromValue, ToValue, Price, BUP_CLZ_ID, BUP_CRG_ID, PricePerPackage, BUL_BUR_ID, CSL_Level StorageRedundancyLevel, CSL_Name StorageRedundancyLevelName, ItemLevelName
					from Consolidation.BillableByUsageItemLevels
						cross apply (select BUL_BUI_ID ItemType, BUL_ID ItemLevel, isnull(l.BUP_UpToNumberOfUnits, 0) FromValue, u.BUP_UpToNumberOfUnits ToValue, u.BUP_PricePerUnit Price, BUP_CLZ_ID, BUP_CRG_ID,
											BUP_PricePerPackage PricePerPackage, CSL_Level, CSL_Name, BUL_Name ItemLevelName
										from Consolidation.BillableByUsageItemLevelPricingScheme u
											left join Consolidation.CloudStorageRedundancyLevels on CSL_ID = BUP_CSL_ID
											outer apply (select top 1 l.BUP_UpToNumberOfUnits, l.BUP_PricePerUnit
															from Consolidation.BillableByUsageItemLevelPricingScheme l
															where l.BUP_BUL_ID = u.BUP_BUL_ID
																and (l.BUP_CSL_ID = u.BUP_CSL_ID
																		or (l.BUP_CSL_ID is null
																			and u.BUP_CSL_ID is null
																			)
																	)
																and (l.BUP_CLZ_ID = u.BUP_CLZ_ID
																		or (l.BUP_CLZ_ID is null
																			and u.BUP_CLZ_ID is null
																			)
																	)
																and (u.BUP_UpToNumberOfUnits > l.BUP_UpToNumberOfUnits
																		or (u.BUP_UpToNumberOfUnits is null
																				and l.BUP_UpToNumberOfUnits is not null
																			)
																	)
															order by isnull(l.BUP_UpToNumberOfUnits, POWER(cast(2 as bigint), 31)) desc
														) l
										where BUL_CLV_ID = @CLV_ID
											and BUL_IsActive = 1
											and BUL_ID = BUP_BUL_ID
								) u
				)
			, UniqueLoadBlock as
				(select distinct LBL_MOB_ID BBU_MOB_ID, PSH_Storage_BUL_ID, CBL_BufferedDiskSizeMB,
								cast(iif(HST_UseMonthlyIOPS = 1, CBL_AvgMonthlyIOPS/100000., iif(BSI_DominantBlockSize > 32 and @CLV_ID in (2, 3), 2, 1)*CBL_BufferedIOPS) as bigint) IOPS, CBL_AvgMonthlyNetworkOutboundMB,
								CRG_ID, CRG_CLZ_ID, CRG_Name
					from Consolidation.ConsolidationBlocks c
						inner join Consolidation.ConsolidationBlocks_LoadBlocks on CBL_CLB_ID = CLB_ID
						inner join Consolidation.ConsolidationGroups on CGR_ID = CLB_CGR_ID
						inner join Consolidation.ConsolidationGroups_CloudRegions on CGG_CGR_ID = CGR_ID
						inner join Consolidation.HostTypes on HST_ID = CLB_HST_ID
						inner join Consolidation.CloudRegions on CRG_ID = CGG_CRG_ID
																	and CRG_CLV_ID = HST_CLV_ID
						inner join Consolidation.PossibleHosts on PSH_ID = CLB_PSH_ID
						inner join Consolidation.LoadBlocks on LBL_ID = CBL_LBL_ID
						inner join Consolidation.BlockSizes on BSI_MOB_ID = LBL_MOB_ID
					where HST_CLV_ID = @CLV_ID
						and (LBL_MOB_ID = @MOB_ID or @MOB_ID is null)
						and CLB_DLR_ID is null
						and CBL_DLR_ID is null
				)
			, Summary as
				(select BBU_MOB_ID, CRG_ID, CRG_CLZ_ID, CRG_Name, PSH_Storage_BUL_ID,
							SUM(CBL_BufferedDiskSizeMB)/1024 [1],
							SUM(IOPS) [2],
							SUM(CBL_AvgMonthlyNetworkOutboundMB)/1024 [3],
							grouping(PSH_Storage_BUL_ID) G1,
							grouping(CRG_Name) G2
					from UniqueLoadBlock
					group by BBU_MOB_ID, CRG_ID, CRG_CLZ_ID, CRG_Name, PSH_Storage_BUL_ID with rollup
				)
			, SummaryUP as
				(select BBU_MOB_ID, CRG_ID, CRG_CLZ_ID, CRG_Name, BillableItemType, Value, PSH_Storage_BUL_ID
					from Summary
						unpivot (Value FOR BillableItemType in ([2], [3])) u
					where G1 = 1
						and G2 = 0
					union
					select BBU_MOB_ID, CRG_ID, CRG_CLZ_ID, CRG_Name, BillableItemType, Value, PSH_Storage_BUL_ID
					from Summary
						unpivot (Value FOR BillableItemType in ([1])) u
					where PSH_Storage_BUL_ID is not null
						and G1 = 0
				)
			, BilledItems as
				(select BBU_MOB_ID, BUI_Name [ItemType],
						case when Value - FromValue > ToValue
								then ToValue
								else Value - FromValue
							end Units, Price PricePerUnit,
							ItemLevel, PricePerPackage, Value TotalUnits, BUL_BUR_ID, StorageRedundancyLevel, StorageRedundancyLevelName, ItemLevelName,
							dense_rank() over(partition by ItemLevel order by FromValue desc) ValueRank
					from SummaryUP
						inner join Consolidation.BillableByUsageItems on BUI_ID = BillableItemType
						inner join Pricing p on ItemType = BillableItemType
											and (ItemLevel = PSH_Storage_BUL_ID
													or PSH_Storage_BUL_ID is null)
											and FromValue <= Value
											and ((exists (select * from Pricing p1 where p1.ItemType = p.ItemType
																						and p1.ItemLevel = p.ItemLevel
																						and p1.BUP_CRG_ID = CRG_ID
															)
														and p.BUP_CRG_ID = CRG_ID)
													or
												(not exists (select * from Pricing p1 where p1.ItemType = p.ItemType
																						and p1.ItemLevel = p.ItemLevel
																						and p1.BUP_CRG_ID = CRG_ID
															)
														and p.BUP_CRG_ID is null)
												)
				)
			, ItemPricingOptions as
				(select BBU_MOB_ID, ItemType, ItemLevelName, Units, PricePerUnit, Units * PricePerUnit AmountToPay, BUL_BUR_ID, StorageRedundancyLevel, StorageRedundancyLevelName
					from BilledItems
					where PricePerPackage is null
					union all
					select BBU_MOB_ID, ItemType, ItemLevelName, TotalUnits Units, PricePerPackage/TotalUnits PricePerUnit, PricePerPackage AmountToPay, BUL_BUR_ID, StorageRedundancyLevel, StorageRedundancyLevelName
					from BilledItems
					where PricePerPackage is not null
						and ValueRank = 1
				)
			, ItemPricingOptionsWithTotal as
				(select BBU_MOB_ID, ItemType, ItemLevelName, Units, PricePerUnit, AmountToPay, BUL_BUR_ID, StorageRedundancyLevel, StorageRedundancyLevelName,
						sum(isnull(AmountToPay, 9999999)) over(partition by ItemLevelName) TotalAmountPerItemLevel
					from ItemPricingOptions
				)
			, ItemPricingOptionsRanked as
				(select BBU_MOB_ID, ItemType, ItemLevelName, Units, PricePerUnit, AmountToPay, BUL_BUR_ID, StorageRedundancyLevel, StorageRedundancyLevelName, TotalAmountPerItemLevel,
						dense_rank() over(partition by ItemType order by TotalAmountPerItemLevel) PriceRank
					from ItemPricingOptionsWithTotal
				)
			, Final as
				(select BBU_MOB_ID, ItemType, isnull(cast(iif(min(PricePerUnit) = 0, null, sum(AmountToPay)) as decimal(15, 3)), 0) AmountToPay
					from ItemPricingOptionsRanked
					where (PriceRank = 1
							or BUL_BUR_ID = 1)
						and (StorageRedundancyLevelName = @StorageRedundancyLevelName
								or StorageRedundancyLevelName is null)
					group by BBU_MOB_ID, ItemType, ItemLevelName, StorageRedundancyLevel, StorageRedundancyLevelName
				)
			, Pvt as
				(select BBU_MOB_ID, [Network usage], [Storage space], [Storage transactions]
					from Final
						pivot (avg(AmountToPay)
								for ItemType IN ([Network usage], [Storage space], [Storage transactions])
							) p
				)
			select BBU_MOB_ID, cast(isnull([Network usage], 0) as decimal(10, 2)) NetworkUsage, cast(isnull([Storage space], 0) as decimal(10, 2)) StorageSpace,
				cast(isnull([Storage transactions], 0) as decimal(10, 2)) StorageTransactions
			from Pvt
	)
GO
