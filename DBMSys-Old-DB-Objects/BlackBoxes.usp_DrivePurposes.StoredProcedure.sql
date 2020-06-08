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
/****** Object:  StoredProcedure [BlackBoxes].[usp_DrivePurposes]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [BlackBoxes].[usp_DrivePurposes]
	@Parameters xml,
	@BlackBox xml output
as
set nocount on

;with Disks as
		(select DSK_ID, max(S_DateTime) S_DateTime, S_EventInstanceName
			from Inventory.Disks
				inner join (select PCR_Parent_MOB_ID, S_MOB_Name, max(S_DateTime) S_DateTime, S_EventInstanceName
							from #SelectedMonitoredObjects
								inner join Inventory.ParentChildRelationships on PCR_Child_MOB_ID = S_MOB_ID
							where S_PLT_ID = 1
								and PCR_IsCurrentParent = 1
							group by PCR_Parent_MOB_ID, S_MOB_Name, S_EventInstanceName) s on DSK_MOB_ID = PCR_Parent_MOB_ID
														and DSK_Path = S_EventInstanceName
			group by DSK_ID, S_EventInstanceName
		)
	, Purposes as
		(select distinct DSK_ID P_DSK_ID, BKL_MOB_ID P_MOB_ID, 'Backup' Purpose
			from Disks
				inner join Inventory.BackupLocations on BKL_DSK_ID = DSK_ID
			union all
			select distinct DSK_ID P_DSK_ID, DBF_MOB_ID P_MOB_ID,
				case when IDB_Name in ('master', 'model', 'msdb') then 'System Databases'
					when IDB_Name = 'tempdb' then 'tempdb'
					else 'User Databases'
				end
				+ ' (' + DFT_Name + ')'
				Purpose
			from Disks
				inner join Inventory.DatabaseFiles on DBF_DSK_ID = DSK_ID
				inner join Inventory.InstanceDatabases on DBF_IDB_ID = IDB_ID
				inner join Inventory.DatabaseFileTypes on DBF_DFT_ID = DFT_ID
		)
select @BlackBox =
	(select 'Purposes of drive ' + S_EventInstanceName Header,
			S_DateTime SnapshotDate,
			(select (select Ordinal, Name
						from (values(1, 'Purpose'),
									(2, 'Database Instance')) [Column](Ordinal, Name)
						for xml auto, type) ColumnNames,
					(select (select 1 [@Ordinal], Purpose [@Value] for xml path('Column'), type),
							(select 2 [@Ordinal], stuff((select ', ' + MOB_Name
														from Purposes p1
															inner join Inventory.MonitoredObjects on p1.P_MOB_ID = MOB_ID
														where p1.Purpose = p.Purpose
														order by MOB_Name
														for xml path('')), 1, 2, '') [@Value] for xml path('Column'), type)
					from (select distinct Purpose
							from Purposes
							where P_DSK_ID = DSK_ID) p
					order by Purpose
					for xml path('Row'), elements, type) [Rows]
				for xml path(''), root('Table'), type)
	from Disks Info
	for xml auto, elements, root('Blackbox')
	)
GO
