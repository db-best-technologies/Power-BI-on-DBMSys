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
/****** Object:  Table [Consolidation].[BillableByUsageItemLevelPricingScheme]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[BillableByUsageItemLevelPricingScheme](
	[BUP_ID] [int] IDENTITY(1,1) NOT NULL,
	[BUP_BUL_ID] [tinyint] NOT NULL,
	[BUP_CSL_ID] [tinyint] NULL,
	[BUP_CLZ_ID] [tinyint] NULL,
	[BUP_UpToNumberOfUnits] [bigint] NULL,
	[BUP_PricePerUnit] [decimal](15, 10) NULL,
	[BUP_CRG_ID] [smallint] NULL,
	[BUP_PricePerPackage] [decimal](15, 3) NULL,
 CONSTRAINT [PK_BillableByUsageItemLevelPricingScheme] PRIMARY KEY CLUSTERED 
(
	[BUP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_BillableByUsageItemLevelPricingScheme_BUP_BUL_ID#BUP_CSL_ID#BUP_CLZ_ID#BUP_CRG_ID#BUP_UpToNumberOfUnits]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_BillableByUsageItemLevelPricingScheme_BUP_BUL_ID#BUP_CSL_ID#BUP_CLZ_ID#BUP_CRG_ID#BUP_UpToNumberOfUnits] ON [Consolidation].[BillableByUsageItemLevelPricingScheme]
(
	[BUP_BUL_ID] ASC,
	[BUP_CSL_ID] ASC,
	[BUP_CLZ_ID] ASC,
	[BUP_CRG_ID] ASC,
	[BUP_UpToNumberOfUnits] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Consolidation].[trg_BillableByUsageItemLevelPricingScheme_HistoryLogging]    Script Date: 6/8/2020 1:14:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Consolidation].[trg_BillableByUsageItemLevelPricingScheme_HistoryLogging] ON [Consolidation].[BillableByUsageItemLevelPricingScheme]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Consolidation.BillableByUsageItemLevelPricingScheme' TabName, BUP_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.BUP_ID, 
					(SELECT CASE WHEN UPDATE(BUP_BUL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'BUP_BUL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.BUP_BUL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.BUP_BUL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(BUP_CSL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'BUP_CSL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.BUP_CSL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.BUP_CSL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(BUP_CLZ_ID) Or @ChangeType = 'D' THEN
							(SELECT 'BUP_CLZ_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.BUP_CLZ_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.BUP_CLZ_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(BUP_UpToNumberOfUnits) Or @ChangeType = 'D' THEN
							(SELECT 'BUP_UpToNumberOfUnits' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.BUP_UpToNumberOfUnits as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.BUP_UpToNumberOfUnits as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(BUP_PricePerUnit) Or @ChangeType = 'D' THEN
							(SELECT 'BUP_PricePerUnit' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.BUP_PricePerUnit as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.BUP_PricePerUnit as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(BUP_CRG_ID) Or @ChangeType = 'D' THEN
							(SELECT 'BUP_CRG_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.BUP_CRG_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.BUP_CRG_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.BUP_ID = D.BUP_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Consolidation.BillableByUsageItemLevelPricingScheme' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Consolidation].[BillableByUsageItemLevelPricingScheme] DISABLE TRIGGER [trg_BillableByUsageItemLevelPricingScheme_HistoryLogging]
GO