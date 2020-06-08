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
/****** Object:  View [Tests].[VW_TST_AIXDF]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_AIXDF]
as
select top 0 CAST(null as varchar(255)) [Filesystem],
			CAST(null as varchar(100)) [1024-blocks],
			CAST(null as varchar(100)) [Free],
			CAST(null as varchar(10)) [%Used],
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_AIXDF]    Script Date: 6/8/2020 1:15:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_AIXDF] on [Tests].[VW_TST_AIXDF]
	instead of insert
as
set nocount on
set transaction isolation level read uncommitted

declare @MOB_ID int,
	@StartDate datetime2(3)

select @MOB_ID = TRH_MOB_ID,
	@StartDate = TRH_StartDate
from inserted
	inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID

merge Inventory.Disks d
	using (select Metadata_ClientID, cast([1024-blocks] as bigint)/1024 SizeMB, Metadata_TRH_ID,
				Filesystem
			from inserted
			where isnumeric([1024-blocks]) = 1
			) s
		on DSK_MOB_ID = @MOB_ID
			and DSK_Path = Filesystem
		when matched then update set
								DSK_TotalSpaceMB = SizeMB,
								DSK_LastSeenDate = @StartDate,
								DSK_Last_TRH_ID = Metadata_TRH_ID
		when not matched then insert (DSK_ClientID, DSK_MOB_ID, DSK_Path, DSK_InstanceName, DSK_TotalSpaceMB, DSK_InsertDate, DSK_LastSeenDate, DSK_Last_TRH_ID)
								values(Metadata_ClientID, @MOB_ID, Filesystem, Filesystem, SizeMB, @StartDate, @StartDate, Metadata_TRH_ID);

;with NewRecords as
	(select DSK_InstanceName, cast(Free as bigint) Free, [%Used], Metadata_TRH_ID, Metadata_ClientID
		from inserted
			inner join Inventory.Disks on DSK_MOB_ID = @MOB_ID
										and DSK_Path = Filesystem
		where DSK_InstanceName is not null
			and isnumeric(Free) = 1
	)
insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Instance, Value, Metadata_TRH_ID, Metadata_ClientID)
select 'AIX File Systems', 'Free Disk Space (MB)', DSK_InstanceName, Free/1024, Metadata_TRH_ID, Metadata_ClientID
from NewRecords
union all
select 'AIX File Systems', 'Free Disk Space %', DSK_InstanceName, 100 - cast(replace([%Used], '%', '') as int) Value, Metadata_TRH_ID, Metadata_ClientID
from NewRecords
GO
