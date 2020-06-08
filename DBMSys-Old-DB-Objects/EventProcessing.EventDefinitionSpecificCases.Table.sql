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
/****** Object:  Table [EventProcessing].[EventDefinitionSpecificCases]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [EventProcessing].[EventDefinitionSpecificCases](
	[EDC_ID] [int] IDENTITY(1,1) NOT NULL,
	[EDC_ClientID] [int] NOT NULL,
	[EDC_EDF_ID] [int] NOT NULL,
	[EDC_MOB_ID] [int] NULL,
	[EDC_EventInstanceName] [varchar](850) NULL,
	[EDC_ProcessingOrder] [int] NOT NULL,
	[EDC_FromNumberOfOccurrences] [int] NULL,
	[EDC_ToNumberOfOccurrences] [int] NULL,
	[EDC_OKFromNumberOfOccurrences] [int] NULL,
	[EDC_OKToNumberOfOccurrences] [int] NULL,
	[EDC_AutoResolveMinutes] [smallint] NULL,
	[EDC_IsActive] [bit] NOT NULL,
	[EDC_IgnoreInstance] [bit] NULL,
 CONSTRAINT [PK_EventDefinitionSpecificCases] PRIMARY KEY CLUSTERED 
(
	[EDC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_EventDefinitionSpecificCases_EDC_EDF_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_EventDefinitionSpecificCases_EDC_EDF_ID] ON [EventProcessing].[EventDefinitionSpecificCases]
(
	[EDC_EDF_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [EventProcessing].[trg_EventDefinitionSpecificCases_HistoryLogging]    Script Date: 6/8/2020 1:14:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [EventProcessing].[trg_EventDefinitionSpecificCases_HistoryLogging] ON [EventProcessing].[EventDefinitionSpecificCases]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'EventProcessing.EventDefinitionSpecificCases' TabName, EDC_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.EDC_ID, 
					(SELECT CASE WHEN UPDATE(EDC_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'EDC_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EDC_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EDC_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EDC_EDF_ID) Or @ChangeType = 'D' THEN
							(SELECT 'EDC_EDF_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EDC_EDF_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EDC_EDF_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EDC_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'EDC_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EDC_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EDC_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EDC_EventInstanceName) Or @ChangeType = 'D' THEN
							(SELECT 'EDC_EventInstanceName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EDC_EventInstanceName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EDC_EventInstanceName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EDC_ProcessingOrder) Or @ChangeType = 'D' THEN
							(SELECT 'EDC_ProcessingOrder' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EDC_ProcessingOrder as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EDC_ProcessingOrder as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EDC_FromNumberOfOccurrences) Or @ChangeType = 'D' THEN
							(SELECT 'EDC_FromNumberOfOccurrences' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EDC_FromNumberOfOccurrences as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EDC_FromNumberOfOccurrences as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EDC_ToNumberOfOccurrences) Or @ChangeType = 'D' THEN
							(SELECT 'EDC_ToNumberOfOccurrences' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EDC_ToNumberOfOccurrences as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EDC_ToNumberOfOccurrences as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EDC_OKFromNumberOfOccurrences) Or @ChangeType = 'D' THEN
							(SELECT 'EDC_OKFromNumberOfOccurrences' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EDC_OKFromNumberOfOccurrences as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EDC_OKFromNumberOfOccurrences as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EDC_OKToNumberOfOccurrences) Or @ChangeType = 'D' THEN
							(SELECT 'EDC_OKToNumberOfOccurrences' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EDC_OKToNumberOfOccurrences as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EDC_OKToNumberOfOccurrences as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EDC_AutoResolveMinutes) Or @ChangeType = 'D' THEN
							(SELECT 'EDC_AutoResolveMinutes' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EDC_AutoResolveMinutes as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EDC_AutoResolveMinutes as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EDC_IsActive) Or @ChangeType = 'D' THEN
							(SELECT 'EDC_IsActive' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EDC_IsActive as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EDC_IsActive as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.EDC_ID = D.EDC_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'EventProcessing.EventDefinitionSpecificCases' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [EventProcessing].[EventDefinitionSpecificCases] DISABLE TRIGGER [trg_EventDefinitionSpecificCases_HistoryLogging]
GO
