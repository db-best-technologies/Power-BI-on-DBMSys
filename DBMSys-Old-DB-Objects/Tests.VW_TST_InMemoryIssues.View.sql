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
/****** Object:  View [Tests].[VW_TST_InMemoryIssues]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_InMemoryIssues]
as
select top 0 cast(null as nvarchar(128)) DbName ,
			cast(null as nvarchar(128)) SchemaName ,
			cast(null as nvarchar(128)) TableName,
			cast(null as varchar(128)) FactorName,
			cast(null as int) IssueCount,
			cast(null as int) Metadata_TRH_ID,
			cast(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_InMemoryIssues]    Script Date: 6/8/2020 1:16:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_InMemoryIssues] on [Tests].[VW_TST_InMemoryIssues]
	instead of insert
as
declare @MOB_ID int ,
		@StartDate datetime2(3),
		@CounterDate datetime2(3)

select top 1 @MOB_ID = TRH_MOB_ID,
			@StartDate = TRH_StartDate,
			@CounterDate = TRH_StartDate
from inserted inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID

merge Inventory.InstanceDatabases d
	using (select distinct Metadata_ClientID, DBName, Metadata_TRH_ID
			from inserted
			where DBName is not null) s
		on IDB_MOB_ID = @MOB_ID
		and DBName = IDB_Name
	when not matched then insert(IDB_ClientID, IDB_MOB_ID, IDB_Name, IDB_InsertDate, IDB_LastSeenDate, IDB_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, DBName, sysdatetime(), sysdatetime(), Metadata_TRH_ID);

merge Inventory.InMemoryIssuesFactors d
	using (select distinct FactorName
			from inserted) s
		on FactorName = IMF_Name
	when not matched then insert(IMF_Name)
							values(FactorName);

merge Inventory.DatabaseObjectNames d
	Using ( Select distinct TableName
				From Inserted) s
		on TableName = DON_Name
	When not matched then Insert (DON_Name)
							Values (TableName);

Merge Inventory.DatabaseSchemaNames d
	Using ( Select distinct SchemaName
				From Inserted) s
		on SchemaName = DSN_Name
	When not matched then Insert (DSN_Name)
							Values (SchemaName);


Merge Inventory.InMemoryIssues
	Using (Select Distinct Metadata_ClientID,  IDB_MOB_ID, IDB_ID, DSN_ID,DON_ID,IMF_ID,IssueCount ,Metadata_TRH_ID   
					From inserted 
					join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
														and IDB_Name = DBName 
					join Inventory.DatabaseObjectNames on DON_Name = TableName
					join Inventory.DatabaseSchemaNames on SchemaName = DSN_Name 
					Join Inventory.InMemoryIssuesFactors on FactorName = IMF_Name
) s

	on IDB_MOB_ID = IMI_MOB_ID and IDB_ID = IMI_IDB_ID and DSN_ID = IMI_DNS_ID AND DON_ID = IMI_DON_ID  AND IMF_ID = IMI_IMF_ID

			When not matched then 
				Insert  ( IMI_ClientID ,
				IMI_MOB_ID ,
				 IMI_IDB_ID,
				IMI_DNS_ID ,
				IMI_DON_ID ,
				IMI_IMF_ID,
				IMI_IssueCount,
				IMI_InsertDate,
				IMI_LastSeenDate,
				IMI_Last_TRH_ID
				
				 ) values 
				 (Metadata_ClientID, IDB_MOB_ID, IDB_ID , DSN_ID , DON_ID ,IMF_ID,IssueCount, @StartDate, @StartDate , Metadata_TRH_ID)	
			When matched then 
				update set
				IMI_LastSeenDate = @StartDate ,
				IMI_Last_TRH_ID = Metadata_TRH_ID,
				IMI_IssueCount = IssueCount;
GO
