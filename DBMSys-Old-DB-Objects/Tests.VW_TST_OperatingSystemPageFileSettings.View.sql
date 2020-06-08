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
/****** Object:  View [Tests].[VW_TST_OperatingSystemPageFileSettings]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_OperatingSystemPageFileSettings]
as
select top 0 CAST(null as int) InitialSize,
			CAST(null as int) MaximumSize,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_OperatingSystemPageFileSettings]    Script Date: 6/8/2020 1:16:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_OperatingSystemPageFileSettings] on [Tests].[VW_TST_OperatingSystemPageFileSettings]
	instead of insert
as
set nocount on

;with PageFileSettings as
		(select MOB_ID, case when InitialSize = 0
														and MaximumSize = 0
													then 1
													else 0
												end AutomaticManagedPageFile
			from inserted
				inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID
				inner join Inventory.MonitoredObjects on TRH_MOB_ID = MOB_ID
			)
update Inventory.OSServers
set OSS_IsAutomaticManagedPageFile = AutomaticManagedPageFile
from PageFileSettings
where OSS_MOB_ID = MOB_ID
	and AutomaticManagedPageFile is not null
	and (OSS_IsAutomaticManagedPageFile <> AutomaticManagedPageFile
			or OSS_IsAutomaticManagedPageFile is null)
GO
