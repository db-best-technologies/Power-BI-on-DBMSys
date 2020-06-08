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
/****** Object:  View [Tests].[VW_TST_LinuxVersion]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_LinuxVersion]
as
select top 0 CAST(null as varchar(1000)) [Output],
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_LinuxVersion]    Script Date: 6/8/2020 1:16:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_LinuxVersion] on [Tests].[VW_TST_LinuxVersion]
	instead of insert
as
set nocount on
set transaction isolation level read uncommitted
declare @MOB_ID int,
		@Distribution varchar(100),
		@Version varchar(100),
		@VersionNumber decimal(20, 10)

select @MOB_ID = TRH_MOB_ID
from inserted
	inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID

select @Distribution = case when lower([Output]) like '%centos%'
							then 'CentOS'
						when lower([Output]) like '%ubuntu%'
							then 'Ubuntu'
						when lower([Output]) like '%Red Hat%'
							then 'Red Hat'
						end,
		@Version = substring([Output], 15, charindex('-', [Output], 1) - 15)
from inserted

select @VersionNumber = cast(parsename(@Version, 3) as decimal(20, 10))
						+ cast(parsename(@Version, 2) as decimal(20, 10))/100
						+ cast(parsename(@Version, 1) as decimal(20, 10))/10000

if @Version is not null
	merge Inventory.Versions d
		using (select 4 PLT_ID, @Version Ver, @VersionNumber VersionNumber) s
			on VER_PLT_ID = PLT_ID
				and VER_Number = @VersionNumber
		when not matched then insert(VER_PLT_ID, VER_Name, VER_Full, VER_Number)
							values(PLT_ID, 'Linux version ' + @Version, @Version, VersionNumber);

if @Distribution is not null
	merge Inventory.Editions d
		using (select 4 PLT_ID, @Distribution Edition) s
			on EDT_PLT_ID = PLT_ID
				and EDT_Name = Edition
		when not matched then insert(EDT_PLT_ID, EDT_Name)
							values(PLT_ID, Edition);

update Inventory.MonitoredObjects
set MOB_VER_ID = VER_ID,
	MOB_Engine_EDT_ID = EDT_ID
from Inventory.Versions
	inner join Inventory.Editions on EDT_PLT_ID = VER_PLT_ID
where VER_Number = @VersionNumber
	and EDT_Name = @Distribution
	and MOB_ID = @MOB_ID
GO
