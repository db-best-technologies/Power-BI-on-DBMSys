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
/****** Object:  View [Tests].[VW_TST_DatabasePrincipals]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Tests].[VW_TST_DatabasePrincipals]
as
select top 0 CAST(null as nvarchar(128)) DatabaseName,
			CAST(null as nvarchar(128)) PrincipalName,
			CAST(null as nvarchar(60)) PrincipalType,
			CAST(null as nvarchar(128)) DefaultSchemaName,
			CAST(null as nvarchar(128)) LoginName,
			CAST(null as int) IsOrphan,
			CAST(null as int) HasConnectPermissions,
			CAST(null as int) HasPermissions,
			CAST(null as int) HasDirectTablePermissions,
			CAST(null as int) HasControlDatabase,
			CAST(null as int) IsMemberOfUserRoles,
			CAST(null as int) IsDBOwner,
			CAST(null as int) IsAccessAdmin,
			CAST(null as int) IsSecurityAdmin,
			CAST(null as int) IsDDLAdmin,
			CAST(null as int) IsBackupOperator,
			CAST(null as int) IsDataReader,
			CAST(null as int) IsDataWriter,
			CAST(null as int) IsDenydataReader,
			CAST(null as int) IsDenyDataWriter,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_DatabasePrincipals]    Script Date: 6/8/2020 1:16:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Tests].[trg_VW_TST_DatabasePrincipals] on [Tests].[VW_TST_DatabasePrincipals]
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

merge Inventory.DatabasePrincipalTypes d
	using (select distinct PrincipalType
			from inserted
			where PrincipalType is not null) s
		on PrincipalType = DPT_OriginalCode
	when not matched then insert (DPT_OriginalCode, DPT_DisplayName)
							values(PrincipalType, PrincipalType);

merge Inventory.DatabaseSchemaNames d
	using (select distinct DefaultSchemaName
			from inserted
			where DefaultSchemaName is not null) s
		on DefaultSchemaName = DSN_Name
	when not matched then insert (DSN_Name)
							values(DefaultSchemaName);

merge Inventory.InstanceLogins d
	using (select distinct LoginName, Metadata_TRH_ID, Metadata_ClientID
			from inserted
			where LoginName is not null) s
		on INL_MOB_ID = @MOB_ID
			and INL_Name = LoginName
	when not matched then insert(INL_ClientID, INL_MOB_ID, INL_Name, INL_InsertDate, INL_LastSeenDate, INL_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, LoginName, @StartDate, @StartDate, Metadata_TRH_ID);

merge Inventory.DatabasePrincipals d
	using (select IDB_ID, PrincipalName, DPT_ID, DSN_ID, INL_ID, IsOrphan, HasConnectPermissions, HasPermissions, HasDirectTablePermissions, HasControlDatabase, IsMemberOfUserRoles, IsDBOwner,
					IsAccessAdmin, IsSecurityAdmin, IsDDLAdmin, IsBackupOperator, IsDataReader, IsDataWriter, IsDenydataReader, IsDenyDataWriter, Metadata_ClientID, Metadata_TRH_ID
			from inserted
				inner join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
														and IDB_Name = DatabaseName
				inner join Inventory.DatabasePrincipalTypes on PrincipalType = DPT_OriginalCode
				left join Inventory.DatabaseSchemaNames on DefaultSchemaName = DSN_Name
				left join Inventory.InstanceLogins on INL_MOB_ID = @MOB_ID
														and INL_Name = LoginName
														) s
		on DPP_MOB_ID = @MOB_ID
			and DPP_IDB_ID = IDB_ID
			and DPP_PrincipalName = PrincipalName
	when matched then update set
							DPP_DPT_ID = DPT_ID,
							DPP_Default_DSN_ID = DSN_ID,
							DPP_INL_ID = INL_ID,
							DPP_IsOrphan = IsOrphan,
							DPP_HasConnectPermissions = HasConnectPermissions,
							DPP_HasPermissions = HasPermissions,
							DPP_HasDirectTablePermissions = HasDirectTablePermissions,
							DPP_HasControlDatabase = HasControlDatabase,
							DPP_IsMemberOfUserRoles = IsMemberOfUserRoles,
							DPP_IsDBOwner = IsDBOwner,
							DPP_IsAccessAdmin = IsAccessAdmin,
							DPP_IsSecurityAdmin = IsSecurityAdmin,
							DPP_IsDDLAdmin = IsDDLAdmin,
							DPP_IsBackupOperator = IsBackupOperator,
							DPP_IsDataReader = IsDataReader,
							DPP_IsDataWriter = IsDataWriter,
							DPP_IsDenydataReader = IsDenydataReader,
							DPP_IsDenyDataWriter = IsDenyDataWriter,
							DPP_LastSeenDate = @StartDate,
							DPP_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(DPP_ClientID, DPP_MOB_ID, DPP_IDB_ID, DPP_PrincipalName, DPP_DPT_ID, DPP_Default_DSN_ID, DPP_INL_ID, DPP_IsOrphan, DPP_HasConnectPermissions, DPP_HasPermissions,
									DPP_HasDirectTablePermissions, DPP_HasControlDatabase, DPP_IsMemberOfUserRoles, DPP_IsDBOwner, DPP_IsAccessAdmin, DPP_IsSecurityAdmin, DPP_IsDDLAdmin,
									DPP_IsBackupOperator, DPP_IsDataReader, DPP_IsDataWriter, DPP_IsDenydataReader, DPP_IsDenyDataWriter, DPP_InsertDate, DPP_LastSeenDate, DPP_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IDB_ID, PrincipalName, DPT_ID, DSN_ID, INL_ID, IsOrphan, HasConnectPermissions, HasPermissions, HasDirectTablePermissions,
									HasControlDatabase, IsMemberOfUserRoles, IsDBOwner, IsAccessAdmin, IsSecurityAdmin, IsDDLAdmin, IsBackupOperator, IsDataReader, IsDataWriter,
									IsDenydataReader, IsDenyDataWriter, @StartDate, @StartDate, Metadata_TRH_ID);
GO
