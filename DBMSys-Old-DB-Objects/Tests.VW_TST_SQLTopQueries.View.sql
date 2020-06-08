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
/****** Object:  View [Tests].[VW_TST_SQLTopQueries]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_SQLTopQueries]
as
select top 0 CAST(null as nvarchar(128)) DatabaseName,
			CAST(null as nvarchar(128)) ObjectName,
			CAST(null as nvarchar(max)) SQLStatement,
			CAST(null as bigint) AverageExecutionsPerDay,
			CAST(null as bigint) AverageReadsPerDay,
			CAST(null as bigint) AverageCPUMilliPerDay,
			CAST(null as bigint) AverageDurationMilliPerDay,
			CAST(null as bigint) AverageReadsPerExecution,
			CAST(null as bigint) AverageCPUMilliPerExecution,
			CAST(null as bigint) AverageDurationMilliPerExecution,
			CAST(null as bigint) RankByCPU,
			CAST(null as bigint) RankByReads,
			CAST(null as nvarchar(max)) ImplicitlyConvertedColumns,
			CAST(null as int) LookupCount,
			CAST(null as nvarchar(max)) ScalarFunctionsUsed,
			CAST(null as nvarchar(max)) RecommendedIndexes,
			cast(null as int) Metadata_TRH_ID,
			cast(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SQLTopQueries]    Script Date: 6/8/2020 1:16:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_SQLTopQueries] on [Tests].[VW_TST_SQLTopQueries]
	instead of insert, update
as
declare @MOB_ID int,
		@StartDate datetime2(3)

select top 1 @MOB_ID = TRH_MOB_ID,
			@StartDate = TRH_StartDate
from inserted inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID

merge Inventory.InstanceDatabases d
	using (select distinct Metadata_ClientID, DatabaseName, Metadata_TRH_ID
			from inserted
			where DatabaseName is not null) s
		on IDB_MOB_ID = @MOB_ID
		and DatabaseName = IDB_Name
	when not matched then insert(IDB_ClientID, IDB_MOB_ID, IDB_Name, IDB_InsertDate, IDB_LastSeenDate, IDB_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, DatabaseName, sysdatetime(), sysdatetime(), Metadata_TRH_ID);

merge Activity.SQLStatements d
	using (select distinct SQLStatement, hashbytes('MD5', left(cast(SQLStatement as varchar(max)), 8000)) StatementHashed
			from inserted
			where SQLStatement is not null) s
		on StatementHashed = SQS_StatementHashed
			and SQLStatement = SQS_Statement
	when matched then update set
							SQS_LastSeenDate = @StartDate
	when not matched then insert(SQS_Statement, SQS_LastSeenDate)
							values(SQLStatement, @StartDate);

merge Activity.ObjectNames d
	using (select distinct ObjectName
			from inserted
			where ObjectName is not null) s
		on ObjectName = OBN_Name
	when not matched then insert(OBN_Name)
							values(ObjectName);

merge Inventory.InstanceTopQueries d
	using (select Metadata_ClientID, IDB_ID, OBN_ID, SQS_ID, AverageExecutionsPerDay, AverageReadsPerDay, AverageCPUMilliPerDay, AverageDurationMilliPerExecution,
				AverageReadsPerExecution, AverageCPUMilliPerExecution, AverageDurationMilliPerDay, RankByCPU, RankByReads, ImplicitlyConvertedColumns, LookupCount,
				ScalarFunctionsUsed, Metadata_TRH_ID
			from inserted
				left join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
														and DatabaseName = IDB_Name
				left join Activity.ObjectNames on OBN_Name = ObjectName
				inner join Activity.SQLStatements on SQS_StatementHashed = hashbytes('MD5', left(cast(SQLStatement as varchar(max)), 8000))
														and SQS_Statement = SQLStatement) s
		on ITQ_MOB_ID = @MOB_ID
			and (ITQ_IDB_ID = IDB_ID
				or (ITQ_IDB_ID is null
					and IDB_ID is null)
				)
			and (ITQ_OBN_ID = OBN_ID
				or (ITQ_OBN_ID is null
					and OBN_ID is null)
				)
			and ITQ_SQS_ID = SQS_ID
	when matched then update set
							ITQ_AverageExecutionsPerDay = AverageExecutionsPerDay,
							ITQ_AverageReadsPerDay = AverageReadsPerDay,
							ITQ_AverageCPUMilliPerDay = AverageCPUMilliPerDay,
							ITQ_AverageDurationMilliPerDay = AverageDurationMilliPerDay,
							ITQ_AverageReadsPerExecution = AverageReadsPerExecution,
							ITQ_AverageCPUMilliPerExecution = AverageCPUMilliPerExecution,
							ITQ_AverageDurationMilliPerExecution = AverageDurationMilliPerExecution,
							ITQ_RankByCPU = RankByCPU,
							ITQ_RankByReads = RankByReads,
							ITQ_ImplicitlyConvertedColumns = ImplicitlyConvertedColumns,
							ITQ_LookupCount = LookupCount,
							ITQ_ScalarFunctionsUsed = ScalarFunctionsUsed,
							ITQ_LastSeenDate = @StartDate,
							ITQ_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(ITQ_ClientID, ITQ_MOB_ID, ITQ_IDB_ID, ITQ_OBN_ID, ITQ_SQS_ID, ITQ_AverageExecutionsPerDay, ITQ_AverageReadsPerDay,
									ITQ_AverageCPUMilliPerDay, ITQ_AverageDurationMilliPerDay, ITQ_AverageReadsPerExecution, ITQ_AverageCPUMilliPerExecution,
									ITQ_AverageDurationMilliPerExecution, ITQ_InsertDate, ITQ_RankByCPU, ITQ_RankByReads, ITQ_ImplicitlyConvertedColumns,
									ITQ_LookupCount, ITQ_ScalarFunctionsUsed, ITQ_LastSeenDate, ITQ_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IDB_ID, OBN_ID, SQS_ID, AverageExecutionsPerDay, AverageReadsPerDay,
									AverageCPUMilliPerDay, AverageDurationMilliPerDay, AverageReadsPerExecution, AverageCPUMilliPerExecution,
									AverageDurationMilliPerExecution, @StartDate, RankByCPU, RankByReads, ImplicitlyConvertedColumns, LookupCount,
									ScalarFunctionsUsed, @StartDate, Metadata_TRH_ID);

merge Inventory.RecommendedIndexes d
	using (select Metadata_ClientID, ITQ_ID, cast(left(Val, charindex('||', Val, 1) - 1) as decimal(10, 2)) IndexImpact,
				substring(Val, CHARINDEX('||', Val, 1) + 2, len(Val)) IndexScript, Metadata_TRH_ID
			from inserted
				left join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
														and DatabaseName = IDB_Name
				left join Activity.ObjectNames on OBN_Name = ObjectName
				left join Activity.SQLStatements on SQS_StatementHashed = hashbytes('MD5', left(cast(SQLStatement as varchar(max)), 8000))
														and SQS_Statement = SQLStatement
				inner join Inventory.InstanceTopQueries on ITQ_MOB_ID = @MOB_ID
															and (ITQ_IDB_ID = IDB_ID
																or (ITQ_IDB_ID is null
																	and IDB_ID is null)
																)
															and (ITQ_OBN_ID = OBN_ID
																or (ITQ_OBN_ID is null
																	and OBN_ID is null)
																)
															and ITQ_SQS_ID = SQS_ID
				cross apply Infra.fn_SplitString(RecommendedIndexes, ';') s
			) s
		on RCI_MOB_ID = @MOB_ID
			and RCI_ITQ_ID = ITQ_ID
			and RCI_HashedIndexScript = hashbytes('MD5',left(CONVERT(varchar(max),IndexScript,0),(8000)))
	when matched then update set
							RCI_Impact = IndexImpact,
							RCI_LastSeenDate = @StartDate,
							RCI_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(RCI_ClientID, RCI_MOB_ID, RCI_ITQ_ID, RCI_Impact, RCI_IndexScript, RCI_InsertDate, RCI_LastSeenDate, RCI_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, ITQ_ID, IndexImpact, IndexScript, @StartDate, @StartDate, Metadata_TRH_ID);
GO
