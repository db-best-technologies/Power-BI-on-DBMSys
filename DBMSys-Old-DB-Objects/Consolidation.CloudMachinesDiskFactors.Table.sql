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
/****** Object:  Table [Consolidation].[CloudMachinesDiskFactors]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[CloudMachinesDiskFactors](
	[CDF_ID] [int] IDENTITY(1,1) NOT NULL,
	[CDF_BUL_ID] [tinyint] NOT NULL,
	[CDF_DiskCount] [int] NOT NULL,
	[CDF_BlockSize] [tinyint] NOT NULL,
	[CDF_ReadsFactor] [decimal](10, 3) NULL,
	[CDF_WritesFactor] [decimal](10, 3) NULL,
	[CDF_ReadsMBFactor] [decimal](10, 3) NULL,
	[CDF_WritesMBFactor] [decimal](10, 3) NULL,
 CONSTRAINT [PK_CloudMachinesDiskFactors] PRIMARY KEY CLUSTERED 
(
	[CDF_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_CloudMachinesDiskFactors_BUL_ID#DiskCount##BlockSize#ReadsFactor#WritesFactor#ReadsMBFactor#WritesMBFactor]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_CloudMachinesDiskFactors_BUL_ID#DiskCount##BlockSize#ReadsFactor#WritesFactor#ReadsMBFactor#WritesMBFactor] ON [Consolidation].[CloudMachinesDiskFactors]
(
	[CDF_BUL_ID] ASC,
	[CDF_DiskCount] ASC
)
INCLUDE([CDF_BlockSize],[CDF_ReadsFactor],[CDF_WritesFactor],[CDF_ReadsMBFactor],[CDF_WritesMBFactor]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_CloudMachinesDiskFactors_CDF_BUL_ID#CDF_DiskCount#CDF_BlockSize]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_CloudMachinesDiskFactors_CDF_BUL_ID#CDF_DiskCount#CDF_BlockSize] ON [Consolidation].[CloudMachinesDiskFactors]
(
	[CDF_BUL_ID] ASC,
	[CDF_DiskCount] ASC,
	[CDF_BlockSize] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Consolidation].[trg_CloudMachinesDiskFactors_HistoryLogging]    Script Date: 6/8/2020 1:14:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Consolidation].[trg_CloudMachinesDiskFactors_HistoryLogging] ON [Consolidation].[CloudMachinesDiskFactors]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Consolidation.CloudMachinesDiskFactors' TabName, CDF_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.CDF_ID, 
					(SELECT CASE WHEN UPDATE(CDF_BUL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'CDF_BUL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CDF_BUL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CDF_BUL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CDF_DiskCount) Or @ChangeType = 'D' THEN
							(SELECT 'CDF_DiskCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CDF_DiskCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CDF_DiskCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CDF_BlockSize) Or @ChangeType = 'D' THEN
							(SELECT 'CDF_BlockSize' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CDF_BlockSize as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CDF_BlockSize as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CDF_ReadsFactor) Or @ChangeType = 'D' THEN
							(SELECT 'CDF_ReadsFactor' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CDF_ReadsFactor as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CDF_ReadsFactor as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CDF_WritesFactor) Or @ChangeType = 'D' THEN
							(SELECT 'CDF_WritesFactor' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CDF_WritesFactor as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CDF_WritesFactor as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CDF_ReadsMBFactor) Or @ChangeType = 'D' THEN
							(SELECT 'CDF_ReadsMBFactor' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CDF_ReadsMBFactor as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CDF_ReadsMBFactor as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CDF_WritesMBFactor) Or @ChangeType = 'D' THEN
							(SELECT 'CDF_WritesMBFactor' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CDF_WritesMBFactor as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CDF_WritesMBFactor as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.CDF_ID = D.CDF_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Consolidation.CloudMachinesDiskFactors' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Consolidation].[CloudMachinesDiskFactors] DISABLE TRIGGER [trg_CloudMachinesDiskFactors_HistoryLogging]
GO
