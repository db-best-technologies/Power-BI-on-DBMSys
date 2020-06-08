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
/****** Object:  Table [Consolidation].[CloudMachineStorageCompatibility]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[CloudMachineStorageCompatibility](
	[CMC_ID] [int] IDENTITY(1,1) NOT NULL,
	[CMC_CMT_ID] [int] NOT NULL,
	[CMC_Storage_BUL_ID] [tinyint] NOT NULL,
	[CMC_MaxDiskCount] [tinyint] NOT NULL,
	[CMC_8KBIOPSLimit] [int] NULL,
	[CMC_8KBMBPSLimit] [int] NULL,
	[CMC_64KBIOPSLimit] [int] NULL,
	[CMC_64KBMBPSLimit] [int] NULL,
 CONSTRAINT [PK_CloudMachineStorageCompatibility] PRIMARY KEY CLUSTERED 
(
	[CMC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_CloudMachineStorageCompatibility_CMC_CMT_ID#CMC_Storage_BUL_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_CloudMachineStorageCompatibility_CMC_CMT_ID#CMC_Storage_BUL_ID] ON [Consolidation].[CloudMachineStorageCompatibility]
(
	[CMC_CMT_ID] ASC,
	[CMC_Storage_BUL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Consolidation].[trg_CloudMachineStorageCompatibility_HistoryLogging]    Script Date: 6/8/2020 1:14:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Consolidation].[trg_CloudMachineStorageCompatibility_HistoryLogging] ON [Consolidation].[CloudMachineStorageCompatibility]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Consolidation.CloudMachineStorageCompatibility' TabName, CMC_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.CMC_ID, 
					(SELECT CASE WHEN UPDATE(CMC_CMT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'CMC_CMT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMC_CMT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMC_CMT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMC_Storage_BUL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'CMC_Storage_BUL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMC_Storage_BUL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMC_Storage_BUL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMC_MaxDiskCount) Or @ChangeType = 'D' THEN
							(SELECT 'CMC_MaxDiskCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMC_MaxDiskCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMC_MaxDiskCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.CMC_ID = D.CMC_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Consolidation.CloudMachineStorageCompatibility' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Consolidation].[CloudMachineStorageCompatibility] DISABLE TRIGGER [trg_CloudMachineStorageCompatibility_HistoryLogging]
GO
