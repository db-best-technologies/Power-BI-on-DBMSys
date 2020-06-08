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
/****** Object:  View [Tests].[VW_TST_FragmentedIndexes]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_FragmentedIndexes]
as
select top 0 CAST(null as nvarchar(128)) DatabaseName,
			CAST(null as nvarchar(60)) ObjectType,
			CAST(null as nvarchar(128)) SchemaName,
			CAST(null as nvarchar(128)) ObjectName,
			CAST(null as int) IndexID,
			CAST(null as tinyint) IndexType,
			CAST(null as nvarchar(128)) IndexName,
			CAST(null as int) PartitionNumber,
			CAST(null as tinyint) AllocationUnitType,
			CAST(null as tinyint) index_depth,
			CAST(null as decimal(6, 4)) avg_fragmentation_in_percent,
			CAST(null as decimal(6, 4)) avg_page_space_used_in_percent,
			CAST(null as bigint) ghost_record_count,
			CAST(null as int) min_record_size_in_bytes,
			CAST(null as int) max_record_size_in_bytes,
			CAST(null as decimal(7, 2)) avg_record_size_in_bytes,
			CAST(null as bigint) forwarded_record_count,
			CAST(null as bigint) compressed_page_count,
			CAST(null as bigint) NumberOfRows,
			CAST(null as bigint) SizeMB,
			CAST(null as tinyint) fill_factor,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_FragmentedIndexes]    Script Date: 6/8/2020 1:16:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_FragmentedIndexes] on [Tests].[VW_TST_FragmentedIndexes]
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

merge Inventory.DatabaseObjectTypes d
	using (select distinct ObjectType
			from inserted
			where ObjectType is not null) s
		on ObjectType = DOT_OriginalCode
	when not matched then insert (DOT_OriginalCode, DOT_DisplayName)
							values(ObjectType, ObjectType);

merge Inventory.DatabaseSchemaNames d
	using (select distinct SchemaName
			from inserted
			where SchemaName is not null) s
		on SchemaName = DSN_Name
	when not matched then insert (DSN_Name)
							values(SchemaName);

merge Inventory.DatabaseObjectNames d
	using (select distinct ObjectName
			from inserted
			where ObjectName is not null) s
		on ObjectName = DON_Name
	when not matched then insert (DON_Name)
							values(ObjectName);
							
merge Inventory.DatabaseIndexNames d
	using (select distinct IndexName
			from inserted
			where IndexName is not null) s
		on IndexName = DIN_Name
	when not matched then insert (DIN_Name)
							values(IndexName);

merge Inventory.FragmentedIndexes d
	using (select IDB_ID, DOT_ID, DSN_ID, DON_ID, IndexID, IndexType, DIN_ID, PartitionNumber, AllocationUnitType, index_depth, avg_fragmentation_in_percent,
				avg_page_space_used_in_percent, ghost_record_count, min_record_size_in_bytes, max_record_size_in_bytes, avg_record_size_in_bytes, forwarded_record_count,
				compressed_page_count, NumberOfRows, SizeMB, fill_factor, Metadata_TRH_ID, Metadata_ClientID
			from inserted
				inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
														and IDB_Name = DatabaseName
				inner join Inventory.DatabaseObjectTypes on ObjectType = DOT_OriginalCode
				inner join Inventory.DatabaseSchemaNames on SchemaName = DSN_Name
				inner join Inventory.DatabaseObjectNames on ObjectName = DON_Name
				inner join Inventory.DatabaseIndexNames on IndexName = DIN_Name) s
		on FRI_MOB_ID = @MOB_ID
			and FRI_IDB_ID = IDB_ID
			and FRI_DSN_ID = DSN_ID
			and FRI_DON_ID = DON_ID
			and FRI_DIN_ID = DIN_ID
			and FRI_PartitionNumber = PartitionNumber
			and FRI_AUT_ID = AllocationUnitType
	when matched then update set
							FRI_IndexID = IndexID,
							FRI_IDT_ID = IndexType,
							FRI_IndexDepth = index_depth,
							FRI_AvgFragmentationInPercent = avg_fragmentation_in_percent,
							FRI_AvgPageSpaceUsedInPercent = avg_page_space_used_in_percent,
							FRI_GhostRecordCount = ghost_record_count,
							FRI_MinRecordSizeInBytes = min_record_size_in_bytes,
							FRI_MaxRecordSizeInBytes = max_record_size_in_bytes,
							FRI_AvgRecordSizeInBytes = avg_record_size_in_bytes,
							FRI_ForwardedRecordCount = forwarded_record_count,
							FRI_CompressedPageCount = compressed_page_count,
							FRI_NumberOfRows = NumberOfRows,
							FRI_SizeMB = SizeMB,
							FRI_FillFactor = fill_factor,
							FRI_LastSeenDate = @StartDate,
							FRI_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(FRI_ClientID, FRI_MOB_ID, FRI_IDB_ID, FRI_DOT_ID, FRI_DSN_ID, FRI_DON_ID, FRI_IndexID, FRI_IDT_ID, FRI_DIN_ID, FRI_PartitionNumber, FRI_AUT_ID,
									FRI_IndexDepth, FRI_AvgFragmentationInPercent, FRI_AvgPageSpaceUsedInPercent, FRI_GhostRecordCount, FRI_MinRecordSizeInBytes, FRI_MaxRecordSizeInBytes,
									FRI_AvgRecordSizeInBytes, FRI_ForwardedRecordCount, FRI_CompressedPageCount, FRI_NumberOfRows, FRI_SizeMB, FRI_FillFactor, FRI_InsertDate, FRI_LastSeenDate, FRI_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IDB_ID, DOT_ID, DSN_ID, DON_ID, IndexID, IndexType, DIN_ID, PartitionNumber, AllocationUnitType, index_depth,
									avg_fragmentation_in_percent, avg_page_space_used_in_percent, ghost_record_count, min_record_size_in_bytes, max_record_size_in_bytes, avg_record_size_in_bytes,
									forwarded_record_count, compressed_page_count, NumberOfRows, SizeMB, fill_factor, @StartDate, @StartDate, Metadata_TRH_ID);
GO
