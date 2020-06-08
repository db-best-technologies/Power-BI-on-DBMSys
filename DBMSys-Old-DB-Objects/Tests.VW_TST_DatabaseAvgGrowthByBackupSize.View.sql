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
/****** Object:  View [Tests].[VW_TST_DatabaseAvgGrowthByBackupSize]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_DatabaseAvgGrowthByBackupSize]
as
select top 0 CAST(null as nvarchar(128)) DatabaseName,
			CAST(null as decimal(20, 2)) AvgGrowthPerDayMB,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_DatabaseAvgGrowthByBackupSize]    Script Date: 6/8/2020 1:15:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_DatabaseAvgGrowthByBackupSize] on [Tests].[VW_TST_DatabaseAvgGrowthByBackupSize]
	instead of insert
as
set nocount on

;with NewRecords as
		(select TRH_MOB_ID, DatabaseName, AvgGrowthPerDayMB
			from inserted
				inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID
		)
update Inventory.InstanceDatabases
set IDB_AvgGrowthPerDayMB = AvgGrowthPerDayMB
from NewRecords
where IDB_MOB_ID = TRH_MOB_ID
	and IDB_Name = DatabaseName
GO
