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
/****** Object:  View [Tests].[VW_TST_PlanGuides]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_PlanGuides]
as
select top 0 CAST(null as nvarchar(128)) DatabaseName,
			CAST(null as nvarchar(128)) PlanGuideName,
			CAST(null as datetime) create_date,
			CAST(null as datetime) modify_date,
			CAST(null as nvarchar(60)) scope_type_desc,
			CAST(null as nvarchar(max)) query_text,
			CAST(null as nvarchar(max)) scope_batch,
			CAST(null as nvarchar(60)) ObjectType,
			CAST(null as nvarchar(128)) ScopeSchemaName,
			CAST(null as nvarchar(128)) ScopeObjectName,
			CAST(null as nvarchar(max)) PlanParameters,
			CAST(null as nvarchar(max)) PlanHints,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_PlanGuides]    Script Date: 6/8/2020 1:16:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_PlanGuides] on [Tests].[VW_TST_PlanGuides]
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

merge Inventory.PlanGuideScopeTypes d
	using (select distinct scope_type_desc
			from inserted
			where scope_type_desc is not null) s
		on scope_type_desc = PGS_Name
	when not matched then insert (PGS_Name)
							values(scope_type_desc);

merge Inventory.DatabaseObjectTypes d
	using (select distinct ObjectType
			from inserted
			where ObjectType is not null) s
		on ObjectType = DOT_OriginalCode
	when not matched then insert (DOT_OriginalCode, DOT_DisplayName)
							values(ObjectType, ObjectType);

merge Inventory.DatabaseSchemaNames d
	using (select distinct ScopeSchemaName SchemaName
			from inserted
			where ScopeSchemaName is not null) s
		on SchemaName = DSN_Name
	when not matched then insert (DSN_Name)
							values(SchemaName);

merge Inventory.DatabaseObjectNames d
	using (select ScopeObjectName ObjectName
			from inserted
			where ScopeObjectName is not null) s
		on ObjectName = DON_Name
	when not matched then insert (DON_Name)
							values(ObjectName);

;with Statements as
		(select query_text SQLStatement
			from inserted
			where query_text is not null
			union
			select scope_batch
			from inserted
			where scope_batch is not null
			union
			select PlanParameters
			from inserted
			where PlanParameters is not null
			union
			select PlanHints
			from inserted
			where PlanHints is not null
		)
merge Activity.SQLStatements d
	using (select distinct SQLStatement, hashbytes('MD5', left(cast(SQLStatement as varchar(max)), 8000)) StatementHashed
			from Statements
			where SQLStatement is not null) s
		on StatementHashed = SQS_StatementHashed
			and SQLStatement = SQS_Statement
	when matched then update set
							SQS_LastSeenDate = @StartDate
	when not matched then insert(SQS_Statement, SQS_LastSeenDate)
							values(SQLStatement, @StartDate);

merge Inventory.PlanGuides d
	using (select IDB_ID, PlanGuideName, create_date, modify_date, PGS_ID, q.SQS_ID QueryText_SQS_ID, b.SQS_ID ScopeBatch_SQS_ID, DOT_ID, DSN_ID, DON_ID, p.SQS_ID PlanParameters_SQS_ID,
				h.SQS_ID PlanHints_SQS_ID, Metadata_ClientID, Metadata_TRH_ID
			from inserted
				inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
														and IDB_Name = DatabaseName
				inner join Inventory.PlanGuideScopeTypes on scope_type_desc = PGS_Name
				left join Activity.SQLStatements q on q.SQS_StatementHashed = hashbytes('MD5', left(cast(query_text as varchar(max)), 8000))
														and q.SQS_Statement = query_text
				left join Activity.SQLStatements b on b.SQS_StatementHashed = hashbytes('MD5', left(cast(scope_batch as varchar(max)), 8000))
														and b.SQS_Statement = scope_batch
				left join Activity.SQLStatements p on q.SQS_StatementHashed = hashbytes('MD5', left(cast(PlanParameters as varchar(max)), 8000))
														and q.SQS_Statement = PlanParameters
				left join Activity.SQLStatements h on q.SQS_StatementHashed = hashbytes('MD5', left(cast(PlanHints as varchar(max)), 8000))
														and q.SQS_Statement = PlanHints
				left join Inventory.DatabaseSchemaNames on ScopeSchemaName = DSN_Name
				left join Inventory.DatabaseObjectNames on ScopeObjectName = DON_Name
				left join Inventory.DatabaseObjectTypes on DOT_OriginalCode = ObjectType) s
		on PGD_MOB_ID = @MOB_ID
			and PGD_IDB_ID = IDB_ID
			and PGD_PlanGuideName = PlanGuideName
	when matched then update set
							PGD_CreateDate = create_date,
							PGD_ModifyDate = modify_date,
							PGD_PGS_ID = PGS_ID,
							PGD_QueryText_SQS_ID = QueryText_SQS_ID,
							PGD_ScopeBatch_SQS_ID = ScopeBatch_SQS_ID,
							PGD_ScopeObject_DOT_ID = DOT_ID,
							PGD_ScopeObject_DSN_ID = DSN_ID,
							PGD_ScopeObject_DON_ID = DON_ID,
							PGD_PlanParameters_SQS_ID = PlanParameters_SQS_ID,
							PGD_PlanHints_SQS_ID = PlanHints_SQS_ID,
							PGD_LastSeenDate = @StartDate,
							PGD_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(PGD_ClientID, PGD_MOB_ID, PGD_IDB_ID, PGD_PlanGuideName, PGD_CreateDate, PGD_ModifyDate, PGD_PGS_ID, PGD_QueryText_SQS_ID, PGD_ScopeBatch_SQS_ID,
									PGD_ScopeObject_DOT_ID, PGD_ScopeObject_DSN_ID, PGD_ScopeObject_DON_ID, PGD_PlanParameters_SQS_ID, PGD_PlanHints_SQS_ID, PGD_InsertDate,
									PGD_LastSeenDate, PGD_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IDB_ID, PlanGuideName, create_date, modify_date, PGS_ID, QueryText_SQS_ID, ScopeBatch_SQS_ID, DOT_ID, DSN_ID, DON_ID,
									PlanParameters_SQS_ID, PlanHints_SQS_ID, @StartDate, @StartDate, Metadata_TRH_ID);
GO
