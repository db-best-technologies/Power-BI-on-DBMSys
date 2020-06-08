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
/****** Object:  View [Tests].[VW_TST_AIXIOStat]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_AIXIOStat]
as
select top 0 CAST(null as varchar(100)) Column1,
			CAST(null as decimal(20, 2)) Column4,
			CAST(null as decimal(20, 2)) Column5,
			CAST(null as decimal(20, 2)) Column6,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_AIXIOStat]    Script Date: 6/8/2020 1:15:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_AIXIOStat] on [Tests].[VW_TST_AIXIOStat]
	instead of insert
as
set nocount on
set transaction isolation level read uncommitted

insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Instance, Value, Metadata_TRH_ID, Metadata_ClientID)
select 'AIX Drives', 'Transfers/sec', Column1, Column4, Metadata_TRH_ID, Metadata_ClientID
from inserted
union all
select 'AIX Drives', 'Bytes read/sec', Column1, Column5*1024, Metadata_TRH_ID, Metadata_ClientID
from inserted
union all
select 'AIX Drives', 'Bytes written/sec', Column1, Column6*1024, Metadata_TRH_ID, Metadata_ClientID
from inserted
GO
