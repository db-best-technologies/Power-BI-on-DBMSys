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
/****** Object:  Table [Inventory].[EncryptionHierarchy]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[EncryptionHierarchy](
	[ENH_ID] [int] IDENTITY(1,1) NOT NULL,
	[ENH_ClientID] [int] NOT NULL,
	[ENH_MOB_ID] [int] NOT NULL,
	[ENH_IDB_ID] [int] NOT NULL,
	[ENH_Encrypted_ENO_ID] [int] NOT NULL,
	[ENH_EncryptionBy_EOT_ID] [tinyint] NOT NULL,
	[ENH_Encypting_ENO_ID] [int] NULL,
	[ENH_EncryptionsByObject] [int] NOT NULL,
	[ENH_InsertDate] [datetime2](3) NOT NULL,
	[ENH_LastSeenDate] [datetime2](3) NOT NULL,
	[ENH_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_EncryptionHierarchy] PRIMARY KEY CLUSTERED 
(
	[ENH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_EncryptionHierarchy_ENH_MOB_ID#ENH_IDB_ID#ENH_Encrypted_ENO_ID#ENH_EncryptionBy_EOT_ID#ENH_Encypting_ENO_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_EncryptionHierarchy_ENH_MOB_ID#ENH_IDB_ID#ENH_Encrypted_ENO_ID#ENH_EncryptionBy_EOT_ID#ENH_Encypting_ENO_ID] ON [Inventory].[EncryptionHierarchy]
(
	[ENH_MOB_ID] ASC,
	[ENH_IDB_ID] ASC,
	[ENH_Encrypted_ENO_ID] ASC,
	[ENH_EncryptionBy_EOT_ID] ASC,
	[ENH_Encypting_ENO_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_EncryptionHierarchy_HistoryLogging]    Script Date: 6/8/2020 1:15:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_EncryptionHierarchy_HistoryLogging] ON [Inventory].[EncryptionHierarchy]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.EncryptionHierarchy' TabName, ENH_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.ENH_ID, 
					(SELECT CASE WHEN UPDATE(ENH_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'ENH_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ENH_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ENH_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ENH_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ENH_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ENH_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ENH_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ENH_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ENH_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ENH_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ENH_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ENH_Encrypted_ENO_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ENH_Encrypted_ENO_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ENH_Encrypted_ENO_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ENH_Encrypted_ENO_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ENH_EncryptionBy_EOT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ENH_EncryptionBy_EOT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ENH_EncryptionBy_EOT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ENH_EncryptionBy_EOT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ENH_Encypting_ENO_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ENH_Encypting_ENO_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ENH_Encypting_ENO_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ENH_Encypting_ENO_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ENH_EncryptionsByObject) Or @ChangeType = 'D' THEN
							(SELECT 'ENH_EncryptionsByObject' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ENH_EncryptionsByObject as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ENH_EncryptionsByObject as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.ENH_ID = D.ENH_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.EncryptionHierarchy' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[EncryptionHierarchy] DISABLE TRIGGER [trg_EncryptionHierarchy_HistoryLogging]
GO
