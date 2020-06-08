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
/****** Object:  Table [EventProcessing].[CounterConditions]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [EventProcessing].[CounterConditions](
	[COC_ID] [int] IDENTITY(1,1) NOT NULL,
	[COC_ClientID] [int] NOT NULL,
	[COC_EDF_ID] [int] NOT NULL,
	[COC_Description] [nvarchar](1000) NOT NULL,
	[COC_SystemID] [tinyint] NOT NULL,
	[COC_CounterID] [int] NOT NULL,
	[COC_InstanceName] [varchar](900) NULL,
	[COC_ORT_ID] [tinyint] NOT NULL,
	[COC_Value] [decimal](18, 5) NULL,
	[COC_Status] [varchar](850) NULL,
	[COC_OK_ORT_ID] [tinyint] NULL,
	[COC_OKValue] [decimal](18, 5) NULL,
	[COC_OKStatus] [varchar](850) NULL,
	[COC_CGT_ID] [tinyint] NULL,
 CONSTRAINT [PK_CounterConditions] PRIMARY KEY CLUSTERED 
(
	[COC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Trigger [EventProcessing].[trg_CounterConditions_HistoryLogging]    Script Date: 6/8/2020 1:14:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [EventProcessing].[trg_CounterConditions_HistoryLogging] ON [EventProcessing].[CounterConditions]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'EventProcessing.CounterConditions' TabName, COC_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.COC_ID, 
					(SELECT CASE WHEN UPDATE(COC_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'COC_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.COC_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.COC_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(COC_EDF_ID) Or @ChangeType = 'D' THEN
							(SELECT 'COC_EDF_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.COC_EDF_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.COC_EDF_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(COC_Description) Or @ChangeType = 'D' THEN
							(SELECT 'COC_Description' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.COC_Description as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.COC_Description as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(COC_SystemID) Or @ChangeType = 'D' THEN
							(SELECT 'COC_SystemID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.COC_SystemID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.COC_SystemID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(COC_CounterID) Or @ChangeType = 'D' THEN
							(SELECT 'COC_CounterID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.COC_CounterID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.COC_CounterID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(COC_InstanceName) Or @ChangeType = 'D' THEN
							(SELECT 'COC_InstanceName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.COC_InstanceName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.COC_InstanceName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(COC_ORT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'COC_ORT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.COC_ORT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.COC_ORT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(COC_Value) Or @ChangeType = 'D' THEN
							(SELECT 'COC_Value' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.COC_Value as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.COC_Value as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(COC_Status) Or @ChangeType = 'D' THEN
							(SELECT 'COC_Status' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.COC_Status as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.COC_Status as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(COC_OK_ORT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'COC_OK_ORT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.COC_OK_ORT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.COC_OK_ORT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(COC_OKValue) Or @ChangeType = 'D' THEN
							(SELECT 'COC_OKValue' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.COC_OKValue as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.COC_OKValue as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(COC_OKStatus) Or @ChangeType = 'D' THEN
							(SELECT 'COC_OKStatus' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.COC_OKStatus as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.COC_OKStatus as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(COC_CGT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'COC_CGT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.COC_CGT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.COC_CGT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.COC_ID = D.COC_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'EventProcessing.CounterConditions' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [EventProcessing].[CounterConditions] DISABLE TRIGGER [trg_CounterConditions_HistoryLogging]
GO
