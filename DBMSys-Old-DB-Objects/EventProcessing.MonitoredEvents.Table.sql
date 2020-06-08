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
/****** Object:  Table [EventProcessing].[MonitoredEvents]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [EventProcessing].[MonitoredEvents](
	[MOV_ID] [int] IDENTITY(1,1) NOT NULL,
	[MOV_ClientID] [int] NOT NULL,
	[MOV_Description] [nvarchar](1000) NOT NULL,
	[MOV_MEG_ID] [int] NULL,
	[MOV_Level] [tinyint] NULL,
	[MOV_IsInternal] [bit] NOT NULL,
	[MOV_IsActive] [bit] NOT NULL,
	[MOV_Weekdays] [varchar](7) NULL,
	[MOV_FromHour] [char](5) NULL,
	[MOV_ToHour] [char](5) NULL,
	[MOV_Weight] [decimal](10, 2) NULL,
	[MOV_THL_ID] [tinyint] NULL,
	[MOV_ESV_ID] [tinyint] NOT NULL,
	[MOV_OCF_BinConcat] [tinyint] NULL,
 CONSTRAINT [PK_MonitoredEvents] PRIMARY KEY CLUSTERED 
(
	[MOV_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Trigger [EventProcessing].[trg_MonitoredEvents_HistoryLogging]    Script Date: 6/8/2020 1:14:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [EventProcessing].[trg_MonitoredEvents_HistoryLogging] ON [EventProcessing].[MonitoredEvents]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'EventProcessing.MonitoredEvents' TabName, MOV_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.MOV_ID, 
					(SELECT CASE WHEN UPDATE(MOV_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'MOV_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MOV_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MOV_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MOV_Description) Or @ChangeType = 'D' THEN
							(SELECT 'MOV_Description' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MOV_Description as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MOV_Description as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MOV_MEG_ID) Or @ChangeType = 'D' THEN
							(SELECT 'MOV_MEG_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MOV_MEG_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MOV_MEG_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MOV_Level) Or @ChangeType = 'D' THEN
							(SELECT 'MOV_Level' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MOV_Level as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MOV_Level as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MOV_IsInternal) Or @ChangeType = 'D' THEN
							(SELECT 'MOV_IsInternal' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MOV_IsInternal as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MOV_IsInternal as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MOV_IsActive) Or @ChangeType = 'D' THEN
							(SELECT 'MOV_IsActive' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MOV_IsActive as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MOV_IsActive as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MOV_Weekdays) Or @ChangeType = 'D' THEN
							(SELECT 'MOV_Weekdays' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MOV_Weekdays as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MOV_Weekdays as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MOV_FromHour) Or @ChangeType = 'D' THEN
							(SELECT 'MOV_FromHour' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MOV_FromHour as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MOV_FromHour as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MOV_ToHour) Or @ChangeType = 'D' THEN
							(SELECT 'MOV_ToHour' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MOV_ToHour as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MOV_ToHour as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MOV_Weight) Or @ChangeType = 'D' THEN
							(SELECT 'MOV_Weight' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MOV_Weight as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MOV_Weight as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MOV_THL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'MOV_THL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MOV_THL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MOV_THL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MOV_ESV_ID) Or @ChangeType = 'D' THEN
							(SELECT 'MOV_ESV_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MOV_ESV_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MOV_ESV_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.MOV_ID = D.MOV_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'EventProcessing.MonitoredEvents' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [EventProcessing].[MonitoredEvents] DISABLE TRIGGER [trg_MonitoredEvents_HistoryLogging]
GO
