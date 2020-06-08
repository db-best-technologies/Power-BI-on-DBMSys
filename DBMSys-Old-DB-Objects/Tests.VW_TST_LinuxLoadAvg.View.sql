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
/****** Object:  View [Tests].[VW_TST_LinuxLoadAvg]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_LinuxLoadAvg]
as
select top 0 CAST(null as decimal(18, 5)) Column2, --CPU/IO last 5 minutes
			CAST(null as varchar(100)) Column4, --Running Processes/Total Processes
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_LinuxLoadAvg]    Script Date: 6/8/2020 1:16:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_LinuxLoadAvg] on [Tests].[VW_TST_LinuxLoadAvg]
	instead of insert
as
set nocount on

insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Value, Metadata_TRH_ID, Metadata_ClientID)
select 'CPU/IO Utilization' CategoryName, 'Last 5 Minutes' CounteName, Column2 Value, Metadata_TRH_ID, Metadata_ClientID
from inserted
union all
select 'Processes' CategoryName, 'Running' CounteName, cast(left(Column4, charindex('/', Column4, 1) - 1) as decimal(18, 5)) Value, Metadata_TRH_ID, Metadata_ClientID
from inserted
union all
select 'Processes' CategoryName, 'Total' CounteName, cast(substring(Column4, charindex('/', Column4, 1) + 1, 1000) as decimal(18, 5)) Value, Metadata_TRH_ID, Metadata_ClientID
from inserted
GO
