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
/****** Object:  Table [ResponseProcessing].[EventSubscriptions_BlackBoxeTypes]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ResponseProcessing].[EventSubscriptions_BlackBoxeTypes](
	[EBB_ID] [int] IDENTITY(1,1) NOT NULL,
	[EBB_ESP_ID] [int] NOT NULL,
	[EBB_BBT_ID] [int] NOT NULL,
	[EBB_IRL_ID] [tinyint] NOT NULL,
	[EBB_MaxWaitTimeSeconds] [int] NULL,
	[EBB_Parameters] [xml] NULL,
	[EBB_Priority] [int] NULL,
 CONSTRAINT [PK_EventSubscriptions_BlackBoxeTypes] PRIMARY KEY CLUSTERED 
(
	[EBB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Trigger [ResponseProcessing].[trg_EventSubscriptions_BlackBoxeTypes_HistoryLogging]    Script Date: 6/8/2020 1:15:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [ResponseProcessing].[trg_EventSubscriptions_BlackBoxeTypes_HistoryLogging] ON [ResponseProcessing].[EventSubscriptions_BlackBoxeTypes]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'ResponseProcessing.EventSubscriptions_BlackBoxeTypes' TabName, EBB_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.EBB_ID, 
					(SELECT CASE WHEN UPDATE(EBB_ESP_ID) Or @ChangeType = 'D' THEN
							(SELECT 'EBB_ESP_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EBB_ESP_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EBB_ESP_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EBB_BBT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'EBB_BBT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EBB_BBT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EBB_BBT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EBB_IRL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'EBB_IRL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EBB_IRL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EBB_IRL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EBB_MaxWaitTimeSeconds) Or @ChangeType = 'D' THEN
							(SELECT 'EBB_MaxWaitTimeSeconds' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EBB_MaxWaitTimeSeconds as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EBB_MaxWaitTimeSeconds as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EBB_Priority) Or @ChangeType = 'D' THEN
							(SELECT 'EBB_Priority' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EBB_Priority as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EBB_Priority as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.EBB_ID = D.EBB_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'ResponseProcessing.EventSubscriptions_BlackBoxeTypes' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [ResponseProcessing].[EventSubscriptions_BlackBoxeTypes] DISABLE TRIGGER [trg_EventSubscriptions_BlackBoxeTypes_HistoryLogging]
GO
