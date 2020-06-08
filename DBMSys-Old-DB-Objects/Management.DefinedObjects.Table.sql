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
/****** Object:  Table [Management].[DefinedObjects]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Management].[DefinedObjects](
	[DFO_ID] [int] IDENTITY(1,1) NOT NULL,
	[DFO_ClientID] [int] NOT NULL,
	[DFO_PLT_ID] [tinyint] NOT NULL,
	[DFO_Name] [nvarchar](128) NOT NULL,
	[DFO_IsWindowsAuthentication] [bit] NOT NULL,
	[DFO_SLG_ID] [int] NULL,
 CONSTRAINT [PK_DefinedObjects] PRIMARY KEY CLUSTERED 
(
	[DFO_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_DefinedObjects_DFO_PLT_ID#DFO_Name]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_DefinedObjects_DFO_PLT_ID#DFO_Name] ON [Management].[DefinedObjects]
(
	[DFO_PLT_ID] ASC,
	[DFO_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Management].[trg_DefinedObjects_Delete]    Script Date: 6/8/2020 1:15:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Management].[trg_DefinedObjects_Delete] on [Management].[DefinedObjects]
	after delete
as
set nocount on
update Inventory.MonitoredObjects
set MOB_OOS_ID = 3
from deleted
where MOB_PLT_ID = DFO_PLT_ID
	and MOB_Entity_ID = DFO_ID
GO
ALTER TABLE [Management].[DefinedObjects] ENABLE TRIGGER [trg_DefinedObjects_Delete]
GO
/****** Object:  Trigger [Management].[trg_DefinedObjects_HistoryLogging]    Script Date: 6/8/2020 1:15:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Management].[trg_DefinedObjects_HistoryLogging] ON [Management].[DefinedObjects]
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
	INSERT INTO Management.History(HIS_Type, HIS_Datetime, HIS_TableName, HIS_PK_1, 	HIS_Changes, HIS_UserName, HIS_AppName, HIS_HostName)
	SELECT *
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Management.DefinedObjects' TabName, DFO_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.DFO_ID, 
					(SELECT CASE WHEN UPDATE(DFO_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'DFO_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DFO_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DFO_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DFO_PLT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DFO_PLT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DFO_PLT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DFO_PLT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DFO_Name) Or @ChangeType = 'D' THEN
							(SELECT 'DFO_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DFO_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DFO_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DFO_IsWindowsAuthentication) Or @ChangeType = 'D' THEN
							(SELECT 'DFO_IsWindowsAuthentication' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DFO_IsWindowsAuthentication as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DFO_IsWindowsAuthentication as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DFO_SLG_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DFO_SLG_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DFO_SLG_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DFO_SLG_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.DFO_ID = D.DFO_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Management.DefinedObjects' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Management].[DefinedObjects] DISABLE TRIGGER [trg_DefinedObjects_HistoryLogging]
GO
/****** Object:  Trigger [Management].[trg_DefinedObjects_Insert]    Script Date: 6/8/2020 1:15:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Management].[trg_DefinedObjects_Insert] on [Management].[DefinedObjects]
	after insert, update
as
set nocount on

merge Inventory.MonitoredObjects d
	using (select i.DFO_ID, i.DFO_ClientID, i.DFO_PLT_ID, i.DFO_Name, i.DFO_SLG_ID, d.DFO_Name OldName
			from inserted i
				left join deleted d on i.DFO_ID = d.DFO_ID
			) s
				on DFO_PLT_ID = MOB_PLT_ID
					and isnull(OldName, DFO_Name) = MOB_Name
	when matched then update set MOB_Name = DFO_Name,
								MOB_SLG_ID = DFO_SLG_ID
	when not matched then insert(MOB_Entity_ID, MOB_ClientID, MOB_PLT_ID, MOB_Name, MOB_OOS_ID, MOB_SLG_ID)
							values(DFO_ID, DFO_ClientID, DFO_PLT_ID, DFO_Name, 1, DFO_SLG_ID);

merge Inventory.OSServers d
	using (select i.DFO_ClientID, i.DFO_PLT_ID, i.DFO_Name, d.DFO_Name OldName, MOB_ID
			from inserted i
				left join deleted d on i.DFO_ID = d.DFO_ID
				LEFT JOIN Inventory.MonitoredObjects m on i.DFO_ID = m.MOB_Entity_ID and MOB_PLT_ID = i.DFO_PLT_ID
			where i.DFO_PLT_ID = 2
			) s
				on isnull(OldName, DFO_Name) = OSS_Name
					and DFO_PLT_ID = OSS_PLT_ID
	when matched then update set OSS_Name = DFO_Name
	when not matched then insert(OSS_ClientID, OSS_PLT_ID, OSS_Name, OSS_IsClusterNode, OSS_IsVirtualServer,OSS_MOB_ID)
							values(DFO_ClientID, DFO_PLT_ID, DFO_Name, 0, 0, MOB_ID);



;with SecureLoginChanges as
		(select MOB_ID Child_MOB_ID, DFO_SLG_ID New_SLG_ID
			from inserted i
				inner join Inventory.MonitoredObjects on MOB_PLT_ID = DFO_PLT_ID
														and MOB_Name = DFO_Name
			where exists (select *
								from deleted d
								where i.DFO_ID = d.DFO_ID
										and (i.DFO_SLG_ID <> d.DFO_SLG_ID
												or (i.DFO_SLG_ID is not null and d.DFO_SLG_ID is null)
												or (i.DFO_SLG_ID is null and d.DFO_SLG_ID is not null)
											)
						)
		)
update Inventory.MonitoredObjects
set MOB_SLG_ID = New_SLG_ID
from Inventory.ParentChildRelationships
	inner join SecureLoginChanges on Child_MOB_ID = PCR_Child_MOB_ID
where MOB_ID= PCR_Parent_MOB_ID
GO
ALTER TABLE [Management].[DefinedObjects] ENABLE TRIGGER [trg_DefinedObjects_Insert]
GO
