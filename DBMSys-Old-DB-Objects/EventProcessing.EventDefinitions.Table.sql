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
/****** Object:  Table [EventProcessing].[EventDefinitions]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [EventProcessing].[EventDefinitions](
	[EDF_ID] [int] IDENTITY(1,1) NOT NULL,
	[EDF_ClientID] [int] NOT NULL,
	[EDF_MOV_ID] [int] NOT NULL,
	[EDF_EFT_ID] [tinyint] NOT NULL,
	[EDF_FromNumberOfOccurrences] [int] NULL,
	[EDF_ToNumberOfOccurrences] [int] NULL,
	[EDF_InLastMinutes] [smallint] NULL,
	[EDF_OKFromNumberOfOccurrences] [int] NULL,
	[EDF_OKToNumberOfOccurrences] [int] NULL,
	[EDF_AutoResolveMinutes] [smallint] NULL,
	[EDF_IgnoreInstanceName] [bit] NOT NULL,
 CONSTRAINT [PK_EventDefinitions] PRIMARY KEY CLUSTERED 
(
	[EDF_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Trigger [EventProcessing].[trg_EventDefinitions_HistoryLogging]    Script Date: 6/8/2020 1:14:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [EventProcessing].[trg_EventDefinitions_HistoryLogging] ON [EventProcessing].[EventDefinitions]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'EventProcessing.EventDefinitions' TabName, EDF_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.EDF_ID, 
					(SELECT CASE WHEN UPDATE(EDF_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'EDF_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EDF_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EDF_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EDF_MOV_ID) Or @ChangeType = 'D' THEN
							(SELECT 'EDF_MOV_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EDF_MOV_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EDF_MOV_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EDF_EFT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'EDF_EFT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EDF_EFT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EDF_EFT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EDF_FromNumberOfOccurrences) Or @ChangeType = 'D' THEN
							(SELECT 'EDF_FromNumberOfOccurrences' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EDF_FromNumberOfOccurrences as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EDF_FromNumberOfOccurrences as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EDF_ToNumberOfOccurrences) Or @ChangeType = 'D' THEN
							(SELECT 'EDF_ToNumberOfOccurrences' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EDF_ToNumberOfOccurrences as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EDF_ToNumberOfOccurrences as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EDF_InLastMinutes) Or @ChangeType = 'D' THEN
							(SELECT 'EDF_InLastMinutes' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EDF_InLastMinutes as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EDF_InLastMinutes as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EDF_OKFromNumberOfOccurrences) Or @ChangeType = 'D' THEN
							(SELECT 'EDF_OKFromNumberOfOccurrences' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EDF_OKFromNumberOfOccurrences as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EDF_OKFromNumberOfOccurrences as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EDF_OKToNumberOfOccurrences) Or @ChangeType = 'D' THEN
							(SELECT 'EDF_OKToNumberOfOccurrences' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EDF_OKToNumberOfOccurrences as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EDF_OKToNumberOfOccurrences as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EDF_AutoResolveMinutes) Or @ChangeType = 'D' THEN
							(SELECT 'EDF_AutoResolveMinutes' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EDF_AutoResolveMinutes as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EDF_AutoResolveMinutes as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EDF_IgnoreInstanceName) Or @ChangeType = 'D' THEN
							(SELECT 'EDF_IgnoreInstanceName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EDF_IgnoreInstanceName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EDF_IgnoreInstanceName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.EDF_ID = D.EDF_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'EventProcessing.EventDefinitions' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [EventProcessing].[EventDefinitions] DISABLE TRIGGER [trg_EventDefinitions_HistoryLogging]
GO
/****** Object:  Trigger [EventProcessing].[trg_EventDefinitions_Insert_Update]    Script Date: 6/8/2020 1:14:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [EventProcessing].[trg_EventDefinitions_Insert_Update] on [EventProcessing].[EventDefinitions]
	for insert, update
as
set nocount on
if exists (select *
			from inserted
				inner join EventProcessing.AnalysisProcedures on EDF_MOV_ID = ANP_MOV_ID)
begin
	rollback
	raiserror('The same Monitored Event can''t hold both Analytical and Online Event Definitions.', 16, 1)
end
GO
ALTER TABLE [EventProcessing].[EventDefinitions] ENABLE TRIGGER [trg_EventDefinitions_Insert_Update]
GO
