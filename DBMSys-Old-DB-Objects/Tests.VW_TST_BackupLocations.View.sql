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
/****** Object:  View [Tests].[VW_TST_BackupLocations]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_BackupLocations]
as
select top 0 CAST(null as nvarchar(128)) database_name,
			CAST(null as varchar(256)) Location,
			CAST(null as datetime) LastUsed,
			CAST(null as int) LastBackupSetID,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_BackupLocations]    Script Date: 6/8/2020 1:15:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_BackupLocations] on [Tests].[VW_TST_BackupLocations]
	instead of insert
as
set nocount on
declare @TST_ID int,
		@MOB_ID int,
		@OS_MOB_ID int,
		@LastValue varchar(100)

select top 1 @TST_ID = TRH_TST_ID,
				@MOB_ID = TRH_MOB_ID,
				@OS_MOB_ID = win.MOB_ID
from inserted
	inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID
	inner join Inventory.MonitoredObjects DB on TRH_MOB_ID = DB.MOB_ID
	inner join Inventory.DatabaseInstanceDetails on DID_DFO_ID = DB.MOB_Entity_ID
	inner join Inventory.OSServers ON DID_OSS_ID = OSS_ID
	inner join Inventory.MonitoredObjects WIN on OSS_MOB_ID = WIN.MOB_ID
													and WIN.MOB_PLT_ID = 2

merge Inventory.InstanceDatabases d
	using (select distinct Metadata_ClientID, database_name, Metadata_TRH_ID
			from inserted) s
		on IDB_MOB_ID = @MOB_ID
		and database_name = IDB_Name
	when not matched then insert(IDB_ClientID, IDB_MOB_ID, IDB_Name, IDB_InsertDate, IDB_LastSeenDate, IDB_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, database_name, sysdatetime(), sysdatetime(), Metadata_TRH_ID);


merge Inventory.BackupLocations d
	using (select Metadata_ClientID, IDB_ID, DSK_ID, Location, LastUsed
			from inserted
				inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
															and database_name = IDB_Name
				cross apply (select top 1 DSK_ID
								from Inventory.Disks
								where DSK_MOB_ID = @OS_MOB_ID
									and Location like DSK_Path + '%'
								order by len(DSK_Path) desc) k
			) s
				on BKL_MOB_ID = @MOB_ID
					and BKL_IDB_ID = IDB_ID
					and BKL_Path = Location
	when matched and BKL_LastUsed <> LastUsed then update set
														BKL_LastUsed = LastUsed,
														BKL_DSK_ID = DSK_ID
	when not matched then insert(BKL_ClientID, BKL_MOB_ID, BKL_IDB_ID, BKL_DSK_ID, BKL_Path, BKL_LastUsed)
							values(Metadata_ClientID, @MOB_ID, IDB_ID, DSK_ID, Location, LastUsed);

select @LastValue = cast(MAX(LastBackupSetID) as varchar(100))
from inserted

exec Collect.usp_UpdateMaxValue @TST_ID, @MOB_ID, @LastValue
GO
