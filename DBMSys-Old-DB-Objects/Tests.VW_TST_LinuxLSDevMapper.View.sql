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
/****** Object:  View [Tests].[VW_TST_LinuxLSDevMapper]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_LinuxLSDevMapper]
as
select top 0 CAST(null as varchar(500)) Column9, --Path
			CAST(null as varchar(500)) Column11, --Alternative name
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_LinuxLSDevMapper]    Script Date: 6/8/2020 1:16:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_LinuxLSDevMapper] on [Tests].[VW_TST_LinuxLSDevMapper]
	instead of insert
as
set nocount on
			
update Inventory.Disks
set DSK_InstanceName = replace(substring(Column11, len(Column11) - charindex('/', reverse(Column11), 2) + 2, 500), '/', '')
from inserted
	inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID
where DSK_MOB_ID = TRH_MOB_ID
			and DSK_Path like '%/' + Column9
GO
