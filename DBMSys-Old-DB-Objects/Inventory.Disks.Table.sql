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
/****** Object:  Table [Inventory].[Disks]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[Disks](
	[DSK_ID] [int] IDENTITY(1,1) NOT NULL,
	[DSK_ClientID] [int] NOT NULL,
	[DSK_MOB_ID] [int] NOT NULL,
	[DSK_FST_ID] [tinyint] NULL,
	[DSK_IsClusteredResource] [bit] NULL,
	[DSK_Path] [varchar](500) NOT NULL,
	[DSK_Letter]  AS (left([DSK_Path],(1))),
	[DSK_TotalSpaceMB] [bigint] NOT NULL,
	[DSK_BlockSize] [bigint] NULL,
	[DSK_IsCompressed] [bit] NULL,
	[DSK_SerialNumber] [bigint] NULL,
	[DSK_InsertDate] [datetime2](3) NOT NULL,
	[DSK_LastSeenDate] [datetime2](3) NOT NULL,
	[DSK_Last_TRH_ID] [int] NOT NULL,
	[DSK_InstanceName] [varchar](500) NULL,
 CONSTRAINT [PK_Disks] PRIMARY KEY CLUSTERED 
(
	[DSK_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Disks_DSK_MOB_ID#DSK_InstanceName###DSK_InstanceName_IS_NOT_NULL]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Disks_DSK_MOB_ID#DSK_InstanceName###DSK_InstanceName_IS_NOT_NULL] ON [Inventory].[Disks]
(
	[DSK_MOB_ID] ASC,
	[DSK_InstanceName] ASC
)
WHERE ([DSK_InstanceName] IS NOT NULL)
WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Disks_DSK_MOB_ID#DSK_Path]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Disks_DSK_MOB_ID#DSK_Path] ON [Inventory].[Disks]
(
	[DSK_MOB_ID] ASC,
	[DSK_Path] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_Disks_HistoryLogging]    Script Date: 6/8/2020 1:15:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_Disks_HistoryLogging] ON [Inventory].[Disks]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.Disks' TabName, C_MOB_ID, DSK_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.DSK_MOB_ID C_MOB_ID, D.DSK_ID, 
					(SELECT CASE WHEN UPDATE(DSK_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'DSK_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DSK_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DSK_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DSK_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DSK_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DSK_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DSK_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DSK_FST_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DSK_FST_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DSK_FST_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DSK_FST_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DSK_IsClusteredResource) Or @ChangeType = 'D' THEN
							(SELECT 'DSK_IsClusteredResource' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DSK_IsClusteredResource as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DSK_IsClusteredResource as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DSK_Path) Or @ChangeType = 'D' THEN
							(SELECT 'DSK_Path' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DSK_Path as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DSK_Path as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DSK_TotalSpaceMB) Or @ChangeType = 'D' THEN
							(SELECT 'DSK_TotalSpaceMB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DSK_TotalSpaceMB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DSK_TotalSpaceMB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DSK_BlockSize) Or @ChangeType = 'D' THEN
							(SELECT 'DSK_BlockSize' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DSK_BlockSize as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DSK_BlockSize as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DSK_IsCompressed) Or @ChangeType = 'D' THEN
							(SELECT 'DSK_IsCompressed' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DSK_IsCompressed as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DSK_IsCompressed as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DSK_SerialNumber) Or @ChangeType = 'D' THEN
							(SELECT 'DSK_SerialNumber' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DSK_SerialNumber as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DSK_SerialNumber as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DSK_InstanceName) Or @ChangeType = 'D' THEN
							(SELECT 'DSK_InstanceName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DSK_InstanceName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DSK_InstanceName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.DSK_ID = D.DSK_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.Disks' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[Disks] DISABLE TRIGGER [trg_Disks_HistoryLogging]
GO
