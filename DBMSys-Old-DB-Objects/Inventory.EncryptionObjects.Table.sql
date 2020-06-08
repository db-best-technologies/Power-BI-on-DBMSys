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
/****** Object:  Table [Inventory].[EncryptionObjects]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[EncryptionObjects](
	[ENO_ID] [int] IDENTITY(1,1) NOT NULL,
	[ENO_ClientID] [int] NOT NULL,
	[ENO_MOB_ID] [int] NOT NULL,
	[ENO_IDB_ID] [int] NOT NULL,
	[ENO_EOT_ID] [tinyint] NOT NULL,
	[ENO_Name] [nvarchar](128) NOT NULL,
	[ENO_KeyLength] [int] NULL,
	[ENO_ENA_ID] [tinyint] NULL,
	[ENO_EPY_ID] [tinyint] NULL,
	[ENO_ProviderAlgorithmID] [nvarchar](1000) NULL,
	[ENO_EncryptionType_EOT_ID] [tinyint] NULL,
	[ENO_IsUsedForSigningModules] [bit] NULL,
	[ENO_IsActiveForBeginDialog] [bit] NULL,
	[ENO_CertificateSubject] [nvarchar](4000) NULL,
	[ENO_CertificateStartDate] [datetime2](3) NULL,
	[ENO_CertificateExpiryDate] [datetime2](3) NULL,
	[ENO_CertificatePrivateKeyLastBackupDate] [datetime2](3) NULL,
	[ENO_InsertDate] [datetime2](3) NOT NULL,
	[ENO_LastSeenDate] [datetime2](3) NOT NULL,
	[ENO_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_EncryptionObjects] PRIMARY KEY CLUSTERED 
(
	[ENO_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_EncryptionObjects_ENO_MOB_ID#ENO_IDB_ID#ENO_EOT_ID#ENO_Name]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_EncryptionObjects_ENO_MOB_ID#ENO_IDB_ID#ENO_EOT_ID#ENO_Name] ON [Inventory].[EncryptionObjects]
(
	[ENO_MOB_ID] ASC,
	[ENO_IDB_ID] ASC,
	[ENO_EOT_ID] ASC,
	[ENO_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_EncryptionObjects_HistoryLogging]    Script Date: 6/8/2020 1:15:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_EncryptionObjects_HistoryLogging] ON [Inventory].[EncryptionObjects]
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
	INSERT INTO Inventory.History(HIS_Type, HIS_Datetime, HIS_TableName, HIS_PK_1, 	HIS_Changes, HIS_UserName, HIS_AppName, HIS_HostName)
	SELECT *
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.EncryptionObjects' TabName, ENO_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.ENO_ID, 
					(SELECT CASE WHEN UPDATE(ENO_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'ENO_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ENO_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ENO_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ENO_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ENO_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ENO_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ENO_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ENO_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ENO_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ENO_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ENO_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ENO_EOT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ENO_EOT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ENO_EOT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ENO_EOT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ENO_Name) Or @ChangeType = 'D' THEN
							(SELECT 'ENO_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ENO_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ENO_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ENO_KeyLength) Or @ChangeType = 'D' THEN
							(SELECT 'ENO_KeyLength' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ENO_KeyLength as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ENO_KeyLength as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ENO_ENA_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ENO_ENA_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ENO_ENA_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ENO_ENA_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ENO_EPY_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ENO_EPY_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ENO_EPY_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ENO_EPY_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ENO_ProviderAlgorithmID) Or @ChangeType = 'D' THEN
							(SELECT 'ENO_ProviderAlgorithmID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ENO_ProviderAlgorithmID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ENO_ProviderAlgorithmID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ENO_EncryptionType_EOT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ENO_EncryptionType_EOT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ENO_EncryptionType_EOT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ENO_EncryptionType_EOT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ENO_IsUsedForSigningModules) Or @ChangeType = 'D' THEN
							(SELECT 'ENO_IsUsedForSigningModules' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ENO_IsUsedForSigningModules as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ENO_IsUsedForSigningModules as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ENO_IsActiveForBeginDialog) Or @ChangeType = 'D' THEN
							(SELECT 'ENO_IsActiveForBeginDialog' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ENO_IsActiveForBeginDialog as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ENO_IsActiveForBeginDialog as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ENO_CertificateSubject) Or @ChangeType = 'D' THEN
							(SELECT 'ENO_CertificateSubject' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ENO_CertificateSubject as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ENO_CertificateSubject as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ENO_CertificateStartDate) Or @ChangeType = 'D' THEN
							(SELECT 'ENO_CertificateStartDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ENO_CertificateStartDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ENO_CertificateStartDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ENO_CertificateExpiryDate) Or @ChangeType = 'D' THEN
							(SELECT 'ENO_CertificateExpiryDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ENO_CertificateExpiryDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ENO_CertificateExpiryDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ENO_CertificatePrivateKeyLastBackupDate) Or @ChangeType = 'D' THEN
							(SELECT 'ENO_CertificatePrivateKeyLastBackupDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ENO_CertificatePrivateKeyLastBackupDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ENO_CertificatePrivateKeyLastBackupDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.ENO_ID = D.ENO_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.EncryptionObjects' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[EncryptionObjects] DISABLE TRIGGER [trg_EncryptionObjects_HistoryLogging]
GO
