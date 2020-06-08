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
/****** Object:  Table [Inventory].[PossiblyBadCode]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[PossiblyBadCode](
	[PBC_ID] [int] IDENTITY(1,1) NOT NULL,
	[PBC_ClientID] [int] NOT NULL,
	[PBC_MOB_ID] [int] NOT NULL,
	[PBC_IDB_ID] [nvarchar](128) NOT NULL,
	[PBC_DOT_ID] [tinyint] NOT NULL,
	[PBC_DSN_ID] [int] NOT NULL,
	[PBC_DON_ID] [int] NOT NULL,
	[PBC_HasSelectStar] [bit] NOT NULL,
	[PBC_HasNonAnsiOuterJoin] [bit] NOT NULL,
	[PBC_HasGoto] [bit] NOT NULL,
	[PBC_InsertDate] [datetime2](3) NOT NULL,
	[PBC_LastSeenDate] [datetime2](3) NOT NULL,
	[PBC_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_PossiblyBadCode] PRIMARY KEY CLUSTERED 
(
	[PBC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_PossiblyBadCode_PBC_MOB_ID#PBC_IDB_ID#PBC_DSN_ID#PBC_DON_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_PossiblyBadCode_PBC_MOB_ID#PBC_IDB_ID#PBC_DSN_ID#PBC_DON_ID] ON [Inventory].[PossiblyBadCode]
(
	[PBC_MOB_ID] ASC,
	[PBC_IDB_ID] ASC,
	[PBC_DSN_ID] ASC,
	[PBC_DON_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_PossiblyBadCode_HistoryLogging]    Script Date: 6/8/2020 1:15:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_PossiblyBadCode_HistoryLogging] ON [Inventory].[PossiblyBadCode]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.PossiblyBadCode' TabName, PBC_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.PBC_ID, 
					(SELECT CASE WHEN UPDATE(PBC_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'PBC_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PBC_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PBC_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PBC_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PBC_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PBC_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PBC_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PBC_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PBC_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PBC_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PBC_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PBC_DOT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PBC_DOT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PBC_DOT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PBC_DOT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PBC_DSN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PBC_DSN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PBC_DSN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PBC_DSN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PBC_DON_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PBC_DON_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PBC_DON_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PBC_DON_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PBC_HasSelectStar) Or @ChangeType = 'D' THEN
							(SELECT 'PBC_HasSelectStar' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PBC_HasSelectStar as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PBC_HasSelectStar as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PBC_HasNonAnsiOuterJoin) Or @ChangeType = 'D' THEN
							(SELECT 'PBC_HasNonAnsiOuterJoin' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PBC_HasNonAnsiOuterJoin as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PBC_HasNonAnsiOuterJoin as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PBC_HasGoto) Or @ChangeType = 'D' THEN
							(SELECT 'PBC_HasGoto' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PBC_HasGoto as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PBC_HasGoto as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.PBC_ID = D.PBC_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.PossiblyBadCode' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[PossiblyBadCode] DISABLE TRIGGER [trg_PossiblyBadCode_HistoryLogging]
GO
