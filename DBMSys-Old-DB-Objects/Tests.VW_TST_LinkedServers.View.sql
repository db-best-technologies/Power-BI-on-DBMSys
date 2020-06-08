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
/****** Object:  View [Tests].[VW_TST_LinkedServers]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_LinkedServers]
as
select top 0 CAST(null as nvarchar(128)) name,
			CAST(null as nvarchar(128)) product,
			CAST(null as nvarchar(128)) provider,
			CAST(null as nvarchar(4000)) data_source,
			CAST(null as nvarchar(4000)) location,
			CAST(null as nvarchar(4000)) provider_string,
			CAST(null as int) connect_timeout,
			CAST(null as int) query_timeout,
			CAST(null as nvarchar(128)) [catalog],
			CAST(null as bit) is_rpc_out_enabled,
			CAST(null as bit) is_data_access_enabled,
			CAST(null as bit) is_collation_compatible,
			CAST(null as bit) uses_remote_collation,
			CAST(null as nvarchar(128)) collation_name,
			CAST(null as bit) lazy_schema_validation,
			CAST(null as bit) is_remote_proc_transaction_promotion_enabled,
			CAST(null as nvarchar(max)) RemoteLogins,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_LinkedServers]    Script Date: 6/8/2020 1:16:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_LinkedServers] on [Tests].[VW_TST_LinkedServers]
	instead of insert
as
set nocount on

declare @MOB_ID int,
		@StartDate datetime2(3)
select top 1 @MOB_ID = TRH_MOB_ID,
			@StartDate = TRH_StartDate
from inserted
	inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID

merge Inventory.LinkedServerProductTypes d
	using (select distinct product
			from inserted
			where product is not null) s
		on product = LPT_Name
	when not matched then insert(LPT_Name)
							values(product);

merge Inventory.LinkedServerProviders d
	using (select distinct provider
			from inserted
			where provider is not null) s
		on provider = LPR_Name
	when not matched then insert(LPR_Name)
							values(provider);

merge inventory.CollationTypes d
	using (select distinct collation_name
			from inserted
			where collation_name is not null) s
		on collation_name = CLT_Name
	when not matched then insert(CLT_Name)
							values(collation_name);

merge Inventory.LinkedServers d
	using (select name, LPT_ID, LPR_ID, data_source, MOB_ID, location, provider_string, [catalog], IDB_ID, is_rpc_out_enabled, is_data_access_enabled,
				is_collation_compatible, uses_remote_collation, CLT_ID, lazy_schema_validation, is_remote_proc_transaction_promotion_enabled, Metadata_ClientID,
				Metadata_TRH_ID
			from inserted
				inner join Inventory.LinkedServerProductTypes on product = LPT_Name
				inner join Inventory.LinkedServerProviders on provider = LPR_Name
				left join Inventory.MonitoredObjects on MOB_PLT_ID = 1
													and MOB_Name = data_source
				left join Inventory.InstanceDatabases on IDB_MOB_ID = MOB_ID
														and IDB_Name = [catalog]
				left join Inventory.CollationTypes on CLT_Name = collation_name
			) s
		on LNS_MOB_ID = @MOB_ID
			and LNS_Name = name
	when matched then update set
							LNS_LPT_ID = LPT_ID,
							LNS_LPR_ID = LPR_ID,
							LNS_DataSource = data_source,
							LNS_DataSource_MOB_ID = MOB_ID,
							LNS_Location = location,
							LNS_ProviderString = provider_string,
							LNS_Catalog = [catalog],
							LNS_Catalog_IDB_ID = IDB_ID,
							LNS_IsRPCOutEnabled = is_rpc_out_enabled,
							LNS_IsDataAccessEnabled = is_data_access_enabled,
							LNS_IsCollationCompatible = is_collation_compatible,
							LNS_UsesRemoteCollation = uses_remote_collation,
							LNS_CLT_ID = CLT_ID,
							LNS_LazySchemaValidation = lazy_schema_validation,
							LNS_IsRemoteProcTransactionPromotionEnabled = is_remote_proc_transaction_promotion_enabled,
							LNS_LastSeenDate = @StartDate,
							LNS_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(LNS_ClientID, LNS_MOB_ID, LNS_Name, LNS_LPT_ID, LNS_LPR_ID, LNS_DataSource, LNS_DataSource_MOB_ID, LNS_Location, LNS_ProviderString,
									LNS_Catalog, LNS_Catalog_IDB_ID, LNS_IsRPCOutEnabled, LNS_IsDataAccessEnabled, LNS_IsCollationCompatible, LNS_UsesRemoteCollation,
									LNS_CLT_ID, LNS_LazySchemaValidation, LNS_IsRemoteProcTransactionPromotionEnabled, LNS_InsertDate, LNS_LastSeenDate, LNS_Last_TRH_ID)
						values(Metadata_ClientID, @MOB_ID, name, LPT_ID, LPR_ID, data_source, MOB_ID, location, provider_string, [catalog], IDB_ID, is_rpc_out_enabled,
								is_data_access_enabled, is_collation_compatible, uses_remote_collation, CLT_ID, lazy_schema_validation,
								is_remote_proc_transaction_promotion_enabled, @StartDate, @StartDate, Metadata_TRH_ID);

merge Inventory.InstanceLogins d
	using (select distinct b.value('@LocalLoginName', 'nvarchar(128)') LocalLoginName, Metadata_TRH_ID, Metadata_ClientID
			from inserted
				cross apply (select cast(RemoteLogins as xml) x) t
				cross apply x.nodes('RemoteLogins/RemoteLogin') a(b)
			where b.value('@LocalLoginName', 'nvarchar(128)') is not null) s
		on INL_MOB_ID = @MOB_ID
			and INL_Name = LocalLoginName
	when not matched then insert(INL_ClientID, INL_MOB_ID, INL_Name, INL_InsertDate, INL_LastSeenDate, INL_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, LocalLoginName, @StartDate, @StartDate, Metadata_TRH_ID);

merge Inventory.LinkedServerRemoteLogins d
	using (select LNS_ID, l.INL_ID LocalLoginID, b.value('@UsesSelfCredential', 'bit') UsesSelfCredential,
				b.value('@RemoteLoginName', 'nvarchar(128)') RemoteLoginName, r.INL_ID RemoteLoginID,
				Metadata_TRH_ID, Metadata_ClientID
			from inserted
				cross apply (select cast(RemoteLogins as xml) x) t
				cross apply x.nodes('RemoteLogins/RemoteLogin') a(b)
				inner join Inventory.LinkedServers on LNS_MOB_ID = @MOB_ID
														and LNS_Name = name
				left join Inventory.InstanceLogins l on l.INL_MOB_ID = @MOB_ID
														and l.INL_Name = b.value('@LocalLoginName', 'nvarchar(128)')
				left join Inventory.MonitoredObjects on MOB_PLT_ID = 1
														and MOB_Name = data_source
				left join Inventory.InstanceLogins r on r.INL_MOB_ID = MOB_ID
														and r.INL_Name = b.value('@RemoteLoginName', 'nvarchar(128)')) s
		on LSR_MOB_ID = @MOB_ID
			and LSR_LNS_ID = LNS_ID
			and (LSR_INL_ID = LocalLoginID
					or (LSR_INL_ID is null
						and LocalLoginID is null)
				)
	when matched then update set
							LSR_UsesSelfCredential = UsesSelfCredential,
							LSR_RemoteLoginName = RemoteLoginName,
							LSR_RemoteLogin_INL_ID = RemoteLoginID,
							LSR_LastSeenDate = @StartDate,
							LSR_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(LSR_ClientID, LSR_MOB_ID, LSR_LNS_ID, LSR_INL_ID, LSR_UsesSelfCredential, LSR_RemoteLoginName, LSR_RemoteLogin_INL_ID, LSR_InsertDate,
									LSR_LastSeenDate, LSR_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, LNS_ID, LocalLoginID, UsesSelfCredential, RemoteLoginName, RemoteLoginID, @StartDate, @StartDate,
									Metadata_TRH_ID);
GO
