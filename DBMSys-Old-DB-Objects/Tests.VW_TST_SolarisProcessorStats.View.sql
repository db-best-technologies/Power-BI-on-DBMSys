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
/****** Object:  View [Tests].[VW_TST_SolarisProcessorStats]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_SolarisProcessorStats]
as
select top 0 CAST(null as bigint) Column1, --%usr
			CAST(null as bigint) Column2, --%sys
			CAST(null as bigint) Column3, --%wio
			CAST(null as bigint) Column4, --%idle
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SolarisProcessorStats]    Script Date: 6/8/2020 1:16:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_SolarisProcessorStats] on [Tests].[VW_TST_SolarisProcessorStats]
	instead of insert
as
set nocount on
set transaction isolation level read uncommitted

insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Value, Metadata_TRH_ID, Metadata_ClientID)
select 'Solaris Processor', 'User Used %', Column1, Metadata_TRH_ID, Metadata_ClientID
from inserted
union
select 'Solaris Processor', 'System Used %', Column2, Metadata_TRH_ID, Metadata_ClientID
from inserted
union
select 'Solaris Processor', 'With IO Used %', Column3, Metadata_TRH_ID, Metadata_ClientID
from inserted
union
select 'Solaris Processor', 'Total Used %', 100-Column4, Metadata_TRH_ID, Metadata_ClientID
from inserted
GO
