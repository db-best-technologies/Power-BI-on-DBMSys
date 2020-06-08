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
/****** Object:  Table [Consolidation].[CloudStorageOptimizationPrices]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[CloudStorageOptimizationPrices](
	[CSO_ID] [int] IDENTITY(1,1) NOT NULL,
	[CSO_CRG_ID] [smallint] NOT NULL,
	[CSO_CMT_ID] [int] NOT NULL,
	[CSO_HourlyPriceUSD] [decimal](15, 3) NOT NULL,
 CONSTRAINT [PK_CloudStorageOptimizationPrices] PRIMARY KEY CLUSTERED 
(
	[CSO_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_CloudStorageOptimizationPrices_CSO_CRG_ID#CSO_CMT_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_CloudStorageOptimizationPrices_CSO_CRG_ID#CSO_CMT_ID] ON [Consolidation].[CloudStorageOptimizationPrices]
(
	[CSO_CRG_ID] ASC,
	[CSO_CMT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Consolidation].[trg_CloudStorageOptimizationPrices_HistoryLogging]    Script Date: 6/8/2020 1:14:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Consolidation].[trg_CloudStorageOptimizationPrices_HistoryLogging] ON [Consolidation].[CloudStorageOptimizationPrices]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Consolidation.CloudStorageOptimizationPrices' TabName, CSO_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.CSO_ID, 
					(SELECT CASE WHEN UPDATE(CSO_CRG_ID) Or @ChangeType = 'D' THEN
							(SELECT 'CSO_CRG_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CSO_CRG_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CSO_CRG_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CSO_CMT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'CSO_CMT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CSO_CMT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CSO_CMT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CSO_HourlyPriceUSD) Or @ChangeType = 'D' THEN
							(SELECT 'CSO_HourlyPriceUSD' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CSO_HourlyPriceUSD as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CSO_HourlyPriceUSD as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.CSO_ID = D.CSO_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Consolidation.CloudStorageOptimizationPrices' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Consolidation].[CloudStorageOptimizationPrices] DISABLE TRIGGER [trg_CloudStorageOptimizationPrices_HistoryLogging]
GO
