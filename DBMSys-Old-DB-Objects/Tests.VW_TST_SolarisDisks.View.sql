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
/****** Object:  View [Tests].[VW_TST_SolarisDisks]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_SolarisDisks]
as
select top 0 CAST(null as varchar(200)) NAME,
			CAST(null as varchar(100)) SIZE,
			CAST(null as varchar(100)) ALLOC,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SolarisDisks]    Script Date: 6/8/2020 1:16:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_SolarisDisks] on [Tests].[VW_TST_SolarisDisks]
	instead of insert
as
set nocount on
set transaction isolation level read uncommitted

merge Inventory.Disks d
	using (select NAME, case when SIZE like '%T'
								then cast(replace(SIZE, 'T', '') as decimal(15, 3))*1024*1024
							when SIZE like '%G'
								then cast(replace(SIZE, 'G', '') as decimal(15, 3))*1024
							when SIZE like '%M'
								then cast(replace(SIZE, 'M', '') as decimal(15, 3))
							when SIZE like '%K'
								then cast(replace(SIZE, 'K', '') as decimal(15, 3))/1024.
							when SIZE like '%B'
								then cast(replace(SIZE, 'B', '') as decimal(15, 3))/1024./1024
						end Size, TRH_MOB_ID, Metadata_ClientID, TRH_ID
			from inserted
				inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID
			) s
		on TRH_MOB_ID = DSK_MOB_ID
			and NAME = DSK_Path
	when matched then update
					set DSK_TotalSpaceMB = Size,
						DSK_InsertDate = getdate(),
						DSK_LastSeenDate = getdate(),
						DSK_Last_TRH_ID = TRH_ID
	when not matched then insert(DSK_ClientID, DSK_MOB_ID, DSK_Path, DSK_TotalSpaceMB, DSK_InsertDate, DSK_LastSeenDate, DSK_Last_TRH_ID)
						values(Metadata_ClientID, TRH_MOB_ID, Name, Size, getdate(), getdate(), TRH_ID);

insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Instance, Value, Metadata_TRH_ID, Metadata_ClientID)
select 'Solaris Disk', 'Free Space (MB)', NAME,
		case when SIZE like '%T'
				then cast(replace(SIZE, 'T', '') as decimal(15, 3))*1024*1024
			when SIZE like '%G'
				then cast(replace(SIZE, 'G', '') as decimal(15, 3))*1024
			when SIZE like '%M'
				then cast(replace(SIZE, 'M', '') as decimal(15, 3))
			when SIZE like '%K'
				then cast(replace(SIZE, 'K', '') as decimal(15, 3))/1024.
			when SIZE like '%B'
				then cast(replace(SIZE, 'B', '') as decimal(15, 3))/1024./1024
		end
		-
		case when ALLOC like '%T'
				then cast(replace(ALLOC, 'T', '') as decimal(15, 3))*1024*1024
			when ALLOC like '%G'
				then cast(replace(ALLOC, 'G', '') as decimal(15, 3))*1024
			when ALLOC like '%M'
				then cast(replace(ALLOC, 'M', '') as decimal(15, 3))
			when ALLOC like '%K'
				then cast(replace(ALLOC, 'K', '') as decimal(15, 3))/1024.
			when ALLOC like '%B'
				then cast(replace(ALLOC, 'B', '') as decimal(15, 3))/1024./1024
		end, Metadata_TRH_ID, Metadata_ClientID
from inserted
union
select 'Solaris Disk', 'Percentage Free', NAME,
		100 -
		case when ALLOC like '%T'
				then cast(replace(ALLOC, 'T', '') as decimal(15, 3))*1024*1024
			when ALLOC like '%G'
				then cast(replace(ALLOC, 'G', '') as decimal(15, 3))*1024
			when ALLOC like '%M'
				then cast(replace(ALLOC, 'M', '') as decimal(15, 3))
			when ALLOC like '%K'
				then cast(replace(ALLOC, 'K', '') as decimal(15, 3))/1024.
			when ALLOC like '%B'
				then cast(replace(ALLOC, 'B', '') as decimal(15, 3))/1024./1024
		end*100/
		case when SIZE like '%T'
				then cast(replace(SIZE, 'T', '') as decimal(15, 3))*1024*1024
			when SIZE like '%G'
				then cast(replace(SIZE, 'G', '') as decimal(15, 3))*1024
			when SIZE like '%M'
				then cast(replace(SIZE, 'M', '') as decimal(15, 3))
			when SIZE like '%K'
				then cast(replace(SIZE, 'K', '') as decimal(15, 3))/1024.
			when SIZE like '%B'
				then cast(replace(SIZE, 'B', '') as decimal(15, 3))/1024./1024
		end, Metadata_TRH_ID, Metadata_ClientID
from inserted
GO
