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
/****** Object:  View [Tests].[VW_TST_FullTextCatalogs]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_FullTextCatalogs]
as
select top 0 CAST(null as nvarchar(128)) DatabaseName,
			CAST(null as nvarchar(128)) CatalogName,
			CAST(null as nvarchar(256)) CatalogPath,
			CAST(null as bit) IsDefault,
			CAST(null as bit) IsAccentSensitivityOn,
			CAST(null as nvarchar(128)) DataSpaceName,
			CAST(null as nvarchar(128)) CatalogFileName,
			CAST(null as datetime) LastPopulationDate,
			CAST(null as int) IndexSizeMB,
			CAST(null as int) ItemCount,
			CAST(null as int) PopulateStatus,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_FullTextCatalogs]    Script Date: 6/8/2020 1:16:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_FullTextCatalogs] on [Tests].[VW_TST_FullTextCatalogs]
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

merge Inventory.DatabaseFileGroups d
	using (select distinct IDB_ID, DataSpaceName, Metadata_ClientID, Metadata_TRH_ID
			from inserted
				inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
																and DatabaseName = IDB_Name
			where DataSpaceName is not null) s
		on DFG_MOB_ID = @MOB_ID
			and DFG_IDB_ID = IDB_ID
			and DFG_Name = DataSpaceName
	when not matched then insert(DFG_ClientID, DFG_MOB_ID, DFG_IDB_ID, DFG_Name, DFG_FGT_ID, DFG_InsertDate, DFG_LastSeenDate, DFG_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IDB_ID, DataSpaceName, 1, @StartDate, @StartDate, Metadata_TRH_ID);

merge Inventory.DatabaseFiles d
	using (select distinct Metadata_ClientID, IDB_ID, CatalogFilename, Metadata_TRH_ID
			from inserted
				inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
															and DatabaseName = IDB_Name
			where CatalogFilename is not null) s
		on DBF_MOB_ID = @MOB_ID
			and DBF_IDB_ID = IDB_ID
			and DBF_Name = CatalogFilename
	when not matched then insert(DBF_ClientID, DBF_MOB_ID, DBF_IDB_ID, DBF_Name, DBF_InsertDate, DBF_LastSeenDate, DBF_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IDB_ID, CatalogFilename, @StartDate, @StartDate, Metadata_TRH_ID);

merge Inventory.FullTextCatalogs d
	using (select IDB_ID, CatalogName, CatalogPath, IsDefault, IsAccentSensitivityOn, DFG_ID, DBF_ID, LastPopulationDate, PopulateStatus, Metadata_ClientID, Metadata_TRH_ID
			from inserted
				inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
														and IDB_Name = DatabaseName
				left join Inventory.DatabaseFileGroups on DFG_MOB_ID = @MOB_ID
															and DFG_IDB_ID = IDB_ID
															and DFG_Name = DataSpaceName
				left join Inventory.DatabaseFiles on DBF_MOB_ID = @MOB_ID
														and DBF_IDB_ID = IDB_ID
														and DBF_Name = CatalogFilename) s
		on FTC_MOB_ID = @MOB_ID
			and FTC_IDB_ID = IDB_ID
			and FTC_CatalogName = CatalogName
	when matched then update set
							FTC_CatalogPath = CatalogPath,
							FTC_IsDefault = IsDefault,
							FTC_IsAccentSensitivityOn = IsAccentSensitivityOn,
							FTC_DFG_ID = DFG_ID,
							FTC_FBF_ID = DBF_ID,
							FTC_LastPopulationDate = LastPopulationDate,
							FTC_FCS_ID = PopulateStatus,
							FTC_LastSeenDate = @StartDate,
							FTC_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(FTC_ClientID, FTC_MOB_ID, FTC_IDB_ID, FTC_CatalogName, FTC_CatalogPath, FTC_IsDefault, FTC_IsAccentSensitivityOn, FTC_DFG_ID, FTC_FBF_ID,
									FTC_LastPopulationDate, FTC_FCS_ID, FTC_InsertDate, FTC_LastSeenDate, FTC_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IDB_ID, CatalogName, CatalogPath, IsDefault, IsAccentSensitivityOn, DFG_ID, DBF_ID, LastPopulationDate, PopulateStatus,
									@StartDate, @StartDate, Metadata_TRH_ID);

insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Instance, Value, [Status], Metadata_TRH_ID, Metadata_ClientID)
select 'Full-Text Catalogs', GNC_CounterName, left(DatabaseName + '\' + CatalogName, 850) Instance,
		case GNC_CounterName
				when 'Index Size (MB)' then IndexSizeMB
				when 'Item Count' then ItemCount
		end Value, null [Status], Metadata_TRH_ID, Metadata_ClientID
from inserted
	cross join (select GNC_CounterName, GNC_CSY_ID, GNC_ID
				from PerformanceData.GeneralCounters
				where GNC_CategoryName = 'Full-Text Catalogs') g
GO
