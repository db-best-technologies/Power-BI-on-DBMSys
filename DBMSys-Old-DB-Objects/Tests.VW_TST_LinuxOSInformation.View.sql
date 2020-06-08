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
/****** Object:  View [Tests].[VW_TST_LinuxOSInformation]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_LinuxOSInformation]
as
select top 0 CAST(null as nvarchar(128)) ServerName,
			CAST(null as decimal(15, 2)) Uptime,
			CAST(null as varchar(100)) Change,
			CAST(null as varchar(100)) Architecture,
			CAST(null as varchar(1000)) DomainName,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_LinuxOSInformation]    Script Date: 6/8/2020 1:16:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_LinuxOSInformation] on [Tests].[VW_TST_LinuxOSInformation]
	instead of insert
as
set nocount on

merge Inventory.DomainNames d
	using (select distinct DomainName
			from inserted
			where DomainName <> ''
				and DomainName is not null
				and DomainName <> '(none)'
			) s
		on DMN_Name = DomainName
	when not matched then insert(DMN_Name)
						values(DomainName);

merge Inventory.OSServers d
	using (select TRH_MOB_ID, Metadata_ClientID, 4  PLT_ID, ServerName,
					cast(cast(stuff(Change, len(Change) -1, 1, ':') + '0' as datetimeoffset) as datetime2(3)) InstallationDate,
					dateadd(second, -Uptime, sysdatetime()) LastBootUpTime,
					case when Architecture = 'x86_64' then 64 else 32 end Architecture,
					DMN_ID
			from inserted
				inner join Collect.TestRunHistory l on TRH_ID = Metadata_TRH_ID
				left join Inventory.DomainNames on DMN_Name = DomainName) s
		on OSS_PLT_ID = PLT_ID
			and OSS_MOB_ID = TRH_MOB_ID
	when matched then update set
						OSS_Name = ServerName,
						OSS_InstallDate = InstallationDate,
						OSS_LastBootUpTime = LastBootUpTime,
						OSS_Architecture = Architecture,
						OSS_DMN_ID = DMN_ID
	when not matched then insert(OSS_ClientID, OSS_MOB_ID, OSS_PLT_ID, OSS_IsVirtualServer, OSS_Name, OSS_InstallDate, OSS_LastBootUpTime, OSS_Architecture, OSS_DMN_ID)
							values(Metadata_ClientID, TRH_MOB_ID, PLT_ID, 0, ServerName, InstallationDate, LastBootUpTime, Architecture, DMN_ID);
GO
