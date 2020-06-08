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
/****** Object:  Table [Inventory].[PlanGuides]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[PlanGuides](
	[PGD_ID] [int] IDENTITY(1,1) NOT NULL,
	[PGD_ClientID] [int] NOT NULL,
	[PGD_MOB_ID] [int] NOT NULL,
	[PGD_IDB_ID] [int] NOT NULL,
	[PGD_PlanGuideName] [nvarchar](128) NOT NULL,
	[PGD_CreateDate] [datetime2](3) NOT NULL,
	[PGD_ModifyDate] [datetime2](3) NOT NULL,
	[PGD_PGS_ID] [tinyint] NOT NULL,
	[PGD_QueryText_SQS_ID] [int] NULL,
	[PGD_ScopeBatch_SQS_ID] [int] NULL,
	[PGD_ScopeObject_DOT_ID] [int] NULL,
	[PGD_ScopeObject_DSN_ID] [int] NULL,
	[PGD_ScopeObject_DON_ID] [int] NULL,
	[PGD_PlanParameters_SQS_ID] [int] NULL,
	[PGD_PlanHints_SQS_ID] [int] NULL,
	[PGD_InsertDate] [datetime2](3) NOT NULL,
	[PGD_LastSeenDate] [datetime2](3) NOT NULL,
	[PGD_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_PlanGuides] PRIMARY KEY CLUSTERED 
(
	[PGD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_PlanGuides_PGD_MOB_ID#PGD_IDB_ID#PGD_PlanGuideName]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_PlanGuides_PGD_MOB_ID#PGD_IDB_ID#PGD_PlanGuideName] ON [Inventory].[PlanGuides]
(
	[PGD_MOB_ID] ASC,
	[PGD_IDB_ID] ASC,
	[PGD_PlanGuideName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_PlanGuides_HistoryLogging]    Script Date: 6/8/2020 1:15:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_PlanGuides_HistoryLogging] ON [Inventory].[PlanGuides]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.PlanGuides' TabName, PGD_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.PGD_ID, 
					(SELECT CASE WHEN UPDATE(PGD_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'PGD_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PGD_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PGD_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PGD_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PGD_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PGD_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PGD_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PGD_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PGD_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PGD_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PGD_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PGD_PlanGuideName) Or @ChangeType = 'D' THEN
							(SELECT 'PGD_PlanGuideName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PGD_PlanGuideName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PGD_PlanGuideName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PGD_CreateDate) Or @ChangeType = 'D' THEN
							(SELECT 'PGD_CreateDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PGD_CreateDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PGD_CreateDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PGD_ModifyDate) Or @ChangeType = 'D' THEN
							(SELECT 'PGD_ModifyDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PGD_ModifyDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PGD_ModifyDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PGD_PGS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PGD_PGS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PGD_PGS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PGD_PGS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PGD_QueryText_SQS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PGD_QueryText_SQS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PGD_QueryText_SQS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PGD_QueryText_SQS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PGD_ScopeBatch_SQS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PGD_ScopeBatch_SQS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PGD_ScopeBatch_SQS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PGD_ScopeBatch_SQS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PGD_ScopeObject_DOT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PGD_ScopeObject_DOT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PGD_ScopeObject_DOT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PGD_ScopeObject_DOT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PGD_ScopeObject_DSN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PGD_ScopeObject_DSN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PGD_ScopeObject_DSN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PGD_ScopeObject_DSN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PGD_ScopeObject_DON_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PGD_ScopeObject_DON_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PGD_ScopeObject_DON_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PGD_ScopeObject_DON_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PGD_PlanParameters_SQS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PGD_PlanParameters_SQS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PGD_PlanParameters_SQS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PGD_PlanParameters_SQS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PGD_PlanHints_SQS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PGD_PlanHints_SQS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PGD_PlanHints_SQS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PGD_PlanHints_SQS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.PGD_ID = D.PGD_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.PlanGuides' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[PlanGuides] DISABLE TRIGGER [trg_PlanGuides_HistoryLogging]
GO
