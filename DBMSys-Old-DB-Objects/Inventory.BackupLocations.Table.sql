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
/****** Object:  Table [Inventory].[BackupLocations]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[BackupLocations](
	[BKL_ID] [int] IDENTITY(1,1) NOT NULL,
	[BKL_ClientID] [int] NOT NULL,
	[BKL_MOB_ID] [int] NOT NULL,
	[BKL_IDB_ID] [int] NOT NULL,
	[BKL_DSK_ID] [int] NOT NULL,
	[BKL_Path] [varchar](256) NOT NULL,
	[BKL_LastUsed] [datetime2](3) NOT NULL,
 CONSTRAINT [PK_BackupLocations] PRIMARY KEY CLUSTERED 
(
	[BKL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_BackupLocations_BKL_MOB_ID#BKL_IDB_ID#BKL_Path]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_BackupLocations_BKL_MOB_ID#BKL_IDB_ID#BKL_Path] ON [Inventory].[BackupLocations]
(
	[BKL_MOB_ID] ASC,
	[BKL_IDB_ID] ASC,
	[BKL_Path] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_BackupLocations_HistoryLogging]    Script Date: 6/8/2020 1:15:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_BackupLocations_HistoryLogging] ON [Inventory].[BackupLocations]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.BackupLocations' TabName, C_MOB_ID, BKL_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.BKL_MOB_ID C_MOB_ID, D.BKL_ID, 
					(SELECT CASE WHEN UPDATE(BKL_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'BKL_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.BKL_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.BKL_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(BKL_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'BKL_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.BKL_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.BKL_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(BKL_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'BKL_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.BKL_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.BKL_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(BKL_DSK_ID) Or @ChangeType = 'D' THEN
							(SELECT 'BKL_DSK_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.BKL_DSK_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.BKL_DSK_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(BKL_Path) Or @ChangeType = 'D' THEN
							(SELECT 'BKL_Path' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.BKL_Path as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.BKL_Path as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.BKL_ID = D.BKL_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.BackupLocations' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[BackupLocations] DISABLE TRIGGER [trg_BackupLocations_HistoryLogging]
GO
