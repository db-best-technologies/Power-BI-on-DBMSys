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
/****** Object:  View [Tests].[VW_TST_UntrustedConstraints]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_UntrustedConstraints]
as
select top 0 CAST(null as nvarchar(128)) DatabaseName,
			CAST(null as nvarchar(128)) SchemaName,
			CAST(null as nvarchar(128)) TableName,
			CAST(null as nvarchar(60)) ConstraintType,
			CAST(null as nvarchar(128)) ConstraintName,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_UntrustedConstraints]    Script Date: 6/8/2020 1:16:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_UntrustedConstraints] on [Tests].[VW_TST_UntrustedConstraints]
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
	using (select TableName ObjectName
			from inserted
			where TableName is not null
			union
			select ConstraintName ObjectName
			from inserted
			where ConstraintName is not null) s
		on ObjectName = DON_Name
	when not matched then insert (DON_Name)
							values(ObjectName);

merge Inventory.UntrustedConstraints d
	using (select IDB_ID, DSN_ID, t.DON_ID Table_DON_ID, DOT_ID, c.DON_ID Constraint_DON_ID, Metadata_TRH_ID, Metadata_ClientID
			from inserted
				inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
														and IDB_Name = DatabaseName
				inner join Inventory.DatabaseSchemaNames on SchemaName = DSN_Name
				inner join Inventory.DatabaseObjectNames t on TableName = t.DON_Name
				inner join Inventory.DatabaseObjectNames c on TableName = c.DON_Name
				inner join Inventory.DatabaseObjectTypes on DOT_OriginalCode = ConstraintType) s
		on UTC_MOB_ID = @MOB_ID
			and UTC_IDB_ID = IDB_ID
			and UTC_DSN_ID = DSN_ID
			and UTC_Table_DON_ID = Table_DON_ID
			and UTC_Constraint_DON_ID = Constraint_DON_ID
	when matched then update set
							UTC_Constraint_DOT_ID = DOT_ID,
							UTC_LastSeenDate = @StartDate,
							UTC_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(UTC_ClientID, UTC_MOB_ID, UTC_IDB_ID, UTC_DSN_ID, UTC_Table_DON_ID, UTC_Constraint_DOT_ID, UTC_Constraint_DON_ID, UTC_InsertDate, UTC_LastSeenDate, UTC_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IDB_ID, DSN_ID, Table_DON_ID, DOT_ID, Constraint_DON_ID, @StartDate, @StartDate, Metadata_TRH_ID);
GO
