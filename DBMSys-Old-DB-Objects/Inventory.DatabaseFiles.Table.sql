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
/****** Object:  Table [Inventory].[DatabaseFiles]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[DatabaseFiles](
	[DBF_ID] [int] IDENTITY(1,1) NOT NULL,
	[DBF_ClientID] [int] NOT NULL,
	[DBF_MOB_ID] [int] NOT NULL,
	[DBF_IDB_ID] [int] NULL,
	[DBF_DFG_ID] [int] NULL,
	[DBF_FileID] [int] NULL,
	[DBF_Name] [nvarchar](128) NOT NULL,
	[DBF_FileName] [nvarchar](260) NULL,
	[DBF_DSK_ID] [int] NULL,
	[DBF_DFT_ID] [tinyint] NULL,
	[DBF_DFS_ID] [tinyint] NULL,
	[DBF_MaxSizeMB] [bigint] NULL,
	[DBF_GrowthMB] [bigint] NULL,
	[DBF_GrowthPercent] [int] NULL,
	[DBF_IsReadOnly] [bit] NULL,
	[DBF_InsertDate] [datetime2](3) NOT NULL,
	[DBF_LastSeenDate] [datetime2](3) NOT NULL,
	[DBF_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_DatabaseFiles] PRIMARY KEY CLUSTERED 
(
	[DBF_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IDX_DatabaseFiles###DBF_MOB_ID#DBF_Last_TRH_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IDX_DatabaseFiles###DBF_MOB_ID#DBF_Last_TRH_ID] ON [Inventory].[DatabaseFiles]
(
	[DBF_MOB_ID] ASC,
	[DBF_Last_TRH_ID] ASC
)
INCLUDE([DBF_ID],[DBF_ClientID],[DBF_IDB_ID],[DBF_DFG_ID],[DBF_Name],[DBF_DSK_ID],[DBF_InsertDate]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_DatabaseFiles#DBF_DSK_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_DatabaseFiles#DBF_DSK_ID] ON [Inventory].[DatabaseFiles]
(
	[DBF_DSK_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_DatabaseFiles_DBF_MOB_ID#DBF_IDB_ID#DBF_Name###DBF_IDB_ID_IS_NOT_NULL]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_DatabaseFiles_DBF_MOB_ID#DBF_IDB_ID#DBF_Name###DBF_IDB_ID_IS_NOT_NULL] ON [Inventory].[DatabaseFiles]
(
	[DBF_MOB_ID] ASC,
	[DBF_IDB_ID] ASC,
	[DBF_Name] ASC
)
WHERE ([DBF_IDB_ID] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Inventory].[DatabaseFiles]  WITH CHECK ADD  CONSTRAINT [FK_DatabaseFiles_DatabaseFileGroups] FOREIGN KEY([DBF_DFG_ID])
REFERENCES [Inventory].[DatabaseFileGroups] ([DFG_ID])
ON DELETE CASCADE
GO
ALTER TABLE [Inventory].[DatabaseFiles] CHECK CONSTRAINT [FK_DatabaseFiles_DatabaseFileGroups]
GO
/****** Object:  Trigger [Inventory].[trg_DatabaseFiles_HistoryLogging]    Script Date: 6/8/2020 1:15:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_DatabaseFiles_HistoryLogging] ON [Inventory].[DatabaseFiles]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.DatabaseFiles' TabName, C_MOB_ID, DBF_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.DBF_MOB_ID C_MOB_ID, D.DBF_ID, 
					(SELECT CASE WHEN UPDATE(DBF_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'DBF_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DBF_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DBF_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DBF_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DBF_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DBF_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DBF_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DBF_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DBF_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DBF_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DBF_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DBF_DFG_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DBF_DFG_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DBF_DFG_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DBF_DFG_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DBF_FileID) Or @ChangeType = 'D' THEN
							(SELECT 'DBF_FileID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DBF_FileID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DBF_FileID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DBF_Name) Or @ChangeType = 'D' THEN
							(SELECT 'DBF_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DBF_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DBF_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DBF_FileName) Or @ChangeType = 'D' THEN
							(SELECT 'DBF_FileName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DBF_FileName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DBF_FileName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DBF_DSK_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DBF_DSK_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DBF_DSK_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DBF_DSK_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DBF_DFT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DBF_DFT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DBF_DFT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DBF_DFT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DBF_DFS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DBF_DFS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DBF_DFS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DBF_DFS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DBF_MaxSizeMB) Or @ChangeType = 'D' THEN
							(SELECT 'DBF_MaxSizeMB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DBF_MaxSizeMB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DBF_MaxSizeMB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DBF_GrowthMB) Or @ChangeType = 'D' THEN
							(SELECT 'DBF_GrowthMB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DBF_GrowthMB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DBF_GrowthMB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DBF_GrowthPercent) Or @ChangeType = 'D' THEN
							(SELECT 'DBF_GrowthPercent' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DBF_GrowthPercent as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DBF_GrowthPercent as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DBF_IsReadOnly) Or @ChangeType = 'D' THEN
							(SELECT 'DBF_IsReadOnly' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DBF_IsReadOnly as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DBF_IsReadOnly as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.DBF_ID = D.DBF_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.DatabaseFiles' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[DatabaseFiles] DISABLE TRIGGER [trg_DatabaseFiles_HistoryLogging]
GO
