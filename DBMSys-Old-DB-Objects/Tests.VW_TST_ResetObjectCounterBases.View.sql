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
/****** Object:  View [Tests].[VW_TST_ResetObjectCounterBases]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_ResetObjectCounterBases]
as
select top 0 CAST(null as decimal(15, 2)) Uptime,
			CAST(null as bigint) Metadata_TRH_ID,
			CAST(null as bigint) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_ResetObjectCounterBases]    Script Date: 6/8/2020 1:16:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_ResetObjectCounterBases] on [Tests].[VW_TST_ResetObjectCounterBases]
	instead of insert
as
set nocount on

declare @MOB_ID int,
		@TST_ID int,
		@LastRestartDate datetime2(3),
		@ClientID int

select @MOB_ID = TRH_MOB_ID,
		@TST_ID = TRH_TST_ID,
		@LastRestartDate = dateadd(second, -Uptime, sysdatetime()),
		@ClientID = Metadata_ClientID
from inserted
	inner join Collect.TestRunHistory l on TRH_ID = Metadata_TRH_ID

merge Inventory.OSServers d
	using (select @ClientID ClientID, MOB_ID, MOB_PLT_ID, @LastRestartDate LastRestartDate, MOB_Name
			from Inventory.MonitoredObjects
			where MOB_ID = @MOB_ID) s
		on OSS_MOB_ID = MOB_ID
	when matched and OSS_LastBootUpTime < dateadd(minute, -1, LastRestartDate)
				then update set
							OSS_LastBootUpTime = LastRestartDate
	when not matched then insert(OSS_ClientID, OSS_PLT_ID, OSS_IsVirtualServer, OSS_MOB_ID, OSS_Name)
						values(ClientID, MOB_PLT_ID, 0, MOB_ID, MOB_Name);

delete Collect.ObjectCounterBases
where OCB_MOB_ID = @MOB_ID
	and OCB_TST_ID = @TST_ID
	and OCB_LastRestartDate < dateadd(minute, -1, @LastRestartDate)
GO
