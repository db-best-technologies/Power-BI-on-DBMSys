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
/****** Object:  View [Tests].[VW_TST_DatabaseFeatureCrawl]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_DatabaseFeatureCrawl]
as
select top 0 CAST(null as nvarchar(128)) DatabaseName,
			CAST(null as bit) Partitioning,
			CAST(null as bit) FullTextIndexes,
			CAST(null as bit) DataCompression,
			CAST(null as bit) Auditing,
			CAST(null as bit) FileStreamData,
			CAST(null as bit) FiltredIndexes,
			CAST(null as bit) ChangeTracking,
			CAST(null as bit) MemoryOptimizedOLTP,
			CAST(null as bit) MergeReplicationWithInfiniteRetention,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[VW_trg_TST_DatabaseFeatureCrawl]    Script Date: 6/8/2020 1:15:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[VW_trg_TST_DatabaseFeatureCrawl] on [Tests].[VW_TST_DatabaseFeatureCrawl]
	instead of insert
as
set nocount on

merge Inventory.InstanceDatabases s
	using (select DatabaseName, Partitioning, FullTextIndexes, DataCompression, Auditing, FileStreamData, FiltredIndexes, ChangeTracking, MemoryOptimizedOLTP,
					MergeReplicationWithInfiniteRetention, Metadata_ClientID, TRH_ID, TRH_MOB_ID, TRH_StartDate
			from inserted
				inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID) d
		on IDB_MOB_ID = TRH_MOB_ID
			and IDB_Name = DatabaseName
	when matched then update set
							IDB_Partitioning = Partitioning,
							IDB_FullTextIndexes = FullTextIndexes,
							IDB_DataCompression = DataCompression,
							IDB_Auditing = Auditing,
							IDB_FileStreamData = FileStreamData,
							IDB_FiltredIndexes = FiltredIndexes,
							IDB_ChangeTracking = ChangeTracking,
							IDB_MemoryOptimizedOLTP = MemoryOptimizedOLTP,
							IDB_MergeReplicationWithInfiniteRetention = MergeReplicationWithInfiniteRetention
	when not matched then insert(IDB_ClientID, IDB_MOB_ID, IDB_Name, IDB_Partitioning, IDB_FullTextIndexes, IDB_DataCompression, IDB_Auditing, IDB_FileStreamData, IDB_FiltredIndexes,
								IDB_ChangeTracking, IDB_MemoryOptimizedOLTP, IDB_MergeReplicationWithInfiniteRetention, IDB_InsertDate, IDB_LastSeenDate, IDB_Last_TRH_ID)
							values(Metadata_ClientID, TRH_MOB_ID, DatabaseName, Partitioning, FullTextIndexes, DataCompression, Auditing, FileStreamData, FiltredIndexes,
								ChangeTracking, MemoryOptimizedOLTP, MergeReplicationWithInfiniteRetention, TRH_StartDate, TRH_StartDate, TRH_ID);
GO
