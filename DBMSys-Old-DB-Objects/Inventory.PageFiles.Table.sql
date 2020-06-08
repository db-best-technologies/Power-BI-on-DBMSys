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
/****** Object:  Table [Inventory].[PageFiles]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[PageFiles](
	[PGF_ID] [int] IDENTITY(1,1) NOT NULL,
	[PGF_ClientID] [int] NOT NULL,
	[PGF_MOB_ID] [int] NOT NULL,
	[PGF_Location] [varchar](1000) NOT NULL,
	[PGF_DSK_ID] [int] NOT NULL,
	[PGF_AllocatedBaseSizeMB] [int] NOT NULL,
	[PGF_CurrentUsageMB] [int] NOT NULL,
	[PGF_PFS_ID] [tinyint] NULL,
	[PGF_IsTempFile] [bit] NULL,
	[PGF_InsertDate] [datetime2](3) NOT NULL,
	[PGF_LastSeenDate] [datetime2](3) NOT NULL,
	[PGF_Last_TRH_ID] [int] NOT NULL,
	[PGF_LocationHashed]  AS (hashbytes('MD5',left(CONVERT([varchar](max),[PGF_Location],(0)),(8000)))),
 CONSTRAINT [PK_PageFiles] PRIMARY KEY CLUSTERED 
(
	[PGF_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
GO
/****** Object:  Index [IX_PageFiles_PGF_MOB_ID#PGF_LocationHashed]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_PageFiles_PGF_MOB_ID#PGF_LocationHashed] ON [Inventory].[PageFiles]
(
	[PGF_MOB_ID] ASC,
	[PGF_LocationHashed] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_PageFiles_HistoryLogging]    Script Date: 6/8/2020 1:15:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_PageFiles_HistoryLogging] ON [Inventory].[PageFiles]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.PageFiles' TabName, C_MOB_ID, PGF_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.PGF_MOB_ID C_MOB_ID, D.PGF_ID, 
					(SELECT CASE WHEN UPDATE(PGF_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'PGF_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PGF_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PGF_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PGF_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PGF_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PGF_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PGF_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PGF_Location) Or @ChangeType = 'D' THEN
							(SELECT 'PGF_Location' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PGF_Location as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PGF_Location as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PGF_DSK_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PGF_DSK_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PGF_DSK_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PGF_DSK_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PGF_AllocatedBaseSizeMB) Or @ChangeType = 'D' THEN
							(SELECT 'PGF_AllocatedBaseSizeMB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PGF_AllocatedBaseSizeMB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PGF_AllocatedBaseSizeMB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PGF_CurrentUsageMB) Or @ChangeType = 'D' THEN
							(SELECT 'PGF_CurrentUsageMB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PGF_CurrentUsageMB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PGF_CurrentUsageMB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PGF_PFS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PGF_PFS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PGF_PFS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PGF_PFS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PGF_IsTempFile) Or @ChangeType = 'D' THEN
							(SELECT 'PGF_IsTempFile' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PGF_IsTempFile as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PGF_IsTempFile as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.PGF_ID = D.PGF_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.PageFiles' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[PageFiles] DISABLE TRIGGER [trg_PageFiles_HistoryLogging]
GO
