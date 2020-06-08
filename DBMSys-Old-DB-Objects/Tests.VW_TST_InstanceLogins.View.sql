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
/****** Object:  View [Tests].[VW_TST_InstanceLogins]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_InstanceLogins]
as
SELECT TOP 0 CAST(null as nvarchar(128)) name,
			CAST(null as varbinary(85)) [sid],
			CAST(null as nvarchar(60)) type_desc,
			CAST(null as bit) is_disabled,
			CAST(null as datetime) create_date,
			CAST(null as datetime) modify_date,
			CAST(null as nvarchar(128)) default_database_name,
			CAST(null as nvarchar(128)) default_language_name,
			CAST(null as bit) IsSysAdmin,
			CAST(null as bit) IsSecurityAdmin,
			CAST(null as bit) IsServerdmin,
			CAST(null as bit) IsSetupAdmin,
			CAST(null as bit) IsProcessAdmin,
			CAST(null as bit) IsDiskAdmin,
			CAST(null as bit) IsDBCreator,
			CAST(null as bit) IsBulkAdmin,
			CAST(null as varbinary(256)) password_hash,
			CAST(null as bit) HasControlServer,
			CAST(null as bit) IsLocked,
			CAST(null as bit) is_policy_checked,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_InstanceLogins]    Script Date: 6/8/2020 1:16:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_InstanceLogins] on [Tests].[VW_TST_InstanceLogins]
	instead of insert
as
set nocount on
declare @MOB_ID int,
		@StartDate datetime2(3)
select top 1 @MOB_ID = TRH_MOB_ID,
			@StartDate = TRH_StartDate
from inserted
	inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID

merge Inventory.InstanceLoginTypes d
	using (select distinct type_desc
			from inserted
			where type_desc is not null) s
		on type_desc = ILT_Name
	when not matched then insert(ILT_Name)
						values(type_desc);

merge Inventory.InstanceDatabases s
	using (select distinct default_database_name, Metadata_TRH_ID, Metadata_ClientID
			from inserted
			where default_database_name is not null) d
		on IDB_MOB_ID = @MOB_ID
			and IDB_Name = default_database_name
	when not matched then insert(IDB_ClientID, IDB_MOB_ID, IDB_Name, IDB_InsertDate, IDB_LastSeenDate, IDB_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, default_database_name, @StartDate, @StartDate, Metadata_TRH_ID);

merge Inventory.InstanceLoginTypes d
	using (select distinct type_desc
			from inserted
			where type_desc is not null) s
		on type_desc = ILT_Name
	when not matched then insert(ILT_Name)
						values(type_desc);

merge Inventory.Languages d
	using (select distinct default_language_name
			from inserted
			where default_language_name is not null) s
		on default_language_name = LNG_Name
	when not matched then insert(LNG_Name)
						values(default_language_name);


select name, CONVERT(VARBINARY,[sid],2) AS [sid] from inserted

merge Inventory.InstanceLogins d
	using (select name, CONVERT(VARBINARY,[sid],2) AS [sid], ILT_ID, is_disabled, create_date, modify_date, IDB_ID, LNG_ID, IsSysAdmin, IsSecurityAdmin, IsServerdmin, IsSetupAdmin,
				IsProcessAdmin, IsDiskAdmin, IsDBCreator, IsBulkAdmin, password_hash, HasControlServer, Islocked, is_policy_checked, Metadata_TRH_ID, Metadata_ClientID
			from inserted
				left join inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
															and default_database_name collate database_default = IDB_Name
				left join Inventory.InstanceLoginTypes on type_desc collate database_default = ILT_Name
				left join Inventory.Languages on default_language_name collate database_default = LNG_Name) s
		on INL_MOB_ID = @MOB_ID
			and INL_Name = name collate database_default
	when matched then update set
							INL_SID = [sid],
							INL_ILT_ID = ILT_ID,
							INL_IsDisabled = is_disabled,
							INL_CreateDate = create_date,
							INL_ModifyDate = modify_date,
							INL_Default_IDB_ID = IDB_ID,
							INL_Default_LNG_ID = LNG_ID,
							INL_IsSysAdmin = IsSysAdmin,
							INL_IsSecurityAdmin = IsSecurityAdmin,
							INL_IsServerdmin = IsServerdmin,
							INL_IsSetupAdmin = IsSetupAdmin,
							INL_IsProcessAdmin = IsProcessAdmin,
							INL_IsDiskAdmin = IsDiskAdmin,
							INL_IsDBCreator = IsDBCreator,
							INL_IsBulkAdmin = IsBulkAdmin,
							INL_PasswordHash = password_hash,
							INL_HasControlServer = HasControlServer,
							INL_IsLocked = IsLocked,
							INL_IsPolicyChecked = is_policy_checked,
							INL_LastSeenDate = @StartDate,
							INL_Last_TRH_ID = Metadata_TRH_ID
	when not matched then insert(INL_ClientID, INL_MOB_ID, INL_Name, INL_SID, INL_ILT_ID, INL_IsDisabled, INL_CreateDate, INL_ModifyDate, INL_Default_IDB_ID, INL_Default_LNG_ID,
									INL_IsSysAdmin, INL_IsSecurityAdmin, INL_IsServerdmin, INL_IsSetupAdmin, INL_IsProcessAdmin, INL_IsDiskAdmin, INL_IsDBCreator, INL_IsBulkAdmin,
									INL_PasswordHash, INL_HasControlServer, INL_IsLocked, INL_IsPolicyChecked, INL_InsertDate, INL_LastSeenDate, INL_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, name, [sid], ILT_ID, is_disabled, create_date, modify_date, IDB_ID, LNG_ID, IsSysAdmin, IsSecurityAdmin, IsServerdmin,
									IsSetupAdmin, IsProcessAdmin, IsDiskAdmin, IsDBCreator, IsBulkAdmin, password_hash, HasControlServer, IsLocked, is_policy_checked, @StartDate, @StartDate,
									Metadata_TRH_ID);
GO
