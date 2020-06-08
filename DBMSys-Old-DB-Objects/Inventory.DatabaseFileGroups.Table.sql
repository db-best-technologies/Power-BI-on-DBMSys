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
/****** Object:  Table [Inventory].[DatabaseFileGroups]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[DatabaseFileGroups](
	[DFG_ID] [int] IDENTITY(1,1) NOT NULL,
	[DFG_ClientID] [int] NOT NULL,
	[DFG_MOB_ID] [int] NOT NULL,
	[DFG_IDB_ID] [int] NOT NULL,
	[DFG_Name] [nvarchar](128) NOT NULL,
	[DFG_FGT_ID] [tinyint] NOT NULL,
	[DFG_IsDefault] [bit] NULL,
	[DFG_IsReadOnly] [bit] NULL,
	[DFG_InsertDate] [datetime2](3) NOT NULL,
	[DFG_LastSeenDate] [datetime2](3) NOT NULL,
	[DFG_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_DatabaseFileGroups] PRIMARY KEY CLUSTERED 
(
	[DFG_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_DatabaseFileGroups_DFG_MOB_ID#DFG_IDB_ID#DFG_Name]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_DatabaseFileGroups_DFG_MOB_ID#DFG_IDB_ID#DFG_Name] ON [Inventory].[DatabaseFileGroups]
(
	[DFG_MOB_ID] ASC,
	[DFG_IDB_ID] ASC,
	[DFG_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_DatabaseFileGroups_HistoryLogging]    Script Date: 6/8/2020 1:15:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_DatabaseFileGroups_HistoryLogging] ON [Inventory].[DatabaseFileGroups]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.DatabaseFileGroups' TabName, C_MOB_ID, DFG_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.DFG_MOB_ID C_MOB_ID, D.DFG_ID, 
					(SELECT CASE WHEN UPDATE(DFG_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'DFG_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DFG_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DFG_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DFG_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DFG_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DFG_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DFG_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DFG_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DFG_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DFG_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DFG_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DFG_Name) Or @ChangeType = 'D' THEN
							(SELECT 'DFG_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DFG_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DFG_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DFG_FGT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DFG_FGT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DFG_FGT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DFG_FGT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DFG_IsDefault) Or @ChangeType = 'D' THEN
							(SELECT 'DFG_IsDefault' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DFG_IsDefault as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DFG_IsDefault as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DFG_IsReadOnly) Or @ChangeType = 'D' THEN
							(SELECT 'DFG_IsReadOnly' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DFG_IsReadOnly as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DFG_IsReadOnly as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.DFG_ID = D.DFG_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.DatabaseFileGroups' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[DatabaseFileGroups] DISABLE TRIGGER [trg_DatabaseFileGroups_HistoryLogging]
GO
