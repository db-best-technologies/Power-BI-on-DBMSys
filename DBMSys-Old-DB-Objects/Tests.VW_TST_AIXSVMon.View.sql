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
/****** Object:  View [Tests].[VW_TST_AIXSVMon]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_AIXSVMon]
as
select top 0 CAST(null as varchar(100)) Column1,
			CAST(null as varchar(100)) size,
			CAST(null as varchar(100)) free,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_AIXSVMon]    Script Date: 6/8/2020 1:15:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_AIXSVMon] on [Tests].[VW_TST_AIXSVMon]
	instead of insert
as
set nocount on
set transaction isolation level read uncommitted

select 350, 2, 3, 'AIX Memory', 'Free (MB)', 0, null

insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Value, Metadata_TRH_ID, Metadata_ClientID)
select 'AIX Memory', 'Free (MB)', cast(free as bigint)/(cast(size as bigint)/OSS_TotalPhysicalMemoryMB), Metadata_TRH_ID, Metadata_ClientID
from inserted
	inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID
	inner join Inventory.OSServers on OSS_MOB_ID = TRH_MOB_ID
where Column1 = 'memory'
GO
