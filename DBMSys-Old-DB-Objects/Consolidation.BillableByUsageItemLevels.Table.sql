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
/****** Object:  Table [Consolidation].[BillableByUsageItemLevels]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[BillableByUsageItemLevels](
	[BUL_ID] [tinyint] NOT NULL,
	[BUL_CLV_ID] [tinyint] NOT NULL,
	[BUL_BUI_ID] [tinyint] NOT NULL,
	[BUL_Name] [varchar](100) NOT NULL,
	[BUL_UnitName] [varchar](100) NOT NULL,
	[BUL_Limitations] [xml] NULL,
	[BUL_IsActive] [bit] NOT NULL,
	[BUL_BUR_ID] [tinyint] NOT NULL,
 CONSTRAINT [PK_BillableByUsageItemLevels] PRIMARY KEY CLUSTERED 
(
	[BUL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Trigger [Consolidation].[trg_BillableByUsageItemLevels_HistoryLogging]    Script Date: 6/8/2020 1:14:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Consolidation].[trg_BillableByUsageItemLevels_HistoryLogging] ON [Consolidation].[BillableByUsageItemLevels]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Consolidation.BillableByUsageItemLevels' TabName, BUL_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.BUL_ID, 
					(SELECT CASE WHEN UPDATE(BUL_CLV_ID) Or @ChangeType = 'D' THEN
							(SELECT 'BUL_CLV_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.BUL_CLV_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.BUL_CLV_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(BUL_BUI_ID) Or @ChangeType = 'D' THEN
							(SELECT 'BUL_BUI_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.BUL_BUI_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.BUL_BUI_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(BUL_Name) Or @ChangeType = 'D' THEN
							(SELECT 'BUL_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.BUL_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.BUL_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(BUL_UnitName) Or @ChangeType = 'D' THEN
							(SELECT 'BUL_UnitName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.BUL_UnitName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.BUL_UnitName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(BUL_IsActive) Or @ChangeType = 'D' THEN
							(SELECT 'BUL_IsActive' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.BUL_IsActive as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.BUL_IsActive as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.BUL_ID = D.BUL_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Consolidation.BillableByUsageItemLevels' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Consolidation].[BillableByUsageItemLevels] DISABLE TRIGGER [trg_BillableByUsageItemLevels_HistoryLogging]
GO
