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
/****** Object:  Table [Inventory].[StaleStatistics]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[StaleStatistics](
	[SAS_ID] [int] IDENTITY(1,1) NOT NULL,
	[SAS_ClientID] [int] NOT NULL,
	[SAS_MOB_ID] [int] NOT NULL,
	[SAS_IDB_ID] [int] NOT NULL,
	[SAS_DOT_ID] [tinyint] NOT NULL,
	[SAS_DSN_ID] [int] NOT NULL,
	[SAS_DON_ID] [int] NOT NULL,
	[SAS_StatisticsID] [int] NOT NULL,
	[SAS_DTN_ID] [int] NOT NULL,
	[SAS_IsIndex] [bit] NOT NULL,
	[SAS_RowCount] [bigint] NULL,
	[SAS_IsAutoCreated] [bit] NOT NULL,
	[SAS_IsUserCreated] [bit] NOT NULL,
	[SAS_IsNoRecompute] [bit] NOT NULL,
	[SAS_HasFilter] [bit] NULL,
	[SAS_FilterDefinition] [nvarchar](max) NULL,
	[SAS_StatisticsUpdateDate] [datetime2](3) NULL,
	[SAS_ModifyCount] [int] NOT NULL,
	[SAS_InsertDate] [datetime2](3) NOT NULL,
	[SAS_LastSeenDate] [datetime2](3) NOT NULL,
	[SAS_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_StaleStatistics] PRIMARY KEY CLUSTERED 
(
	[SAS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_StaleStatistics_SAS_MOB_ID#SAS_IDB_ID#SAS_DSN_ID#SAS_DON_ID#SAS_DTN_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_StaleStatistics_SAS_MOB_ID#SAS_IDB_ID#SAS_DSN_ID#SAS_DON_ID#SAS_DTN_ID] ON [Inventory].[StaleStatistics]
(
	[SAS_MOB_ID] ASC,
	[SAS_IDB_ID] ASC,
	[SAS_DSN_ID] ASC,
	[SAS_DON_ID] ASC,
	[SAS_DTN_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_StaleStatistics_HistoryLogging]    Script Date: 6/8/2020 1:15:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_StaleStatistics_HistoryLogging] ON [Inventory].[StaleStatistics]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.StaleStatistics' TabName, SAS_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.SAS_ID, 
					(SELECT CASE WHEN UPDATE(SAS_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'SAS_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SAS_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SAS_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SAS_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'SAS_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SAS_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SAS_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SAS_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'SAS_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SAS_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SAS_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SAS_DOT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'SAS_DOT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SAS_DOT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SAS_DOT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SAS_DSN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'SAS_DSN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SAS_DSN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SAS_DSN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SAS_DON_ID) Or @ChangeType = 'D' THEN
							(SELECT 'SAS_DON_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SAS_DON_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SAS_DON_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SAS_StatisticsID) Or @ChangeType = 'D' THEN
							(SELECT 'SAS_StatisticsID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SAS_StatisticsID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SAS_StatisticsID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SAS_DTN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'SAS_DTN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SAS_DTN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SAS_DTN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SAS_IsIndex) Or @ChangeType = 'D' THEN
							(SELECT 'SAS_IsIndex' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SAS_IsIndex as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SAS_IsIndex as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SAS_RowCount) Or @ChangeType = 'D' THEN
							(SELECT 'SAS_RowCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SAS_RowCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SAS_RowCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SAS_IsAutoCreated) Or @ChangeType = 'D' THEN
							(SELECT 'SAS_IsAutoCreated' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SAS_IsAutoCreated as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SAS_IsAutoCreated as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SAS_IsUserCreated) Or @ChangeType = 'D' THEN
							(SELECT 'SAS_IsUserCreated' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SAS_IsUserCreated as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SAS_IsUserCreated as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SAS_IsNoRecompute) Or @ChangeType = 'D' THEN
							(SELECT 'SAS_IsNoRecompute' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SAS_IsNoRecompute as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SAS_IsNoRecompute as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SAS_HasFilter) Or @ChangeType = 'D' THEN
							(SELECT 'SAS_HasFilter' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SAS_HasFilter as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SAS_HasFilter as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SAS_StatisticsUpdateDate) Or @ChangeType = 'D' THEN
							(SELECT 'SAS_StatisticsUpdateDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SAS_StatisticsUpdateDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SAS_StatisticsUpdateDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SAS_ModifyCount) Or @ChangeType = 'D' THEN
							(SELECT 'SAS_ModifyCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SAS_ModifyCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SAS_ModifyCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.SAS_ID = D.SAS_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.StaleStatistics' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[StaleStatistics] DISABLE TRIGGER [trg_StaleStatistics_HistoryLogging]
GO
