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
/****** Object:  Table [Collect].[TestVersions]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Collect].[TestVersions](
	[TSV_ID] [int] IDENTITY(1,1) NOT NULL,
	[TSV_TST_ID] [int] NOT NULL,
	[TSV_MinVersion] [decimal](20, 10) NULL,
	[TSV_MaxVersion] [decimal](20, 10) NULL,
	[TSV_Query] [nvarchar](max) NULL,
	[TSV_QueryFunction] [nvarchar](514) NULL,
	[TSV_OutputTable] [nvarchar](514) NULL,
	[TSV_PLT_ID] [tinyint] NOT NULL,
	[TSV_Editions] [varchar](1000) NULL,
 CONSTRAINT [PK_TestVersions] PRIMARY KEY CLUSTERED 
(
	[TSV_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_TestVersions_TSV_PLT_ID#TSV_TST_ID#TSV_MinVersion#TSV_MaxVersion#TSV_Editions]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_TestVersions_TSV_PLT_ID#TSV_TST_ID#TSV_MinVersion#TSV_MaxVersion#TSV_Editions] ON [Collect].[TestVersions]
(
	[TSV_PLT_ID] ASC,
	[TSV_TST_ID] ASC,
	[TSV_MinVersion] ASC,
	[TSV_MaxVersion] ASC,
	[TSV_Editions] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Collect].[trg_TestVersions_HistoryLogging]    Script Date: 6/8/2020 1:14:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Collect].[trg_TestVersions_HistoryLogging] ON [Collect].[TestVersions]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Collect.TestVersions' TabName, TSV_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.TSV_ID, 
					(SELECT CASE WHEN UPDATE(TSV_TST_ID) Or @ChangeType = 'D' THEN
							(SELECT 'TSV_TST_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TSV_TST_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TSV_TST_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TSV_MinVersion) Or @ChangeType = 'D' THEN
							(SELECT 'TSV_MinVersion' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TSV_MinVersion as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TSV_MinVersion as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TSV_MaxVersion) Or @ChangeType = 'D' THEN
							(SELECT 'TSV_MaxVersion' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TSV_MaxVersion as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TSV_MaxVersion as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TSV_QueryFunction) Or @ChangeType = 'D' THEN
							(SELECT 'TSV_QueryFunction' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TSV_QueryFunction as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TSV_QueryFunction as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TSV_OutputTable) Or @ChangeType = 'D' THEN
							(SELECT 'TSV_OutputTable' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TSV_OutputTable as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TSV_OutputTable as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TSV_PLT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'TSV_PLT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TSV_PLT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TSV_PLT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TSV_Editions) Or @ChangeType = 'D' THEN
							(SELECT 'TSV_Editions' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TSV_Editions as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TSV_Editions as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.TSV_ID = D.TSV_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Collect.TestVersions' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Collect].[TestVersions] DISABLE TRIGGER [trg_TestVersions_HistoryLogging]
GO
