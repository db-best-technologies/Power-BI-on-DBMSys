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
/****** Object:  StoredProcedure [BlackBoxes].[usp_SQLRunningProcesses]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [BlackBoxes].[usp_SQLRunningProcesses]
	@Parameters xml,
	@BlackBox xml output
as
set nocount on

select @BlackBox =
	(select 'Running SQL Processes for SQL Instance: ' + S_MOB_Name Header,
			S_DateTime SnapshotDate,
			(select (select Ordinal, Name
						from (values(1, 'Session ID'),
									(2, 'Number Of Threads'),
									(3, 'Seconds Running'),
									(4, 'Wait Type'),
									(5, 'Wait Time'),
									(6, 'Database Name'),
									(7, 'Blocked By Session ID'),
									(8, 'SQL Statement'),
									(9, 'Object Name'),
									(10, 'CPU Time'),
									(11, 'Logical Reads'),
									(12, 'Host Name'),
									(13, 'Login Name'),
									(14, 'Program Name')) [Column](Ordinal, Name)
						for xml auto, type) ColumnNames,
					(select (select 1 [@Ordinal], RQP_SessionID [@Value] for xml path('Column'), type),
							(select 2 [@Ordinal], RQP_NumberOfThreads [@Value] for xml path('Column'), type),
							(select 3 [@Ordinal], DATEDIFF(second, RQP_StartTime, RQP_DateTime) [@Value] for xml path('Column'), type),
							(select 4 [@Ordinal], GNC_CounterName [@Value] for xml path('Column'), type),
							(select 5 [@Ordinal], RQP_WaitTime [@Value] for xml path('Column'), type),
							(select 6 [@Ordinal], IDB_Name [@Value] for xml path('Column'), type),
							(select 7 [@Ordinal], RQP_BlockedBySessionID [@Value] for xml path('Column'), type),
							(select 8 [@Ordinal], SQS_Statement [@Value] for xml path('Column'), type),
							(select 9 [@Ordinal], OBN_Name [@Value] for xml path('Column'), type),
							(select 10 [@Ordinal], RQP_CPUTime [@Value] for xml path('Column'), type),
							(select 11 [@Ordinal], RQP_LogicalReads [@Value] for xml path('Column'), type),
							(select 12 [@Ordinal], HSN_Name [@Value] for xml path('Column'), type),
							(select 13 [@Ordinal], LGN_Name [@Value] for xml path('Column'), type),
							(select 14 [@Ordinal], PGN_Name [@Value] for xml path('Column'), type)
						from Activity.RunningSQLProcesses
							left join PerformanceData.GeneralCounters on GNC_ID = RQP_WaitType_GNC_ID
							inner join Inventory.InstanceDatabases on IDB_ID = RQP_IDB_ID
							left join Activity.SQLStatements on SQS_ID = RQP_SQS_ID
							left join Activity.ObjectNames on OBN_ID = RQP_OBN_ID
							left join Activity.HostNames on HSN_ID = RQP_HSN_ID
							inner join Activity.LoginNames on LGN_ID = RQP_LGN_ID
							left join Activity.ProgramNames on PGN_ID = RQP_PGN_ID
						where RQP_MOB_ID = S_MOB_ID
							and RQP_DateTime = S_DateTime
						order by RQP_NumberOfThreads desc
						for xml path('Row'), elements, type) [Rows]
			for xml path(''), root('Table'), type)
	from (select S_MOB_ID, S_MOB_Name, max(S_DateTime) S_DateTime, S_EventInstanceName
				from #SelectedMonitoredObjects
				where S_PLT_ID = 1
					and S_TST_ID = 23
				group by S_MOB_ID, S_MOB_Name, S_EventInstanceName) Info
	for xml auto, elements, root('Blackbox')
	)
GO
