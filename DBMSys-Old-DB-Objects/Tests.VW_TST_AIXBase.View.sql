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
/****** Object:  View [Tests].[VW_TST_AIXBase]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_AIXBase]
as
select top 0 CAST(null as nvarchar(128)) [ServerName],
			CAST(null as varchar(20)) Architecture,
			CAST(null as varchar(128)) DomainName,
			CAST(null as varchar(20)) [Version],
			CAST(null as bigint) TotalMemory,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_AIXBase]    Script Date: 6/8/2020 1:15:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_AIXBase] on [Tests].[VW_TST_AIXBase]
	instead of insert
as
set nocount on
set transaction isolation level read uncommitted
declare @MOB_ID int

select @MOB_ID = TRH_MOB_ID
from (select top 1 Metadata_TRH_ID
		from inserted) i
	inner join Collect.TestRunHistory l on TRH_ID = Metadata_TRH_ID

merge Inventory.Versions d
	using (select 5 PLT_ID, [Version] Ver,
				cast(parsename([Version], 4) as decimal(20, 10))
				+ cast(parsename([Version], 3) as decimal(20, 10))/100
				+ cast(parsename([Version], 2) as decimal(20, 10))/10000
				+ cast(parsename([Version], 1) as decimal(20, 10))/1000000 VersionNumber
			from inserted) s
		on VER_PLT_ID = PLT_ID
			and VER_Number = VersionNumber
	when not matched then insert(VER_PLT_ID, VER_Name, VER_Full, VER_Number)
						values(PLT_ID, 'AIX version ' + Ver, Ver, VersionNumber);

update Inventory.MonitoredObjects
set MOB_VER_ID = VER_ID
from inserted
	inner join Inventory.Versions on VER_PLT_ID = 5
										and VER_Full = [Version]
where MOB_ID = @MOB_ID
	and (MOB_VER_ID = VER_ID
			or MOB_VER_ID is null)

merge Inventory.DomainNames d
	using (select distinct DomainName
			from inserted
			where DomainName is not null
			) s
		on DMN_Name = DomainName
	when not matched then insert(DMN_Name)
							values(DomainName);

merge Inventory.OSServers d
	using (select ServerName, cast(replace(Architecture, '-bit', '') as int) Architecture, DMN_ID, TotalMemory, Metadata_ClientID
			from inserted
				left join Inventory.DomainNames on DomainName = DMN_Name) s
		on OSS_MOB_ID = @MOB_ID
	when matched then update set
						OSS_Name = ServerName,
						OSS_Architecture = Architecture,
						OSS_DMN_ID = DMN_ID,
						OSS_TotalPhysicalMemoryMB = TotalMemory
	when not matched then insert(OSS_ClientID, OSS_MOB_ID, OSS_PLT_ID, OSS_Name, OSS_Architecture, OSS_DMN_ID, OSS_TotalPhysicalMemoryMB, OSS_IsVirtualServer)
						values(Metadata_ClientID, @MOB_ID, 5, ServerName, Architecture, DMN_ID, TotalMemory, 0);
GO
