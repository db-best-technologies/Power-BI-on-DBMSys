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
/****** Object:  Table [BusinessLogic].[ObjectTypes]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BusinessLogic].[ObjectTypes](
	[OBT_ID] [tinyint] NOT NULL,
	[OBT_Name] [varchar](100) NOT NULL,
	[OBT_Parent_OBT_ID] [tinyint] NULL,
	[OBT_IncludesMonitoredObjectID] [bit] NOT NULL,
	[OBT_ObjectCountProcedure] [nvarchar](257) NULL,
	[OBT_PLC_ID] [tinyint] NULL,
 CONSTRAINT [PK_ObjectTypes] PRIMARY KEY CLUSTERED 
(
	[OBT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Trigger [BusinessLogic].[trg_ObjectTypes_HistoryLogging]    Script Date: 6/8/2020 1:14:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [BusinessLogic].[trg_ObjectTypes_HistoryLogging] ON [BusinessLogic].[ObjectTypes]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'BusinessLogic.ObjectTypes' TabName, OBT_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.OBT_ID, 
					(SELECT CASE WHEN UPDATE(OBT_Name) Or @ChangeType = 'D' THEN
							(SELECT 'OBT_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OBT_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OBT_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OBT_Parent_OBT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OBT_Parent_OBT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OBT_Parent_OBT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OBT_Parent_OBT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OBT_IncludesMonitoredObjectID) Or @ChangeType = 'D' THEN
							(SELECT 'OBT_IncludesMonitoredObjectID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OBT_IncludesMonitoredObjectID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OBT_IncludesMonitoredObjectID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OBT_ObjectCountProcedure) Or @ChangeType = 'D' THEN
							(SELECT 'OBT_ObjectCountProcedure' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OBT_ObjectCountProcedure as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OBT_ObjectCountProcedure as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OBT_PLC_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OBT_PLC_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OBT_PLC_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OBT_PLC_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.OBT_ID = D.OBT_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'BusinessLogic.ObjectTypes' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [BusinessLogic].[ObjectTypes] DISABLE TRIGGER [trg_ObjectTypes_HistoryLogging]
GO
