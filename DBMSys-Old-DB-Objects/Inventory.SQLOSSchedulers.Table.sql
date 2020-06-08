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
/****** Object:  Table [Inventory].[SQLOSSchedulers]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[SQLOSSchedulers](
	[SOS_ID] [int] IDENTITY(1,1) NOT NULL,
	[SOS_ClientID] [int] NOT NULL,
	[SOS_MOB_ID] [int] NOT NULL,
	[SOS_ParentNodeID] [int] NULL,
	[SOS_SchedulerID] [int] NOT NULL,
	[SOS_ProcessorID] [int] NOT NULL,
	[SOS_SDS_ID] [tinyint] NOT NULL,
	[SOS_IsOnline] [bit] NOT NULL,
	[SOS_IsIdle] [bit] NOT NULL,
	[SOS_InsertDate] [datetime2](3) NOT NULL,
	[SOS_LastSeenDate] [datetime2](3) NOT NULL,
	[SOS_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_SQLOSSchedulers] PRIMARY KEY CLUSTERED 
(
	[SOS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_SQLOSSchedulers_SOS_MOB_ID#SOS_SchedulerID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_SQLOSSchedulers_SOS_MOB_ID#SOS_SchedulerID] ON [Inventory].[SQLOSSchedulers]
(
	[SOS_MOB_ID] ASC,
	[SOS_SchedulerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_SQLOSSchedulers_HistoryLogging]    Script Date: 6/8/2020 1:15:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_SQLOSSchedulers_HistoryLogging] ON [Inventory].[SQLOSSchedulers]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.SQLOSSchedulers' TabName, SOS_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.SOS_ID, 
					(SELECT CASE WHEN UPDATE(SOS_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'SOS_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SOS_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SOS_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SOS_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'SOS_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SOS_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SOS_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SOS_ParentNodeID) Or @ChangeType = 'D' THEN
							(SELECT 'SOS_ParentNodeID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SOS_ParentNodeID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SOS_ParentNodeID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SOS_SchedulerID) Or @ChangeType = 'D' THEN
							(SELECT 'SOS_SchedulerID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SOS_SchedulerID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SOS_SchedulerID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SOS_ProcessorID) Or @ChangeType = 'D' THEN
							(SELECT 'SOS_ProcessorID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SOS_ProcessorID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SOS_ProcessorID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SOS_SDS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'SOS_SDS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SOS_SDS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SOS_SDS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SOS_IsOnline) Or @ChangeType = 'D' THEN
							(SELECT 'SOS_IsOnline' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SOS_IsOnline as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SOS_IsOnline as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SOS_IsIdle) Or @ChangeType = 'D' THEN
							(SELECT 'SOS_IsIdle' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SOS_IsIdle as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SOS_IsIdle as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.SOS_ID = D.SOS_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.SQLOSSchedulers' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[SQLOSSchedulers] DISABLE TRIGGER [trg_SQLOSSchedulers_HistoryLogging]
GO
