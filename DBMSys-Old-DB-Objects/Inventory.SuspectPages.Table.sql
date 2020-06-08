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
/****** Object:  Table [Inventory].[SuspectPages]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[SuspectPages](
	[SSP_ID] [int] IDENTITY(1,1) NOT NULL,
	[SSP_ClientID] [int] NOT NULL,
	[SSP_MOB_ID] [int] NOT NULL,
	[SSP_IDB_ID] [int] NOT NULL,
	[SSP_FileID] [int] NULL,
	[SSP_PageID] [bigint] NULL,
	[SSP_EventType] [int] NULL,
	[SSP_ErrorCount] [int] NULL,
	[SSP_LastUpdateDate] [datetime2](3) NULL,
	[SSP_InsertDate] [datetime2](3) NOT NULL,
	[SSP_LastSeenDate] [datetime2](3) NOT NULL,
	[SSP_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_SuspectPages] PRIMARY KEY CLUSTERED 
(
	[SSP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_SuspectPages_SSP_MOB_ID#SSP_IDB#SSP_FileID#SSP_PageID#SSP_EventType]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_SuspectPages_SSP_MOB_ID#SSP_IDB#SSP_FileID#SSP_PageID#SSP_EventType] ON [Inventory].[SuspectPages]
(
	[SSP_MOB_ID] ASC,
	[SSP_IDB_ID] ASC,
	[SSP_FileID] ASC,
	[SSP_PageID] ASC,
	[SSP_EventType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_SuspectPages_HistoryLogging]    Script Date: 6/8/2020 1:15:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_SuspectPages_HistoryLogging] ON [Inventory].[SuspectPages]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.SuspectPages' TabName, C_MOB_ID, SSP_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.SSP_MOB_ID C_MOB_ID, D.SSP_ID, 
					(SELECT CASE WHEN UPDATE(SSP_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'SSP_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SSP_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SSP_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SSP_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'SSP_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SSP_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SSP_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SSP_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'SSP_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SSP_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SSP_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SSP_FileID) Or @ChangeType = 'D' THEN
							(SELECT 'SSP_FileID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SSP_FileID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SSP_FileID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SSP_PageID) Or @ChangeType = 'D' THEN
							(SELECT 'SSP_PageID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SSP_PageID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SSP_PageID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SSP_EventType) Or @ChangeType = 'D' THEN
							(SELECT 'SSP_EventType' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SSP_EventType as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SSP_EventType as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SSP_ErrorCount) Or @ChangeType = 'D' THEN
							(SELECT 'SSP_ErrorCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SSP_ErrorCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SSP_ErrorCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SSP_LastUpdateDate) Or @ChangeType = 'D' THEN
							(SELECT 'SSP_LastUpdateDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SSP_LastUpdateDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SSP_LastUpdateDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.SSP_ID = D.SSP_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.SuspectPages' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[SuspectPages] DISABLE TRIGGER [trg_SuspectPages_HistoryLogging]
GO
