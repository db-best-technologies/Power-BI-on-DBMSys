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
/****** Object:  Table [Inventory].[MirroredDatabases]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[MirroredDatabases](
	[MRD_ID] [int] IDENTITY(1,1) NOT NULL,
	[MRD_ClientID] [int] NOT NULL,
	[MRD_MOB_ID] [int] NOT NULL,
	[MRD_IDB_ID] [int] NOT NULL,
	[MRD_GUID] [uniqueidentifier] NOT NULL,
	[MRD_MST_ID] [tinyint] NOT NULL,
	[MRD_MRL_ID] [tinyint] NOT NULL,
	[MRD_MSL_ID] [tinyint] NOT NULL,
	[MRD_Partner_Name] [nvarchar](128) NULL,
	[MRD_Partner_MOB_ID] [int] NULL,
	[MRD_Witness_Name] [nvarchar](128) NULL,
	[MRD_Witness_MOB_ID] [int] NULL,
	[MRD_MWS_ID] [tinyint] NULL,
	[MRD_ConnectionTimeout] [int] NOT NULL,
	[MRD_MaxRedoQueueSize] [int] NULL,
	[MRD_IsRedoQueueUnlimited] [bit] NULL,
	[MRD_InsertDate] [datetime2](3) NOT NULL,
	[MRD_LastSeenDate] [datetime2](3) NOT NULL,
	[MRD_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_MirroredDatabases] PRIMARY KEY CLUSTERED 
(
	[MRD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_MirroredDatabases_MRD_GUID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_MirroredDatabases_MRD_GUID] ON [Inventory].[MirroredDatabases]
(
	[MRD_GUID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_MirroredDatabases_MRD_MOB_ID#MRD_IDB_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_MirroredDatabases_MRD_MOB_ID#MRD_IDB_ID] ON [Inventory].[MirroredDatabases]
(
	[MRD_MOB_ID] ASC,
	[MRD_IDB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_MirroredDatabases_MRD_MOB_ID#MRD_Last_TRH_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_MirroredDatabases_MRD_MOB_ID#MRD_Last_TRH_ID] ON [Inventory].[MirroredDatabases]
(
	[MRD_MOB_ID] ASC,
	[MRD_Last_TRH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_MirroredDatabases_HistoryLogging]    Script Date: 6/8/2020 1:15:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_MirroredDatabases_HistoryLogging] ON [Inventory].[MirroredDatabases]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.MirroredDatabases' TabName, C_MOB_ID, MRD_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.MRD_MOB_ID C_MOB_ID, D.MRD_ID, 
					(SELECT CASE WHEN UPDATE(MRD_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'MRD_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MRD_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MRD_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MRD_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'MRD_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MRD_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MRD_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MRD_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'MRD_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MRD_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MRD_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MRD_GUID) Or @ChangeType = 'D' THEN
							(SELECT 'MRD_GUID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MRD_GUID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MRD_GUID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MRD_MST_ID) Or @ChangeType = 'D' THEN
							(SELECT 'MRD_MST_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MRD_MST_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MRD_MST_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MRD_MRL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'MRD_MRL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MRD_MRL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MRD_MRL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MRD_MSL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'MRD_MSL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MRD_MSL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MRD_MSL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MRD_Partner_Name) Or @ChangeType = 'D' THEN
							(SELECT 'MRD_Partner_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MRD_Partner_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MRD_Partner_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MRD_Partner_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'MRD_Partner_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MRD_Partner_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MRD_Partner_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MRD_Witness_Name) Or @ChangeType = 'D' THEN
							(SELECT 'MRD_Witness_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MRD_Witness_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MRD_Witness_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MRD_Witness_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'MRD_Witness_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MRD_Witness_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MRD_Witness_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MRD_MWS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'MRD_MWS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MRD_MWS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MRD_MWS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MRD_ConnectionTimeout) Or @ChangeType = 'D' THEN
							(SELECT 'MRD_ConnectionTimeout' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MRD_ConnectionTimeout as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MRD_ConnectionTimeout as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MRD_MaxRedoQueueSize) Or @ChangeType = 'D' THEN
							(SELECT 'MRD_MaxRedoQueueSize' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MRD_MaxRedoQueueSize as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MRD_MaxRedoQueueSize as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MRD_IsRedoQueueUnlimited) Or @ChangeType = 'D' THEN
							(SELECT 'MRD_IsRedoQueueUnlimited' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MRD_IsRedoQueueUnlimited as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MRD_IsRedoQueueUnlimited as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.MRD_ID = D.MRD_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.MirroredDatabases' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[MirroredDatabases] DISABLE TRIGGER [trg_MirroredDatabases_HistoryLogging]
GO
/****** Object:  Trigger [Inventory].[trg_MirroredDatabases_LogRoleSwitches]    Script Date: 6/8/2020 1:15:23 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Inventory].[trg_MirroredDatabases_LogRoleSwitches] on [Inventory].[MirroredDatabases] for update
as
set nocount on
insert into Activity.MirroringRoleSwitches(MRS_ClientID, MRS_MOB_ID, MRS_DateRecorded, MRS_MRD_GUID, MRS_Previous_MRL_ID, MRS_Current_MRL_ID)
select i.MRD_ClientID, i.MRD_MOB_ID, sysdatetime(), i.MRD_GUID, d.MRD_MRL_ID, i.MRD_MRL_ID
from inserted i
	inner join deleted d on i.MRD_ID = d.MRD_ID
							and i.MRD_MRL_ID <> d.MRD_MRL_ID
GO
ALTER TABLE [Inventory].[MirroredDatabases] ENABLE TRIGGER [trg_MirroredDatabases_LogRoleSwitches]
GO
