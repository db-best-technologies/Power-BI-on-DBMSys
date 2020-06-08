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
/****** Object:  Table [Inventory].[AvailabilityGroupReplicatedDatabases]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[AvailabilityGroupReplicatedDatabases](
	[AGD_ID] [int] IDENTITY(1,1) NOT NULL,
	[AGD_ClientID] [int] NOT NULL,
	[AGD_MOB_ID] [int] NOT NULL,
	[AGD_GroupID] [uniqueidentifier] NOT NULL,
	[AGD_ReplicaID] [uniqueidentifier] NOT NULL,
	[AGD_IDB_ID] [int] NOT NULL,
	[AGD_ASS_ID] [tinyint] NOT NULL,
	[AGD_IsCommitParticipant] [bit] NOT NULL,
	[AGD_ASH_ID] [tinyint] NOT NULL,
	[AGD_IDS_ID] [tinyint] NOT NULL,
	[AGD_IsSuspended] [bit] NOT NULL,
	[AGD_ASR_ID] [tinyint] NULL,
	[AGD_IsFailoverReady] [bit] NOT NULL,
	[AGD_IsPendingSecondarySuspend] [bit] NOT NULL,
	[AGD_IsDatabaseJoined] [bit] NOT NULL,
	[AGD_InsertDate] [datetime2](3) NOT NULL,
	[AGD_LastSeenDate] [datetime2](3) NOT NULL,
	[AGD_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_AvailabilityGroupReplicatedDatabases] PRIMARY KEY CLUSTERED 
(
	[AGD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_AvailabilityGroupReplicatedDatabases_AGD_MOB_ID#AGD_GroupID#AGD_ReplicaID#AGD_IDB_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_AvailabilityGroupReplicatedDatabases_AGD_MOB_ID#AGD_GroupID#AGD_ReplicaID#AGD_IDB_ID] ON [Inventory].[AvailabilityGroupReplicatedDatabases]
(
	[AGD_MOB_ID] ASC,
	[AGD_GroupID] ASC,
	[AGD_ReplicaID] ASC,
	[AGD_IDB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_AvailabilityGroupReplicatedDatabases_HistoryLogging]    Script Date: 6/8/2020 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_AvailabilityGroupReplicatedDatabases_HistoryLogging] ON [Inventory].[AvailabilityGroupReplicatedDatabases]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.AvailabilityGroupReplicatedDatabases' TabName, C_MOB_ID, AGD_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.AGD_MOB_ID C_MOB_ID, D.AGD_ID, 
					(SELECT CASE WHEN UPDATE(AGD_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'AGD_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGD_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGD_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGD_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'AGD_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGD_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGD_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGD_GroupID) Or @ChangeType = 'D' THEN
							(SELECT 'AGD_GroupID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGD_GroupID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGD_GroupID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGD_ReplicaID) Or @ChangeType = 'D' THEN
							(SELECT 'AGD_ReplicaID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGD_ReplicaID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGD_ReplicaID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGD_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'AGD_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGD_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGD_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGD_ASS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'AGD_ASS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGD_ASS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGD_ASS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGD_IsCommitParticipant) Or @ChangeType = 'D' THEN
							(SELECT 'AGD_IsCommitParticipant' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGD_IsCommitParticipant as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGD_IsCommitParticipant as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGD_ASH_ID) Or @ChangeType = 'D' THEN
							(SELECT 'AGD_ASH_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGD_ASH_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGD_ASH_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGD_IDS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'AGD_IDS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGD_IDS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGD_IDS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGD_IsSuspended) Or @ChangeType = 'D' THEN
							(SELECT 'AGD_IsSuspended' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGD_IsSuspended as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGD_IsSuspended as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGD_ASR_ID) Or @ChangeType = 'D' THEN
							(SELECT 'AGD_ASR_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGD_ASR_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGD_ASR_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGD_IsFailoverReady) Or @ChangeType = 'D' THEN
							(SELECT 'AGD_IsFailoverReady' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGD_IsFailoverReady as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGD_IsFailoverReady as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGD_IsPendingSecondarySuspend) Or @ChangeType = 'D' THEN
							(SELECT 'AGD_IsPendingSecondarySuspend' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGD_IsPendingSecondarySuspend as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGD_IsPendingSecondarySuspend as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGD_IsDatabaseJoined) Or @ChangeType = 'D' THEN
							(SELECT 'AGD_IsDatabaseJoined' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGD_IsDatabaseJoined as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGD_IsDatabaseJoined as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.AGD_ID = D.AGD_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.AvailabilityGroupReplicatedDatabases' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[AvailabilityGroupReplicatedDatabases] DISABLE TRIGGER [trg_AvailabilityGroupReplicatedDatabases_HistoryLogging]
GO
