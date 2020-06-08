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
/****** Object:  Table [Inventory].[FullTextCatalogs]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[FullTextCatalogs](
	[FTC_ID] [int] IDENTITY(1,1) NOT NULL,
	[FTC_ClientID] [int] NOT NULL,
	[FTC_MOB_ID] [int] NOT NULL,
	[FTC_IDB_ID] [int] NOT NULL,
	[FTC_CatalogName] [nvarchar](128) NOT NULL,
	[FTC_CatalogPath] [nvarchar](256) NULL,
	[FTC_IsDefault] [bit] NOT NULL,
	[FTC_IsAccentSensitivityOn] [bit] NOT NULL,
	[FTC_DFG_ID] [int] NULL,
	[FTC_FBF_ID] [int] NULL,
	[FTC_LastPopulationDate] [datetime2](3) NOT NULL,
	[FTC_FCS_ID] [tinyint] NOT NULL,
	[FTC_InsertDate] [datetime2](3) NOT NULL,
	[FTC_LastSeenDate] [datetime2](3) NOT NULL,
	[FTC_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_FullTextCatalogs] PRIMARY KEY CLUSTERED 
(
	[FTC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_FullTextCatalogs_FTC_MOB_ID#FTC_IDB_ID#FTC_CatalogName]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_FullTextCatalogs_FTC_MOB_ID#FTC_IDB_ID#FTC_CatalogName] ON [Inventory].[FullTextCatalogs]
(
	[FTC_MOB_ID] ASC,
	[FTC_IDB_ID] ASC,
	[FTC_CatalogName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_FullTextCatalogs_HistoryLogging]    Script Date: 6/8/2020 1:15:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_FullTextCatalogs_HistoryLogging] ON [Inventory].[FullTextCatalogs]
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
	INSERT INTO Inventory.History(HIS_Type, HIS_Datetime, HIS_TableName, HIS_PK_1, 	HIS_Changes, HIS_UserName, HIS_AppName, HIS_HostName)
	SELECT *
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.FullTextCatalogs' TabName, FTC_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.FTC_ID, 
					(SELECT CASE WHEN UPDATE(FTC_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'FTC_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FTC_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FTC_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FTC_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'FTC_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FTC_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FTC_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FTC_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'FTC_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FTC_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FTC_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FTC_CatalogName) Or @ChangeType = 'D' THEN
							(SELECT 'FTC_CatalogName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FTC_CatalogName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FTC_CatalogName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FTC_CatalogPath) Or @ChangeType = 'D' THEN
							(SELECT 'FTC_CatalogPath' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FTC_CatalogPath as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FTC_CatalogPath as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FTC_IsDefault) Or @ChangeType = 'D' THEN
							(SELECT 'FTC_IsDefault' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FTC_IsDefault as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FTC_IsDefault as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FTC_IsAccentSensitivityOn) Or @ChangeType = 'D' THEN
							(SELECT 'FTC_IsAccentSensitivityOn' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FTC_IsAccentSensitivityOn as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FTC_IsAccentSensitivityOn as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FTC_DFG_ID) Or @ChangeType = 'D' THEN
							(SELECT 'FTC_DFG_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FTC_DFG_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FTC_DFG_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FTC_FBF_ID) Or @ChangeType = 'D' THEN
							(SELECT 'FTC_FBF_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FTC_FBF_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FTC_FBF_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FTC_LastPopulationDate) Or @ChangeType = 'D' THEN
							(SELECT 'FTC_LastPopulationDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FTC_LastPopulationDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FTC_LastPopulationDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(FTC_FCS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'FTC_FCS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.FTC_FCS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.FTC_FCS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.FTC_ID = D.FTC_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.FullTextCatalogs' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[FullTextCatalogs] DISABLE TRIGGER [trg_FullTextCatalogs_HistoryLogging]
GO
