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
/****** Object:  View [Tests].[VW_TST_EncryptionObjects]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_EncryptionObjects]
as
select top 0 CAST(null as nvarchar(128)) DatabaseName,
			CAST(null as varchar(100)) EncryptionObjectType,
			CAST(null as nvarchar(128)) name,
			CAST(null as int) key_length,
			CAST(null as nvarchar(60)) algorithm_desc,
			CAST(null as nvarchar(60)) provider_type,
			CAST(null as nvarchar(1000)) ProviderAlgorithmID,
			CAST(null as nvarchar(60)) EncryptionType,
			CAST(null as nvarchar(max)) EncyptionByObjects,
			CAST(null as int) IsUsedForSigningModules,
			CAST(null as bit) is_active_for_begin_dialog,
			CAST(null as nvarchar(4000)) CertificateSubject,
			CAST(null as datetime) CertificateStartDate,
			CAST(null as datetime) CertificateExpiryDate,
			CAST(null as datetime) pvt_key_last_backup_date,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_EncryptionObjects]    Script Date: 6/8/2020 1:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_EncryptionObjects] on [Tests].[VW_TST_EncryptionObjects]
	instead of insert
as
set nocount on
declare @MOB_ID int,
		@StartDate datetime2(3)
select top 1 @MOB_ID = TRH_MOB_ID,
			@StartDate = TRH_StartDate
from inserted
	inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID

merge Inventory.InstanceDatabases s
	using (select DatabaseName, Metadata_TRH_ID, Metadata_ClientID
			from inserted) d
		on IDB_MOB_ID = @MOB_ID
			and IDB_Name = DatabaseName
	when not matched then insert(IDB_ClientID, IDB_MOB_ID, IDB_Name, IDB_InsertDate, IDB_LastSeenDate, IDB_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, DatabaseName, @StartDate, @StartDate, Metadata_TRH_ID);

merge Inventory.EncryptionObjectTypes d
	using (select distinct replace(replace(replace(EncryptionType, '_', ' '), 'ENCRYPTION BY ', ''), 'ENCRYPTED BY ', '') EncryptionType
			from inserted
			where EncryptionType is not null
			union
			select distinct replace(replace(replace(b.value('@EncyptedBy', 'nvarchar(60)'), '_', ' '), 'ENCRYPTION BY ', ''), 'ENCRYPTED BY ', '') EncryptionType
			from inserted
				cross apply (select cast(EncyptionByObjects as xml) x) t
				cross apply x.nodes('EncyptionByObjects/EncryptionObject') a(b)
			where EncyptionByObjects is not null
			) s
		on EncryptionType = EOT_OriginalCode
	when not matched then insert (EOT_OriginalCode, EOT_DisplayName)
							values(EncryptionType, EncryptionType);

merge Inventory.EncryptionAlgorithms d
	using (select distinct EOT_ID, algorithm_desc
			from inserted
				inner join Inventory.EncryptionObjectTypes on EncryptionObjectType = EOT_DisplayName
			where algorithm_desc is not null) s
		on EOT_ID = ENA_EOT_ID
			and algorithm_desc = ENA_Name
	when not matched then insert (ENA_EOT_ID, ENA_Name)
							values(EOT_ID, algorithm_desc);

merge Inventory.EncryptionProviderTypes d
	using (select distinct provider_type
			from inserted
			where provider_type is not null) s
		on provider_type = EPY_Name
	when not matched then insert(EPY_Name)
							values(provider_type);

;with EncryptedObjects as
		(select IDB_ID, ot.EOT_ID ObjectType, name, key_length, ENA_ID, EPY_ID, ProviderAlgorithmID, et.EOT_ID EncryptionType, IsUsedForSigningModules,
				is_active_for_begin_dialog, CertificateSubject, CertificateStartDate, CertificateExpiryDate, pvt_key_last_backup_date,
				Metadata_ClientID, Metadata_TRH_ID
			from inserted
				inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
														and IDB_Name = DatabaseName
				inner join Inventory.EncryptionObjectTypes ot on EncryptionObjectType = ot.EOT_DisplayName
				left join Inventory.EncryptionAlgorithms on EOT_ID = ENA_EOT_ID
														and algorithm_desc = ENA_Name
				left join Inventory.EncryptionProviderTypes on provider_type = EPY_Name
				left join Inventory.EncryptionObjectTypes et on replace(replace(replace(EncryptionType, '_', ' '), 'ENCRYPTION BY ', ''), 'ENCRYPTED BY ', '') = et.EOT_OriginalCode
			union
			select IDB_ID, EOT_ID ObjectType, b.value('@EncryptionObjectName', 'nvarchar(128)') name, cast(null as int) key_length,
				cast(null as tinyint) ENA_ID, cast(null as tinyint) EPY_ID, cast(null as nvarchar(1000)) ProviderAlgorithmID, cast(null as tinyint) EncryptionType,
				cast(null as bit) IsUsedForSigningModules, cast(null as bit) is_active_for_begin_dialog, cast(null as nvarchar(4000)) CertificateSubject,
				cast(null as datetime) CertificateStartDate, cast(null as datetime) CertificateExpiryDate, cast(null as datetime) pvt_key_last_backup_date,
				Metadata_ClientID, Metadata_TRH_ID
			from inserted
				inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
														and IDB_Name = DatabaseName
				cross apply (select cast(EncyptionByObjects as xml) x) t
				cross apply x.nodes('EncyptionByObjects/EncryptionObject') a(b)
				inner join Inventory.EncryptionObjectTypes on replace(replace(replace(b.value('@EncyptedBy', 'nvarchar(60)'), '_', ' '), 'ENCRYPTION BY ', ''), 'ENCRYPTED BY ', '')
																 = EOT_OriginalCode
			where EncyptionByObjects is not null
				and b.value('@EncryptionObjectName', 'nvarchar(128)') is not null
		),
	UniqueEncryptedObjects as
		(select IDB_ID, ObjectType, name, max(key_length) key_length, max(ENA_ID) ENA_ID, max(EPY_ID) EPY_ID, max(ProviderAlgorithmID) ProviderAlgorithmID,
				max(EncryptionType) EncryptionType, max(cast(IsUsedForSigningModules as tinyint)) IsUsedForSigningModules,
				max(cast(is_active_for_begin_dialog as bigint)) is_active_for_begin_dialog, max(CertificateSubject) CertificateSubject,
				max(CertificateStartDate) CertificateStartDate, max(CertificateExpiryDate) CertificateExpiryDate, max(pvt_key_last_backup_date) pvt_key_last_backup_date,
				Metadata_ClientID, Metadata_TRH_ID
		from EncryptedObjects
		group by IDB_ID, ObjectType, name, Metadata_ClientID, Metadata_TRH_ID)
merge Inventory.EncryptionObjects d
	using UniqueEncryptedObjects s
		on ENO_MOB_ID = @MOB_ID
			and ENO_IDB_ID = IDB_ID
			and ENO_EOT_ID = ObjectType
			and ENO_Name = name
	when matched then update set
							ENO_KeyLength = key_length,
							ENO_ENA_ID = ENA_ID,
							ENO_EPY_ID = EPY_ID,
							ENO_ProviderAlgorithmID = ProviderAlgorithmID,
							ENO_EncryptionType_EOT_ID = EncryptionType,
							ENO_IsUsedForSigningModules = IsUsedForSigningModules,
							ENO_IsActiveForBeginDialog = is_active_for_begin_dialog,
							ENO_CertificateSubject = CertificateSubject,
							ENO_CertificateStartDate = CertificateStartDate,
							ENO_CertificateExpiryDate = CertificateExpiryDate,
							ENO_CertificatePrivateKeyLastBackupDate = pvt_key_last_backup_date,
							ENO_LastSeenDate = @StartDate,
							ENO_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(ENO_ClientID, ENO_MOB_ID, ENO_IDB_ID, ENO_EOT_ID, ENO_Name, ENO_KeyLength, ENO_ENA_ID, ENO_EPY_ID, ENO_ProviderAlgorithmID, ENO_EncryptionType_EOT_ID,
									ENO_IsUsedForSigningModules, ENO_IsActiveForBeginDialog, ENO_CertificateSubject, ENO_CertificateStartDate, ENO_CertificateExpiryDate,
									ENO_CertificatePrivateKeyLastBackupDate, ENO_InsertDate, ENO_LastSeenDate, ENO_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IDB_ID, ObjectType, name, key_length, ENA_ID, EPY_ID, ProviderAlgorithmID, EncryptionType,
									IsUsedForSigningModules, is_active_for_begin_dialog, CertificateSubject, CertificateStartDate, CertificateExpiryDate, pvt_key_last_backup_date,
									@StartDate, @StartDate, Metadata_TRH_ID);

merge Inventory.EncryptionHierarchy d
	using (select IDB_ID, eon.ENO_ID EncryptedObject, ent.EOT_ID EncyptingObjectType, enn.ENO_ID EncryptingObjectID,
				b.value('@EncryptionsByObject', 'int') EncryptionsByObject, Metadata_ClientID, Metadata_TRH_ID
			from inserted
				inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
											and IDB_Name = DatabaseName
				inner join Inventory.EncryptionObjectTypes eot on EncryptionObjectType = eot.EOT_DisplayName
				inner join Inventory.EncryptionObjects eon on eon.ENO_MOB_ID = @MOB_ID
															and eon.ENO_IDB_ID = IDB_ID
															and eon.ENO_EOT_ID = eot.EOT_ID
															and eon.ENO_Name = name
				cross apply (select cast(EncyptionByObjects as xml) x) t
				cross apply x.nodes('EncyptionByObjects/EncryptionObject') a(b)
				inner join Inventory.EncryptionObjectTypes ent on replace(replace(replace(b.value('@EncyptedBy', 'nvarchar(60)'), '_', ' '), 'ENCRYPTION BY ', ''), 'ENCRYPTED BY ', '')
																	= ent.EOT_OriginalCode
				left join Inventory.EncryptionObjects enn on enn.ENO_MOB_ID = @MOB_ID
															and enn.ENO_IDB_ID = IDB_ID
															and enn.ENO_EOT_ID = ent.EOT_ID
															and enn.ENO_Name = b.value('@EncryptionObjectName', 'nvarchar(128)')
			where EncyptionByObjects is not null) s
		on ENH_MOB_ID = @MOB_ID
			and ENH_IDB_ID = IDB_ID
			and ENH_Encrypted_ENO_ID = EncryptedObject
			and ENH_EncryptionBy_EOT_ID = EncyptingObjectType
			and (ENH_Encypting_ENO_ID = EncryptingObjectID
				or (ENH_Encypting_ENO_ID is null
					and EncryptingObjectID is null)
				)
	when matched then update set
							ENH_EncryptionsByObject = EncryptionsByObject,
							ENH_LastSeenDate = @StartDate,
							ENH_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(ENH_ClientID, ENH_MOB_ID, ENH_IDB_ID, ENH_Encrypted_ENO_ID, ENH_EncryptionBy_EOT_ID, ENH_Encypting_ENO_ID, ENH_EncryptionsByObject,
									ENH_InsertDate, ENH_LastSeenDate, ENH_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IDB_ID, EncryptedObject, EncyptingObjectType, EncryptingObjectID, EncryptionsByObject, @StartDate,
									@StartDate, Metadata_TRH_ID);
GO
