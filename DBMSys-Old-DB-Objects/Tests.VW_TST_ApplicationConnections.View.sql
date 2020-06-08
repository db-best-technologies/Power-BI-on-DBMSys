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
/****** Object:  View [Tests].[VW_TST_ApplicationConnections]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_ApplicationConnections]
as
select top 0 cast(null as nvarchar(128)) DatabaseName,
			cast(null as nvarchar(128)) HostName,
			cast(null as nvarchar(128)) ProgramName,
			cast(null as nvarchar(128)) LoginName,
			cast(null as varchar(48)) IPAddress,
			cast(null as int) Metadata_TRH_ID,
			cast(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_ApplicationConnections]    Script Date: 6/8/2020 1:15:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_ApplicationConnections] on [Tests].[VW_TST_ApplicationConnections]
	instead of insert
as
declare @MOB_ID int,
		@StartDate datetime2(3)

select top 1 @MOB_ID = TRH_MOB_ID,
			@StartDate = TRH_StartDate
from inserted inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID

merge Inventory.InstanceDatabases d
	using (select distinct Metadata_ClientID, DatabaseName, Metadata_TRH_ID
			from inserted
			where DatabaseName is not null) s
		on IDB_MOB_ID = @MOB_ID
		and DatabaseName = IDB_Name
	when not matched then insert(IDB_ClientID, IDB_MOB_ID, IDB_Name, IDB_InsertDate, IDB_LastSeenDate, IDB_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, DatabaseName, sysdatetime(), sysdatetime(), Metadata_TRH_ID);

merge Activity.HostNames d
	using (select distinct HostName
			from inserted
			where HostName is not null) s
		on HostName = HSN_Name
	when not matched then insert(HSN_Name)
							values(HostName);

merge Activity.ProgramNames d
	using (select distinct ProgramName
			from inserted
			where ProgramName is not null) s
		on ProgramName = PGN_Name
	when not matched then insert(PGN_Name)
							values(ProgramName);

merge Inventory.InstanceLogins d
	using (select distinct LoginName, Metadata_TRH_ID, Metadata_ClientID
			from inserted
			where LoginName is not null) s
		on INL_MOB_ID = @MOB_ID
			and INL_Name = LoginName
	when not matched then insert(INL_ClientID, INL_MOB_ID, INL_Name, INL_InsertDate, INL_LastSeenDate, INL_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, LoginName, @StartDate, @StartDate, Metadata_TRH_ID);

merge Inventory.ApplicationIPAddresses d
	using (select distinct IPAddress
			from inserted
			where IPAddress is not null) s
		on IPAddress = AIA_IPAddress
	when not matched then insert(AIA_IPAddress)
							values(IPAddress);

merge Inventory.ApplicationConnections d
	using (select Metadata_ClientID, IDB_ID, HSN_ID, PGN_ID, INL_ID, AIA_ID
			from inserted
				inner join Inventory.InstanceDatabases on IDB_Name = DatabaseName
															and IDB_MOB_ID = @MOB_ID
				left join Activity.HostNames on HSN_Name = HostName
				left join Activity.ProgramNames on PGN_Name = ProgramName
				inner join Inventory.InstanceLogins on INL_Name = LoginName
														and INL_MOB_ID = @MOB_ID
				left join Inventory.ApplicationIPAddresses on AIA_IPAddress = IPAddress
			) s
		on ACN_MOB_ID = @MOB_ID
			and ACN_IDB_ID = IDB_ID
			and (ACN_HSN_ID = HSN_ID
					or (ACN_HSN_ID is null
							and HSN_ID is null)
				)
			and (ACN_PGN_ID = PGN_ID
					or (ACN_PGN_ID is null
							and PGN_ID is null)
				)
			and ACN_INL_ID = INL_ID
			and (ACN_AIA_ID = AIA_ID
					or (ACN_AIA_ID is null
							and AIA_ID is null)
				)
		when matched then update
			set ACN_LastSeen = @StartDate
		when not matched then insert(ACN_ClientID, ACN_MOB_ID, ACN_IDB_ID, ACN_HSN_ID, ACN_PGN_ID, ACN_INL_ID, ACN_AIA_ID, ACN_LastSeen)
								values(Metadata_ClientID, @MOB_ID, IDB_ID, HSN_ID, PGN_ID, INL_ID, AIA_ID, @StartDate);
GO
