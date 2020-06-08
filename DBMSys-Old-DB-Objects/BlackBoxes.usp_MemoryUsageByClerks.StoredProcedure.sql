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
/****** Object:  StoredProcedure [BlackBoxes].[usp_MemoryUsageByClerks]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [BlackBoxes].[usp_MemoryUsageByClerks]
	@Parameters xml,
	@BlackBox xml output
as
set nocount on

;with Instances as
	(select S_MOB_ID, S_MOB_Name, max(S_DateTime) S_DateTime, S_EventInstanceName
		from #SelectedMonitoredObjects
		where S_PLT_ID = 1
			and S_TST_ID = 32
		group by S_MOB_ID, S_MOB_Name, S_EventInstanceName)
select @BlackBox =
	(select 'Top memory consuming clerks' Header,
			(select MAX(S_DateTime) from Instances) SnapshotDate,
			(select (select Ordinal, Name
						from (values(1, 'SQL Instance'),
									(2, 'Memory Clerk'),
									(3, 'Memory Usage (MB)')) [Column](Ordinal, Name)
						for xml auto, type) ColumnNames,
					(select top(isnull(@Parameters.value('(Parameters/Parameter[@Name="NumberOfClerks"])[1]/@Value', 'int'), 99999))
								(select 1 [@Ordinal], S_MOB_Name [@Value] for xml path('Column'), type),
								(select 2 [@Ordinal], CIN_Name [@Value] for xml path('Column'), type),
								(select 3 [@Ordinal], CRS_Value [@Value] for xml path('Column'), type)
							from Instances
								inner join PerformanceData.CounterResults on CRS_MOB_ID = S_MOB_ID
								inner join PerformanceData.CounterInstances on CRS_InstanceID = CIN_ID
							where CRS_SystemID = 3
								and CRS_CounterID = 92
								and CRS_DateTime between dateadd(second, -30, S_DateTime)
													and dateadd(second, 30, S_DateTime)
								and CIN_Name <> '_Total'
					order by CRS_Value desc
					for xml path('Row'), elements, type) [Rows]
				for xml path(''), root('Table'), type)
	for xml path('Info'), root('Blackbox')
	)
GO
