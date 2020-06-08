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
/****** Object:  View [Tests].[VW_TST_SQLRunningProcesses]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_SQLRunningProcesses]
as
select top 0 cast(null as smallint) SessionID,
			cast(null as int) NumberOfThreads,
			cast(null as datetime) StartTime,
			cast(null as nvarchar(max)) WaitType,
			cast(null as int) WaitTime,
			cast(null as nvarchar(max)) DatabaseName,
			cast(null as smallint) BlockedBySessionID,
			cast(null as nvarchar(max)) SQLStatement,
			cast(null as nvarchar(max)) ObjectName,
			cast(null as int) CPUTime,
			cast(null as bigint) LogicalReads,
			cast(null as nvarchar(max)) HostName,
			cast(null as nvarchar(max)) LoginName,
			cast(null as nvarchar(max)) ProgramName,
			cast(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SQLRunningProcesses]    Script Date: 6/8/2020 1:16:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_SQLRunningProcesses] on [Tests].[VW_TST_SQLRunningProcesses]
	instead of insert
as
set nocount on
declare @MOB_ID int,
		@StartDate datetime2(3)

select top 1 @MOB_ID = TRH_MOB_ID,
			@StartDate = TRH_StartDate
from inserted inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID

;with ExistingWaitTypes as
		(select GNC_ID, GNC_PCG_ID, GNC_CSY_ID, GNC_CategoryName, GNC_CounterName, GNC_IsAggregative
			from PerformanceData.GeneralCounters
			where GNC_CSY_ID = 5
					and GNC_CategoryName = 'SQL Waits')
merge ExistingWaitTypes d
	using (select row_number() over (order by WaitType) + MaxID NextID,  WaitType
			from inserted
				cross join (select max(GNC_ID) MaxID from ExistingWaitTypes) m
			where WaitType is not null
				and not exists (select *
								from ExistingWaitTypes
								where WaitType = GNC_CounterName)
			) s
		on WaitType = GNC_CounterName
	when not matched then insert(GNC_ID, GNC_PCG_ID, GNC_CSY_ID, GNC_CategoryName, GNC_CounterName, GNC_IsAggregative)
							values(NextID, 0, 5, 'SQL Waits', WaitType, 1);

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

merge Activity.HostNames d
	using (select distinct HostName
			from inserted
			where HostName is not null) s
		on HostName = HSN_Name
	when not matched then insert(HSN_Name)
							values(HostName);

merge Activity.LoginNames d
	using (select distinct LoginName
			from inserted) s
		on LoginName = LGN_Name
	when not matched then insert(LGN_Name)
							values(LoginName);

merge Activity.ProgramNames d
	using (select distinct ProgramName
			from inserted
			where ProgramName is not null) s
		on ProgramName = PGN_Name
	when not matched then insert(PGN_Name)
							values(ProgramName);

insert into Activity.RunningSQLProcesses(RQP_ClientID, RQP_MOB_ID, RQP_DateTime, RQP_SessionID, RQP_NumberOfThreads, RQP_StartTime,
											RQP_WaitType_GNC_ID, RQP_WaitTime, RQP_IDB_ID, RQP_BlockedBySessionID, RQP_SQS_ID, RQP_OBN_ID,
											RQP_CPUTime, RQP_LogicalReads, RQP_HSN_ID, RQP_LGN_ID, RQP_PGN_ID)
select Metadata_ClientID, @MOB_ID, @StartDate, SessionID, NumberOfThreads, StartTime, GNC_ID, WaitTime, IDB_ID, BlockedBySessionID, SQS_ID,
		OBN_ID, CPUTime, LogicalReads, HSN_ID, LGN_ID, PGN_ID
from inserted
	left join PerformanceData.GeneralCounters on GNC_CounterName = WaitType
													and GNC_CSY_ID = 5
													and GNC_CategoryName = 'SQL Waits'
	inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
												and IDB_Name = DatabaseName
	left join Activity.SQLStatements on SQS_StatementHashed = hashbytes('MD5', left(cast(SQLStatement as varchar(max)), 8000))
											and SQS_Statement = SQLStatement
	left join Activity.ObjectNames on OBN_Name = ObjectName
	left join Activity.HostNames on HSN_Name = HostName
	inner join Activity.LoginNames on LGN_Name = LoginName
	left join Activity.ProgramNames on PGN_Name = ProgramName


;WITH CurrRunProc AS
(
	SELECT 
			*
	FROM	Activity.CurrentLongRunningProcesses
	WHERE	CRP_MOB_ID = @MOB_ID
	
)

MERGE CurrRunProc
	USING (
			select Metadata_ClientID, @MOB_ID AS MOB_ID, @StartDate AS SeenDate, SessionID, StartTime, GNC_ID, IDB_ID, SQS_ID,
					OBN_ID, HSN_ID, LGN_ID, PGN_ID, Metadata_TRH_ID
			from inserted
				left join PerformanceData.GeneralCounters on GNC_CounterName = WaitType
																and GNC_CSY_ID = 5
																and GNC_CategoryName = 'SQL Waits'
				inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
															and IDB_Name = DatabaseName
				left join Activity.SQLStatements on SQS_StatementHashed = hashbytes('MD5', left(cast(SQLStatement as varchar(max)), 8000))
														and SQS_Statement = SQLStatement
				left join Activity.ObjectNames on OBN_Name = ObjectName
				left join Activity.HostNames on HSN_Name = HostName
				inner join Activity.LoginNames on LGN_Name = LoginName
				left join Activity.ProgramNames on PGN_Name = ProgramName
			WHERE DATEDIFF(mi,StartTime,@StartDate)>30
					AND SQS_Statement <> 'sp_server_diagnostics'

			)s ON CRP_MOB_ID = MOB_ID	
				 AND CRP_SessionID			=  SessionID	
				 AND CRP_StartDate			=  StartTime	
				 AND CRP_LGN_ID				=  LGN_ID		
				 AND CRP_PGN_ID				=  PGN_ID		
				 AND ISNULL(CRP_OBN_ID,0)	=  ISNULL(OBN_ID,0)
				 AND CRP_IDB_ID				=  IDB_ID		
				 AND CRP_HSN_ID				=  HSN_ID		
		WHEN MATCHED
		THEN UPDATE
					SET	CRP_Last_SeenDate	= SeenDate
						,CRP_SQS_ID			=  SQS_ID		
						,CRP_Last_TRH_ID	= Metadata_TRH_ID
						,CRP_IsFinished		= 0
		when not matched then insert (CRP_ClientID,CRP_MOB_ID,CRP_StartDate,CRP_SessionID,CRP_SQS_ID,CRP_LGN_ID,CRP_PGN_ID,CRP_OBN_ID,CRP_IDB_ID,CRP_HSN_ID,CRP_IsFinished,CRP_Last_TRH_ID,CRP_Last_SeenDate)
		VALUES (Metadata_ClientID,MOB_ID,StartTime,SessionID,SQS_ID,LGN_ID,PGN_ID,OBN_ID,IDB_ID,HSN_ID,0,Metadata_TRH_ID,SeenDate)

		WHEN NOT MATCHED BY SOURCE
			THEN UPDATE	SET CRP_IsFinished = 1;
GO
