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
/****** Object:  Table [Inventory].[DatabaseInstanceDetails]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[DatabaseInstanceDetails](
	[DID_ID] [int] IDENTITY(1,1) NOT NULL,
	[DID_ClientID] [int] NOT NULL,
	[DID_DFO_ID] [int] NOT NULL,
	[DID_OSS_ID] [int] NULL,
	[DID_EDT_ID] [int] NULL,
	[DID_Name] [nvarchar](128) NULL,
	[DID_InstanceName] [nvarchar](128) NULL,
	[DID_IsClustered] [bit] NULL,
	[DID_Architecture] [tinyint] NULL,
	[DID_CLT_ID] [smallint] NULL,
	[DID_IsFullTextInstalled] [bit] NULL,
	[DID_IsIntegratedSecurityOnly] [bit] NULL,
	[DID_PRL_ID] [tinyint] NULL,
	[DID_FilestreamEffectiveLevel] [int] NULL,
	[DID_LastRestartDate] [datetime2](3) NULL,
	[DID_OldestBackupHistory] [datetime2](3) NULL,
	[DID_OldestJobHistory] [datetime2](3) NULL,
	[DID_CurrentErrorLogStartDate] [datetime2](3) NULL,
	[DID_IsServerNameNull] [bit] NULL,
	[DID_IsServerNameWrong] [bit] NULL,
	[DID_Port] [int] NULL,
	[DID_DynamicPort] [int] NULL,
	[DID_IsTcpEnabled] [bit] NULL,
	[DID_IsNamedPipesEnabled] [bit] NULL,
	[DID_IsViaEnabled] [bit] NULL,
	[DID_AllowLockPagesInMemory] [int] NULL,
	[DID_IsSystemHealthSessionRunning] [int] NULL,
	[DID_IsResourceGovernorEnabled] [bit] NULL,
	[DID_LogonTriggerCount] [smallint] NULL,
	[DID_NumberOfAvailableSchedulers] [int] NULL,
 CONSTRAINT [PK_DatabaseInstanceDetails] PRIMARY KEY CLUSTERED 
(
	[DID_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_DatabaseInstanceDetails_DID_DFO_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_DatabaseInstanceDetails_DID_DFO_ID] ON [Inventory].[DatabaseInstanceDetails]
(
	[DID_DFO_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_DatabaseInstanceDetails_HistoryLogging]    Script Date: 6/8/2020 1:15:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_DatabaseInstanceDetails_HistoryLogging] ON [Inventory].[DatabaseInstanceDetails]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.DatabaseInstanceDetails' TabName, C_MOB_ID, DID_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT  NULL C_MOB_ID, D.DID_ID, 
					(SELECT CASE WHEN UPDATE(DID_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'DID_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_DFO_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DID_DFO_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_DFO_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_DFO_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_OSS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DID_OSS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_OSS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_OSS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_EDT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DID_EDT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_EDT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_EDT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_Name) Or @ChangeType = 'D' THEN
							(SELECT 'DID_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_InstanceName) Or @ChangeType = 'D' THEN
							(SELECT 'DID_InstanceName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_InstanceName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_InstanceName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_IsClustered) Or @ChangeType = 'D' THEN
							(SELECT 'DID_IsClustered' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_IsClustered as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_IsClustered as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_Architecture) Or @ChangeType = 'D' THEN
							(SELECT 'DID_Architecture' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_Architecture as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_Architecture as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_CLT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DID_CLT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_CLT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_CLT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_IsFullTextInstalled) Or @ChangeType = 'D' THEN
							(SELECT 'DID_IsFullTextInstalled' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_IsFullTextInstalled as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_IsFullTextInstalled as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_IsIntegratedSecurityOnly) Or @ChangeType = 'D' THEN
							(SELECT 'DID_IsIntegratedSecurityOnly' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_IsIntegratedSecurityOnly as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_IsIntegratedSecurityOnly as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_PRL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DID_PRL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_PRL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_PRL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_FilestreamEffectiveLevel) Or @ChangeType = 'D' THEN
							(SELECT 'DID_FilestreamEffectiveLevel' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_FilestreamEffectiveLevel as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_FilestreamEffectiveLevel as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_LastRestartDate) Or @ChangeType = 'D' THEN
							(SELECT 'DID_LastRestartDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_LastRestartDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_LastRestartDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_OldestBackupHistory) Or @ChangeType = 'D' THEN
							(SELECT 'DID_OldestBackupHistory' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_OldestBackupHistory as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_OldestBackupHistory as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_OldestJobHistory) Or @ChangeType = 'D' THEN
							(SELECT 'DID_OldestJobHistory' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_OldestJobHistory as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_OldestJobHistory as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_CurrentErrorLogStartDate) Or @ChangeType = 'D' THEN
							(SELECT 'DID_CurrentErrorLogStartDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_CurrentErrorLogStartDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_CurrentErrorLogStartDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_IsServerNameNull) Or @ChangeType = 'D' THEN
							(SELECT 'DID_IsServerNameNull' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_IsServerNameNull as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_IsServerNameNull as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_IsServerNameWrong) Or @ChangeType = 'D' THEN
							(SELECT 'DID_IsServerNameWrong' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_IsServerNameWrong as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_IsServerNameWrong as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_Port) Or @ChangeType = 'D' THEN
							(SELECT 'DID_Port' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_Port as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_Port as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_DynamicPort) Or @ChangeType = 'D' THEN
							(SELECT 'DID_DynamicPort' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_DynamicPort as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_DynamicPort as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_IsTcpEnabled) Or @ChangeType = 'D' THEN
							(SELECT 'DID_IsTcpEnabled' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_IsTcpEnabled as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_IsTcpEnabled as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_IsNamedPipesEnabled) Or @ChangeType = 'D' THEN
							(SELECT 'DID_IsNamedPipesEnabled' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_IsNamedPipesEnabled as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_IsNamedPipesEnabled as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_IsViaEnabled) Or @ChangeType = 'D' THEN
							(SELECT 'DID_IsViaEnabled' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_IsViaEnabled as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_IsViaEnabled as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_AllowLockPagesInMemory) Or @ChangeType = 'D' THEN
							(SELECT 'DID_AllowLockPagesInMemory' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_AllowLockPagesInMemory as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_AllowLockPagesInMemory as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_IsSystemHealthSessionRunning) Or @ChangeType = 'D' THEN
							(SELECT 'DID_IsSystemHealthSessionRunning' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_IsSystemHealthSessionRunning as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_IsSystemHealthSessionRunning as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_IsResourceGovernorEnabled) Or @ChangeType = 'D' THEN
							(SELECT 'DID_IsResourceGovernorEnabled' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_IsResourceGovernorEnabled as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_IsResourceGovernorEnabled as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_LogonTriggerCount) Or @ChangeType = 'D' THEN
							(SELECT 'DID_LogonTriggerCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_LogonTriggerCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_LogonTriggerCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DID_NumberOfAvailableSchedulers) Or @ChangeType = 'D' THEN
							(SELECT 'DID_NumberOfAvailableSchedulers' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DID_NumberOfAvailableSchedulers as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DID_NumberOfAvailableSchedulers as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.DID_ID = D.DID_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.DatabaseInstanceDetails' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[DatabaseInstanceDetails] DISABLE TRIGGER [trg_DatabaseInstanceDetails_HistoryLogging]
GO
