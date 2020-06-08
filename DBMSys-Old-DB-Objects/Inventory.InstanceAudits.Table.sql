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
/****** Object:  Table [Inventory].[InstanceAudits]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[InstanceAudits](
	[IAU_ID] [int] IDENTITY(1,1) NOT NULL,
	[IAU_ClientID] [int] NOT NULL,
	[IAU_MOB_ID] [int] NOT NULL,
	[IAU_Name] [nvarchar](128) NOT NULL,
	[IAU_CreateDate] [datetime2](3) NOT NULL,
	[IAU_ModifyDate] [datetime2](3) NOT NULL,
	[IAU_IAT_ID] [tinyint] NOT NULL,
	[IAU_IAF_ID] [tinyint] NULL,
	[IAU_IsEnabled] [bit] NOT NULL,
	[IAU_QueueDelay] [int] NULL,
	[IAU_LastStatusUpdateDate] [datetime2](3) NULL,
	[IAU_IAS_ID] [tinyint] NULL,
	[IAU_InsertDate] [datetime2](3) NOT NULL,
	[IAU_LastSeenDate] [datetime2](3) NOT NULL,
	[IAU_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_InstanceAudits] PRIMARY KEY CLUSTERED 
(
	[IAU_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_InstanceAudits_IAU_MOB_ID#IAU_Name]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_InstanceAudits_IAU_MOB_ID#IAU_Name] ON [Inventory].[InstanceAudits]
(
	[IAU_MOB_ID] ASC,
	[IAU_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_InstanceAudits_HistoryLogging]    Script Date: 6/8/2020 1:15:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_InstanceAudits_HistoryLogging] ON [Inventory].[InstanceAudits]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.InstanceAudits' TabName, IAU_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.IAU_ID, 
					(SELECT CASE WHEN UPDATE(IAU_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'IAU_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IAU_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IAU_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IAU_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IAU_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IAU_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IAU_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IAU_Name) Or @ChangeType = 'D' THEN
							(SELECT 'IAU_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IAU_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IAU_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IAU_CreateDate) Or @ChangeType = 'D' THEN
							(SELECT 'IAU_CreateDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IAU_CreateDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IAU_CreateDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IAU_ModifyDate) Or @ChangeType = 'D' THEN
							(SELECT 'IAU_ModifyDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IAU_ModifyDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IAU_ModifyDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IAU_IAT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IAU_IAT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IAU_IAT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IAU_IAT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IAU_IAF_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IAU_IAF_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IAU_IAF_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IAU_IAF_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IAU_IsEnabled) Or @ChangeType = 'D' THEN
							(SELECT 'IAU_IsEnabled' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IAU_IsEnabled as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IAU_IsEnabled as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IAU_QueueDelay) Or @ChangeType = 'D' THEN
							(SELECT 'IAU_QueueDelay' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IAU_QueueDelay as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IAU_QueueDelay as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IAU_LastStatusUpdateDate) Or @ChangeType = 'D' THEN
							(SELECT 'IAU_LastStatusUpdateDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IAU_LastStatusUpdateDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IAU_LastStatusUpdateDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IAU_IAS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IAU_IAS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IAU_IAS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IAU_IAS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.IAU_ID = D.IAU_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.InstanceAudits' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[InstanceAudits] DISABLE TRIGGER [trg_InstanceAudits_HistoryLogging]
GO
