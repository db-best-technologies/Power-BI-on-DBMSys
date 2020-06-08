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
/****** Object:  Table [GUI].[GUIObjects]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [GUI].[GUIObjects](
	[GIO_ID] [int] IDENTITY(1,1) NOT NULL,
	[GIO_Code] [varchar](50) NOT NULL,
	[GIO_DisplayName] [varchar](100) NOT NULL,
	[GIO_IconLink] [varchar](1000) NULL,
	[GIO_ProcedureName] [nvarchar](257) NULL,
	[GIO_AllowSearch] [bit] NULL,
 CONSTRAINT [PK_GUIObjects] PRIMARY KEY NONCLUSTERED 
(
	[GIO_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_GUIObjects_GIO_Code]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE CLUSTERED INDEX [IX_GUIObjects_GIO_Code] ON [GUI].[GUIObjects]
(
	[GIO_Code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [GUI].[trg_GUIObjects_HistoryLogging]    Script Date: 6/8/2020 1:14:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [GUI].[trg_GUIObjects_HistoryLogging] ON [GUI].[GUIObjects]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'GUI.GUIObjects' TabName, GIO_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.GIO_ID, 
					(SELECT CASE WHEN UPDATE(GIO_Code) Or @ChangeType = 'D' THEN
							(SELECT 'GIO_Code' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.GIO_Code as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.GIO_Code as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(GIO_DisplayName) Or @ChangeType = 'D' THEN
							(SELECT 'GIO_DisplayName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.GIO_DisplayName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.GIO_DisplayName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(GIO_IconLink) Or @ChangeType = 'D' THEN
							(SELECT 'GIO_IconLink' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.GIO_IconLink as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.GIO_IconLink as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(GIO_ProcedureName) Or @ChangeType = 'D' THEN
							(SELECT 'GIO_ProcedureName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.GIO_ProcedureName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.GIO_ProcedureName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(GIO_AllowSearch) Or @ChangeType = 'D' THEN
							(SELECT 'GIO_AllowSearch' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.GIO_AllowSearch as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.GIO_AllowSearch as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.GIO_ID = D.GIO_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'GUI.GUIObjects' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [GUI].[GUIObjects] DISABLE TRIGGER [trg_GUIObjects_HistoryLogging]
GO
