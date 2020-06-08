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
/****** Object:  View [Tests].[VW_TST_SQLInstanceCPUUtilization]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_SQLInstanceCPUUtilization]
as
select top 0 CAST(null as int) CPU,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SQLInstanceCPUUtilization]    Script Date: 6/8/2020 1:16:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_SQLInstanceCPUUtilization] on [Tests].[VW_TST_SQLInstanceCPUUtilization]
	instead of insert
as
set nocount on
insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Value, Metadata_TRH_ID, Metadata_ClientID)
select 'SQL Instance CPU', '% Processor Time', CPU, Metadata_TRH_ID, Metadata_ClientID
from inserted
GO
