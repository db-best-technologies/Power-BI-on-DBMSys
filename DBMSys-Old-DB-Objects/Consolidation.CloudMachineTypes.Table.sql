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
/****** Object:  Table [Consolidation].[CloudMachineTypes]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[CloudMachineTypes](
	[CMT_ID] [int] IDENTITY(1,1) NOT NULL,
	[CMT_CLV_ID] [tinyint] NOT NULL,
	[CMT_Name] [varchar](100) NOT NULL,
	[CMT_CPUName] [varchar](100) NULL,
	[CMT_CoreCount] [decimal](10, 2) NULL,
	[CMT_CPUStrength] [int] NULL,
	[CMT_MemoryMB] [bigint] NULL,
	[CMT_NetworkSpeedDownloadMbit] [int] NULL,
	[CMT_NetworkSpeedUploadMbit] [int] NULL,
	[CMT_LocalSSDDriveGB] [int] NULL,
	[CMT_SupportsAutoScale] [bit] NULL,
	[CMT_SupportLoadBalancing] [bit] NULL,
	[CMT_SupportsRDMA] [bit] NULL,
	[CMT_IsActive] [bit] NOT NULL,
	[CMT_ECU] [decimal](10, 2) NULL,
	[CMT_CMG_ID] [smallint] NULL,
	[CMT_DTUs] [int] NULL,
	[CMT_MaxStorageGB] [int] NULL,
 CONSTRAINT [PK_CloudMachineTypes] PRIMARY KEY CLUSTERED 
(
	[CMT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Trigger [Consolidation].[trg_CloudMachineTypes_HistoryLogging]    Script Date: 6/8/2020 1:14:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Consolidation].[trg_CloudMachineTypes_HistoryLogging] ON [Consolidation].[CloudMachineTypes]
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
	INSERT INTO Management.History(HIS_Type, HIS_Datetime, HIS_TableName, HIS_PK_1, 	HIS_Changes, HIS_UserName, HIS_AppName, HIS_HostName)
	SELECT *
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Consolidation.CloudMachineTypes' TabName, CMT_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.CMT_ID, 
					(SELECT CASE WHEN UPDATE(CMT_CLV_ID) Or @ChangeType = 'D' THEN
							(SELECT 'CMT_CLV_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMT_CLV_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMT_CLV_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMT_Name) Or @ChangeType = 'D' THEN
							(SELECT 'CMT_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMT_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMT_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMT_CPUName) Or @ChangeType = 'D' THEN
							(SELECT 'CMT_CPUName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMT_CPUName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMT_CPUName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMT_CoreCount) Or @ChangeType = 'D' THEN
							(SELECT 'CMT_CoreCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMT_CoreCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMT_CoreCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMT_CPUStrength) Or @ChangeType = 'D' THEN
							(SELECT 'CMT_CPUStrength' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMT_CPUStrength as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMT_CPUStrength as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMT_MemoryMB) Or @ChangeType = 'D' THEN
							(SELECT 'CMT_MemoryMB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMT_MemoryMB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMT_MemoryMB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMT_NetworkSpeedDownloadMbit) Or @ChangeType = 'D' THEN
							(SELECT 'CMT_NetworkSpeedDownloadMbit' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMT_NetworkSpeedDownloadMbit as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMT_NetworkSpeedDownloadMbit as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMT_NetworkSpeedUploadMbit) Or @ChangeType = 'D' THEN
							(SELECT 'CMT_NetworkSpeedUploadMbit' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMT_NetworkSpeedUploadMbit as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMT_NetworkSpeedUploadMbit as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMT_LocalSSDDriveGB) Or @ChangeType = 'D' THEN
							(SELECT 'CMT_LocalSSDDriveGB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMT_LocalSSDDriveGB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMT_LocalSSDDriveGB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMT_SupportsAutoScale) Or @ChangeType = 'D' THEN
							(SELECT 'CMT_SupportsAutoScale' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMT_SupportsAutoScale as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMT_SupportsAutoScale as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMT_SupportLoadBalancing) Or @ChangeType = 'D' THEN
							(SELECT 'CMT_SupportLoadBalancing' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMT_SupportLoadBalancing as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMT_SupportLoadBalancing as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMT_SupportsRDMA) Or @ChangeType = 'D' THEN
							(SELECT 'CMT_SupportsRDMA' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMT_SupportsRDMA as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMT_SupportsRDMA as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMT_IsActive) Or @ChangeType = 'D' THEN
							(SELECT 'CMT_IsActive' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMT_IsActive as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMT_IsActive as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMT_ECU) Or @ChangeType = 'D' THEN
							(SELECT 'CMT_ECU' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMT_ECU as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMT_ECU as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMT_CMG_ID) Or @ChangeType = 'D' THEN
							(SELECT 'CMT_CMG_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMT_CMG_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMT_CMG_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMT_DTUs) Or @ChangeType = 'D' THEN
							(SELECT 'CMT_DTUs' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMT_DTUs as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMT_DTUs as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMT_MaxStorageGB) Or @ChangeType = 'D' THEN
							(SELECT 'CMT_MaxStorageGB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMT_MaxStorageGB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMT_MaxStorageGB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.CMT_ID = D.CMT_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Consolidation.CloudMachineTypes' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Consolidation].[CloudMachineTypes] DISABLE TRIGGER [trg_CloudMachineTypes_HistoryLogging]
GO
