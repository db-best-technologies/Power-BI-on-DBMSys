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
/****** Object:  View [Tests].[VW_TST_MemoryClerks]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_MemoryClerks]
as
select top 0 CAST(null as nvarchar(900)) InstanceName,
			CAST(null as bigint) single_pages_mb,
			CAST(null as bigint) multi_pages_mb,
			CAST(null as bigint) pages_mb,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_MemoryClerks]    Script Date: 6/8/2020 1:16:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_MemoryClerks] on [Tests].[VW_TST_MemoryClerks]
	instead of insert
as

;with Results as
		(select 'Memory Clerks' CategoryName, CounterName, InstanceName,
				case CounterName
					when 'Single Pages (MB)' then single_pages_mb
					when 'Multi Pages (MB)' then multi_pages_mb
					when 'Pages (MB)' then pages_mb
				end Value, Metadata_TRH_ID, Metadata_ClientID
			from inserted
				cross join (select GNC_CounterName CounterName
								from PerformanceData.GeneralCounters
								where GNC_CategoryName = 'Memory Clerks') c
		)
insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Instance, Value, Metadata_TRH_ID, Metadata_ClientID)
select CategoryName, CounterName, InstanceName, Value, Metadata_TRH_ID, Metadata_ClientID
from Results
where Value is not null
GO
