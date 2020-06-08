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
/****** Object:  View [Tests].[VW_TST_ResourceUsageBySQLDatabase]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_ResourceUsageBySQLDatabase]
as
select top 0 cast(null as nvarchar(128)) DatabaseName,
			cast(null as decimal(28, 5)) CPUUsage,
			cast(null as bigint) PlanCacheMemorySizeMB,
			cast(null as bigint) BufferPoolMemorySizeMB,
			cast(null as bigint) TotalMemorySizeMB,
			cast(null as int) Metadata_TRH_ID,
			cast(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_ResourceUsageBySQLDatabase]    Script Date: 6/8/2020 1:16:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_ResourceUsageBySQLDatabase] on [Tests].[VW_TST_ResourceUsageBySQLDatabase]
	instead of insert
as
set nocount on
declare @MOB_ID int,
		@StartDate datetime2(3)

select top 1 @MOB_ID = TRH_MOB_ID,
			@StartDate = TRH_StartDate
from inserted inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID

;with Results as
		(select CounterName,
					max(case CounterName
							when 'CPU %' then CPUUsage
							when 'Total memory usage (MB)' then TotalMemorySizeMB
							when 'Buffer pool memory usage (MB)' then BufferPoolMemorySizeMB
							when 'Plan cache memory usage (MB)' then PlanCacheMemorySizeMB
						end) Value, DatabaseName, Metadata_TRH_ID, Metadata_ClientID
			from inserted
				cross join (select GNC_CounterName CounterName
								from PerformanceData.GeneralCounters
								where GNC_CategoryName = 'Resource usage per Database') c

			group by CounterName, DatabaseName, Metadata_TRH_ID, Metadata_ClientID
		)
insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Instance, DatabaseName, Value, Metadata_TRH_ID, Metadata_ClientID)
select 'Resource usage per Database' Category, CounterName, isnull(DatabaseName, '_Total') InstanceName, DatabaseName, Value, Metadata_TRH_ID, Metadata_ClientID
from Results
where Value > 0
GO
