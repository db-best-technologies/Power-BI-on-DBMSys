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
/****** Object:  Table [Inventory].[TablespacesInformation]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[TablespacesInformation](
	[TSI_ID] [int] IDENTITY(1,1) NOT NULL,
	[TSI_Client_ID] [int] NOT NULL,
	[TSI_MOB_ID] [int] NOT NULL,
	[TSI_TSP_ID] [int] NOT NULL,
	[TSI_OCS_ID] [int] NOT NULL,
	[TSI_CNT_ID] [int] NOT NULL,
	[TSI_SizeMB] [int] NOT NULL,
	[TSI_FreeSpaceMB] [int] NOT NULL,
	[TSI_UsedSpaceMB] [int] NOT NULL,
	[TSI_PercentFreeMB] [int] NOT NULL,
	[TSI_PercentUsed] [int] NOT NULL,
	[TSI_MaxSizeMB] [int] NOT NULL,
	[TSI_UsedMaxSize] [int] NOT NULL,
	[TSI_InsertDate] [datetime2](3) NOT NULL,
	[TSI_LastSeenDate] [datetime2](3) NOT NULL,
	[TSI_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_TablespacesInformation] PRIMARY KEY CLUSTERED 
(
	[TSI_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_TablespacesInformation_HistoryLogging]    Script Date: 6/8/2020 1:15:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_TablespacesInformation_HistoryLogging] ON [Inventory].[TablespacesInformation]
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
	INSERT INTO Inventory.History(HIS_Type, HIS_Datetime, HIS_TableName, HIS_MOB_ID, HIS_PK_1, 	HIS_Changes, HIS_UserName, HIS_AppName, HIS_HostName)
	SELECT *
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.TablespacesInformation' TabName, C_MOB_ID, TSI_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.TSI_MOB_ID C_MOB_ID, D.TSI_ID, 
					(SELECT CASE WHEN UPDATE(TSI_Client_ID) Or @ChangeType = 'D' THEN
							(SELECT 'TSI_Client_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TSI_Client_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TSI_Client_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TSI_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'TSI_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TSI_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TSI_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TSI_TSP_ID) Or @ChangeType = 'D' THEN
							(SELECT 'TSI_TSP_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TSI_TSP_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TSI_TSP_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TSI_OCS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'TSI_OCS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TSI_OCS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TSI_OCS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TSI_CNT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'TSI_CNT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TSI_CNT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TSI_CNT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TSI_SizeMB) Or @ChangeType = 'D' THEN
							(SELECT 'TSI_SizeMB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TSI_SizeMB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TSI_SizeMB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TSI_FreeSpaceMB) Or @ChangeType = 'D' THEN
							(SELECT 'TSI_FreeSpaceMB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TSI_FreeSpaceMB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TSI_FreeSpaceMB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TSI_UsedSpaceMB) Or @ChangeType = 'D' THEN
							(SELECT 'TSI_UsedSpaceMB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TSI_UsedSpaceMB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TSI_UsedSpaceMB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TSI_PercentFreeMB) Or @ChangeType = 'D' THEN
							(SELECT 'TSI_PercentFreeMB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TSI_PercentFreeMB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TSI_PercentFreeMB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TSI_PercentUsed) Or @ChangeType = 'D' THEN
							(SELECT 'TSI_PercentUsed' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TSI_PercentUsed as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TSI_PercentUsed as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TSI_MaxSizeMB) Or @ChangeType = 'D' THEN
							(SELECT 'TSI_MaxSizeMB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TSI_MaxSizeMB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TSI_MaxSizeMB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TSI_UsedMaxSize) Or @ChangeType = 'D' THEN
							(SELECT 'TSI_UsedMaxSize' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TSI_UsedMaxSize as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TSI_UsedMaxSize as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.TSI_ID = D.TSI_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.TablespacesInformation' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[TablespacesInformation] DISABLE TRIGGER [trg_TablespacesInformation_HistoryLogging]
GO
