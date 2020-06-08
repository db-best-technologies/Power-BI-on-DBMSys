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
/****** Object:  View [Tests].[VW_TST_PossibleIndexProblems]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_PossibleIndexProblems]
as
select top 0 CAST(null as nvarchar(128)) DatabaseName,
			CAST(null as nvarchar(60)) ObjectType,
			CAST(null as nvarchar(128)) SchemaName,
			CAST(null as nvarchar(128)) ObjectName,
			CAST(null as int) index_id,
			CAST(null as tinyint) IndexType,
			CAST(null as nvarchar(128)) IndexName,
			CAST(null as nvarchar(max)) IndexColumns,
			CAST(null as nvarchar(max)) IncludedColumns,
			CAST(null as nvarchar(max)) Filter,
			CAST(null as bit) is_primary_key,
			CAST(null as bit) is_unique_constraint,
			CAST(null as bit) is_hypothetical,
			CAST(null as bit) is_disabled,
			CAST(null as bit) no_recompute,
			CAST(null as tinyint) fill_factor,
			CAST(null as bit) AllowPageLocks,
			CAST(null as bit) AllowRowLocks,
			CAST(null as bit) IsNotAligned,
			CAST(null as tinyint) IsUnused,
			CAST(null as bigint) AvgSeeksPerDay,
			CAST(null as bigint) AvgScansPerDay,
			CAST(null as bigint) AvgLookupsPerDay,
			CAST(null as datetime) last_user_seek,
			CAST(null as datetime) last_user_scan,
			CAST(null as datetime) last_user_lookup,
			CAST(null as bigint) RowCnt,
			CAST(null as bigint) SizeMB,
			CAST(null as tinyint) PercentCompressed,
			CAST(null as int) MaxRowSizeBytes,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_PossibleIndexProblems]    Script Date: 6/8/2020 1:16:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_PossibleIndexProblems] on [Tests].[VW_TST_PossibleIndexProblems]
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
	using (select distinct ObjectName
			from inserted
			where ObjectName is not null) s
		on ObjectName = DON_Name
	when not matched then insert (DON_Name)
							values(ObjectName);
							
merge Inventory.DatabaseIndexNames d
	using (select IndexName
			from inserted
			where IndexName is not null) s
		on IndexName = DIN_Name
	when not matched then insert (DIN_Name)
							values(IndexName);

merge Inventory.PossibleIndexProblems d
	using (select IDB_ID, DOT_ID, DSN_ID, DON_ID, index_id, IndexType, DIN_ID, IndexColumns, IncludedColumns, Filter, is_primary_key, is_unique_constraint, is_hypothetical,
				is_disabled, no_recompute, fill_factor, AllowPageLocks, AllowRowLocks, IsNotAligned, IsUnused, AvgSeeksPerDay, AvgScansPerDay, AvgLookupsPerDay, last_user_seek,
				last_user_scan, last_user_lookup, RowCnt, SizeMB, PercentCompressed, MaxRowSizeBytes, Metadata_TRH_ID, Metadata_ClientID
			from inserted
				inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
														and IDB_Name = DatabaseName
				inner join Inventory.DatabaseSchemaNames on SchemaName = DSN_Name
				inner join Inventory.DatabaseObjectNames on ObjectName = DON_Name
				inner join Inventory.DatabaseIndexNames on IndexName = DIN_Name
				inner join Inventory.DatabaseObjectTypes on DOT_OriginalCode = ObjectType) s
		on PIP_MOB_ID = @MOB_ID
			and PIP_IDB_ID = IDB_ID
			and PIP_DSN_ID = DSN_ID
			and PIP_DON_ID = DON_ID
			and PIP_DIN_ID = DIN_ID
	when matched then update set
							PIP_DOT_ID = DOT_ID,
							PIP_IndexID = index_id,
							PIP_IDT_ID = IndexType,
							PIP_IndexColumns = IndexColumns,
							PIP_IncludedColumns = IncludedColumns,
							PIP_Filter = Filter,
							PIP_IsPrimaryKey = is_primary_key,
							PIP_IsUniqueConstraint = is_unique_constraint,
							PIP_IsHypothetical = is_hypothetical,
							PIP_IsDisabled = is_disabled,
							PIP_NoRecompute = no_recompute,
							PIP_FillFactor = fill_factor,
							PIP_AllowPageLocks = AllowPageLocks,
							PIP_AllowRowLocks = AllowRowLocks,
							PIP_IsNotAligned = IsNotAligned,
							PIP_IsUnused = IsUnused,
							PIP_AvgSeeksPerDay = AvgSeeksPerDay,
							PIP_AvgScansPerDay = AvgScansPerDay,
							PIP_AvgLookupsPerDay = AvgLookupsPerDay,
							PIP_LastUserSeek = last_user_seek,
							PIP_LastUserScan = last_user_scan,
							PIP_LastUserLookup = last_user_lookup,
							PIP_RowCnt = RowCnt,
							PIP_SizeMB = SizeMB,
							PIP_MaxRowSizeBytes = MaxRowSizeBytes,
							PIP_PercentCompressed = PercentCompressed,
							PIP_LastSeenDate = @StartDate,
							PIP_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(PIP_ClientID, PIP_MOB_ID, PIP_IDB_ID, PIP_DOT_ID, PIP_DSN_ID, PIP_DON_ID, PIP_IndexID, PIP_IDT_ID, PIP_DIN_ID, PIP_IndexColumns, PIP_IncludedColumns,
								PIP_Filter, PIP_IsPrimaryKey, PIP_IsUniqueConstraint, PIP_IsHypothetical, PIP_IsDisabled, PIP_NoRecompute, PIP_FillFactor, PIP_AllowPageLocks,
								PIP_AllowRowLocks, PIP_IsNotAligned, PIP_IsUnused, PIP_AvgSeeksPerDay, PIP_AvgScansPerDay, PIP_AvgLookupsPerDay, PIP_LastUserSeek, PIP_LastUserScan,
								PIP_LastUserLookup, PIP_RowCnt, PIP_SizeMB, PIP_PercentCompressed, PIP_MaxRowSizeBytes, PIP_InsertDate, PIP_LastSeenDate, PIP_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IDB_ID, DOT_ID, DSN_ID, DON_ID, index_id, IndexType, DIN_ID, IndexColumns, IncludedColumns, Filter, is_primary_key,
									is_unique_constraint, is_hypothetical, is_disabled, no_recompute, fill_factor, AllowPageLocks, AllowRowLocks, IsNotAligned, IsUnused, AvgSeeksPerDay,
									AvgScansPerDay, AvgLookupsPerDay, last_user_seek, last_user_scan, last_user_lookup, RowCnt, SizeMB, PercentCompressed, MaxRowSizeBytes, @StartDate, @StartDate,
									Metadata_TRH_ID);
GO
