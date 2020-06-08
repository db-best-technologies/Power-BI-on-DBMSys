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
/****** Object:  Table [Inventory].[InstanceAlerts]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[InstanceAlerts](
	[ISA_ID] [int] IDENTITY(1,1) NOT NULL,
	[ISA_MOB_ID] [int] NOT NULL,
	[ISA_Name] [nvarchar](128) NOT NULL,
	[ISA_Event_Source] [nvarchar](100) NOT NULL,
	[ISA_Event_CategoryID] [int] NULL,
	[ISA_EventID] [int] NULL,
	[ISA_IUM_ID] [int] NOT NULL,
	[ISA_Enabled] [tinyint] NOT NULL,
	[ISA_Delay_Between_Responses] [int] NOT NULL,
	[ISA_Last_Occurrence_Date] [int] NOT NULL,
	[ISA_Last_Occurrence_Time] [int] NOT NULL,
	[ISA_Last_Response_Date] [int] NOT NULL,
	[ISA_Last_Response_Time] [int] NOT NULL,
	[ISA_Notification_Message] [nvarchar](512) NULL,
	[ISA_Include_Event_Description] [tinyint] NOT NULL,
	[ISA_IDB_ID] [int] NULL,
	[ISA_Event_Description_Keyword] [nvarchar](100) NULL,
	[ISA_Occurrence_Count] [int] NOT NULL,
	[ISA_Count_Reset_Date] [int] NOT NULL,
	[ISA_Count_Reset_Time] [int] NOT NULL,
	[ISA_IJB_ID] [int] NULL,
	[ISA_Has_Notification] [int] NOT NULL,
	[ISA_Flags] [int] NOT NULL,
	[ISA_Performance_Condition] [nvarchar](512) NULL,
	[ISA_CategoryID] [int] NOT NULL,
	[ISA_InsertDate] [datetime2](3) NOT NULL,
	[ISA_LastSeenDate] [datetime2](3) NOT NULL,
	[ISA_Last_TRH_ID] [int] NOT NULL,
	[ISA_ClientID] [int] NOT NULL,
 CONSTRAINT [PK_InstanceSysalerts] PRIMARY KEY CLUSTERED 
(
	[ISA_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_InstanceSysalerts]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IDX_InstanceSysalerts] ON [Inventory].[InstanceAlerts]
(
	[ISA_MOB_ID] ASC,
	[ISA_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_InstanceAlerts_HistoryLogging]    Script Date: 6/8/2020 1:15:14 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_InstanceAlerts_HistoryLogging] ON [Inventory].[InstanceAlerts]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.InstanceAlerts' TabName, C_MOB_ID, ISA_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.ISA_MOB_ID C_MOB_ID, D.ISA_ID, 
					(SELECT CASE WHEN UPDATE(ISA_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISA_Name) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISA_Event_Source) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_Event_Source' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_Event_Source as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_Event_Source as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISA_Event_CategoryID) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_Event_CategoryID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_Event_CategoryID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_Event_CategoryID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISA_EventID) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_EventID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_EventID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_EventID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISA_IUM_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_IUM_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_IUM_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_IUM_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISA_Enabled) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_Enabled' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_Enabled as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_Enabled as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISA_Delay_Between_Responses) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_Delay_Between_Responses' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_Delay_Between_Responses as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_Delay_Between_Responses as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISA_Last_Occurrence_Date) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_Last_Occurrence_Date' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_Last_Occurrence_Date as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_Last_Occurrence_Date as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISA_Last_Occurrence_Time) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_Last_Occurrence_Time' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_Last_Occurrence_Time as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_Last_Occurrence_Time as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISA_Last_Response_Date) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_Last_Response_Date' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_Last_Response_Date as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_Last_Response_Date as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISA_Last_Response_Time) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_Last_Response_Time' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_Last_Response_Time as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_Last_Response_Time as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISA_Notification_Message) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_Notification_Message' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_Notification_Message as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_Notification_Message as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISA_Include_Event_Description) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_Include_Event_Description' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_Include_Event_Description as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_Include_Event_Description as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISA_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISA_Event_Description_Keyword) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_Event_Description_Keyword' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_Event_Description_Keyword as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_Event_Description_Keyword as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISA_Occurrence_Count) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_Occurrence_Count' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_Occurrence_Count as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_Occurrence_Count as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISA_Count_Reset_Date) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_Count_Reset_Date' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_Count_Reset_Date as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_Count_Reset_Date as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISA_Count_Reset_Time) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_Count_Reset_Time' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_Count_Reset_Time as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_Count_Reset_Time as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISA_IJB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_IJB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_IJB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_IJB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISA_Has_Notification) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_Has_Notification' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_Has_Notification as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_Has_Notification as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISA_Flags) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_Flags' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_Flags as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_Flags as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISA_Performance_Condition) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_Performance_Condition' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_Performance_Condition as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_Performance_Condition as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISA_CategoryID) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_CategoryID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_CategoryID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_CategoryID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ISA_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'ISA_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ISA_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ISA_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.ISA_ID = D.ISA_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.InstanceAlerts' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[InstanceAlerts] DISABLE TRIGGER [trg_InstanceAlerts_HistoryLogging]
GO
