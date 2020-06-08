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
/****** Object:  Table [Inventory].[PossibleIndexProblems]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[PossibleIndexProblems](
	[PIP_ID] [int] IDENTITY(1,1) NOT NULL,
	[PIP_ClientID] [int] NOT NULL,
	[PIP_MOB_ID] [int] NOT NULL,
	[PIP_IDB_ID] [int] NOT NULL,
	[PIP_DOT_ID] [tinyint] NOT NULL,
	[PIP_DSN_ID] [int] NOT NULL,
	[PIP_DON_ID] [int] NOT NULL,
	[PIP_IndexID] [int] NOT NULL,
	[PIP_IDT_ID] [tinyint] NOT NULL,
	[PIP_DIN_ID] [int] NOT NULL,
	[PIP_IndexColumns] [nvarchar](max) NULL,
	[PIP_IncludedColumns] [nvarchar](max) NULL,
	[PIP_Filter] [nvarchar](max) NULL,
	[PIP_IsPrimaryKey] [bit] NOT NULL,
	[PIP_IsUniqueConstraint] [bit] NOT NULL,
	[PIP_IsHypothetical] [bit] NOT NULL,
	[PIP_IsDisabled] [bit] NOT NULL,
	[PIP_NoRecompute] [bit] NOT NULL,
	[PIP_FillFactor] [tinyint] NOT NULL,
	[PIP_AllowPageLocks] [bit] NOT NULL,
	[PIP_AllowRowLocks] [bit] NOT NULL,
	[PIP_IsNotAligned] [bit] NOT NULL,
	[PIP_IsUnused] [tinyint] NOT NULL,
	[PIP_AvgSeeksPerDay] [bigint] NULL,
	[PIP_AvgScansPerDay] [bigint] NULL,
	[PIP_AvgLookupsPerDay] [bigint] NULL,
	[PIP_LastUserSeek] [datetime] NULL,
	[PIP_LastUserScan] [datetime] NULL,
	[PIP_LastUserLookup] [datetime] NULL,
	[PIP_RowCnt] [bigint] NOT NULL,
	[PIP_SizeMB] [bigint] NOT NULL,
	[PIP_PercentCompressed] [tinyint] NULL,
	[PIP_MaxRowSizeBytes] [int] NULL,
	[PIP_InsertDate] [datetime2](3) NOT NULL,
	[PIP_LastSeenDate] [datetime2](3) NOT NULL,
	[PIP_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_PossibleIndexProblems] PRIMARY KEY CLUSTERED 
(
	[PIP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_PossibleIndexProblems_PIP_MOB_ID#PIP_IDB_ID#PIP_DSN_ID#PIP_DON_ID#PIP_DIN_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_PossibleIndexProblems_PIP_MOB_ID#PIP_IDB_ID#PIP_DSN_ID#PIP_DON_ID#PIP_DIN_ID] ON [Inventory].[PossibleIndexProblems]
(
	[PIP_MOB_ID] ASC,
	[PIP_IDB_ID] ASC,
	[PIP_DSN_ID] ASC,
	[PIP_DON_ID] ASC,
	[PIP_DIN_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_PossibleIndexProblems_HistoryLogging]    Script Date: 6/8/2020 1:15:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_PossibleIndexProblems_HistoryLogging] ON [Inventory].[PossibleIndexProblems]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.PossibleIndexProblems' TabName, PIP_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.PIP_ID, 
					(SELECT CASE WHEN UPDATE(PIP_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_DOT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_DOT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_DOT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_DOT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_DSN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_DSN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_DSN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_DSN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_DON_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_DON_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_DON_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_DON_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_IndexID) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_IndexID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_IndexID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_IndexID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_IDT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_IDT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_IDT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_IDT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_DIN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_DIN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_DIN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_DIN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_IsPrimaryKey) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_IsPrimaryKey' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_IsPrimaryKey as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_IsPrimaryKey as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_IsUniqueConstraint) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_IsUniqueConstraint' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_IsUniqueConstraint as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_IsUniqueConstraint as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_IsHypothetical) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_IsHypothetical' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_IsHypothetical as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_IsHypothetical as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_IsDisabled) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_IsDisabled' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_IsDisabled as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_IsDisabled as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_NoRecompute) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_NoRecompute' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_NoRecompute as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_NoRecompute as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_FillFactor) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_FillFactor' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_FillFactor as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_FillFactor as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_AllowPageLocks) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_AllowPageLocks' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_AllowPageLocks as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_AllowPageLocks as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_AllowRowLocks) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_AllowRowLocks' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_AllowRowLocks as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_AllowRowLocks as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_IsNotAligned) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_IsNotAligned' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_IsNotAligned as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_IsNotAligned as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_IsUnused) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_IsUnused' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_IsUnused as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_IsUnused as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_AvgSeeksPerDay) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_AvgSeeksPerDay' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_AvgSeeksPerDay as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_AvgSeeksPerDay as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_AvgScansPerDay) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_AvgScansPerDay' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_AvgScansPerDay as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_AvgScansPerDay as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_AvgLookupsPerDay) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_AvgLookupsPerDay' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_AvgLookupsPerDay as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_AvgLookupsPerDay as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_LastUserSeek) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_LastUserSeek' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_LastUserSeek as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_LastUserSeek as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_LastUserScan) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_LastUserScan' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_LastUserScan as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_LastUserScan as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_LastUserLookup) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_LastUserLookup' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_LastUserLookup as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_LastUserLookup as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_RowCnt) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_RowCnt' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_RowCnt as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_RowCnt as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_SizeMB) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_SizeMB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_SizeMB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_SizeMB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_PercentCompressed) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_PercentCompressed' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_PercentCompressed as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_PercentCompressed as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PIP_MaxRowSizeBytes) Or @ChangeType = 'D' THEN
							(SELECT 'PIP_MaxRowSizeBytes' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PIP_MaxRowSizeBytes as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PIP_MaxRowSizeBytes as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.PIP_ID = D.PIP_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.PossibleIndexProblems' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[PossibleIndexProblems] DISABLE TRIGGER [trg_PossibleIndexProblems_HistoryLogging]
GO
