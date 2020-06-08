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
/****** Object:  Table [Inventory].[SQLOSSchedulerNodes]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[SQLOSSchedulerNodes](
	[SON_ID] [int] IDENTITY(1,1) NOT NULL,
	[SON_ClientID] [int] NOT NULL,
	[SON_MOB_ID] [int] NOT NULL,
	[SON_NodeID] [smallint] NULL,
	[SON_SNS_ID] [tinyint] NOT NULL,
	[SON_MemoryNodeID] [smallint] NOT NULL,
	[SON_CpuAffinityMask] [bigint] NOT NULL,
	[SON_InsertDate] [datetime2](3) NOT NULL,
	[SON_LastSeenDate] [datetime2](3) NOT NULL,
	[SON_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_SQLOSSchedulerNodes] PRIMARY KEY CLUSTERED 
(
	[SON_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_SQLOSSchedulerNodes_SON_MOB_ID#SON_NodeID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_SQLOSSchedulerNodes_SON_MOB_ID#SON_NodeID] ON [Inventory].[SQLOSSchedulerNodes]
(
	[SON_MOB_ID] ASC,
	[SON_NodeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_SQLOSSchedulerNodes_HistoryLogging]    Script Date: 6/8/2020 1:15:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_SQLOSSchedulerNodes_HistoryLogging] ON [Inventory].[SQLOSSchedulerNodes]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.SQLOSSchedulerNodes' TabName, SON_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.SON_ID, 
					(SELECT CASE WHEN UPDATE(SON_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'SON_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SON_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SON_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SON_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'SON_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SON_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SON_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SON_NodeID) Or @ChangeType = 'D' THEN
							(SELECT 'SON_NodeID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SON_NodeID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SON_NodeID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SON_SNS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'SON_SNS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SON_SNS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SON_SNS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SON_MemoryNodeID) Or @ChangeType = 'D' THEN
							(SELECT 'SON_MemoryNodeID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SON_MemoryNodeID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SON_MemoryNodeID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SON_CpuAffinityMask) Or @ChangeType = 'D' THEN
							(SELECT 'SON_CpuAffinityMask' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SON_CpuAffinityMask as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SON_CpuAffinityMask as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.SON_ID = D.SON_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.SQLOSSchedulerNodes' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[SQLOSSchedulerNodes] DISABLE TRIGGER [trg_SQLOSSchedulerNodes_HistoryLogging]
GO
