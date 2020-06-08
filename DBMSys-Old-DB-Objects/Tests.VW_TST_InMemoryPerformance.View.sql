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
/****** Object:  View [Tests].[VW_TST_InMemoryPerformance]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_InMemoryPerformance]
as
			
Select top 0 
	Cast(Null as  [nvarchar](128)) [DBName] ,
	Cast(Null as  [nvarchar](128)) [TableName]  ,
	Cast(Null as  [nvarchar](128)) [SchemaName] ,
	Cast(Null as  [decimal](18,5)) [Sum_Leaf_Insert_Count]  , 
	Cast(Null as  [decimal](18,5)) [Sum_Leaf_Delete_Count]   ,
	Cast(Null as  [decimal](18,5)) [Sum_Leaf_update_count] ,
	Cast(Null as  [decimal](18,5)) [Sum_NonLeaf_insert_count] ,
	Cast(Null as  [decimal](18,5))[Sum_NonLeaf_delete_count]  ,
	Cast(Null as  [decimal](18,5)) [Sum_NonLeaf_update_count] ,
	Cast(Null as  [decimal](18,5))[Sum_range_scan_count]  ,
	Cast(Null as  [decimal](18,5)) [Sum_singleton_lookup_count] ,
	Cast(Null as  [decimal](18,5)) [Sum_row_lock_count] ,
	Cast(Null as  [decimal](18,5)) [Sum_row_lock_Wait_Count] ,
	Cast(Null as  [decimal](18,5)) [Sum_row_lock_Wait_in_MS] ,
	Cast(Null as  [decimal](18,5)) [Sum_page_lock_count] ,
	Cast(Null as  [decimal](18,5)) [Sum_page_lock_Wait_count]  ,
	Cast(Null as  [decimal](18,5)) [Sum_Page_Lock_Wait_in_MS] , 
	Cast(Null as  [decimal](18,5)) [Sum_Page_latch_Wait_count] ,  
	Cast(Null as  [decimal](18,5)) [Sum_Page_Latch_Wait_in_MS] , 
	Cast(Null as  [decimal](18,5)) [Sum_page_IO_Latch_Wait_Count] , 
	Cast(Null as  [decimal](18,5)) [Sum_page_io_latch_Wait_in_ms] ,
	cast(null as int) Metadata_TRH_ID,
	cast(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_InMemoryPerformance]    Script Date: 6/8/2020 1:16:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_InMemoryPerformance] on [Tests].[VW_TST_InMemoryPerformance]
	instead of insert
as

Insert [Collect].[VW_TST_PerformanceCounters] (Category, [Counter], Instance, DatabaseName, Value, [Status], Metadata_TRH_ID, Metadata_ClientID)
select 'Index Usage' Category, 'Leaf Insert Count/sec' CounterName,SchemaName + '.' + TableName Instance, DBName, Sum_Leaf_Insert_Count value , null status , Metadata_TRH_ID, Metadata_ClientID
		from inserted
Union all 
select 'Index Usage' Category, 'Leaf Delete Count/sec' CounterName, SchemaName + '.' + TableName Instance, DBName, Sum_Leaf_Delete_Count value , null status , Metadata_TRH_ID, Metadata_ClientID
		from inserted	
Union all 
select 'Index Usage' Category, 'Leaf Update Count/sec' CounterName, SchemaName + '.' + TableName Instance, DBName, Sum_Leaf_update_count value , null status , Metadata_TRH_ID, Metadata_ClientID
		from inserted		
Union all 
select 'Index Usage' Category, 'NonLeaf Insert Count/sec' CounterName, SchemaName + '.' + TableName Instance , DBName, Sum_NonLeaf_insert_count value , null status , Metadata_TRH_ID, Metadata_ClientID
		from inserted		
Union all 
select 'Index Usage' Category, 'NonLeaf Delete Count/sec' CounterName, SchemaName + '.' + TableName Instance, DBName, Sum_NonLeaf_delete_count value , null status , Metadata_TRH_ID, Metadata_ClientID
		from inserted	
Union all 
select 'Index Usage' Category, 'NonLeaf Update Count/sec' CounterName,SchemaName + '.' + TableName Instance, DBName, Sum_NonLeaf_update_count value , null status , Metadata_TRH_ID, Metadata_ClientID
		from inserted		
Union all 
select 'Index Usage' Category, 'Range Scan Count/sec' CounterName,SchemaName + '.' + TableName Instance, DBName, Sum_range_scan_count value , null status , Metadata_TRH_ID, Metadata_ClientID
		from inserted		
Union all 
select 'Index Usage' Category, 'Singleton lookup Count/sec' CounterName,SchemaName + '.' + TableName Instance, DBName, Sum_singleton_lookup_count value , null status , Metadata_TRH_ID, Metadata_ClientID
		from inserted	
Union all 
select 'Index Usage' Category, 'Row Lock Count/sec' CounterName,SchemaName + '.' + TableName Instance, DBName, Sum_row_lock_count value , null status , Metadata_TRH_ID, Metadata_ClientID
		from inserted	
Union all 
select 'Index Usage' Category, 'Row Lock Wait Count/sec' CounterName, SchemaName + '.' + TableName Instance, DBName, Sum_row_lock_Wait_Count value , null status , Metadata_TRH_ID, Metadata_ClientID
		from inserted	
Union all 
select 'Index Usage' Category, 'Row Lock Wait in MS/sec' CounterName,SchemaName + '.' + TableName Instance, DBName, Sum_row_lock_Wait_in_MS value , null status , Metadata_TRH_ID, Metadata_ClientID
		from inserted
Union all 
select 'Index Usage' Category, 'Page Lock Count/sec' CounterName,SchemaName + '.' + TableName Instance, DBName, Sum_page_lock_count value , null status , Metadata_TRH_ID, Metadata_ClientID
		from inserted	
Union all 
select 'Index Usage' Category, 'Page Lock Wait Count/sec' CounterName,SchemaName + '.' + TableName Instance, DBName, Sum_page_lock_Wait_count value , null status , Metadata_TRH_ID, Metadata_ClientID
		from inserted
Union all 
select 'Index Usage' Category, 'Page Lock Wait in MS/sec' CounterName,SchemaName + '.' + TableName Instance, DBName, Sum_Page_Lock_Wait_in_MS value , null status , Metadata_TRH_ID, Metadata_ClientID
		from inserted		
Union all 
select 'Index Usage' Category, 'Page IO Latch Wait Count/sec' CounterName,SchemaName + '.' + TableName Instance, DBName, Sum_page_IO_Latch_Wait_Count value , null status , Metadata_TRH_ID, Metadata_ClientID
		from inserted		
Union all 
select 'Index Usage' Category, 'Page IO latch Wait in ms/sec' CounterName,SchemaName + '.' + TableName Instance, DBName, Sum_page_io_latch_Wait_in_ms value , null status , Metadata_TRH_ID, Metadata_ClientID
		from inserted	
Union all 
select 'Index Usage' Category, 'Page Latch Wait Count/sec' CounterName,SchemaName + '.' + TableName Instance, DBName, Sum_Page_latch_Wait_count value , null status , Metadata_TRH_ID, Metadata_ClientID
		from inserted	
Union all 
select 'Index Usage' Category, 'Page Latch Wait in MS/sec' CounterName,SchemaName + '.' + TableName Instance, DBName, Sum_Page_Latch_Wait_in_MS value , null status , Metadata_TRH_ID, Metadata_ClientID
		from inserted
GO
