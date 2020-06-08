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
/****** Object:  Table [Inventory].[LinkedServerRemoteLogins]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[LinkedServerRemoteLogins](
	[LSR_ID] [int] IDENTITY(1,1) NOT NULL,
	[LSR_ClientID] [int] NOT NULL,
	[LSR_MOB_ID] [int] NOT NULL,
	[LSR_LNS_ID] [int] NOT NULL,
	[LSR_INL_ID] [int] NULL,
	[LSR_UsesSelfCredential] [bit] NOT NULL,
	[LSR_RemoteLoginName] [nvarchar](128) NULL,
	[LSR_RemoteLogin_INL_ID] [int] NULL,
	[LSR_InsertDate] [datetime2](3) NOT NULL,
	[LSR_LastSeenDate] [datetime2](3) NOT NULL,
	[LSR_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_LinkedServerRemoteLogins] PRIMARY KEY CLUSTERED 
(
	[LSR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_LinkedServerRemoteLogins_LSR_MOB_ID#LSR_LNS_ID#LSR_INL_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_LinkedServerRemoteLogins_LSR_MOB_ID#LSR_LNS_ID#LSR_INL_ID] ON [Inventory].[LinkedServerRemoteLogins]
(
	[LSR_MOB_ID] ASC,
	[LSR_LNS_ID] ASC,
	[LSR_INL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_LinkedServerRemoteLogins_HistoryLogging]    Script Date: 6/8/2020 1:15:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_LinkedServerRemoteLogins_HistoryLogging] ON [Inventory].[LinkedServerRemoteLogins]
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
	INSERT INTO Inventory.History(HIS_Type, HIS_Datetime, HIS_TableName, HIS_PK_1, 	HIS_Changes, HIS_UserName, HIS_AppName, HIS_HostName)
	SELECT *
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.LinkedServerRemoteLogins' TabName, LSR_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.LSR_ID, 
					(SELECT CASE WHEN UPDATE(LSR_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'LSR_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LSR_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LSR_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LSR_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'LSR_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LSR_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LSR_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LSR_LNS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'LSR_LNS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LSR_LNS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LSR_LNS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LSR_INL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'LSR_INL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LSR_INL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LSR_INL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LSR_UsesSelfCredential) Or @ChangeType = 'D' THEN
							(SELECT 'LSR_UsesSelfCredential' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LSR_UsesSelfCredential as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LSR_UsesSelfCredential as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LSR_RemoteLoginName) Or @ChangeType = 'D' THEN
							(SELECT 'LSR_RemoteLoginName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LSR_RemoteLoginName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LSR_RemoteLoginName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LSR_RemoteLogin_INL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'LSR_RemoteLogin_INL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LSR_RemoteLogin_INL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LSR_RemoteLogin_INL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.LSR_ID = D.LSR_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.LinkedServerRemoteLogins' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[LinkedServerRemoteLogins] DISABLE TRIGGER [trg_LinkedServerRemoteLogins_HistoryLogging]
GO
