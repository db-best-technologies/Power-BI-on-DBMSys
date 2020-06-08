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
/****** Object:  View [Tests].[VW_TST_SQLDatabaseTopTables]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_SQLDatabaseTopTables]
as
select top 0 cast(null as nvarchar(128)) DatabaseName,
			cast(null as nvarchar(257)) TableName,
			cast(null as bigint) NumberOfRows,
			cast(null as bigint) SizeMB,
			cast(null as int) NumberOfPartitions,
			cast(null as tinyint) PrecentCompressed,
			cast(null as int) Metadata_TRH_ID,
			cast(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SQLDatabaseTopTables]    Script Date: 6/8/2020 1:16:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_SQLDatabaseTopTables] on [Tests].[VW_TST_SQLDatabaseTopTables]
	instead of insert
as
set nocount on

insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Instance, DatabaseName, Value, Metadata_TRH_ID, Metadata_ClientID)
select 'Top Table Statistics' Category, GNC_CounterName CounterName, '(' + DatabaseName + ') ' + TableName Instance, DatabaseName,
		case GNC_CounterName
			when 'Number Of Rows' then NumberOfRows
			when 'Number of Partitions' then NumberOfPartitions
			when 'Size (MB)' then SizeMB
		end Value, Metadata_TRH_ID, Metadata_ClientID
from inserted
	cross join (select GNC_CounterName, GNC_CSY_ID, GNC_ID
				from PerformanceData.GeneralCounters
				where GNC_CategoryName = 'Top Table Statistics') g

merge Inventory.TopDatabaseTables d
	using (select Metadata_ClientID ClientID, TRH_MOB_ID MOB_ID, IDB_ID, TableName, NumberOfRows, SizeMB, NumberOfPartitions, PrecentCompressed,
				TRH_StartDate, TRH_ID
			from inserted
				inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID
				inner join Inventory.InstanceDatabases on IDB_MOB_ID = TRH_MOB_ID
														and IDB_Name = DatabaseName) s
		on MOB_ID = TDT_MOB_ID
			and IDB_ID = TDT_IDB_ID
			and TableName = TDT_TableName
	when matched then update set
		TDT_NumberOfRows = NumberOfRows,
		TDT_NumberOfPartitions = NumberOfPartitions,
		TDT_PrecentCompressed = PrecentCompressed,
		TDT_LastSeenDate = TRH_StartDate,
		TDT_Last_TRH_ID = TRH_ID
	when not matched then insert(TDT_ClientID, TDT_MOB_ID, TDT_IDB_ID, TDT_TableName, TDT_NumberOfRows, TDT_NumberOfPartitions,
										TDT_PrecentCompressed, TDT_InsertDate, TDT_LastSeenDate, TDT_Last_TRH_ID)
							values(ClientID, MOB_ID, IDB_ID, TableName, NumberOfRows, NumberOfPartitions, PrecentCompressed, TRH_StartDate,
									TRH_StartDate, TRH_ID);
GO
