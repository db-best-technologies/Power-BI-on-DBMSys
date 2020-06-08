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
/****** Object:  Table [Inventory].[InstanceDatabases]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[InstanceDatabases](
	[IDB_ID] [int] IDENTITY(1,1) NOT NULL,
	[IDB_ClientID] [int] NOT NULL,
	[IDB_MOB_ID] [int] NOT NULL,
	[IDB_Name] [nvarchar](128) NOT NULL,
	[IDB_CreateDate] [datetime] NULL,
	[IDB_CompatibilityLevel] [tinyint] NULL,
	[IDB_CLT_ID] [smallint] NULL,
	[IDB_IsReadOnly] [bit] NULL,
	[IDB_IsAutoCloseOn] [bit] NULL,
	[IDB_IsAutoShrinkOn] [bit] NULL,
	[IDB_IDS_ID] [tinyint] NULL,
	[IDB_IsInStandby] [bit] NULL,
	[IDB_SnapshotIsolationState] [bit] NULL,
	[IDB_IsReadCommittedSnapshotOn] [bit] NULL,
	[IDB_RCM_ID] [tinyint] NULL,
	[IDB_PVO_ID] [tinyint] NULL,
	[IDB_IsAutoCreateStatsOn] [bit] NULL,
	[IDB_IsAutoUpdateStatsOn] [bit] NULL,
	[IDB_IsAutoUpdateStatsAsyncOn] [bit] NULL,
	[IDB_IsRecursiveTriggersOn] [bit] NULL,
	[IDB_IsTrustworthyOn] [bit] NULL,
	[IDB_IsDatabaseChainingOn] [bit] NULL,
	[IDB_IsParameterizationForced] [bit] NULL,
	[IDB_IsPublished] [bit] NULL,
	[IDB_IsSubscribed] [bit] NULL,
	[IDB_IsMergePublished] [bit] NULL,
	[IDB_IsDistributor] [bit] NULL,
	[IDB_IsBrokerEnabled] [bit] NULL,
	[IDB_LRW_ID] [tinyint] NULL,
	[IDB_IsCDCEnabled] [bit] NULL,
	[IDB_IsEncrypted] [bit] NULL,
	[IDB_AvgFullBackupInterval] [int] NULL,
	[IDB_AvgLogBackupInterval] [int] NULL,
	[IDB_InsertDate] [datetime2](3) NOT NULL,
	[IDB_LastSeenDate] [datetime2](3) NOT NULL,
	[IDB_Last_TRH_ID] [int] NOT NULL,
	[IDB_DAT_ID] [tinyint] NULL,
	[IDB_Source_IDB_ID] [int] NULL,
	[IDB_Owner_INL_ID] [int] NULL,
	[IDB_IsDateCorrelationOn] [bit] NULL,
	[IDB_LastFullBackupDate] [datetime2](3) NULL,
	[IDB_AvgBackupCompressionRatio] [decimal](10, 2) NULL,
	[IDB_Partitioning] [bit] NULL,
	[IDB_FullTextIndexes] [bit] NULL,
	[IDB_DataCompression] [bit] NULL,
	[IDB_Auditing] [bit] NULL,
	[IDB_FileStreamData] [bit] NULL,
	[IDB_FiltredIndexes] [bit] NULL,
	[IDB_ChangeTracking] [bit] NULL,
	[IDB_MemoryOptimizedOLTP] [bit] NULL,
	[IDB_MergeReplicationWithInfiniteRetention] [bit] NULL,
	[IDB_LastLogBackupDate] [datetime2](3) NULL,
	[IDB_AvgGrowthPerDayMB] [decimal](20, 2) NULL,
	[IDB_LastUsageDate] [datetime2](3) NULL,
	[IDB_IsDeleted] [bit] NOT NULL,
 CONSTRAINT [PK_InstanceDatabases] PRIMARY KEY CLUSTERED 
(
	[IDB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_InstanceDatabases_IDB_MOB_ID#IDB_Name]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_InstanceDatabases_IDB_MOB_ID#IDB_Name] ON [Inventory].[InstanceDatabases]
(
	[IDB_MOB_ID] ASC,
	[IDB_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Inventory].[InstanceDatabases] ADD  DEFAULT ((0)) FOR [IDB_IsDeleted]
GO
/****** Object:  Trigger [Inventory].[trg_InstanceDatabases_HistoryLogging]    Script Date: 6/8/2020 1:15:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_InstanceDatabases_HistoryLogging] ON [Inventory].[InstanceDatabases]
FOR UPDATE, DELETE
NOT FOR REPLICATION
AS
SET NOCOUNT ON
SET ANSI_PADDING ON
SET QUOTED_IDENTIFIER ON
DECLARE @ChangeType char(1),
		@Info xml,
		@ErrorMessage nvarchar(max)

IF EXISTS (SELECT * FROM inserted)
	SET @ChangeType = 'U'
ELSE
	SET @ChangeType = 'D'
BEGIN TRY
	INSERT INTO Inventory.History(HIS_Type, HIS_Datetime, HIS_TableName, HIS_MOB_ID, HIS_PK_1, 	HIS_Changes, HIS_UserName, HIS_AppName, HIS_HostName)
	SELECT *
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.InstanceDatabases' TabName, C_MOB_ID, IDB_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.IDB_MOB_ID C_MOB_ID, D.IDB_ID, 
					(SELECT CASE WHEN UPDATE(IDB_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_Name) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_CreateDate) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_CreateDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_CreateDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_CreateDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_CompatibilityLevel) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_CompatibilityLevel' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_CompatibilityLevel as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_CompatibilityLevel as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_CLT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_CLT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_CLT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_CLT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_IsReadOnly) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_IsReadOnly' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_IsReadOnly as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_IsReadOnly as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_IsAutoCloseOn) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_IsAutoCloseOn' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_IsAutoCloseOn as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_IsAutoCloseOn as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_IsAutoShrinkOn) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_IsAutoShrinkOn' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_IsAutoShrinkOn as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_IsAutoShrinkOn as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_IDS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_IDS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_IDS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_IDS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_IsInStandby) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_IsInStandby' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_IsInStandby as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_IsInStandby as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_SnapshotIsolationState) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_SnapshotIsolationState' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_SnapshotIsolationState as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_SnapshotIsolationState as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_IsReadCommittedSnapshotOn) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_IsReadCommittedSnapshotOn' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_IsReadCommittedSnapshotOn as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_IsReadCommittedSnapshotOn as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_RCM_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_RCM_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_RCM_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_RCM_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_PVO_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_PVO_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_PVO_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_PVO_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_IsAutoCreateStatsOn) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_IsAutoCreateStatsOn' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_IsAutoCreateStatsOn as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_IsAutoCreateStatsOn as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_IsAutoUpdateStatsOn) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_IsAutoUpdateStatsOn' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_IsAutoUpdateStatsOn as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_IsAutoUpdateStatsOn as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_IsAutoUpdateStatsAsyncOn) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_IsAutoUpdateStatsAsyncOn' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_IsAutoUpdateStatsAsyncOn as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_IsAutoUpdateStatsAsyncOn as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_IsRecursiveTriggersOn) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_IsRecursiveTriggersOn' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_IsRecursiveTriggersOn as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_IsRecursiveTriggersOn as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_IsTrustworthyOn) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_IsTrustworthyOn' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_IsTrustworthyOn as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_IsTrustworthyOn as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_IsDatabaseChainingOn) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_IsDatabaseChainingOn' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_IsDatabaseChainingOn as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_IsDatabaseChainingOn as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_IsParameterizationForced) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_IsParameterizationForced' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_IsParameterizationForced as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_IsParameterizationForced as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_IsPublished) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_IsPublished' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_IsPublished as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_IsPublished as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_IsSubscribed) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_IsSubscribed' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_IsSubscribed as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_IsSubscribed as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_IsMergePublished) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_IsMergePublished' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_IsMergePublished as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_IsMergePublished as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_IsDistributor) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_IsDistributor' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_IsDistributor as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_IsDistributor as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_IsBrokerEnabled) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_IsBrokerEnabled' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_IsBrokerEnabled as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_IsBrokerEnabled as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_IsCDCEnabled) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_IsCDCEnabled' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_IsCDCEnabled as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_IsCDCEnabled as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_IsEncrypted) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_IsEncrypted' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_IsEncrypted as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_IsEncrypted as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_AvgFullBackupInterval) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_AvgFullBackupInterval' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_AvgFullBackupInterval as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_AvgFullBackupInterval as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_AvgLogBackupInterval) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_AvgLogBackupInterval' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_AvgLogBackupInterval as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_AvgLogBackupInterval as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_DAT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_DAT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_DAT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_DAT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_Source_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_Source_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_Source_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_Source_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_Owner_INL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_Owner_INL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_Owner_INL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_Owner_INL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_IsDateCorrelationOn) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_IsDateCorrelationOn' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_IsDateCorrelationOn as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_IsDateCorrelationOn as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_LastFullBackupDate) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_LastFullBackupDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_LastFullBackupDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_LastFullBackupDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_AvgBackupCompressionRatio) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_AvgBackupCompressionRatio' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_AvgBackupCompressionRatio as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_AvgBackupCompressionRatio as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_Partitioning) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_Partitioning' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_Partitioning as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_Partitioning as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_FullTextIndexes) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_FullTextIndexes' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_FullTextIndexes as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_FullTextIndexes as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_DataCompression) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_DataCompression' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_DataCompression as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_DataCompression as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_Auditing) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_Auditing' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_Auditing as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_Auditing as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_FileStreamData) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_FileStreamData' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_FileStreamData as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_FileStreamData as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_FiltredIndexes) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_FiltredIndexes' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_FiltredIndexes as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_FiltredIndexes as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_ChangeTracking) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_ChangeTracking' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_ChangeTracking as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_ChangeTracking as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_MemoryOptimizedOLTP) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_MemoryOptimizedOLTP' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_MemoryOptimizedOLTP as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_MemoryOptimizedOLTP as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_MergeReplicationWithInfiniteRetention) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_MergeReplicationWithInfiniteRetention' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_MergeReplicationWithInfiniteRetention as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_MergeReplicationWithInfiniteRetention as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_LastLogBackupDate) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_LastLogBackupDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_LastLogBackupDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_LastLogBackupDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IDB_AvgGrowthPerDayMB) Or @ChangeType = 'D' THEN
							(SELECT 'IDB_AvgGrowthPerDayMB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IDB_AvgGrowthPerDayMB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IDB_AvgGrowthPerDayMB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.IDB_ID = D.IDB_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.InstanceDatabases' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[InstanceDatabases] DISABLE TRIGGER [trg_InstanceDatabases_HistoryLogging]
GO
