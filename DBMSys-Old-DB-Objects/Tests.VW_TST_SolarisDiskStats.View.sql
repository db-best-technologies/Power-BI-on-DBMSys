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
/****** Object:  View [Tests].[VW_TST_SolarisDiskStats]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_SolarisDiskStats]
as
select top 0 CAST(null as varchar(200)) device,
			CAST(null as decimal(15, 3)) [r/s],
			CAST(null as decimal(15, 3)) [w/s],
			CAST(null as decimal(15, 3)) [kr/s],
			CAST(null as decimal(15, 3)) [kw/s],
			CAST(null as decimal(15, 3)) [wait],
			CAST(null as decimal(15, 3)) [actv],
			CAST(null as decimal(15, 3)) [svc_t],
			CAST(null as decimal(15, 3)) [%w],
			CAST(null as decimal(15, 3)) [%b],
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SolarisDiskStats]    Script Date: 6/8/2020 1:16:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_SolarisDiskStats] on [Tests].[VW_TST_SolarisDiskStats]
	instead of insert
as
set nocount on
set transaction isolation level read uncommitted

insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Instance, Value, Metadata_TRH_ID, Metadata_ClientID)
select 'Solaris Disk', 'Reads per second', device, [r/s], Metadata_TRH_ID, Metadata_ClientID
from inserted
union all
select 'Solaris Disk', 'Writes per second', device, [w/s], Metadata_TRH_ID, Metadata_ClientID
from inserted
union all
select 'Solaris Disk', 'Bytes read per second', device, [kr/s], Metadata_TRH_ID, Metadata_ClientID
from inserted
union all
select 'Solaris Disk', 'Bytes written per second', device, [kw/s], Metadata_TRH_ID, Metadata_ClientID
from inserted
union all
select 'Solaris Disk', 'Average number of transactions that are waiting for service (queue length)', device, [wait], Metadata_TRH_ID, Metadata_ClientID
from inserted
union all
select 'Solaris Disk', 'Average number of transactions that are actively being serviced', device, [actv], Metadata_TRH_ID, Metadata_ClientID
from inserted
union all
select 'Solaris Disk', 'Average service time, in milliseconds', device, [svc_t], Metadata_TRH_ID, Metadata_ClientID
from inserted
union all
select 'Solaris Disk', 'Percentage of time that the queue is not empty', device, [%w], Metadata_TRH_ID, Metadata_ClientID
from inserted
union all
select 'Solaris Disk', 'Percentage of time that the disk is busy', device, [%b], Metadata_TRH_ID, Metadata_ClientID
from inserted
GO
