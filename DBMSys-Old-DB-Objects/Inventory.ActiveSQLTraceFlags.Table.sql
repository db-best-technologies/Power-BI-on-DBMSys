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
/****** Object:  Table [Inventory].[ActiveSQLTraceFlags]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[ActiveSQLTraceFlags](
	[ATF_ID] [int] IDENTITY(1,1) NOT NULL,
	[ATF_ClientID] [int] NOT NULL,
	[ATF_MOB_ID] [int] NOT NULL,
	[ATF_TraceFlag] [int] NOT NULL,
	[ATF_Status] [bit] NOT NULL,
	[ATF_Global] [bit] NOT NULL,
	[ATF_Session] [bit] NOT NULL,
	[ATF_InsertDate] [datetime2](3) NOT NULL,
	[ATF_LastSeenDate] [datetime2](3) NOT NULL,
	[ATF_Last_TRH_ID] [int] NULL,
 CONSTRAINT [PK_ActiveSQLTraceFlags] PRIMARY KEY CLUSTERED 
(
	[ATF_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_ActiveSQLTraceFlags_ATF_MOB_ID#ATF_TraceFlag]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ActiveSQLTraceFlags_ATF_MOB_ID#ATF_TraceFlag] ON [Inventory].[ActiveSQLTraceFlags]
(
	[ATF_MOB_ID] ASC,
	[ATF_TraceFlag] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_ActiveSQLTraceFlags_HistoryLogging]    Script Date: 6/8/2020 1:14:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_ActiveSQLTraceFlags_HistoryLogging] ON [Inventory].[ActiveSQLTraceFlags]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.ActiveSQLTraceFlags' TabName, ATF_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.ATF_ID, 
					(SELECT CASE WHEN UPDATE(ATF_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'ATF_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ATF_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ATF_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ATF_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ATF_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ATF_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ATF_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ATF_TraceFlag) Or @ChangeType = 'D' THEN
							(SELECT 'ATF_TraceFlag' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ATF_TraceFlag as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ATF_TraceFlag as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ATF_Status) Or @ChangeType = 'D' THEN
							(SELECT 'ATF_Status' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ATF_Status as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ATF_Status as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ATF_Global) Or @ChangeType = 'D' THEN
							(SELECT 'ATF_Global' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ATF_Global as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ATF_Global as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ATF_Session) Or @ChangeType = 'D' THEN
							(SELECT 'ATF_Session' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ATF_Session as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ATF_Session as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.ATF_ID = D.ATF_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.ActiveSQLTraceFlags' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[ActiveSQLTraceFlags] DISABLE TRIGGER [trg_ActiveSQLTraceFlags_HistoryLogging]
GO
