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
/****** Object:  Table [Inventory].[InstanceUserMessage]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[InstanceUserMessage](
	[IUM_ID] [int] IDENTITY(1,1) NOT NULL,
	[IUM_MessageID] [int] NOT NULL,
	[IUM_MOB_ID] [int] NOT NULL,
	[IUM_LanguageID] [smallint] NULL,
	[IUM_Severity] [tinyint] NULL,
	[IUM_IsEventLogged] [bit] NULL,
	[IUM_Text] [nvarchar](2048) NULL,
	[IUM_InsertDate] [datetime2](3) NOT NULL,
	[IUM_LastSeenDate] [datetime2](3) NOT NULL,
	[IUM_Last_TRH_ID] [int] NOT NULL,
	[IUM_ClientID] [int] NOT NULL,
 CONSTRAINT [PK_InstanceUserMessage] PRIMARY KEY CLUSTERED 
(
	[IUM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IDX_InstanceUserMessage]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IDX_InstanceUserMessage] ON [Inventory].[InstanceUserMessage]
(
	[IUM_MOB_ID] ASC,
	[IUM_MessageID] ASC,
	[IUM_LanguageID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_InstanceUserMessage_HistoryLogging]    Script Date: 6/8/2020 1:15:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_InstanceUserMessage_HistoryLogging] ON [Inventory].[InstanceUserMessage]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.InstanceUserMessage' TabName, C_MOB_ID, IUM_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.IUM_MOB_ID C_MOB_ID, D.IUM_ID, 
					(SELECT CASE WHEN UPDATE(IUM_MessageID) Or @ChangeType = 'D' THEN
							(SELECT 'IUM_MessageID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IUM_MessageID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IUM_MessageID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IUM_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IUM_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IUM_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IUM_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IUM_LanguageID) Or @ChangeType = 'D' THEN
							(SELECT 'IUM_LanguageID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IUM_LanguageID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IUM_LanguageID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IUM_Severity) Or @ChangeType = 'D' THEN
							(SELECT 'IUM_Severity' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IUM_Severity as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IUM_Severity as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IUM_IsEventLogged) Or @ChangeType = 'D' THEN
							(SELECT 'IUM_IsEventLogged' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IUM_IsEventLogged as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IUM_IsEventLogged as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IUM_Text) Or @ChangeType = 'D' THEN
							(SELECT 'IUM_Text' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IUM_Text as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IUM_Text as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IUM_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'IUM_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IUM_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IUM_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.IUM_ID = D.IUM_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.InstanceUserMessage' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[InstanceUserMessage] DISABLE TRIGGER [trg_InstanceUserMessage_HistoryLogging]
GO
