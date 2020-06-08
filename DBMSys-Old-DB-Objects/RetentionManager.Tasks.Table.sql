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
/****** Object:  Table [RetentionManager].[Tasks]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [RetentionManager].[Tasks](
	[TAS_ID] [int] IDENTITY(1,1) NOT NULL,
	[TAS_TableName] [nvarchar](257) NOT NULL,
	[TAS_DateColumn] [nvarchar](128) NOT NULL,
	[TAS_RetentionPeriod_SET_Key] [varchar](100) NOT NULL,
	[TAS_WhereClause] [nvarchar](max) NULL,
	[TAS_MinRowsToKeep] [int] NULL,
	[TAS_MinRowsToKeepBy] [nvarchar](max) NULL,
	[TAS_IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_Tasks] PRIMARY KEY CLUSTERED 
(
	[TAS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Trigger [RetentionManager].[trg_Tasks_HistoryLogging]    Script Date: 6/8/2020 1:15:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [RetentionManager].[trg_Tasks_HistoryLogging] ON [RetentionManager].[Tasks]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'RetentionManager.Tasks' TabName, TAS_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.TAS_ID, 
					(SELECT CASE WHEN UPDATE(TAS_TableName) Or @ChangeType = 'D' THEN
							(SELECT 'TAS_TableName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TAS_TableName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TAS_TableName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TAS_DateColumn) Or @ChangeType = 'D' THEN
							(SELECT 'TAS_DateColumn' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TAS_DateColumn as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TAS_DateColumn as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TAS_RetentionPeriod_SET_Key) Or @ChangeType = 'D' THEN
							(SELECT 'TAS_RetentionPeriod_SET_Key' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TAS_RetentionPeriod_SET_Key as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TAS_RetentionPeriod_SET_Key as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TAS_MinRowsToKeep) Or @ChangeType = 'D' THEN
							(SELECT 'TAS_MinRowsToKeep' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TAS_MinRowsToKeep as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TAS_MinRowsToKeep as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TAS_IsActive) Or @ChangeType = 'D' THEN
							(SELECT 'TAS_IsActive' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TAS_IsActive as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TAS_IsActive as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.TAS_ID = D.TAS_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'RetentionManager.Tasks' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [RetentionManager].[Tasks] DISABLE TRIGGER [trg_Tasks_HistoryLogging]
GO
