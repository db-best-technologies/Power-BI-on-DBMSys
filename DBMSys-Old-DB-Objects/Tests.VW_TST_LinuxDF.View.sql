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
/****** Object:  View [Tests].[VW_TST_LinuxDF]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Tests].[VW_TST_LinuxDF]
AS
	SELECT TOP 
		0 CAST(null as varchar(500)) Filesystem,
		CAST(null as varchar(100)) [Type],
		CAST(null as bigint) [1048576-blocks],
		CAST(null as bigint) Available,
		CAST(null as varchar(10)) [Used],
		CAST(null as int) Metadata_TRH_ID,
		CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_LinuxDF]    Script Date: 6/8/2020 1:16:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Tests].[trg_VW_TST_LinuxDF] on [Tests].[VW_TST_LinuxDF]
instead of insert
as
	set nocount on
	declare @MOB_ID int,
		@StartDate datetime2(3)

	select @MOB_ID = TRH_MOB_ID,
		@StartDate = TRH_StartDate
	from inserted
		inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID

	merge Inventory.FileSystems d
		using (select [Type], row_number() over(order by [Type]) + LastID ID
				from (select distinct [Type]
						from inserted) i
					cross apply (select max(FST_ID) LastID
									from Inventory.FileSystems) l
				where not exists (select *
									from Inventory.FileSystems
									where FST_Name = [Type])
				) s
			on FST_Name = [Type]
		when not matched then insert(FST_ID, FST_Name)
								values(ID, [Type]);

	merge Inventory.Disks d
		using (select Metadata_ClientID, Filesystem, FST_ID, [1048576-blocks], Metadata_TRH_ID,
					case when Filesystem like '%\dm-%'
											or Filesystem like '%sd%'
											or Filesystem like '%hd%'
						then replace(substring(Filesystem, len(Filesystem) - charindex('/', reverse(Filesystem), 2) + 2, 500), '/', '')
					end InstanceName
				from inserted
					inner join Inventory.FileSystems on FST_Name = [Type]
					) s
			on DSK_MOB_ID = @MOB_ID
				and DSK_Path = Filesystem
			when matched then update set
									DSK_FST_ID = FST_ID,
									DSK_TotalSpaceMB = [1048576-blocks],
									DSK_LastSeenDate = @StartDate,
									DSK_Last_TRH_ID = Metadata_TRH_ID
			when not matched then insert (DSK_ClientID, DSK_MOB_ID, DSK_FST_ID, DSK_Path, DSK_InstanceName, DSK_TotalSpaceMB, DSK_InsertDate, DSK_LastSeenDate, DSK_Last_TRH_ID)
									values(Metadata_ClientID, @MOB_ID, FST_ID, Filesystem, InstanceName, [1048576-blocks], @StartDate, @StartDate, Metadata_TRH_ID);

	;with NewRecords as
		(select DSK_InstanceName, Available, [used], Metadata_TRH_ID, Metadata_ClientID
			from inserted
				inner join Inventory.Disks on DSK_MOB_ID = @MOB_ID
											and DSK_Path = Filesystem
			where DSK_InstanceName is not null
		)
	insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Instance, Value, Metadata_TRH_ID, Metadata_ClientID)
	select 'Linux Drives', 'Free Disk Space (MB)', DSK_InstanceName, Available, Metadata_TRH_ID, Metadata_ClientID
	from NewRecords
	union all
	select 'Linux Drives', 'Free Disk Space %', DSK_InstanceName, 100 - cast(replace([used], '%', '') as int) Value, Metadata_TRH_ID, Metadata_ClientID
	from NewRecords
GO
