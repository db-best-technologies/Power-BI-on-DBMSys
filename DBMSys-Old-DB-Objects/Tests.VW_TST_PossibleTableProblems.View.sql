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
/****** Object:  View [Tests].[VW_TST_PossibleTableProblems]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_PossibleTableProblems]
as
select top 0 CAST(null as nvarchar(128)) DatabaseName,
			CAST(null as nvarchar(128)) SchemaName,
			CAST(null as nvarchar(128)) TableName,
			CAST(null as bit) HasClusteredIndex,
			CAST(null as bit) HasPrimaryKey,
			CAST(null as bit) IsVarDecimalStorage,
			CAST(null as int) ColumnCount,
			CAST(null as int) IndexCount,
			CAST(null as bigint) RowCnt,
			CAST(null as bigint) TotalSizeMB,
			CAST(null as bigint) range_scan_count,
			CAST(null as bigint) row_lock_wait_count,
			CAST(null as bigint) row_lock_wait_in_ms,
			CAST(null as bigint) page_lock_wait_count,
			CAST(null as bigint) page_lock_wait_in_ms,
			CAST(null as bigint) index_lock_promotion_attempt_count,
			CAST(null as bigint) index_lock_promotion_count,
			CAST(null as tinyint) PercentOfClusteredIndexOrHeapPartitionsCompressed,
			CAST(null as tinyint) PercentOfNonClusteredIndexPartitionsCompressed,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_PossibleTableProblems]    Script Date: 6/8/2020 1:16:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_PossibleTableProblems] on [Tests].[VW_TST_PossibleTableProblems]
	instead of insert
as
set nocount on
declare @MOB_ID int,
		@StartDate datetime2(3)
select top 1 @MOB_ID = TRH_MOB_ID,
			@StartDate = TRH_StartDate
from inserted
	inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID

merge Inventory.InstanceDatabases s
	using (select DatabaseName, Metadata_TRH_ID, Metadata_ClientID
			from inserted) d
		on IDB_MOB_ID = @MOB_ID
			and IDB_Name = DatabaseName
	when not matched then insert(IDB_ClientID, IDB_MOB_ID, IDB_Name, IDB_InsertDate, IDB_LastSeenDate, IDB_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, DatabaseName, @StartDate, @StartDate, Metadata_TRH_ID);

merge Inventory.DatabaseSchemaNames d
	using (select distinct SchemaName
			from inserted
			where SchemaName is not null) s
		on SchemaName = DSN_Name
	when not matched then insert (DSN_Name)
							values(SchemaName);

merge Inventory.DatabaseObjectNames d
	using (select distinct TableName
			from inserted
			where TableName is not null) s
		on TableName = DON_Name
	when not matched then insert (DON_Name)
							values(TableName);

merge Inventory.PossibleTableProblems d
	using (select IDB_ID, DSN_ID, DON_ID, HasPrimaryKey, HasClusteredIndex, IsVarDecimalStorage, ColumnCount, IndexCount, RowCnt, TotalSizeMB, range_scan_count, row_lock_wait_count,
				row_lock_wait_in_ms, page_lock_wait_count, page_lock_wait_in_ms, index_lock_promotion_attempt_count, index_lock_promotion_count, PercentOfClusteredIndexOrHeapPartitionsCompressed,
				PercentOfNonClusteredIndexPartitionsCompressed, Metadata_TRH_ID, Metadata_ClientID
			from inserted
				inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
														and IDB_Name = DatabaseName
				inner join Inventory.DatabaseSchemaNames on SchemaName = DSN_Name
				inner join Inventory.DatabaseObjectNames on TableName = DON_Name) s
		on PTP_MOB_ID = @MOB_ID
			and PTP_IDB_ID = IDB_ID
			and PTP_DSN_ID = DSN_ID
			and PTP_DON_ID = DON_ID
	when matched then update set
							PTP_HasPrimaryKey = HasPrimaryKey,
							PTP_HasClusteredIndex = HasClusteredIndex,
							PTP_IsVarDecimalStorage = IsVarDecimalStorage,
							PTP_ColumnCount = ColumnCount,
							PTP_IndexCount = IndexCount,
							PTP_RowCount = RowCnt,
							PTP_TotalSizeMB = TotalSizeMB,
							PTP_RangeScanCount = range_scan_count,
							PTP_RowLockWaitCount = row_lock_wait_count,
							PTP_RowLockWaitInMS = row_lock_wait_in_ms,
							PTP_PageLockWaitCount = page_lock_wait_count,
							PTP_PageLockWaitInMS = page_lock_wait_in_ms,
							PTP_IndexLockPromotionAttemptCount = index_lock_promotion_attempt_count,
							PTP_IndexLockPromotionCount = index_lock_promotion_count,
							PTP_PercentOfClusteredIndexOrHeapPartitionsCompressed = PercentOfClusteredIndexOrHeapPartitionsCompressed,
							PTP_PercentOfNonClusteredIndexPartitionsCompressed = PercentOfNonClusteredIndexPartitionsCompressed,
							PTP_LastSeenDate = @StartDate,
							PTP_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(PTP_ClientID, PTP_MOB_ID, PTP_IDB_ID, PTP_DSN_ID, PTP_DON_ID, PTP_HasPrimaryKey, PTP_HasClusteredIndex, PTP_IsVarDecimalStorage, PTP_ColumnCount,
									PTP_IndexCount, PTP_RowCount, PTP_TotalSizeMB, PTP_RangeScanCount, PTP_RowLockWaitCount, PTP_RowLockWaitInMS, PTP_PageLockWaitCount, PTP_PageLockWaitInMS,
									PTP_IndexLockPromotionAttemptCount, PTP_IndexLockPromotionCount, PTP_PercentOfClusteredIndexOrHeapPartitionsCompressed,
									PTP_PercentOfNonClusteredIndexPartitionsCompressed, PTP_InsertDate, PTP_LastSeenDate, PTP_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IDB_ID, DSN_ID, DON_ID, HasPrimaryKey, HasClusteredIndex, IsVarDecimalStorage, ColumnCount, IndexCount, RowCnt, TotalSizeMB,
									range_scan_count, row_lock_wait_count, row_lock_wait_in_ms, page_lock_wait_count, page_lock_wait_in_ms, index_lock_promotion_attempt_count,
									index_lock_promotion_count, PercentOfClusteredIndexOrHeapPartitionsCompressed, PercentOfNonClusteredIndexPartitionsCompressed, @StartDate, @StartDate,
									Metadata_TRH_ID);
GO
