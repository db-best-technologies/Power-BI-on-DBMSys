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
/****** Object:  Table [Inventory].[Processors]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[Processors](
	[PRS_ID] [int] IDENTITY(1,1) NOT NULL,
	[PRS_ClientID] [int] NOT NULL,
	[PRS_MOB_ID] [int] NOT NULL,
	[PRS_PAC_ID] [tinyint] NULL,
	[PRS_PAV_ID] [tinyint] NULL,
	[PRS_PCA_ID] [int] NULL,
	[PRS_PCS_ID] [tinyint] NULL,
	[PRS_CurrentClockSpeed] [int] NULL,
	[PRS_CurrentVoltage] [int] NULL,
	[PRS_DataWidth] [tinyint] NULL,
	[PRS_DeviceID] [varchar](20) NOT NULL,
	[PRS_L2CacheSize] [int] NULL,
	[PRS_L3CacheSize] [int] NULL,
	[PRS_PMN_ID] [int] NULL,
	[PRS_MaxClockSpeed] [int] NULL,
	[PRS_PSN_ID] [int] NULL,
	[PRS_NumberOfCores] [int] NULL,
	[PRS_NumberOfLogicalProcessors] [int] NULL,
	[PRS_POS_ID] [int] NULL,
	[PRS_InsertDate] [datetime2](3) NOT NULL,
	[PRS_LastSeenDate] [datetime2](3) NOT NULL,
	[PRS_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_Processors] PRIMARY KEY CLUSTERED 
(
	[PRS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Processors_PRS_MOB_ID#PRS_DeviceID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Processors_PRS_MOB_ID#PRS_DeviceID] ON [Inventory].[Processors]
(
	[PRS_MOB_ID] ASC,
	[PRS_DeviceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Processors_PRS_MOB_ID#PRS_Last_TRH_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_Processors_PRS_MOB_ID#PRS_Last_TRH_ID] ON [Inventory].[Processors]
(
	[PRS_MOB_ID] ASC,
	[PRS_Last_TRH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_Processors_HistoryLogging]    Script Date: 6/8/2020 1:15:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_Processors_HistoryLogging] ON [Inventory].[Processors]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.Processors' TabName, C_MOB_ID, PRS_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.PRS_MOB_ID C_MOB_ID, D.PRS_ID, 
					(SELECT CASE WHEN UPDATE(PRS_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'PRS_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PRS_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PRS_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PRS_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PRS_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PRS_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PRS_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PRS_PAC_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PRS_PAC_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PRS_PAC_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PRS_PAC_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PRS_PAV_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PRS_PAV_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PRS_PAV_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PRS_PAV_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PRS_PCA_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PRS_PCA_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PRS_PCA_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PRS_PCA_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PRS_PCS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PRS_PCS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PRS_PCS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PRS_PCS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PRS_CurrentClockSpeed) Or @ChangeType = 'D' THEN
							(SELECT 'PRS_CurrentClockSpeed' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PRS_CurrentClockSpeed as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PRS_CurrentClockSpeed as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PRS_CurrentVoltage) Or @ChangeType = 'D' THEN
							(SELECT 'PRS_CurrentVoltage' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PRS_CurrentVoltage as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PRS_CurrentVoltage as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PRS_DataWidth) Or @ChangeType = 'D' THEN
							(SELECT 'PRS_DataWidth' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PRS_DataWidth as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PRS_DataWidth as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PRS_DeviceID) Or @ChangeType = 'D' THEN
							(SELECT 'PRS_DeviceID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PRS_DeviceID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PRS_DeviceID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PRS_L2CacheSize) Or @ChangeType = 'D' THEN
							(SELECT 'PRS_L2CacheSize' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PRS_L2CacheSize as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PRS_L2CacheSize as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PRS_L3CacheSize) Or @ChangeType = 'D' THEN
							(SELECT 'PRS_L3CacheSize' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PRS_L3CacheSize as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PRS_L3CacheSize as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PRS_PMN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PRS_PMN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PRS_PMN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PRS_PMN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PRS_MaxClockSpeed) Or @ChangeType = 'D' THEN
							(SELECT 'PRS_MaxClockSpeed' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PRS_MaxClockSpeed as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PRS_MaxClockSpeed as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PRS_PSN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PRS_PSN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PRS_PSN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PRS_PSN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PRS_NumberOfCores) Or @ChangeType = 'D' THEN
							(SELECT 'PRS_NumberOfCores' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PRS_NumberOfCores as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PRS_NumberOfCores as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PRS_NumberOfLogicalProcessors) Or @ChangeType = 'D' THEN
							(SELECT 'PRS_NumberOfLogicalProcessors' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PRS_NumberOfLogicalProcessors as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PRS_NumberOfLogicalProcessors as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PRS_POS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PRS_POS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PRS_POS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PRS_POS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.PRS_ID = D.PRS_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.Processors' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[Processors] DISABLE TRIGGER [trg_Processors_HistoryLogging]
GO
