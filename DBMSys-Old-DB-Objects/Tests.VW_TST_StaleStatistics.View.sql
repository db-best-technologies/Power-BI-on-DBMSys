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
/****** Object:  View [Tests].[VW_TST_StaleStatistics]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_StaleStatistics]
as
select top 0 CAST(null as nvarchar(128)) DatabaseName,
			CAST(null as nvarchar(60)) ObjectType,
			CAST(null as nvarchar(128)) SchemaName,
			CAST(null as nvarchar(128)) ObjectName,
			CAST(null as int) stats_id,
			CAST(null as nvarchar(128)) StatisticsName,
			CAST(null as int) IsIndex,
			CAST(null as bigint) rowcnt,
			CAST(null as bit) auto_created,
			CAST(null as bit) user_created,
			CAST(null as bit) no_recompute,
			CAST(null as bit) has_filter,
			CAST(null as nvarchar(max)) filter_definition,
			CAST(null as datetime) StatisticsUpdateDate,
			CAST(null as int) rowmodctr,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_StaleStatistics]    Script Date: 6/8/2020 1:16:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_StaleStatistics] on [Tests].[VW_TST_StaleStatistics]
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

merge Inventory.DatabaseStatisticsNames d
	using (select distinct StatisticsName
			from inserted
			where StatisticsName is not null) s
		on StatisticsName = DTN_Name
	when not matched then insert (DTN_Name)
							values(StatisticsName);

merge Inventory.StaleStatistics d
	using (select IDB_ID, DOT_ID, DSN_ID, DON_ID, stats_id, DTN_ID, IsIndex, rowcnt, auto_created, user_created, no_recompute, has_filter, filter_definition,
				StatisticsUpdateDate, rowmodctr, Metadata_TRH_ID, Metadata_ClientID
			from inserted
				inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
														and IDB_Name = DatabaseName
				inner join Inventory.DatabaseObjectTypes on ObjectType = DOT_OriginalCode
				inner join Inventory.DatabaseSchemaNames on SchemaName = DSN_Name
				inner join Inventory.DatabaseObjectNames on ObjectName = DON_Name
				inner join Inventory.DatabaseStatisticsNames on StatisticsName = DTN_Name) s
		on SAS_MOB_ID = @MOB_ID
			and SAS_IDB_ID = IDB_ID
			and SAS_DSN_ID = DSN_ID
			and SAS_DON_ID = DON_ID
			and SAS_DTN_ID = DTN_ID
	when matched then update set
							SAS_StatisticsID = stats_id,
							SAS_IsIndex = IsIndex,
							SAS_RowCount = rowcnt,
							SAS_IsAutoCreated = auto_created,
							SAS_IsUserCreated = user_created,
							SAS_IsNoRecompute = no_recompute,
							SAS_HasFilter = has_filter,
							SAS_FilterDefinition = filter_definition,
							SAS_StatisticsUpdateDate = StatisticsUpdateDate,
							SAS_ModifyCount = rowmodctr,
							SAS_LastSeenDate = @StartDate,
							SAS_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(SAS_ClientID, SAS_MOB_ID, SAS_IDB_ID, SAS_DOT_ID, SAS_DSN_ID, SAS_DON_ID, SAS_StatisticsID, SAS_DTN_ID, SAS_IsIndex, SAS_RowCount, SAS_IsAutoCreated,
									SAS_IsUserCreated, SAS_IsNoRecompute, SAS_HasFilter, SAS_FilterDefinition, SAS_StatisticsUpdateDate, SAS_ModifyCount, SAS_InsertDate, SAS_LastSeenDate,
									SAS_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IDB_ID, DOT_ID, DSN_ID, DON_ID, stats_id, DTN_ID, IsIndex, rowcnt, auto_created, user_created, no_recompute, has_filter,
									filter_definition, StatisticsUpdateDate, rowmodctr, @StartDate, @StartDate, Metadata_TRH_ID);
GO
