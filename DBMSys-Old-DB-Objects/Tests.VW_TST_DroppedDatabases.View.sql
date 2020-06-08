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
/****** Object:  View [Tests].[VW_TST_DroppedDatabases]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_DroppedDatabases]
as
select top 0CAST(null as nvarchar(128)) DatabaseName,
			CAST(null as nvarchar(128)) HostName,
			CAST(null as nvarchar(128)) ApplicationName,
			CAST(null as nvarchar(128)) LoginName,
			CAST(null as datetime) StartTime,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_DroppedDatabases]    Script Date: 6/8/2020 1:16:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_DroppedDatabases] on [Tests].[VW_TST_DroppedDatabases]
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

merge Activity.HostNames d
	using (select distinct HostName
			from inserted
			where HostName is not null) s
		on HostName = HSN_Name
	when not matched then insert(HSN_Name)
							values(HostName);

merge Activity.ProgramNames d
	using (select distinct ApplicationName
			from inserted
			where ApplicationName is not null) s
		on ApplicationName = PGN_Name
	when not matched then insert(PGN_Name)
							values(ApplicationName);

merge Activity.LoginNames d
	using (select distinct LoginName
			from inserted) s
		on LoginName = LGN_Name
	when not matched then insert(LGN_Name)
							values(LoginName);

insert into Activity.DatabaseDropEvents(DDE_ClientID, DDE_MOB_ID, DDE_DatabaseName, DDE_HSN_ID, DDE_PGN_ID, DDE_INL_ID, DDE_DropDate)
select Metadata_ClientID, @MOB_ID, DatabaseName, HSN_ID, PGN_ID, INL_ID, StartTime
from inserted
	inner join Activity.HostNames on HSN_Name = HostName
	left join Activity.ProgramNames on PGN_Name = ApplicationName
	inner join Inventory.InstanceLogins on INL_MOB_ID = @MOB_ID
											and INL_Name = LoginName

select @LastValue = '''' + replace(convert(char(19), dateadd(second, 1, StartTime), 121), '-', '') + ''''
from inserted

if @LastValue is not null
	exec Collect.usp_UpdateMaxValue @TST_ID, @MOB_ID, @LastValue
GO
