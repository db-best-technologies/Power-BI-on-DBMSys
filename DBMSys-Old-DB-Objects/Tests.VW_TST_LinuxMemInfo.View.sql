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
/****** Object:  View [Tests].[VW_TST_LinuxMemInfo]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_LinuxMemInfo]
as
select top 0 CAST(null as varchar(100)) MemTotal,
			CAST(null as varchar(100)) Hugepagesize,
			CAST(null as varchar(100)) VmallocTotal,
			CAST(null as varchar(100)) MemFree,
			CAST(null as varchar(100)) Buffers,
			CAST(null as varchar(100)) Cached,
			CAST(null as varchar(100)) Active,
			CAST(null as varchar(100)) Inactive,
			CAST(null as varchar(100)) SwapTotal,
			CAST(null as varchar(100)) SwapFree,
			CAST(null as varchar(100)) Dirty,
			CAST(null as varchar(100)) Writeback,
			CAST(null as varchar(100)) Committed_AS,
			CAST(null as varchar(100)) VmallocChunk,
			CAST(null as varchar(100)) HardwareCorrupted,
			CAST(null as varchar(100)) HugePages_Total,
			CAST(null as varchar(100)) HugePages_Free,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_LinuxMemInfo]    Script Date: 6/8/2020 1:16:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_LinuxMemInfo] on [Tests].[VW_TST_LinuxMemInfo]
	instead of insert
as
set nocount on
set transaction isolation level read uncommitted
declare @MOB_ID int

select @MOB_ID = TRH_MOB_ID
from (select top 1 Metadata_TRH_ID, Metadata_ClientID
		from inserted) i
	inner join Collect.TestRunHistory l on TRH_ID = Metadata_TRH_ID

merge Inventory.OSServers d
	using (select Metadata_ClientID, 4  PLT_ID, cast(replace(MemTotal, ' KB', '') as bigint)/1024 MemTotal,
					cast(replace(Hugepagesize, ' KB', '') as bigint)/1024 Hugepagesize,
					cast(replace(VmallocTotal, ' KB', '') as bigint)/1024 VmallocTotal
			from inserted) s
		on OSS_PLT_ID = PLT_ID
			and OSS_MOB_ID = @MOB_ID
	when matched then update set
						OSS_TotalPhysicalMemoryMB = MemTotal,
						OSS_MaxProcessMemorySizeMB = VmallocTotal,
						OSS_HugePageSizeMB = Hugepagesize
	when not matched then insert(OSS_ClientID, OSS_MOB_ID, OSS_PLT_ID, OSS_IsVirtualServer, OSS_TotalPhysicalMemoryMB, OSS_MaxProcessMemorySizeMB, OSS_HugePageSizeMB)
							values(Metadata_ClientID, @MOB_ID, PLT_ID, 0, MemTotal, Hugepagesize, VmallocTotal);
	
insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Value, Metadata_TRH_ID, Metadata_ClientID)
select 'Linux Memory', CounterName, cast(replace(Value, ' KB', '') as bigint)/1024 Value, Metadata_TRH_ID, Metadata_ClientID
from (select MemFree [Free memory (MB)], Buffers [Buffer memory (MB)], Cached [Cached memory (MB)], Active [Active memory (MB)],
			Inactive [Inactive memory (MB)], SwapTotal [Total Swapped memory (MB)], SwapFree [Free Swapped memory (MB)], Dirty [Dirty memory (MB)],
			Writeback [Writeback memory (MB)], Committed_AS [Committed memory (MB)], VmallocChunk [Free virtual address space (MB)],
			HardwareCorrupted [Harware corrupted memory (MB)], HugePages_Total [Total Huge Pages memory (MB)], HugePages_Free [Free Huge Pages memory (MB)],
			Metadata_TRH_ID, Metadata_ClientID
		from inserted) t
	unpivot (Value for CounterName in ([Free memory (MB)], [Buffer memory (MB)], [Cached memory (MB)], [Active memory (MB)], [Inactive memory (MB)], 
										[Total Swapped memory (MB)], [Free Swapped memory (MB)], [Dirty memory (MB)], [Writeback memory (MB)], 
										[Committed memory (MB)], [Free virtual address space (MB)], [Harware corrupted memory (MB)], [Total Huge Pages memory (MB)], 
										[Free Huge Pages memory (MB)])) u
GO
