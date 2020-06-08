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
/****** Object:  Table [Inventory].[OperatingSystemServices]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[OperatingSystemServices](
	[OSR_ID] [int] IDENTITY(1,1) NOT NULL,
	[OSR_ClientID] [int] NOT NULL,
	[OSR_MOB_ID] [int] NOT NULL,
	[OSR_SNM_ID] [int] NOT NULL,
	[OSR_SDN_ID] [int] NOT NULL,
	[OSR_SCD_ID] [int] NULL,
	[OSR_SPT_ID] [int] NULL,
	[OSR_STP_ID] [tinyint] NOT NULL,
	[OSR_SSM_ID] [tinyint] NOT NULL,
	[OSR_SST_ID] [tinyint] NOT NULL,
	[OSR_STT_ID] [tinyint] NOT NULL,
	[OSR_SLN_ID] [int] NULL,
	[OSR_InsertDate] [datetime2](3) NOT NULL,
	[OSR_LastSeenDate] [datetime2](3) NOT NULL,
	[OSR_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_OperatingSystemServices] PRIMARY KEY CLUSTERED 
(
	[OSR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_OperatingSystemServices_OSR_MOB_ID#OSR_SNM_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_OperatingSystemServices_OSR_MOB_ID#OSR_SNM_ID] ON [Inventory].[OperatingSystemServices]
(
	[OSR_MOB_ID] ASC,
	[OSR_SNM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_OperatingSystemServices_HistoryLogging]    Script Date: 6/8/2020 1:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_OperatingSystemServices_HistoryLogging] ON [Inventory].[OperatingSystemServices]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.OperatingSystemServices' TabName, C_MOB_ID, OSR_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.OSR_MOB_ID C_MOB_ID, D.OSR_ID, 
					(SELECT CASE WHEN UPDATE(OSR_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'OSR_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSR_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSR_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSR_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OSR_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSR_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSR_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSR_SNM_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OSR_SNM_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSR_SNM_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSR_SNM_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSR_SDN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OSR_SDN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSR_SDN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSR_SDN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSR_SCD_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OSR_SCD_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSR_SCD_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSR_SCD_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSR_SPT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OSR_SPT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSR_SPT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSR_SPT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSR_STP_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OSR_STP_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSR_STP_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSR_STP_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSR_SSM_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OSR_SSM_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSR_SSM_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSR_SSM_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSR_SST_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OSR_SST_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSR_SST_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSR_SST_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSR_STT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OSR_STT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSR_STT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSR_STT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSR_SLN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OSR_SLN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSR_SLN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSR_SLN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.OSR_ID = D.OSR_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.OperatingSystemServices' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[OperatingSystemServices] DISABLE TRIGGER [trg_OperatingSystemServices_HistoryLogging]
GO
