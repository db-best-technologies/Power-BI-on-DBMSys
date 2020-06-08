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
/****** Object:  Table [Inventory].[PossibleTableProblems]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[PossibleTableProblems](
	[PTP_ID] [int] IDENTITY(1,1) NOT NULL,
	[PTP_ClientID] [int] NOT NULL,
	[PTP_MOB_ID] [int] NOT NULL,
	[PTP_IDB_ID] [int] NOT NULL,
	[PTP_DSN_ID] [int] NOT NULL,
	[PTP_DON_ID] [int] NOT NULL,
	[PTP_HasClusteredIndex] [bit] NOT NULL,
	[PTP_HasPrimaryKey] [bit] NOT NULL,
	[PTP_IsVarDecimalStorage] [bit] NULL,
	[PTP_ColumnCount] [int] NOT NULL,
	[PTP_IndexCount] [int] NOT NULL,
	[PTP_RowCount] [bigint] NOT NULL,
	[PTP_TotalSizeMB] [bigint] NOT NULL,
	[PTP_RangeScanCount] [bigint] NULL,
	[PTP_RowLockWaitCount] [bigint] NULL,
	[PTP_RowLockWaitInMS] [bigint] NULL,
	[PTP_PageLockWaitCount] [bigint] NULL,
	[PTP_PageLockWaitInMS] [bigint] NULL,
	[PTP_IndexLockPromotionAttemptCount] [bigint] NULL,
	[PTP_IndexLockPromotionCount] [bigint] NULL,
	[PTP_PercentOfClusteredIndexOrHeapPartitionsCompressed] [tinyint] NULL,
	[PTP_PercentOfNonClusteredIndexPartitionsCompressed] [tinyint] NULL,
	[PTP_InsertDate] [datetime2](3) NOT NULL,
	[PTP_LastSeenDate] [datetime2](3) NOT NULL,
	[PTP_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_PossibleTableProblems] PRIMARY KEY CLUSTERED 
(
	[PTP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_PossibleTableProblems_PTP_MOB_ID#PTP_IDB_ID#PTP_DSN_ID#PTP_DON_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_PossibleTableProblems_PTP_MOB_ID#PTP_IDB_ID#PTP_DSN_ID#PTP_DON_ID] ON [Inventory].[PossibleTableProblems]
(
	[PTP_MOB_ID] ASC,
	[PTP_IDB_ID] ASC,
	[PTP_DSN_ID] ASC,
	[PTP_DON_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_PossibleTableProblems_HistoryLogging]    Script Date: 6/8/2020 1:15:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_PossibleTableProblems_HistoryLogging] ON [Inventory].[PossibleTableProblems]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.PossibleTableProblems' TabName, PTP_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.PTP_ID, 
					(SELECT CASE WHEN UPDATE(PTP_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'PTP_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PTP_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PTP_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PTP_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PTP_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PTP_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PTP_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PTP_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PTP_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PTP_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PTP_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PTP_DSN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PTP_DSN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PTP_DSN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PTP_DSN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PTP_DON_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PTP_DON_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PTP_DON_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PTP_DON_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PTP_HasClusteredIndex) Or @ChangeType = 'D' THEN
							(SELECT 'PTP_HasClusteredIndex' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PTP_HasClusteredIndex as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PTP_HasClusteredIndex as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PTP_HasPrimaryKey) Or @ChangeType = 'D' THEN
							(SELECT 'PTP_HasPrimaryKey' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PTP_HasPrimaryKey as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PTP_HasPrimaryKey as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PTP_IsVarDecimalStorage) Or @ChangeType = 'D' THEN
							(SELECT 'PTP_IsVarDecimalStorage' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PTP_IsVarDecimalStorage as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PTP_IsVarDecimalStorage as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PTP_ColumnCount) Or @ChangeType = 'D' THEN
							(SELECT 'PTP_ColumnCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PTP_ColumnCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PTP_ColumnCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PTP_IndexCount) Or @ChangeType = 'D' THEN
							(SELECT 'PTP_IndexCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PTP_IndexCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PTP_IndexCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PTP_RowCount) Or @ChangeType = 'D' THEN
							(SELECT 'PTP_RowCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PTP_RowCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PTP_RowCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PTP_TotalSizeMB) Or @ChangeType = 'D' THEN
							(SELECT 'PTP_TotalSizeMB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PTP_TotalSizeMB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PTP_TotalSizeMB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PTP_RangeScanCount) Or @ChangeType = 'D' THEN
							(SELECT 'PTP_RangeScanCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PTP_RangeScanCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PTP_RangeScanCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PTP_RowLockWaitCount) Or @ChangeType = 'D' THEN
							(SELECT 'PTP_RowLockWaitCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PTP_RowLockWaitCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PTP_RowLockWaitCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PTP_RowLockWaitInMS) Or @ChangeType = 'D' THEN
							(SELECT 'PTP_RowLockWaitInMS' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PTP_RowLockWaitInMS as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PTP_RowLockWaitInMS as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PTP_PageLockWaitCount) Or @ChangeType = 'D' THEN
							(SELECT 'PTP_PageLockWaitCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PTP_PageLockWaitCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PTP_PageLockWaitCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PTP_PageLockWaitInMS) Or @ChangeType = 'D' THEN
							(SELECT 'PTP_PageLockWaitInMS' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PTP_PageLockWaitInMS as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PTP_PageLockWaitInMS as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PTP_IndexLockPromotionAttemptCount) Or @ChangeType = 'D' THEN
							(SELECT 'PTP_IndexLockPromotionAttemptCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PTP_IndexLockPromotionAttemptCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PTP_IndexLockPromotionAttemptCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PTP_IndexLockPromotionCount) Or @ChangeType = 'D' THEN
							(SELECT 'PTP_IndexLockPromotionCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PTP_IndexLockPromotionCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PTP_IndexLockPromotionCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PTP_PercentOfClusteredIndexOrHeapPartitionsCompressed) Or @ChangeType = 'D' THEN
							(SELECT 'PTP_PercentOfClusteredIndexOrHeapPartitionsCompressed' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PTP_PercentOfClusteredIndexOrHeapPartitionsCompressed as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PTP_PercentOfClusteredIndexOrHeapPartitionsCompressed as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PTP_PercentOfNonClusteredIndexPartitionsCompressed) Or @ChangeType = 'D' THEN
							(SELECT 'PTP_PercentOfNonClusteredIndexPartitionsCompressed' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PTP_PercentOfNonClusteredIndexPartitionsCompressed as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PTP_PercentOfNonClusteredIndexPartitionsCompressed as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.PTP_ID = D.PTP_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.PossibleTableProblems' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[PossibleTableProblems] DISABLE TRIGGER [trg_PossibleTableProblems_HistoryLogging]
GO
