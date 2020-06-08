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
/****** Object:  View [Tests].[VW_TST_UserObjectsInSystemDatabases]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_UserObjectsInSystemDatabases]
as
select top 0 CAST(null as nvarchar(128)) DatabaseName,
			CAST(null as nvarchar(60)) ObjectType,
			CAST(null as nvarchar(128)) SchemaName,
			CAST(null as nvarchar(128)) ObjectName,
			CAST(null as bit) IsStartupProcedure,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_UserObjectsInSystemDatabases]    Script Date: 6/8/2020 1:16:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_UserObjectsInSystemDatabases] on [Tests].[VW_TST_UserObjectsInSystemDatabases]
	instead of insert
as
set nocount on
declare @MOB_ID int,
		@StartDate datetime2(3)

select top 1 @MOB_ID = TRH_MOB_ID,
			@StartDate = TRH_StartDate
from inserted inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID

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

merge Inventory.InstanceDatabases d
	using (select distinct Metadata_ClientID, DatabaseName, Metadata_TRH_ID
			from inserted
			where DatabaseName is not null) s
		on IDB_MOB_ID = @MOB_ID
		and DatabaseName = IDB_Name
	when not matched then insert(IDB_ClientID, IDB_MOB_ID, IDB_Name, IDB_InsertDate, IDB_LastSeenDate, IDB_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, DatabaseName, @StartDate, @StartDate, Metadata_TRH_ID);

select Metadata_ClientID, Metadata_TRH_ID, IDB_ID, DSN_ID, DON_ID, DOT_ID, IsStartupProcedure
				from inserted
					inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
																and IDB_Name = DatabaseName
					inner join Inventory.DatabaseSchemaNames on DSN_Name = SchemaName
					inner join Inventory.DatabaseObjectNames on DON_Name = ObjectName
					inner join Inventory.DatabaseObjectTypes on DOT_OriginalCode = ObjectType

merge Inventory.UserObjectsInSystemDatabases d
	using (select Metadata_ClientID, Metadata_TRH_ID, IDB_ID, DOT_ID, DSN_ID, DON_ID, IsStartupProcedure
				from inserted
					inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
																and IDB_Name = DatabaseName
					inner join Inventory.DatabaseObjectTypes on DOT_OriginalCode = ObjectType
					inner join Inventory.DatabaseSchemaNames on DSN_Name = SchemaName
					inner join Inventory.DatabaseObjectNames on DON_Name = ObjectName) s
		on UOS_MOB_ID = @MOB_ID
			and UOS_IDB_ID = IDB_ID
			and UOS_DSN_ID = DSN_ID
			and UOS_DON_ID = DON_ID
	when matched then update set
							UOS_DOT_ID = DOT_ID,
							UOS_IsStartupProcedure = IsStartupProcedure,
							UOS_LastSeenDate = @StartDate,
							UOS_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(UOS_ClientID, UOS_MOB_ID, UOS_IDB_ID, UOS_DOT_ID, UOS_DSN_ID, UOS_DON_ID, UOS_IsStartupProcedure,
									UOS_InsertDate, UOS_LastSeenDate, UOS_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IDB_ID, DOT_ID, DSN_ID, DON_ID, IsStartupProcedure,
									@StartDate, @StartDate, Metadata_TRH_ID);
GO
