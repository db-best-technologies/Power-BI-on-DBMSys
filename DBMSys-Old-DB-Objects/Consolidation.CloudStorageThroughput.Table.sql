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
/****** Object:  Table [Consolidation].[CloudStorageThroughput]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[CloudStorageThroughput](
	[CST_ID] [int] IDENTITY(1,1) NOT NULL,
	[CST_BUL_ID] [tinyint] NOT NULL,
	[CST_DiskCount] [tinyint] NULL,
	[CST_MaxIOPS8KB] [int] NULL,
	[CST_MaxMBPerSec8KB] [int] NULL,
	[CST_MaxIOPS64KB] [int] NULL,
	[CST_MaxMBPerSec64KB] [int] NULL,
 CONSTRAINT [PK_CloudStorageThroughput] PRIMARY KEY CLUSTERED 
(
	[CST_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_CloudStorageThroughput_CST_BUL_ID#CST_DiskCount]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_CloudStorageThroughput_CST_BUL_ID#CST_DiskCount] ON [Consolidation].[CloudStorageThroughput]
(
	[CST_BUL_ID] ASC,
	[CST_DiskCount] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Consolidation].[trg_CloudStorageThroughput_HistoryLogging]    Script Date: 6/8/2020 1:14:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Consolidation].[trg_CloudStorageThroughput_HistoryLogging] ON [Consolidation].[CloudStorageThroughput]
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
	INSERT INTO Management.History(HIS_Type, HIS_Datetime, HIS_TableName, HIS_PK_1, 	HIS_Changes, HIS_UserName, HIS_AppName, HIS_HostName)
	SELECT *
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Consolidation.CloudStorageThroughput' TabName, CST_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.CST_ID, 
					(SELECT CASE WHEN UPDATE(CST_BUL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'CST_BUL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CST_BUL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CST_BUL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CST_DiskCount) Or @ChangeType = 'D' THEN
							(SELECT 'CST_DiskCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CST_DiskCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CST_DiskCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CST_MaxIOPS8KB) Or @ChangeType = 'D' THEN
							(SELECT 'CST_MaxIOPS8KB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CST_MaxIOPS8KB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CST_MaxIOPS8KB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CST_MaxMBPerSec8KB) Or @ChangeType = 'D' THEN
							(SELECT 'CST_MaxMBPerSec8KB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CST_MaxMBPerSec8KB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CST_MaxMBPerSec8KB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CST_MaxIOPS64KB) Or @ChangeType = 'D' THEN
							(SELECT 'CST_MaxIOPS64KB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CST_MaxIOPS64KB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CST_MaxIOPS64KB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CST_MaxMBPerSec64KB) Or @ChangeType = 'D' THEN
							(SELECT 'CST_MaxMBPerSec64KB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CST_MaxMBPerSec64KB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CST_MaxMBPerSec64KB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.CST_ID = D.CST_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Consolidation.CloudStorageThroughput' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Consolidation].[CloudStorageThroughput] DISABLE TRIGGER [trg_CloudStorageThroughput_HistoryLogging]
GO
