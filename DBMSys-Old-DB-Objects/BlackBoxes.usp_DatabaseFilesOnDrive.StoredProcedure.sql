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
/****** Object:  StoredProcedure [BlackBoxes].[usp_DatabaseFilesOnDrive]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [BlackBoxes].[usp_DatabaseFilesOnDrive]
	@Parameters xml,
	@BlackBox xml output
as
set nocount on
declare @Top int

set @Top = isnull(@Parameters.value('(Parameters/Parameter[@Name="NumberOfFiles"])[1]/@Value', 'int'), 999999)

select @BlackBox =
	(select '10 Largest Database Files on drive ' + S_EventInstanceName Header,
			S_DateTime SnapshotDate,
			(select (select Ordinal, Name
						from (values(1, 'Database Instance Name'),
									(2, 'Database Name'),
									(3, 'File Name'),
									(4, 'Size (MB)'),
									(5, '% Used')) [Column](Ordinal, Name)
						for xml auto, type) ColumnNames,
					
					(select top(@Top) (select 1 [@Ordinal], MOB_Name [@Value] for xml path('Column'), type),
										(select 2 [@Ordinal], IDB_Name [@Value] for xml path('Column'), type),
										(select 3 [@Ordinal], DBF_FileName [@Value] for xml path('Column'), type),
										(select 4 [@Ordinal], FileSizeMB [@Value] for xml path('Column'), type),
										(select 5 [@Ordinal], PercentUsed [@Value] for xml path('Column'), type)
						from (select distinct PCR_Parent_MOB_ID, S_MOB_ID, S_EventInstanceName
								from #SelectedMonitoredObjects
									inner join Inventory.ParentChildRelationships on PCR_Child_MOB_ID = S_MOB_ID
								where S_PLT_ID = 1
									and PCR_IsCurrentParent = 1	
								) smo
							inner join Inventory.Disks on DSK_MOB_ID = PCR_Parent_MOB_ID
														and DSK_Path = S_EventInstanceName
							inner join Inventory.DatabaseFiles on DBF_MOB_ID = S_MOB_ID
																and DBF_DSK_ID = DSK_ID
							inner join Inventory.MonitoredObjects on DBF_MOB_ID = MOB_ID
							inner join Inventory.InstanceDatabases on DBF_IDB_ID = IDB_ID
							inner join PerformanceData.CounterInstances on DBF_FileName = CIN_Name
							outer apply (select top 1 cast(CRS_Value as bigint) FileSizeMB
											from PerformanceData.CounterResults with (forceseek)
											where CRS_MOB_ID = MOB_ID
													and CRS_SystemID = 3
													and CRS_CounterID = 41
													and CRS_InstanceID = CIN_ID
													and CRS_DateTime > dateadd(hour, -1, SYSDATETIME())
											order by CRS_DateTime desc) s
							outer apply (select top 1 cast(CRS_Value as bigint) PercentUsed
											from PerformanceData.CounterResults with (forceseek)
											where CRS_MOB_ID = MOB_ID
													and CRS_SystemID = 3
													and CRS_CounterID = 43
													and CRS_InstanceID = CIN_ID
													and CRS_DateTime > dateadd(hour, -1, SYSDATETIME())
											order by CRS_DateTime desc) p			
						order by FileSizeMB desc, PercentUsed
						for xml path('Row'), elements, type) [Rows]
			for xml path(''), root('Table'), type)
	from (select top 1 PCR_Parent_MOB_ID, S_MOB_Name, max(S_DateTime) S_DateTime, S_EventInstanceName
			from #SelectedMonitoredObjects
				inner join Inventory.ParentChildRelationships on PCR_Child_MOB_ID = S_MOB_ID
			where S_PLT_ID = 1
				and PCR_IsCurrentParent = 1
			group by PCR_Parent_MOB_ID, S_MOB_Name, S_EventInstanceName
			) Info
	for xml auto, elements, root('Blackbox')
	)
GO
