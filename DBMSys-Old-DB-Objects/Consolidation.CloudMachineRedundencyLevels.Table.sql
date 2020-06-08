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
/****** Object:  Table [Consolidation].[CloudMachineRedundencyLevels]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[CloudMachineRedundencyLevels](
	[CRL_ID] [tinyint] NOT NULL,
	[CRL_CLV_ID] [tinyint] NOT NULL,
	[CRL_RedundencyLevel] [tinyint] NOT NULL,
	[CRL_Name] [varchar](100) NULL,
 CONSTRAINT [PK_CloudMachineRedundencyLevels] PRIMARY KEY CLUSTERED 
(
	[CRL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_CloudMachineRedundencyLevels_CRL_CLV_ID#CRL_RedundencyLevel]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_CloudMachineRedundencyLevels_CRL_CLV_ID#CRL_RedundencyLevel] ON [Consolidation].[CloudMachineRedundencyLevels]
(
	[CRL_CLV_ID] ASC,
	[CRL_RedundencyLevel] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Consolidation].[trg_CloudMachineRedundencyLevels_HistoryLogging]    Script Date: 6/8/2020 1:14:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Consolidation].[trg_CloudMachineRedundencyLevels_HistoryLogging] ON [Consolidation].[CloudMachineRedundencyLevels]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Consolidation.CloudMachineRedundencyLevels' TabName, CRL_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.CRL_ID, 
					(SELECT CASE WHEN UPDATE(CRL_CLV_ID) Or @ChangeType = 'D' THEN
							(SELECT 'CRL_CLV_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CRL_CLV_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CRL_CLV_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CRL_RedundencyLevel) Or @ChangeType = 'D' THEN
							(SELECT 'CRL_RedundencyLevel' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CRL_RedundencyLevel as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CRL_RedundencyLevel as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CRL_Name) Or @ChangeType = 'D' THEN
							(SELECT 'CRL_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CRL_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CRL_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.CRL_ID = D.CRL_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Consolidation.CloudMachineRedundencyLevels' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Consolidation].[CloudMachineRedundencyLevels] DISABLE TRIGGER [trg_CloudMachineRedundencyLevels_HistoryLogging]
GO
