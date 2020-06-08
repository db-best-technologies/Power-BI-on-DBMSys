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
/****** Object:  Table [Inventory].[InstalledPatches]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[InstalledPatches](
	[ISP_ID] [tinyint] IDENTITY(1,1) NOT NULL,
	[ISP_ClientID] [int] NOT NULL,
	[ISP_MOB_ID] [int] NOT NULL,
	[ISP_PTY_ID] [int] NOT NULL,
	[ISP_InstalledDate] [date] NULL,
	[ISP_PST_ID] [tinyint] NULL,
	[ISP_InsertDate] [datetime2](3) NOT NULL,
	[ISP_LastSeenDate] [datetime2](3) NOT NULL,
	[ISP_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_InstalledPatches] PRIMARY KEY CLUSTERED 
(
	[ISP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_InstalledPatches_ISP_MOB_ID#ISP_PTY_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_InstalledPatches_ISP_MOB_ID#ISP_PTY_ID] ON [Inventory].[InstalledPatches]
(
	[ISP_MOB_ID] ASC,
	[ISP_PTY_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_InstalledPatches_HistoryLogging]    Script Date: 6/8/2020 1:15:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_InstalledPatches_HistoryLogging] ON [Inventory].[InstalledPatches]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.InstalledPatches' TabName, ISP_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.ISP_ID, 
					(SELECT CASE WHEN UPDATE(ISP_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'ISP_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISP_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISP_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISP_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ISP_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISP_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISP_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISP_PTY_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ISP_PTY_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISP_PTY_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISP_PTY_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISP_InstalledDate) Or @ChangeType = 'D' THEN
							(SELECT 'ISP_InstalledDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISP_InstalledDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISP_InstalledDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISP_PST_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ISP_PST_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISP_PST_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISP_PST_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.ISP_ID = D.ISP_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.InstalledPatches' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[InstalledPatches] DISABLE TRIGGER [trg_InstalledPatches_HistoryLogging]
GO
