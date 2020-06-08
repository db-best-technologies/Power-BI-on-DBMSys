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
/****** Object:  Table [Inventory].[LinkedServers]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[LinkedServers](
	[LNS_ID] [int] IDENTITY(1,1) NOT NULL,
	[LNS_ClientID] [int] NOT NULL,
	[LNS_MOB_ID] [int] NOT NULL,
	[LNS_Name] [nvarchar](128) NOT NULL,
	[LNS_LPT_ID] [tinyint] NOT NULL,
	[LNS_LPR_ID] [tinyint] NOT NULL,
	[LNS_DataSource] [nvarchar](128) NULL,
	[LNS_DataSource_MOB_ID] [int] NULL,
	[LNS_Location] [nvarchar](4000) NULL,
	[LNS_ProviderString] [nvarchar](4000) NULL,
	[LNS_Catalog] [nvarchar](128) NULL,
	[LNS_Catalog_IDB_ID] [int] NULL,
	[LNS_IsRPCOutEnabled] [bit] NOT NULL,
	[LNS_IsDataAccessEnabled] [bit] NOT NULL,
	[LNS_IsCollationCompatible] [bit] NOT NULL,
	[LNS_UsesRemoteCollation] [bit] NOT NULL,
	[LNS_CLT_ID] [smallint] NULL,
	[LNS_LazySchemaValidation] [bit] NOT NULL,
	[LNS_IsRemoteProcTransactionPromotionEnabled] [bit] NULL,
	[LNS_InsertDate] [datetime2](3) NOT NULL,
	[LNS_LastSeenDate] [datetime2](3) NOT NULL,
	[LNS_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_LinkedServers] PRIMARY KEY CLUSTERED 
(
	[LNS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_LinkedServers_LNS_MOB_ID#LNS_Name]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_LinkedServers_LNS_MOB_ID#LNS_Name] ON [Inventory].[LinkedServers]
(
	[LNS_MOB_ID] ASC,
	[LNS_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_LinkedServers_HistoryLogging]    Script Date: 6/8/2020 1:15:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_LinkedServers_HistoryLogging] ON [Inventory].[LinkedServers]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.LinkedServers' TabName, LNS_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.LNS_ID, 
					(SELECT CASE WHEN UPDATE(LNS_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'LNS_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LNS_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LNS_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LNS_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'LNS_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LNS_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LNS_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LNS_Name) Or @ChangeType = 'D' THEN
							(SELECT 'LNS_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LNS_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LNS_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LNS_LPT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'LNS_LPT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LNS_LPT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LNS_LPT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LNS_LPR_ID) Or @ChangeType = 'D' THEN
							(SELECT 'LNS_LPR_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LNS_LPR_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LNS_LPR_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LNS_DataSource) Or @ChangeType = 'D' THEN
							(SELECT 'LNS_DataSource' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LNS_DataSource as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LNS_DataSource as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LNS_DataSource_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'LNS_DataSource_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LNS_DataSource_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LNS_DataSource_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LNS_Location) Or @ChangeType = 'D' THEN
							(SELECT 'LNS_Location' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LNS_Location as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LNS_Location as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LNS_ProviderString) Or @ChangeType = 'D' THEN
							(SELECT 'LNS_ProviderString' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LNS_ProviderString as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LNS_ProviderString as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LNS_Catalog) Or @ChangeType = 'D' THEN
							(SELECT 'LNS_Catalog' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LNS_Catalog as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LNS_Catalog as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LNS_Catalog_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'LNS_Catalog_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LNS_Catalog_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LNS_Catalog_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LNS_IsRPCOutEnabled) Or @ChangeType = 'D' THEN
							(SELECT 'LNS_IsRPCOutEnabled' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LNS_IsRPCOutEnabled as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LNS_IsRPCOutEnabled as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LNS_IsDataAccessEnabled) Or @ChangeType = 'D' THEN
							(SELECT 'LNS_IsDataAccessEnabled' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LNS_IsDataAccessEnabled as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LNS_IsDataAccessEnabled as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LNS_IsCollationCompatible) Or @ChangeType = 'D' THEN
							(SELECT 'LNS_IsCollationCompatible' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LNS_IsCollationCompatible as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LNS_IsCollationCompatible as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LNS_UsesRemoteCollation) Or @ChangeType = 'D' THEN
							(SELECT 'LNS_UsesRemoteCollation' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LNS_UsesRemoteCollation as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LNS_UsesRemoteCollation as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LNS_CLT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'LNS_CLT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LNS_CLT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LNS_CLT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LNS_LazySchemaValidation) Or @ChangeType = 'D' THEN
							(SELECT 'LNS_LazySchemaValidation' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LNS_LazySchemaValidation as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LNS_LazySchemaValidation as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LNS_IsRemoteProcTransactionPromotionEnabled) Or @ChangeType = 'D' THEN
							(SELECT 'LNS_IsRemoteProcTransactionPromotionEnabled' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LNS_IsRemoteProcTransactionPromotionEnabled as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LNS_IsRemoteProcTransactionPromotionEnabled as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.LNS_ID = D.LNS_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.LinkedServers' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[LinkedServers] DISABLE TRIGGER [trg_LinkedServers_HistoryLogging]
GO
