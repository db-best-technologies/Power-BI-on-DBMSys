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
/****** Object:  StoredProcedure [BlackBoxes].[usp_TranasactionalReplicationLatencyInformation]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [BlackBoxes].[usp_TranasactionalReplicationLatencyInformation]
	@Parameters xml,
	@BlackBox xml output
as
set nocount on

;with Results as
	(select GNC_ID, GNC_CounterName, CRS_Value, CRS_DateTime
		from (select S_MOB_ID, max(S_DateTime) S_DateTime, S_EventInstanceName
				from #SelectedMonitoredObjects
				where S_PLT_ID = 1
				group by S_MOB_ID, S_EventInstanceName) t
			cross join PerformanceData.GeneralCounters
			cross apply (select top 1 cast(CRS_Value as int) CRS_Value, CRS_DateTime
							from PerformanceData.CounterResults
								inner join PerformanceData.CounterInstances on CIN_ID = CRS_InstanceID
							where CRS_DateTime >= S_DateTime
								and CRS_MOB_ID = S_MOB_ID
								and CRS_SystemID = 3
								and CRS_CounterID = GNC_ID
								and (CIN_Name = S_EventInstanceName
										or S_EventInstanceName like CIN_Name + ', To DB%')
							order by CRS_DateTime desc
						) r
		where GNC_ID in (170, 171, 172, 173)
		)
select @BlackBox =
	(select 'Replication Latency Information' Header,
			(select MAX(CRS_DateTime) from Results) SnapshotDate,
			(select (select Ordinal, Name
						from (values(1, 'Counter'),
									(2, 'Value')) [Column](Ordinal, Name)
						for xml auto, type) ColumnNames,
					(select top(isnull(@Parameters.value('(Parameters/Parameter[@Name="NumberOfDatabases"])[1]/@Value', 'int'), 99999))
								(select 1 [@Ordinal], GNC_CounterName [@Value] for xml path('Column'), type),
								(select 2 [@Ordinal], CRS_Value [@Value] for xml path('Column'), type)
							from Results
					order by GNC_ID desc
					for xml path('Row'), elements, type) [Rows]
				for xml path(''), root('Table'), type)
	for xml path('Info'), root('Blackbox')
	)
GO
