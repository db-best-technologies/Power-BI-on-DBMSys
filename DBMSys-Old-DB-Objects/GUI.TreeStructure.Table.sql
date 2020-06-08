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
/****** Object:  Table [GUI].[TreeStructure]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [GUI].[TreeStructure](
	[TRT_ID] [int] IDENTITY(1,1) NOT NULL,
	[TRT_TTY_ID] [tinyint] NOT NULL,
	[TRT_GIO_Code] [varchar](50) NOT NULL,
	[TRT_Parent_GIO_Code] [varchar](50) NULL,
	[TRT_OAT_ID] [tinyint] NOT NULL,
	[TRT_AlternativeDisplayName] [varchar](100) NULL,
	[TRT_AlternativeIconLink] [varchar](1000) NULL,
	[TRT_IsVisible] [bit] NOT NULL,
 CONSTRAINT [PK_TreeStructure] PRIMARY KEY CLUSTERED 
(
	[TRT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_TreeStructure_TRT_TTY_ID#TRT_Parent_GIO_Code#TRT_GIO_Code#TRT_OAT_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_TreeStructure_TRT_TTY_ID#TRT_Parent_GIO_Code#TRT_GIO_Code#TRT_OAT_ID] ON [GUI].[TreeStructure]
(
	[TRT_TTY_ID] ASC,
	[TRT_Parent_GIO_Code] ASC,
	[TRT_GIO_Code] ASC,
	[TRT_OAT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [GUI].[trg_TreeStructure_HistoryLogging]    Script Date: 6/8/2020 1:14:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [GUI].[trg_TreeStructure_HistoryLogging] ON [GUI].[TreeStructure]
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
	INSERT INTO Internal.History(HIS_Type, HIS_Datetime, HIS_TableName, HIS_PK_1, 	HIS_Changes, HIS_UserName, HIS_AppName, HIS_HostName)
	SELECT *
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'GUI.TreeStructure' TabName, TRT_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.TRT_ID, 
					(SELECT CASE WHEN UPDATE(TRT_TTY_ID) Or @ChangeType = 'D' THEN
							(SELECT 'TRT_TTY_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TRT_TTY_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TRT_TTY_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TRT_GIO_Code) Or @ChangeType = 'D' THEN
							(SELECT 'TRT_GIO_Code' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TRT_GIO_Code as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TRT_GIO_Code as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TRT_Parent_GIO_Code) Or @ChangeType = 'D' THEN
							(SELECT 'TRT_Parent_GIO_Code' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TRT_Parent_GIO_Code as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TRT_Parent_GIO_Code as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TRT_OAT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'TRT_OAT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TRT_OAT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TRT_OAT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TRT_AlternativeDisplayName) Or @ChangeType = 'D' THEN
							(SELECT 'TRT_AlternativeDisplayName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TRT_AlternativeDisplayName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TRT_AlternativeDisplayName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TRT_AlternativeIconLink) Or @ChangeType = 'D' THEN
							(SELECT 'TRT_AlternativeIconLink' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TRT_AlternativeIconLink as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TRT_AlternativeIconLink as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TRT_IsVisible) Or @ChangeType = 'D' THEN
							(SELECT 'TRT_IsVisible' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TRT_IsVisible as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TRT_IsVisible as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.TRT_ID = D.TRT_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'GUI.TreeStructure' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [GUI].[TreeStructure] DISABLE TRIGGER [trg_TreeStructure_HistoryLogging]
GO
