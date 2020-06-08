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
/****** Object:  Table [Inventory].[TransactionalReplicationSubscriptions]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[TransactionalReplicationSubscriptions](
	[TRB_ID] [int] IDENTITY(1,1) NOT NULL,
	[TRB_ClientID] [int] NOT NULL,
	[TRB_MOB_ID] [int] NOT NULL,
	[TRB_TRP_ID] [int] NOT NULL,
	[TRB_DistributionAgentID] [int] NOT NULL,
	[TRB_TPT_ID] [tinyint] NOT NULL,
	[TRB_SubscriberServerName] [nvarchar](128) NOT NULL,
	[TRB_Subscriber_MOB_ID] [int] NULL,
	[TRB_SubscriberDatabaseName] [nvarchar](128) NOT NULL,
	[TRB_Subscriber_IDB_ID] [int] NOT NULL,
	[TRB_DistributionAgent_TRA_ID] [tinyint] NULL,
	[TRB_InsertDate] [datetime2](3) NOT NULL,
	[TRB_LastSeenDate] [datetime2](3) NOT NULL,
	[TRB_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_TransactionalReplicationSubscriptions] PRIMARY KEY CLUSTERED 
(
	[TRB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_TransactionalReplicationSubscriptions_TRB_MOB_ID#TRB_TRP_ID#TRB_DistributionAgentID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_TransactionalReplicationSubscriptions_TRB_MOB_ID#TRB_TRP_ID#TRB_DistributionAgentID] ON [Inventory].[TransactionalReplicationSubscriptions]
(
	[TRB_MOB_ID] ASC,
	[TRB_TRP_ID] ASC,
	[TRB_DistributionAgentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_TransactionalReplicationSubscriptions_TRB_TRP_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_TransactionalReplicationSubscriptions_TRB_TRP_ID] ON [Inventory].[TransactionalReplicationSubscriptions]
(
	[TRB_TRP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_TransactionalReplicationSubscriptions_HistoryLogging]    Script Date: 6/8/2020 1:15:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_TransactionalReplicationSubscriptions_HistoryLogging] ON [Inventory].[TransactionalReplicationSubscriptions]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.TransactionalReplicationSubscriptions' TabName, C_MOB_ID, TRB_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.TRB_MOB_ID C_MOB_ID, D.TRB_ID, 
					(SELECT CASE WHEN UPDATE(TRB_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'TRB_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TRB_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TRB_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TRB_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'TRB_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TRB_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TRB_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TRB_TRP_ID) Or @ChangeType = 'D' THEN
							(SELECT 'TRB_TRP_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TRB_TRP_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TRB_TRP_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TRB_DistributionAgentID) Or @ChangeType = 'D' THEN
							(SELECT 'TRB_DistributionAgentID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TRB_DistributionAgentID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TRB_DistributionAgentID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TRB_TPT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'TRB_TPT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TRB_TPT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TRB_TPT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TRB_SubscriberServerName) Or @ChangeType = 'D' THEN
							(SELECT 'TRB_SubscriberServerName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TRB_SubscriberServerName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TRB_SubscriberServerName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TRB_Subscriber_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'TRB_Subscriber_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TRB_Subscriber_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TRB_Subscriber_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TRB_SubscriberDatabaseName) Or @ChangeType = 'D' THEN
							(SELECT 'TRB_SubscriberDatabaseName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TRB_SubscriberDatabaseName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TRB_SubscriberDatabaseName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TRB_Subscriber_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'TRB_Subscriber_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TRB_Subscriber_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TRB_Subscriber_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.TRB_ID = D.TRB_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.TransactionalReplicationSubscriptions' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[TransactionalReplicationSubscriptions] DISABLE TRIGGER [trg_TransactionalReplicationSubscriptions_HistoryLogging]
GO
