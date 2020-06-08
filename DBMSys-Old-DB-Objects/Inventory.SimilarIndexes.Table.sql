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
/****** Object:  Table [Inventory].[SimilarIndexes]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[SimilarIndexes](
	[SIX_ID] [int] IDENTITY(1,1) NOT NULL,
	[SIX_ClientID] [int] NOT NULL,
	[SIX_MOB_ID] [int] NOT NULL,
	[SIX_IDB_ID] [int] NOT NULL,
	[SIX_DSN_ID] [int] NOT NULL,
	[SIX_DON_ID] [int] NOT NULL,
	[SIX_IndexID] [int] NOT NULL,
	[SIX_IDT_ID] [int] NOT NULL,
	[SIX_DIN_ID] [int] NOT NULL,
	[SIX_IndexColumns] [nvarchar](max) NOT NULL,
	[SIX_IncludedColumns] [nvarchar](max) NULL,
	[SIX_IndexFilter] [nvarchar](max) NULL,
	[SIX_SimilarIndexID] [int] NOT NULL,
	[SIX_Similar_IDT_ID] [int] NOT NULL,
	[SIX_Similar_DIN_ID] [int] NOT NULL,
	[SIX_SimilarIndexColumns] [nvarchar](max) NOT NULL,
	[SIX_SimilarIndexIncludedColumns] [nvarchar](max) NULL,
	[SIX_InsertDate] [datetime2](3) NOT NULL,
	[SIX_LastSeenDate] [datetime2](3) NOT NULL,
	[SIX_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_SimilarIndexes] PRIMARY KEY CLUSTERED 
(
	[SIX_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_SimilarIndexes_SIX_MOB_ID#SIX_IDB_ID#SIX_DSN_ID#SIX_DON_ID#SIX_DIN_ID#SIX_Similar_DIN_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_SimilarIndexes_SIX_MOB_ID#SIX_IDB_ID#SIX_DSN_ID#SIX_DON_ID#SIX_DIN_ID#SIX_Similar_DIN_ID] ON [Inventory].[SimilarIndexes]
(
	[SIX_MOB_ID] ASC,
	[SIX_IDB_ID] ASC,
	[SIX_DSN_ID] ASC,
	[SIX_DON_ID] ASC,
	[SIX_DIN_ID] ASC,
	[SIX_Similar_DIN_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_SimilarIndexes_HistoryLogging]    Script Date: 6/8/2020 1:15:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_SimilarIndexes_HistoryLogging] ON [Inventory].[SimilarIndexes]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.SimilarIndexes' TabName, SIX_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.SIX_ID, 
					(SELECT CASE WHEN UPDATE(SIX_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'SIX_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SIX_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SIX_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SIX_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'SIX_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SIX_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SIX_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SIX_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'SIX_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SIX_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SIX_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SIX_DSN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'SIX_DSN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SIX_DSN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SIX_DSN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SIX_DON_ID) Or @ChangeType = 'D' THEN
							(SELECT 'SIX_DON_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SIX_DON_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SIX_DON_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SIX_IndexID) Or @ChangeType = 'D' THEN
							(SELECT 'SIX_IndexID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SIX_IndexID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SIX_IndexID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SIX_IDT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'SIX_IDT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SIX_IDT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SIX_IDT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SIX_DIN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'SIX_DIN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SIX_DIN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SIX_DIN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SIX_SimilarIndexID) Or @ChangeType = 'D' THEN
							(SELECT 'SIX_SimilarIndexID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SIX_SimilarIndexID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SIX_SimilarIndexID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SIX_Similar_IDT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'SIX_Similar_IDT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SIX_Similar_IDT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SIX_Similar_IDT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SIX_Similar_DIN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'SIX_Similar_DIN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SIX_Similar_DIN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SIX_Similar_DIN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.SIX_ID = D.SIX_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.SimilarIndexes' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[SimilarIndexes] DISABLE TRIGGER [trg_SimilarIndexes_HistoryLogging]
GO
