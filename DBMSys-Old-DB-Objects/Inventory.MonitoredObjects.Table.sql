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
/****** Object:  Table [Inventory].[MonitoredObjects]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[MonitoredObjects](
	[MOB_ID] [int] IDENTITY(1,1) NOT NULL,
	[MOB_ClientID] [int] NOT NULL,
	[MOB_PLT_ID] [tinyint] NOT NULL,
	[MOB_Entity_ID] [int] NOT NULL,
	[MOB_Name] [nvarchar](128) NOT NULL,
	[MOB_VER_ID] [int] NULL,
	[MOB_Engine_EDT_ID] [int] NULL,
	[MOB_OOS_ID] [tinyint] NOT NULL,
	[MOB_SLG_ID] [int] NULL,
	[MOB_CTR_ID] [int] NULL,
 CONSTRAINT [PK_MonitoredObjects] PRIMARY KEY CLUSTERED 
(
	[MOB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_MonitoredObjects_MOB_PLC_ID#MOB_Name]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_MonitoredObjects_MOB_PLC_ID#MOB_Name] ON [Inventory].[MonitoredObjects]
(
	[MOB_PLT_ID] ASC,
	[MOB_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_MonitoredObjects_MOB_PLT_ID#MOB_Name]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_MonitoredObjects_MOB_PLT_ID#MOB_Name] ON [Inventory].[MonitoredObjects]
(
	[MOB_PLT_ID] ASC,
	[MOB_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[MonitoredObjects_DeactivationProcedure]    Script Date: 6/8/2020 1:15:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Inventory].[MonitoredObjects_DeactivationProcedure] on [Inventory].[MonitoredObjects]
	for update
as
set nocount on
delete Collect.ScheduledTests
from inserted
where MOB_ID = SCT_MOB_ID
	and MOB_OOS_ID in (2, 3, 4)
	and SCT_STS_ID = 1
GO
ALTER TABLE [Inventory].[MonitoredObjects] ENABLE TRIGGER [MonitoredObjects_DeactivationProcedure]
GO
/****** Object:  Trigger [Inventory].[trg_MonitoredObjects_HistoryLogging]    Script Date: 6/8/2020 1:15:24 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_MonitoredObjects_HistoryLogging] ON [Inventory].[MonitoredObjects]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.MonitoredObjects' TabName, C_MOB_ID, MOB_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.MOB_ID C_MOB_ID, D.MOB_ID, 
					(SELECT CASE WHEN UPDATE(MOB_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'MOB_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MOB_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MOB_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MOB_PLT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'MOB_PLT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MOB_PLT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MOB_PLT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MOB_Entity_ID) Or @ChangeType = 'D' THEN
							(SELECT 'MOB_Entity_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MOB_Entity_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MOB_Entity_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MOB_Name) Or @ChangeType = 'D' THEN
							(SELECT 'MOB_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MOB_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MOB_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MOB_VER_ID) Or @ChangeType = 'D' THEN
							(SELECT 'MOB_VER_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MOB_VER_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MOB_VER_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MOB_Engine_EDT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'MOB_Engine_EDT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MOB_Engine_EDT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MOB_Engine_EDT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MOB_OOS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'MOB_OOS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MOB_OOS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MOB_OOS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MOB_SLG_ID) Or @ChangeType = 'D' THEN
							(SELECT 'MOB_SLG_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MOB_SLG_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MOB_SLG_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.MOB_ID = D.MOB_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.MonitoredObjects' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[MonitoredObjects] DISABLE TRIGGER [trg_MonitoredObjects_HistoryLogging]
GO
