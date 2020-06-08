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
/****** Object:  Table [Inventory].[TransactionalReplicationPublications]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[TransactionalReplicationPublications](
	[TRP_ID] [int] IDENTITY(1,1) NOT NULL,
	[TRP_ClientID] [int] NOT NULL,
	[TRP_MOB_ID] [int] NOT NULL,
	[TRP_Name] [nvarchar](128) NOT NULL,
	[TRP_IDB_ID] [int] NOT NULL,
	[TRP_Distributor_MOB_ID] [int] NOT NULL,
	[TRP_Distributor_IDB_ID] [int] NOT NULL,
	[TRP_LogReader_TRA_ID] [tinyint] NULL,
	[TRP_SnapshotAgent_TRA_ID] [tinyint] NULL,
	[TRP_InsertDate] [datetime2](3) NOT NULL,
	[TRP_LastSeenDate] [datetime2](3) NOT NULL,
	[TRP_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_TransactionalReplicationPublications] PRIMARY KEY CLUSTERED 
(
	[TRP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_TransactionalReplicationPublications_TRP_Distributor_MOB_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_TransactionalReplicationPublications_TRP_Distributor_MOB_ID] ON [Inventory].[TransactionalReplicationPublications]
(
	[TRP_Distributor_MOB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_TransactionalReplicationPublications_TRP_MOB_ID#TRP_Name]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_TransactionalReplicationPublications_TRP_MOB_ID#TRP_Name] ON [Inventory].[TransactionalReplicationPublications]
(
	[TRP_MOB_ID] ASC,
	[TRP_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_TransactionalReplicationPublications_HistoryLogging]    Script Date: 6/8/2020 1:15:35 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_TransactionalReplicationPublications_HistoryLogging] ON [Inventory].[TransactionalReplicationPublications]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.TransactionalReplicationPublications' TabName, C_MOB_ID, TRP_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.TRP_MOB_ID C_MOB_ID, D.TRP_ID, 
					(SELECT CASE WHEN UPDATE(TRP_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'TRP_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TRP_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TRP_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TRP_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'TRP_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TRP_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TRP_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TRP_Name) Or @ChangeType = 'D' THEN
							(SELECT 'TRP_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TRP_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TRP_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TRP_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'TRP_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TRP_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TRP_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TRP_Distributor_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'TRP_Distributor_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TRP_Distributor_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TRP_Distributor_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TRP_Distributor_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'TRP_Distributor_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TRP_Distributor_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TRP_Distributor_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.TRP_ID = D.TRP_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.TransactionalReplicationPublications' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[TransactionalReplicationPublications] DISABLE TRIGGER [trg_TransactionalReplicationPublications_HistoryLogging]
GO
