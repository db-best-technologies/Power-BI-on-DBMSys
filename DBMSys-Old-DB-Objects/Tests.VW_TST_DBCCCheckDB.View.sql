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
/****** Object:  View [Tests].[VW_TST_DBCCCheckDB]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_DBCCCheckDB]
as
select top 0 CAST(null as nvarchar(128)) DatabaseName,
			CAST(null as nvarchar(60)) ObjectType,
			CAST(null as nvarchar(128)) SchemaName,
			CAST(null as nvarchar(128)) ObjectName,
			CAST(null as nvarchar(128)) DatabaseFileName,
			CAST(null as int) Error,
			CAST(null as int) ErrorLevel,
			CAST(null as varchar(200)) RepairLevel,
			CAST(null as int) AffectedPagesCount,
			CAST(null as int) Errors,
			CAST(null as varchar(7000)) ExampleMessage,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_DBCCCheckDB]    Script Date: 6/8/2020 1:16:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_DBCCCheckDB] on [Tests].[VW_TST_DBCCCheckDB]
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
					
merge Inventory.DatabaseFiles d
	using (select distinct Metadata_ClientID, IDB_ID, DatabaseFileName, Metadata_TRH_ID
			from inserted
				inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
															and DatabaseName = IDB_Name
			where DatabaseFileName is not null) s
		on DBF_MOB_ID = @MOB_ID
			and DBF_IDB_ID = IDB_ID
			and DBF_Name = DatabaseFileName
	when not matched then insert(DBF_ClientID, DBF_MOB_ID, DBF_IDB_ID, DBF_Name, DBF_InsertDate, DBF_LastSeenDate, DBF_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IDB_ID, DatabaseFileName, @StartDate, @StartDate, Metadata_TRH_ID);

merge Inventory.DBCCCheckDB d
	using (select IDB_ID, DOT_ID, DSN_ID, DON_ID, DBF_ID, Error,  ErrorLevel, RepairLevel, AffectedPagesCount, Errors, ExampleMessage, Metadata_TRH_ID, Metadata_ClientID
			from inserted
				inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
														and IDB_Name = DatabaseName
				left join Inventory.DatabaseObjectTypes on ObjectType = DOT_OriginalCode
				left join Inventory.DatabaseSchemaNames on SchemaName = DSN_Name
				left join Inventory.DatabaseObjectNames on ObjectName = DON_Name
				left join Inventory.DatabaseFiles on DBF_MOB_ID = @MOB_ID
														and DBF_IDB_ID = IDB_ID
														and DBF_Name = DatabaseFileName
			) s
		on DCD_MOB_ID = @MOB_ID
			and DCD_IDB_ID = IDB_ID
			and DCD_DSN_ID = DSN_ID
			and DCD_DON_ID = DON_ID
			and DCD_DBF_ID = DBF_ID
			and DCD_ErrorNumber = Error
			and DCD_RepairLevel = RepairLevel
	when matched then update set
							DCD_DOT_ID = DOT_ID,
							DCD_ErrorLevel = ErrorLevel,
							DCD_AffectedPagesCount = AffectedPagesCount,
							DCD_ErrorCount = Errors,
							DCD_ExampleMessage = ExampleMessage,
							DCD_LastSeenDate = @StartDate,
							DCD_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(DCD_ClientID, DCD_MOB_ID, DCD_IDB_ID, DCD_DOT_ID, DCD_DSN_ID, DCD_DON_ID, DCD_DBF_ID, DCD_ErrorNumber, DCD_ErrorLevel, DCD_RepairLevel, DCD_AffectedPagesCount,
								DCD_ErrorCount, DCD_ExampleMessage, DCD_InsertDate, DCD_LastSeenDate, DCD_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IDB_ID, DOT_ID, DSN_ID, DON_ID, DBF_ID, Error,  ErrorLevel, RepairLevel, AffectedPagesCount, Errors, ExampleMessage, @StartDate,
									@StartDate, Metadata_TRH_ID);
GO
