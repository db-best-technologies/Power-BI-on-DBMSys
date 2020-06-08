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
/****** Object:  Table [Inventory].[OSServers]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[OSServers](
	[OSS_ID] [int] IDENTITY(1,1) NOT NULL,
	[OSS_ClientID] [int] NOT NULL,
	[OSS_PLT_ID] [tinyint] NOT NULL,
	[OSS_Name] [nvarchar](128) NULL,
	[OSS_IsClusterNode] [bit] NULL,
	[OSS_IsVirtualServer] [bit] NOT NULL,
	[OSS_CodeSet] [int] NULL,
	[OSS_CountryCode] [smallint] NULL,
	[OSS_PRL_ID] [tinyint] NULL,
	[OSS_CurrentTimeZone] [smallint] NULL,
	[OSS_InstallDate] [datetime2](3) NULL,
	[OSS_LastBootUpTime] [datetime2](3) NULL,
	[OSS_Locale] [varchar](10) NULL,
	[OSS_Architecture] [tinyint] NULL,
	[OSS_Language] [smallint] NULL,
	[OSS_TotalPhysicalMemoryMB] [bigint] NULL,
	[OSS_OPT_ID] [tinyint] NULL,
	[OSS_MaxProcessMemorySizeMB] [bigint] NULL,
	[OSS_IsPAEEnabled] [bit] NULL,
	[OSS_IsAutomaticManagedPageFile] [bit] NULL,
	[OSS_PPT_ID] [tinyint] NULL,
	[OSS_DMN_ID] [int] NULL,
	[OSS_DRL_ID] [tinyint] NULL,
	[OSS_IsHypervisorPresent] [bit] NULL,
	[OSS_MMN_ID] [int] NULL,
	[OSS_MMD_ID] [int] NULL,
	[OSS_NumberOfLogicalProcessors] [int] NULL,
	[OSS_NumberOfProcessors] [int] NULL,
	[OSS_SOA_ID] [int] NULL,
	[OSS_WGN_ID] [int] NULL,
	[OSS_MOB_ID] [int] NULL,
	[OSS_HugePageSizeMB] [bigint] NULL,
	[OSS_CSName] [nvarchar](256) NULL,
 CONSTRAINT [PK_OSServers] PRIMARY KEY CLUSTERED 
(
	[OSS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_OSServers_OSS_PLT_ID#OSS_Name]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_OSServers_OSS_PLT_ID#OSS_Name] ON [Inventory].[OSServers]
(
	[OSS_PLT_ID] ASC,
	[OSS_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_OSServers_HistoryLogging]    Script Date: 6/8/2020 1:15:26 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_OSServers_HistoryLogging] ON [Inventory].[OSServers]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.OSServers' TabName, C_MOB_ID, OSS_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.OSS_MOB_ID C_MOB_ID, D.OSS_ID, 
					(SELECT CASE WHEN UPDATE(OSS_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_PLT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_PLT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_PLT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_PLT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_Name) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_IsClusterNode) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_IsClusterNode' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_IsClusterNode as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_IsClusterNode as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_IsVirtualServer) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_IsVirtualServer' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_IsVirtualServer as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_IsVirtualServer as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_CodeSet) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_CodeSet' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_CodeSet as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_CodeSet as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_CountryCode) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_CountryCode' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_CountryCode as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_CountryCode as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_PRL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_PRL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_PRL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_PRL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_CurrentTimeZone) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_CurrentTimeZone' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_CurrentTimeZone as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_CurrentTimeZone as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_InstallDate) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_InstallDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_InstallDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_InstallDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_LastBootUpTime) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_LastBootUpTime' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_LastBootUpTime as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_LastBootUpTime as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_Locale) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_Locale' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_Locale as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_Locale as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_Architecture) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_Architecture' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_Architecture as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_Architecture as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_Language) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_Language' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_Language as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_Language as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_TotalPhysicalMemoryMB) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_TotalPhysicalMemoryMB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_TotalPhysicalMemoryMB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_TotalPhysicalMemoryMB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_OPT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_OPT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_OPT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_OPT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_MaxProcessMemorySizeMB) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_MaxProcessMemorySizeMB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_MaxProcessMemorySizeMB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_MaxProcessMemorySizeMB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_IsPAEEnabled) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_IsPAEEnabled' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_IsPAEEnabled as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_IsPAEEnabled as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_IsAutomaticManagedPageFile) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_IsAutomaticManagedPageFile' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_IsAutomaticManagedPageFile as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_IsAutomaticManagedPageFile as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_PPT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_PPT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_PPT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_PPT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_DMN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_DMN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_DMN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_DMN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_DRL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_DRL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_DRL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_DRL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_IsHypervisorPresent) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_IsHypervisorPresent' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_IsHypervisorPresent as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_IsHypervisorPresent as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_MMN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_MMN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_MMN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_MMN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_MMD_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_MMD_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_MMD_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_MMD_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_NumberOfLogicalProcessors) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_NumberOfLogicalProcessors' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_NumberOfLogicalProcessors as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_NumberOfLogicalProcessors as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_NumberOfProcessors) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_NumberOfProcessors' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_NumberOfProcessors as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_NumberOfProcessors as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_SOA_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_SOA_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_SOA_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_SOA_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_WGN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_WGN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_WGN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_WGN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OSS_HugePageSizeMB) Or @ChangeType = 'D' THEN
							(SELECT 'OSS_HugePageSizeMB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OSS_HugePageSizeMB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OSS_HugePageSizeMB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.OSS_ID = D.OSS_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.OSServers' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[OSServers] DISABLE TRIGGER [trg_OSServers_HistoryLogging]
GO
