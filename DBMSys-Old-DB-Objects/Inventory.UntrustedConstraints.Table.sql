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
/****** Object:  Table [Inventory].[UntrustedConstraints]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[UntrustedConstraints](
	[UTC_ID] [int] IDENTITY(1,1) NOT NULL,
	[UTC_ClientID] [int] NOT NULL,
	[UTC_MOB_ID] [int] NOT NULL,
	[UTC_IDB_ID] [int] NOT NULL,
	[UTC_DSN_ID] [int] NOT NULL,
	[UTC_Table_DON_ID] [int] NOT NULL,
	[UTC_Constraint_DOT_ID] [tinyint] NOT NULL,
	[UTC_Constraint_DON_ID] [int] NOT NULL,
	[UTC_InsertDate] [datetime2](3) NOT NULL,
	[UTC_LastSeenDate] [datetime2](3) NOT NULL,
	[UTC_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_UntrustedConstraints] PRIMARY KEY CLUSTERED 
(
	[UTC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_UntrustedConstraints_UTC_MOB_ID#UTC_IDB_ID#UTC_DSN_ID#UTC_Table_DON_ID#UTC_Constraint_DON_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_UntrustedConstraints_UTC_MOB_ID#UTC_IDB_ID#UTC_DSN_ID#UTC_Table_DON_ID#UTC_Constraint_DON_ID] ON [Inventory].[UntrustedConstraints]
(
	[UTC_MOB_ID] ASC,
	[UTC_IDB_ID] ASC,
	[UTC_DSN_ID] ASC,
	[UTC_Table_DON_ID] ASC,
	[UTC_Constraint_DON_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_UntrustedConstraints_HistoryLogging]    Script Date: 6/8/2020 1:15:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_UntrustedConstraints_HistoryLogging] ON [Inventory].[UntrustedConstraints]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.UntrustedConstraints' TabName, UTC_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.UTC_ID, 
					(SELECT CASE WHEN UPDATE(UTC_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'UTC_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.UTC_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.UTC_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(UTC_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'UTC_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.UTC_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.UTC_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(UTC_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'UTC_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.UTC_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.UTC_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(UTC_DSN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'UTC_DSN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.UTC_DSN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.UTC_DSN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(UTC_Table_DON_ID) Or @ChangeType = 'D' THEN
							(SELECT 'UTC_Table_DON_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.UTC_Table_DON_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.UTC_Table_DON_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(UTC_Constraint_DOT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'UTC_Constraint_DOT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.UTC_Constraint_DOT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.UTC_Constraint_DOT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(UTC_Constraint_DON_ID) Or @ChangeType = 'D' THEN
							(SELECT 'UTC_Constraint_DON_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.UTC_Constraint_DON_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.UTC_Constraint_DON_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.UTC_ID = D.UTC_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.UntrustedConstraints' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[UntrustedConstraints] DISABLE TRIGGER [trg_UntrustedConstraints_HistoryLogging]
GO
