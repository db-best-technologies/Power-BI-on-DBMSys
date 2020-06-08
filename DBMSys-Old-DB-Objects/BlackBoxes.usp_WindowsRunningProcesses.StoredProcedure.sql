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
/****** Object:  StoredProcedure [BlackBoxes].[usp_WindowsRunningProcesses]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [BlackBoxes].[usp_WindowsRunningProcesses]
	@Parameters xml,
	@BlackBox xml output
as
set nocount on
select @BlackBox =
	(select 'Running Windows Processes on Windows Server: ' + S_MOB_Name Header,
			S_DateTime SnapshotDate,
			(select (select Ordinal, Name
						from (values(1, 'Process Name'),
									(2, '% CPU Usage'),
									(3, 'Memory Usage (MB)')) [Column](Ordinal, Name)
						for xml auto, type) ColumnNames,
					(select (select 1 [@Ordinal], Process [@Value] for xml path('Column'), type),
							(select 2 [@Ordinal], CPU [@Value] for xml path('Column'), type),
							(select 3 [@Ordinal], Memory [@Value] for xml path('Column'), type)
						from (select CIN_Name Process, cast(max(case when CRS_CounterID = 24 then CRS_Value else 0 end) as int)/Processors CPU,
									cast(max(case when CRS_CounterID = 25 then CRS_Value/1024/1024 else 0 end) as int) Memory
								from PerformanceData.CounterResults
									inner join PerformanceData.CounterInstances on CRS_InstanceID = CIN_ID
									cross apply (select sum(PRS_NumberOfLogicalProcessors) Processors
													from inventory.Processors
													where PRS_MOB_ID = S_MOB_ID) p
								where CRS_SystemID = 4
									and CRS_CounterID in (24, 25)
									and CIN_Name not in ('_Total', 'Idle')
									and CRS_MOB_ID = S_MOB_ID
									and CRS_DateTime between dateadd(second, -30, S_DateTime)
														and dateadd(second, 30, S_DateTime)
								group by CIN_Name, Processors) Results
						where CPU > 0
							or Memory > 0
						order by case @Parameters.value('(Parameters/Parameter[@Name="SortBy"])[1]/@Value', 'varchar(100)')
										when 'CPU' then CPU
										when 'Memory' then Memory
									end desc
						for xml path('Row'), elements, type) [Rows]
			for xml path(''), root('Table'), type)
	from (select S_MOB_ID, S_MOB_Name, max(S_DateTime) S_DateTime, S_EventInstanceName
			from #SelectedMonitoredObjects
			where S_PLT_ID = 2
				and S_TST_ID = 6
			group by S_MOB_ID, S_MOB_Name, S_EventInstanceName) Info
	for xml auto, elements, root('Blackbox')
	)
GO
