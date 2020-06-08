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
/****** Object:  View [Tests].[VW_TST_InstanceDatabases]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_InstanceDatabases]
as
select top 0 CAST(null as nvarchar(128)) name,
			CAST(null as datetime) create_date,
			CAST(null as tinyint) compatibility_level,
			CAST(null as nvarchar(128)) collation_name,
			CAST(null as bit) is_read_only,
			CAST(null as bit) is_auto_close_on,
			CAST(null as bit) is_auto_shrink_on,
			CAST(null as nvarchar(60)) state_desc,
			CAST(null as bit) is_in_standby,
			CAST(null as tinyint) snapshot_isolation_state,
			CAST(null as bit) is_read_committed_snapshot_on,
			CAST(null as nvarchar(60)) recovery_model_desc,
			CAST(null as nvarchar(60)) page_verify_option_desc,
			CAST(null as bit) is_auto_create_stats_on,
			CAST(null as bit) is_auto_update_stats_on,
			CAST(null as bit) is_auto_update_stats_async_on,
			CAST(null as bit) is_recursive_triggers_on,
			CAST(null as bit) is_trustworthy_on,
			CAST(null as bit) is_db_chaining_on,
			CAST(null as bit) is_parameterization_forced,
			CAST(null as bit) is_published,
			CAST(null as bit) is_subscribed,
			CAST(null as bit) is_merge_published,
			CAST(null as bit) is_distributor,
			CAST(null as bit) is_broker_enabled,
			CAST(null as nvarchar(60)) log_reuse_wait_desc,
			CAST(null as bit) is_cdc_enabled,
			CAST(null as bit) is_encrypted,
			CAST(null as int) AvgFullBackupInterval,
			CAST(null as int) AvgLogBackupInterval,
			CAST(null as tinyint) user_access,
			CAST(null as nvarchar(128)) SourceDatabaseName,
			CAST(null as nvarchar(128)) OwnerLogin,
			CAST(null as bit) is_date_correlation_on,
			CAST(null as datetime) LastFullBackupDate,
			CAST(null as decimal) AvgBackupCompressionRatio,
			CAST(null as datetime) LastLogBackupDate,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID,
			CAST(null as datetime) LastUsageDate
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_InstanceDatabases]    Script Date: 6/8/2020 1:16:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_InstanceDatabases] on [Tests].[VW_TST_InstanceDatabases]
	instead of insert
as
set nocount on
declare @MOB_ID int,
		@StartDate datetime2(3)
		,@TRHID INT

select @MOB_ID = TRH_MOB_ID,
		@StartDate = TRH_StartDate
		,@TRHID = TRH_ID
from inserted
	inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID

merge inventory.CollationTypes d
	using (select distinct collation_name
			from inserted
			where collation_name is not null) s
		on collation_name = CLT_Name
	when not matched then insert(CLT_Name)
							values(collation_name);

merge inventory.InstanceDatabaseStates d
	using (select distinct state_desc
			from inserted
			where state_desc is not null) s
		on state_desc = IDS_Name
	when not matched then insert(IDS_Name)
							values(state_desc);

merge inventory.LogReuseWaitReasons d
	using (select distinct log_reuse_wait_desc
			from inserted
			where log_reuse_wait_desc is not null) s
		on log_reuse_wait_desc = LRW_Name
	when not matched then insert(LRW_Name)
							values(log_reuse_wait_desc);

merge Inventory.InstanceLogins d
	using (select distinct OwnerLogin, Metadata_TRH_ID, Metadata_ClientID
			from inserted
			where OwnerLogin is not null) s
		on INL_MOB_ID = @MOB_ID
			and INL_Name = OwnerLogin
	when not matched then insert(INL_ClientID, INL_MOB_ID, INL_Name, INL_InsertDate, INL_LastSeenDate, INL_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, OwnerLogin, @StartDate, @StartDate, Metadata_TRH_ID);

;with ExistingRows as
		(select IDB_ClientID, IDB_MOB_ID, IDB_Name, IDB_CreateDate, IDB_CompatibilityLevel, IDB_CLT_ID,
				IDB_IsReadOnly, IDB_IsAutoCloseOn, IDB_IsAutoShrinkOn, IDB_IDS_ID, IDB_IsInStandby,
				IDB_SnapshotIsolationState, IDB_IsReadCommittedSnapshotOn, IDB_RCM_ID,
				IDB_PVO_ID, IDB_IsAutoCreateStatsOn, IDB_IsAutoUpdateStatsOn, IDB_IsAutoUpdateStatsAsyncOn,
				IDB_IsRecursiveTriggersOn, IDB_IsTrustworthyOn, IDB_IsDatabaseChainingOn,
				IDB_IsParameterizationForced, IDB_IsPublished, IDB_IsSubscribed, IDB_IsMergePublished,
				IDB_IsDistributor, IDB_IsBrokerEnabled, IDB_LRW_ID, IDB_IsCDCEnabled, IDB_IsEncrypted,
				IDB_AvgFullBackupInterval, IDB_AvgLogBackupInterval, IDB_InsertDate, IDB_LastSeenDate, IDB_Last_TRH_ID,
				IDB_DAT_ID, IDB_Source_IDB_ID, IDB_Owner_INL_ID, IDB_IsDateCorrelationOn, IDB_LastFullBackupDate,
				IDB_AvgBackupCompressionRatio, IDB_LastLogBackupDate, IDB_LastUsageDate, IDB_IsDeleted
		from Inventory.InstanceDatabases with (forceseek)
		where exists (select *
						from inserted
							inner join Collect.TestRunHistory on TRH_ID = Metadata_TRH_ID
						where TRH_MOB_ID = IDB_MOB_ID
							and name = IDB_Name)
					)
merge ExistingRows d
	using (select Metadata_ClientID, name, create_date, [compatibility_level], CLT_ID, is_read_only, is_auto_close_on,
				is_auto_shrink_on, IDS_ID, is_in_standby, snapshot_isolation_state, is_read_committed_snapshot_on,
				RCM_ID, PVO_ID, is_auto_create_stats_on, is_auto_update_stats_on, is_auto_update_stats_async_on,
				is_recursive_triggers_on, is_trustworthy_on, is_db_chaining_on, is_parameterization_forced, is_published,
				is_subscribed, is_merge_published, is_distributor, is_broker_enabled, LRW_ID, is_cdc_enabled, is_encrypted,
				AvgFullBackupInterval, AvgLogBackupInterval, Metadata_TRH_ID, user_access, src.IDB_ID Source_IDB_ID, INL_ID,
				is_date_correlation_on, LastFullBackupDate, AvgBackupCompressionRatio, LastLogBackupDate, LastUsageDate
			from inserted
				left join Inventory.LogReuseWaitReasons on log_reuse_wait_desc = LRW_Name
				left join Inventory.PageVerificationOptions on page_verify_option_desc = PVO_Name
				left join Inventory.RecoveryModels on recovery_model_desc = RCM_Name
				left join Inventory.InstanceDatabaseStates on state_desc = IDS_Name
				left join Inventory.CollationTypes on collation_name = CLT_Name
				left join Inventory.InstanceDatabases src on src.IDB_MOB_ID = @MOB_ID
																and src.IDB_Name = SourceDatabaseName
				left join Inventory.InstanceLogins on INL_MOB_ID = @MOB_ID
														and INL_Name = OwnerLogin
				) s
			on IDB_MOB_ID = @MOB_ID
				and name = IDB_Name
	when matched then update set
								IDB_CreateDate = create_date,
								IDB_CompatibilityLevel = [compatibility_level],
								IDB_CLT_ID = CLT_ID,
								IDB_IsReadOnly = is_read_only,
								IDB_IsAutoCloseOn = is_auto_close_on,
								IDB_IsAutoShrinkOn = is_auto_shrink_on,
								IDB_IDS_ID = IDS_ID,
								IDB_IsInStandby = is_in_standby,
								IDB_SnapshotIsolationState = snapshot_isolation_state,
								IDB_IsReadCommittedSnapshotOn = is_read_committed_snapshot_on,
								IDB_RCM_ID = RCM_ID,
								IDB_PVO_ID = PVO_ID,
								IDB_IsAutoCreateStatsOn = is_auto_create_stats_on,
								IDB_IsAutoUpdateStatsOn = is_auto_update_stats_on,
								IDB_IsAutoUpdateStatsAsyncOn = is_auto_update_stats_async_on,
								IDB_IsRecursiveTriggersOn = is_recursive_triggers_on,
								IDB_IsTrustworthyOn = is_trustworthy_on,
								IDB_IsDatabaseChainingOn = is_db_chaining_on,
								IDB_IsParameterizationForced = is_parameterization_forced,
								IDB_IsPublished = is_published,
								IDB_IsSubscribed = is_subscribed,
								IDB_IsMergePublished = is_merge_published,
								IDB_IsDistributor = is_distributor,
								IDB_IsBrokerEnabled = is_broker_enabled,
								IDB_LRW_ID = LRW_ID,
								IDB_IsCDCEnabled = is_cdc_enabled,
								IDB_IsEncrypted = is_encrypted,
								IDB_AvgFullBackupInterval = AvgFullBackupInterval,
								IDB_AvgLogBackupInterval = AvgLogBackupInterval,
								IDB_LastSeenDate = @StartDate,
								IDB_Last_TRH_ID = Metadata_TRH_ID,
								IDB_DAT_ID = user_access,
								IDB_Source_IDB_ID = Source_IDB_ID,
								IDB_Owner_INL_ID = INL_ID,
								IDB_IsDateCorrelationOn = is_date_correlation_on,
								IDB_LastFullBackupDate = LastFullBackupDate,
								IDB_AvgBackupCompressionRatio = AvgBackupCompressionRatio,
								IDB_LastLogBackupDate = LastLogBackupDate,
								IDB_LastUsageDate = LastUsageDate,
								IDB_IsDeleted = 0
	when not matched then insert(IDB_ClientID, IDB_MOB_ID, IDB_Name, IDB_CreateDate, IDB_CompatibilityLevel, IDB_CLT_ID,
								IDB_IsReadOnly, IDB_IsAutoCloseOn, IDB_IsAutoShrinkOn, IDB_IDS_ID, IDB_IsInStandby,
								IDB_SnapshotIsolationState, IDB_IsReadCommittedSnapshotOn, IDB_RCM_ID,
								IDB_PVO_ID, IDB_IsAutoCreateStatsOn, IDB_IsAutoUpdateStatsOn, IDB_IsAutoUpdateStatsAsyncOn,
								IDB_IsRecursiveTriggersOn, IDB_IsTrustworthyOn, IDB_IsDatabaseChainingOn,
								IDB_IsParameterizationForced, IDB_IsPublished, IDB_IsSubscribed, IDB_IsMergePublished,
								IDB_IsDistributor, IDB_IsBrokerEnabled, IDB_LRW_ID, IDB_IsCDCEnabled, IDB_IsEncrypted,
								IDB_AvgFullBackupInterval, IDB_AvgLogBackupInterval, IDB_InsertDate, IDB_LastSeenDate, IDB_Last_TRH_ID,
								IDB_DAT_ID, IDB_Source_IDB_ID, IDB_Owner_INL_ID, IDB_IsDateCorrelationOn, IDB_LastFullBackupDate,
								IDB_AvgBackupCompressionRatio, IDB_LastLogBackupDate, IDB_LastUsageDate)
						values(Metadata_ClientID, @MOB_ID, name, create_date, [compatibility_level], CLT_ID, is_read_only, is_auto_close_on,
								is_auto_shrink_on, IDS_ID, is_in_standby, snapshot_isolation_state, is_read_committed_snapshot_on, RCM_ID,
								PVO_ID, is_auto_create_stats_on, is_auto_update_stats_on, is_auto_update_stats_async_on, is_recursive_triggers_on,
								is_trustworthy_on, is_db_chaining_on, is_parameterization_forced, is_published, is_subscribed, is_merge_published,
								is_distributor, is_broker_enabled, LRW_ID, is_cdc_enabled, is_encrypted, AvgFullBackupInterval, AvgLogBackupInterval,
								@StartDate, @StartDate, Metadata_TRH_ID, user_access, Source_IDB_ID, INL_ID, is_date_correlation_on, LastFullBackupDate,
								AvgBackupCompressionRatio, LastLogBackupDate, LastUsageDate)
;WITH exDB AS 
(
	select Metadata_ClientID, name, create_date, [compatibility_level], CLT_ID, is_read_only, is_auto_close_on,
				is_auto_shrink_on, IDS_ID, is_in_standby, snapshot_isolation_state, is_read_committed_snapshot_on,
				RCM_ID, PVO_ID, is_auto_create_stats_on, is_auto_update_stats_on, is_auto_update_stats_async_on,
				is_recursive_triggers_on, is_trustworthy_on, is_db_chaining_on, is_parameterization_forced, is_published,
				is_subscribed, is_merge_published, is_distributor, is_broker_enabled, LRW_ID, is_cdc_enabled, is_encrypted,
				AvgFullBackupInterval, AvgLogBackupInterval, Metadata_TRH_ID, user_access, src.IDB_ID Source_IDB_ID, INL_ID,
				is_date_correlation_on, LastFullBackupDate, AvgBackupCompressionRatio, LastLogBackupDate, LastUsageDate
			from inserted
				left join Inventory.LogReuseWaitReasons on log_reuse_wait_desc = LRW_Name
				left join Inventory.PageVerificationOptions on page_verify_option_desc = PVO_Name
				left join Inventory.RecoveryModels on recovery_model_desc = RCM_Name
				left join Inventory.InstanceDatabaseStates on state_desc = IDS_Name
				left join Inventory.CollationTypes on collation_name = CLT_Name
				left join Inventory.InstanceDatabases src on src.IDB_MOB_ID = @MOB_ID
																and src.IDB_Name = SourceDatabaseName
				left join Inventory.InstanceLogins on INL_MOB_ID = @MOB_ID
														and INL_Name = OwnerLogin
				
				) 
UPDATE	Inventory.InstanceDatabases 
SET		IDB_IsDeleted = 1 
		,IDB_LastSeenDate = @StartDate
WHERE	IDB_MOB_ID = @MOB_ID 
		AND NOT EXISTS (SELECT TOP 1 1 FROM exDB WHERE IDB_MOB_ID = @MOB_ID	and name = IDB_Name)
		AND EXISTS (SELECT * FROM Collect.GetLastTestTRHID(@TRHID,10)f WHERE f.RN>2 AND IDB_Last_TRH_ID = TRHID)
GO
