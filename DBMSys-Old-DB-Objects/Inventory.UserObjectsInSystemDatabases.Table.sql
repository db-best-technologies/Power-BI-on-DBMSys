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
/****** Object:  Table [Inventory].[UserObjectsInSystemDatabases]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[UserObjectsInSystemDatabases](
	[UOS_ID] [int] IDENTITY(1,1) NOT NULL,
	[UOS_ClientID] [int] NOT NULL,
	[UOS_MOB_ID] [int] NOT NULL,
	[UOS_IDB_ID] [nvarchar](128) NOT NULL,
	[UOS_DOT_ID] [tinyint] NOT NULL,
	[UOS_DSN_ID] [int] NOT NULL,
	[UOS_DON_ID] [int] NOT NULL,
	[UOS_IsStartupProcedure] [bit] NULL,
	[UOS_InsertDate] [datetime2](3) NOT NULL,
	[UOS_LastSeenDate] [datetime2](3) NOT NULL,
	[UOS_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_UserObjectsInSystemDatabases] PRIMARY KEY CLUSTERED 
(
	[UOS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IDX_UserObjectsInSystemDatabases###UOS_MOB_ID#UOS_DSN_ID#UOS_DON_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IDX_UserObjectsInSystemDatabases###UOS_MOB_ID#UOS_DSN_ID#UOS_DON_ID] ON [Inventory].[UserObjectsInSystemDatabases]
(
	[UOS_MOB_ID] ASC,
	[UOS_DSN_ID] ASC,
	[UOS_DON_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_UserObjectsInSystemDatabases_UOS_MOB_ID#UOS_IDB_ID#UOS_DSN_ID#UOS_DON_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_UserObjectsInSystemDatabases_UOS_MOB_ID#UOS_IDB_ID#UOS_DSN_ID#UOS_DON_ID] ON [Inventory].[UserObjectsInSystemDatabases]
(
	[UOS_MOB_ID] ASC,
	[UOS_IDB_ID] ASC,
	[UOS_DSN_ID] ASC,
	[UOS_DON_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_UserObjectsInSystemDatabases_HistoryLogging]    Script Date: 6/8/2020 1:15:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_UserObjectsInSystemDatabases_HistoryLogging] ON [Inventory].[UserObjectsInSystemDatabases]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.UserObjectsInSystemDatabases' TabName, UOS_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.UOS_ID, 
					(SELECT CASE WHEN UPDATE(UOS_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'UOS_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.UOS_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.UOS_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(UOS_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'UOS_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.UOS_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.UOS_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(UOS_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'UOS_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.UOS_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.UOS_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(UOS_DOT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'UOS_DOT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.UOS_DOT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.UOS_DOT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(UOS_DSN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'UOS_DSN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.UOS_DSN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.UOS_DSN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(UOS_DON_ID) Or @ChangeType = 'D' THEN
							(SELECT 'UOS_DON_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.UOS_DON_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.UOS_DON_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(UOS_IsStartupProcedure) Or @ChangeType = 'D' THEN
							(SELECT 'UOS_IsStartupProcedure' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.UOS_IsStartupProcedure as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.UOS_IsStartupProcedure as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.UOS_ID = D.UOS_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.UserObjectsInSystemDatabases' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[UserObjectsInSystemDatabases] DISABLE TRIGGER [trg_UserObjectsInSystemDatabases_HistoryLogging]
GO
