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
/****** Object:  View [Tests].[VW_TST_BaseSQLcollection]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_BaseSQLcollection]
as
select top 0 CAST(null as nvarchar(128)) InstanceName,
			CAST(null as varchar(100)) ProductVersion,
			CAST(null as varchar(100)) VersionName,
			CAST(null as decimal(20, 10)) VersionNumber,
			CAST(null as varchar(100)) Edition,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_BaseSQLcollection]    Script Date: 6/8/2020 1:15:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_BaseSQLcollection] on [Tests].[VW_TST_BaseSQLcollection]
	instead of insert
as
set nocount on
declare @MOB_ID int,
		@VersionNumber decimal(20, 10),
		@PLT_ID int

select top 1 @MOB_ID = l.TRH_MOB_ID,
			@VersionNumber = VersionNumber,
			@PLT_ID = MOB_PLT_ID
from inserted
	inner join Collect.TestRunHistory l on Metadata_TRH_ID = l.TRH_ID
	inner join Inventory.MonitoredObjects on MOB_ID = TRH_MOB_ID

if @VersionNumber is null
	with Ver as
		(select Id, cast(Val as decimal(20, 10)) Val
			from inserted
				cross apply Infra.fn_SplitString(ProductVersion, '.')
		)
	select @VersionNumber = MAX(case when Id = 1 then Val else 0 end)
								+ MAX(case when Id = 2 then Val/10 else 0 end)
								+ MAX(case when Id = 3 then Val/1000 else 0 end)
								+ MAX(case when Id = 4 then Val/100000 else 0 end)
								+ MAX(case when Id = 5 then Val/10000000 else 0 end)
	from Ver

merge Inventory.Versions d
	using (select distinct ProductVersion, VersionName
			from inserted) s
				on VER_PLT_ID = @PLT_ID
				and @VersionNumber = VER_Number
	when not matched then insert (VER_PLT_ID, VER_Full, VER_Name, VER_Number)
							values(@PLT_ID, ProductVersion, VersionName, @VersionNumber);

merge Inventory.Editions d
	using (select distinct Edition
			from inserted) s
				on EDT_PLT_ID = @PLT_ID
				and Edition = EDT_Name
	when not matched then insert (EDT_PLT_ID, EDT_Name)
							values(@PLT_ID, Edition);

merge Inventory.DatabaseInstanceDetails d
	using (select Metadata_ClientID, DFO_ID, InstanceName
			from inserted
				inner join Inventory.MonitoredObjects on MOB_ID = @MOB_ID
				inner join Management.DefinedObjects on DFO_PLT_ID = MOB_PLT_ID
														and DFO_ID = MOB_Entity_ID) s
				on DFO_ID = DID_DFO_ID
			when matched then update set
								DID_Name = InstanceName
			when not matched then insert(DID_ClientID, DID_DFO_ID, DID_Name)
									values(Metadata_ClientID, DFO_ID, InstanceName);

merge Inventory.MonitoredObjects d
	using (select Metadata_ClientID, VER_ID, EDT_ID
			from inserted
				inner join Inventory.Versions on VER_PLT_ID = @PLT_ID
												and VER_Number = @VersionNumber
				inner join Inventory.Editions on EDT_PLT_ID = @PLT_ID
												and EDT_Name = Edition) s
					on MOB_ID = @MOB_ID
			when matched then update set
									MOB_VER_ID = VER_ID,
									MOB_Engine_EDT_ID = EDT_ID;
GO
