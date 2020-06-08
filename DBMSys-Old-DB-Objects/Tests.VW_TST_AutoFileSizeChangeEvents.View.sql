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
/****** Object:  View [Tests].[VW_TST_AutoFileSizeChangeEvents]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_AutoFileSizeChangeEvents]
as
select top 0 CAST(null as int) EventClass,
			CAST(null as nvarchar(256)) DatabaseName,
			CAST(null as nvarchar(256)) DatabaseFilename,
			CAST(null as datetime) StartTime,
			CAST(null as datetime) EndTime,
			CAST(null as bigint) DurationMS,
			CAST(null as int) ChangeInSizeMB,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_AutoFileSizeChangeEvents]    Script Date: 6/8/2020 1:15:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_AutoFileSizeChangeEvents] on [Tests].[VW_TST_AutoFileSizeChangeEvents]
	instead of insert
as
set nocount on
declare @MOB_ID int,
		@StartDate datetime2(3),
		@LastValue varchar(100),
		@TST_ID int

select top 1 @MOB_ID = TRH_MOB_ID,
			@StartDate = TRH_StartDate,
			@TST_ID = TRH_TST_ID
from inserted inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID

merge Inventory.InstanceDatabases d
	using (select distinct Metadata_ClientID, DatabaseName, Metadata_TRH_ID
			from inserted
			where DatabaseName is not null) s
		on IDB_MOB_ID = @MOB_ID
		and DatabaseName = IDB_Name
	when not matched then insert(IDB_ClientID, IDB_MOB_ID, IDB_Name, IDB_InsertDate, IDB_LastSeenDate, IDB_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, DatabaseName, @StartDate, @StartDate, Metadata_TRH_ID);

merge Inventory.DatabaseFiles d
	using (select distinct Metadata_ClientID, IDB_ID, DatabaseFilename, Metadata_TRH_ID
			from inserted
				inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
															and DatabaseName = IDB_Name) s
		on DBF_MOB_ID = @MOB_ID
			and DBF_IDB_ID = IDB_ID
			and DBF_Name = DatabaseFilename
	when not matched then insert(DBF_ClientID, DBF_MOB_ID, DBF_IDB_ID, DBF_Name, DBF_InsertDate, DBF_LastSeenDate, DBF_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IDB_ID, DatabaseFilename, @StartDate, @StartDate, Metadata_TRH_ID);

insert into Activity.AutoFileSizeChangeEvents(AFS_ClientID, AFS_MOB_ID, AFS_AFC_ID, AFS_IDB_ID, AFS_DBF_ID, AFS_ProcessStartTime, AFS_ProcessEndTime, AFS_DurationMS,
												AFS_ChangeInSizeMB)
select Metadata_ClientID, @MOB_ID, EventClass, IDB_ID, DBF_ID, StartTime, EndTime, DurationMS, ChangeInSizeMB
from inserted
	inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
												and DatabaseName = IDB_Name
	inner join Inventory.DatabaseFiles on DBF_MOB_ID = @MOB_ID
											and DBF_IDB_ID = IDB_ID
											and DBF_Name = DatabaseFilename

select @LastValue = '''' + replace(convert(char(19), dateadd(second, 1, EndTime), 121), '-', '') + ''''
from inserted

if @LastValue is not null
	exec Collect.usp_UpdateMaxValue @TST_ID, @MOB_ID, @LastValue
GO
