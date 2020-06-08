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
/****** Object:  Table [Inventory].[FragmentedIndexes]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[FragmentedIndexes](
	[FRI_ID] [int] IDENTITY(1,1) NOT NULL,
	[FRI_ClientID] [int] NOT NULL,
	[FRI_MOB_ID] [int] NOT NULL,
	[FRI_IDB_ID] [int] NOT NULL,
	[FRI_DOT_ID] [int] NOT NULL,
	[FRI_DSN_ID] [int] NOT NULL,
	[FRI_DON_ID] [int] NOT NULL,
	[FRI_IndexID] [int] NOT NULL,
	[FRI_IDT_ID] [tinyint] NOT NULL,
	[FRI_DIN_ID] [int] NOT NULL,
	[FRI_PartitionNumber] [int] NOT NULL,
	[FRI_AUT_ID] [tinyint] NOT NULL,
	[FRI_IndexDepth] [tinyint] NOT NULL,
	[FRI_AvgFragmentationInPercent] [decimal](6, 4) NOT NULL,
	[FRI_AvgPageSpaceUsedInPercent] [decimal](6, 4) NOT NULL,
	[FRI_GhostRecordCount] [bigint] NULL,
	[FRI_MinRecordSizeInBytes] [int] NULL,
	[FRI_MaxRecordSizeInBytes] [int] NULL,
	[FRI_AvgRecordSizeInBytes] [decimal](7, 2) NULL,
	[FRI_ForwardedRecordCount] [bigint] NULL,
	[FRI_CompressedPageCount] [bigint] NULL,
	[FRI_NumberOfRows] [bigint] NOT NULL,
	[FRI_SizeMB] [bigint] NOT NULL,
	[FRI_FillFactor] [tinyint] NOT NULL,
	[FRI_InsertDate] [datetime2](3) NOT NULL,
	[FRI_LastSeenDate] [datetime2](3) NOT NULL,
	[FRI_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_FragmentedIndexes] PRIMARY KEY CLUSTERED 
(
	[FRI_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_FragmentedIndexes_FRI_MOB_ID#FRI_IDB_ID#FRI_DSN_ID#FRI_DON_ID#FRI_DIN_ID#FRI_PartitionNumber#FRI_AUT_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_FragmentedIndexes_FRI_MOB_ID#FRI_IDB_ID#FRI_DSN_ID#FRI_DON_ID#FRI_DIN_ID#FRI_PartitionNumber#FRI_AUT_ID] ON [Inventory].[FragmentedIndexes]
(
	[FRI_MOB_ID] ASC,
	[FRI_IDB_ID] ASC,
	[FRI_DSN_ID] ASC,
	[FRI_DON_ID] ASC,
	[FRI_DIN_ID] ASC,
	[FRI_PartitionNumber] ASC,
	[FRI_AUT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_FragmentedIndexes_HistoryLogging]    Script Date: 6/8/2020 1:15:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_FragmentedIndexes_HistoryLogging] ON [Inventory].[FragmentedIndexes]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.FragmentedIndexes' TabName, FRI_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.FRI_ID, 
					(SELECT CASE WHEN UPDATE(FRI_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'FRI_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FRI_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FRI_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FRI_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'FRI_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FRI_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FRI_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FRI_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'FRI_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FRI_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FRI_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FRI_DOT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'FRI_DOT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FRI_DOT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FRI_DOT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FRI_DSN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'FRI_DSN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FRI_DSN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FRI_DSN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FRI_DON_ID) Or @ChangeType = 'D' THEN
							(SELECT 'FRI_DON_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FRI_DON_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FRI_DON_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FRI_IndexID) Or @ChangeType = 'D' THEN
							(SELECT 'FRI_IndexID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FRI_IndexID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FRI_IndexID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FRI_IDT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'FRI_IDT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FRI_IDT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FRI_IDT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FRI_DIN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'FRI_DIN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FRI_DIN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FRI_DIN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FRI_PartitionNumber) Or @ChangeType = 'D' THEN
							(SELECT 'FRI_PartitionNumber' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FRI_PartitionNumber as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FRI_PartitionNumber as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FRI_AUT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'FRI_AUT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FRI_AUT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FRI_AUT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FRI_IndexDepth) Or @ChangeType = 'D' THEN
							(SELECT 'FRI_IndexDepth' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FRI_IndexDepth as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FRI_IndexDepth as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FRI_AvgFragmentationInPercent) Or @ChangeType = 'D' THEN
							(SELECT 'FRI_AvgFragmentationInPercent' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FRI_AvgFragmentationInPercent as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FRI_AvgFragmentationInPercent as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FRI_AvgPageSpaceUsedInPercent) Or @ChangeType = 'D' THEN
							(SELECT 'FRI_AvgPageSpaceUsedInPercent' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FRI_AvgPageSpaceUsedInPercent as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FRI_AvgPageSpaceUsedInPercent as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FRI_GhostRecordCount) Or @ChangeType = 'D' THEN
							(SELECT 'FRI_GhostRecordCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FRI_GhostRecordCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FRI_GhostRecordCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FRI_MinRecordSizeInBytes) Or @ChangeType = 'D' THEN
							(SELECT 'FRI_MinRecordSizeInBytes' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FRI_MinRecordSizeInBytes as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FRI_MinRecordSizeInBytes as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FRI_MaxRecordSizeInBytes) Or @ChangeType = 'D' THEN
							(SELECT 'FRI_MaxRecordSizeInBytes' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FRI_MaxRecordSizeInBytes as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FRI_MaxRecordSizeInBytes as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FRI_AvgRecordSizeInBytes) Or @ChangeType = 'D' THEN
							(SELECT 'FRI_AvgRecordSizeInBytes' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FRI_AvgRecordSizeInBytes as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FRI_AvgRecordSizeInBytes as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FRI_ForwardedRecordCount) Or @ChangeType = 'D' THEN
							(SELECT 'FRI_ForwardedRecordCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FRI_ForwardedRecordCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FRI_ForwardedRecordCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FRI_CompressedPageCount) Or @ChangeType = 'D' THEN
							(SELECT 'FRI_CompressedPageCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FRI_CompressedPageCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FRI_CompressedPageCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FRI_NumberOfRows) Or @ChangeType = 'D' THEN
							(SELECT 'FRI_NumberOfRows' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FRI_NumberOfRows as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FRI_NumberOfRows as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FRI_SizeMB) Or @ChangeType = 'D' THEN
							(SELECT 'FRI_SizeMB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FRI_SizeMB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FRI_SizeMB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FRI_FillFactor) Or @ChangeType = 'D' THEN
							(SELECT 'FRI_FillFactor' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FRI_FillFactor as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FRI_FillFactor as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.FRI_ID = D.FRI_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.FragmentedIndexes' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[FragmentedIndexes] DISABLE TRIGGER [trg_FragmentedIndexes_HistoryLogging]
GO
