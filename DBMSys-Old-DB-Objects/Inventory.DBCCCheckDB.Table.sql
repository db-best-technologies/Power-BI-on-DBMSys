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
/****** Object:  Table [Inventory].[DBCCCheckDB]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[DBCCCheckDB](
	[DCD_ID] [int] IDENTITY(1,1) NOT NULL,
	[DCD_ClientID] [int] NOT NULL,
	[DCD_MOB_ID] [int] NOT NULL,
	[DCD_IDB_ID] [int] NOT NULL,
	[DCD_DOT_ID] [int] NULL,
	[DCD_DSN_ID] [int] NULL,
	[DCD_DON_ID] [int] NULL,
	[DCD_DBF_ID] [int] NULL,
	[DCD_ErrorNumber] [int] NOT NULL,
	[DCD_ErrorLevel] [int] NOT NULL,
	[DCD_RepairLevel] [varchar](200) NOT NULL,
	[DCD_AffectedPagesCount] [bigint] NULL,
	[DCD_ErrorCount] [bigint] NOT NULL,
	[DCD_ExampleMessage] [varchar](7000) NOT NULL,
	[DCD_InsertDate] [datetime2](3) NOT NULL,
	[DCD_LastSeenDate] [datetime2](3) NOT NULL,
	[DCD_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_DBCCCheckDB] PRIMARY KEY CLUSTERED 
(
	[DCD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_DBCCCheckDB_DCD_MOB_ID#DCD_IDB_ID#DCD_DSN_ID#DCD_DON_ID#DCD_DBF_ID#DCD_ErrorNumber#DCD_RepairLevel]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_DBCCCheckDB_DCD_MOB_ID#DCD_IDB_ID#DCD_DSN_ID#DCD_DON_ID#DCD_DBF_ID#DCD_ErrorNumber#DCD_RepairLevel] ON [Inventory].[DBCCCheckDB]
(
	[DCD_MOB_ID] ASC,
	[DCD_IDB_ID] ASC,
	[DCD_DSN_ID] ASC,
	[DCD_DON_ID] ASC,
	[DCD_DBF_ID] ASC,
	[DCD_ErrorNumber] ASC,
	[DCD_RepairLevel] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_DBCCCheckDB_HistoryLogging]    Script Date: 6/8/2020 1:15:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_DBCCCheckDB_HistoryLogging] ON [Inventory].[DBCCCheckDB]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.DBCCCheckDB' TabName, C_MOB_ID, DCD_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.DCD_MOB_ID C_MOB_ID, D.DCD_ID, 
					(SELECT CASE WHEN UPDATE(DCD_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'DCD_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DCD_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DCD_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DCD_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DCD_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DCD_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DCD_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DCD_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DCD_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DCD_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DCD_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DCD_DOT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DCD_DOT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DCD_DOT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DCD_DOT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DCD_DSN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DCD_DSN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DCD_DSN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DCD_DSN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DCD_DON_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DCD_DON_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DCD_DON_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DCD_DON_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DCD_DBF_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DCD_DBF_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DCD_DBF_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DCD_DBF_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DCD_ErrorNumber) Or @ChangeType = 'D' THEN
							(SELECT 'DCD_ErrorNumber' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DCD_ErrorNumber as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DCD_ErrorNumber as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DCD_ErrorLevel) Or @ChangeType = 'D' THEN
							(SELECT 'DCD_ErrorLevel' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DCD_ErrorLevel as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DCD_ErrorLevel as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DCD_RepairLevel) Or @ChangeType = 'D' THEN
							(SELECT 'DCD_RepairLevel' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DCD_RepairLevel as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DCD_RepairLevel as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DCD_AffectedPagesCount) Or @ChangeType = 'D' THEN
							(SELECT 'DCD_AffectedPagesCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DCD_AffectedPagesCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DCD_AffectedPagesCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DCD_ErrorCount) Or @ChangeType = 'D' THEN
							(SELECT 'DCD_ErrorCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DCD_ErrorCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DCD_ErrorCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DCD_ExampleMessage) Or @ChangeType = 'D' THEN
							(SELECT 'DCD_ExampleMessage' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DCD_ExampleMessage as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DCD_ExampleMessage as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.DCD_ID = D.DCD_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.DBCCCheckDB' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[DBCCCheckDB] DISABLE TRIGGER [trg_DBCCCheckDB_HistoryLogging]
GO
