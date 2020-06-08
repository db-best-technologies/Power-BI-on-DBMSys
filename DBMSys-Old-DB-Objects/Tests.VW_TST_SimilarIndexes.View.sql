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
/****** Object:  View [Tests].[VW_TST_SimilarIndexes]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_SimilarIndexes]
as
select top 0 CAST(null as nvarchar(128)) DatabaseName,
			CAST(null as nvarchar(128)) SchemaName,
			CAST(null as nvarchar(128)) TableName,
			CAST(null as int) IndexID,
			CAST(null as tinyint) IndexType,
			CAST(null as nvarchar(128)) IndexName,
			CAST(null as nvarchar(max)) IndexColumns,
			CAST(null as nvarchar(max)) IncludedColumns,
			CAST(null as nvarchar(max)) IndexFilter,
			CAST(null as int) SimilarIndexID,
			CAST(null as tinyint) SimilarIndexType,
			CAST(null as nvarchar(128)) SimilarIndexName,
			CAST(null as nvarchar(max)) SimilarIndexColumns,
			CAST(null as nvarchar(max)) SimilarIndexIncludedColumns,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SimilarIndexes]    Script Date: 6/8/2020 1:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_SimilarIndexes] on [Tests].[VW_TST_SimilarIndexes]
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
							
merge Inventory.DatabaseIndexNames d
	using (select IndexName
			from inserted
			where IndexName is not null
			union
			select SimilarIndexName
			from inserted
			where SimilarIndexName is not null) s
		on IndexName = DIN_Name
	when not matched then insert (DIN_Name)
							values(IndexName);

merge Inventory.SimilarIndexes d
	using (select IDB_ID, DSN_ID, DON_ID, IndexID, IndexType, i1.DIN_ID, IndexColumns, IncludedColumns, IndexFilter, SimilarIndexID, SimilarIndexType,
					i2.DIN_ID Similar_DIN_ID, SimilarIndexColumns, SimilarIndexIncludedColumns, Metadata_TRH_ID, Metadata_ClientID
			from inserted
				inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
														and IDB_Name = DatabaseName
				inner join Inventory.DatabaseSchemaNames on SchemaName = DSN_Name
				inner join Inventory.DatabaseObjectNames on TableName = DON_Name
				inner join Inventory.DatabaseIndexNames i1 on IndexName = i1.DIN_Name
				inner join Inventory.DatabaseIndexNames i2 on SimilarIndexName = i2.DIN_Name) s
		on SIX_MOB_ID = @MOB_ID
			and SIX_IDB_ID = IDB_ID
			and SIX_DSN_ID = DSN_ID
			and SIX_DON_ID = DON_ID
			and SIX_DIN_ID = DIN_ID
			and SIX_Similar_DIN_ID = Similar_DIN_ID
	when matched then update set
							SIX_IndexID = IndexID,
							SIX_IDT_ID = IndexType,
							SIX_IndexColumns = IndexColumns,
							SIX_IncludedColumns = IncludedColumns,
							SIX_SimilarIndexID = SimilarIndexID,
							SIX_Similar_IDT_ID = SimilarIndexType,
							SIX_SimilarIndexColumns = SimilarIndexColumns,
							SIX_SimilarIndexIncludedColumns = SimilarIndexIncludedColumns,
							SIX_LastSeenDate = @StartDate,
							SIX_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(SIX_ClientID, SIX_MOB_ID, SIX_IDB_ID, SIX_DSN_ID, SIX_DON_ID, SIX_IndexID, SIX_IDT_ID, SIX_DIN_ID, SIX_IndexColumns, SIX_IncludedColumns,
									SIX_IndexFilter, SIX_SimilarIndexID, SIX_Similar_IDT_ID, SIX_Similar_DIN_ID, SIX_SimilarIndexColumns, SIX_SimilarIndexIncludedColumns,
									SIX_InsertDate, SIX_LastSeenDate, SIX_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IDB_ID, DSN_ID, DON_ID, IndexID, IndexType, DIN_ID, IndexColumns, IncludedColumns, IndexFilter,
									SimilarIndexID, SimilarIndexType, Similar_DIN_ID, SimilarIndexColumns, SimilarIndexIncludedColumns, @StartDate, @StartDate, Metadata_TRH_ID);
GO
