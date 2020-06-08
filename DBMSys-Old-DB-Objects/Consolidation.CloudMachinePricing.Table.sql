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
/****** Object:  Table [Consolidation].[CloudMachinePricing]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[CloudMachinePricing](
	[CMP_ID] [int] IDENTITY(1,1) NOT NULL,
	[CMP_CRG_ID] [smallint] NOT NULL,
	[CMP_CMT_ID] [int] NOT NULL,
	[CMP_CRL_ID] [tinyint] NULL,
	[CMP_OST_ID] [tinyint] NULL,
	[CMP_CHE_ID] [tinyint] NULL,
	[CMP_CPM_ID] [tinyint] NOT NULL,
	[CMP_UpfrontPaymnetUSD] [decimal](15, 3) NULL,
	[CMP_MonthlyPaymentUSD] [decimal](15, 3) NULL,
	[CMP_HourlyPaymentUSD] [decimal](15, 3) NULL,
	[CMP_EffectiveHourlyPaymentUSD] [decimal](15, 3) NULL,
	[CMP_Storage_BUL_ID] [tinyint] NULL,
	[CMP_CTT_ID] [tinyint] NULL,
	[CMP_CPT_ID] [tinyint] NULL,
	[CMP_CHA_ID] [tinyint] NULL,
 CONSTRAINT [PK_CloudMachinePricing] PRIMARY KEY CLUSTERED 
(
	[CMP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_CloudMachinePricing_CRG_ID#CMT_ID#CRL_ID#OST_ID#CHA_ID#CHE_ID#CPM_ID#Storage_BUL_ID#CTT_ID#CPT_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_CloudMachinePricing_CRG_ID#CMT_ID#CRL_ID#OST_ID#CHA_ID#CHE_ID#CPM_ID#Storage_BUL_ID#CTT_ID#CPT_ID] ON [Consolidation].[CloudMachinePricing]
(
	[CMP_CRG_ID] ASC,
	[CMP_CMT_ID] ASC,
	[CMP_CRL_ID] ASC,
	[CMP_OST_ID] ASC,
	[CMP_CHA_ID] ASC,
	[CMP_CHE_ID] ASC,
	[CMP_CPM_ID] ASC,
	[CMP_Storage_BUL_ID] ASC,
	[CMP_CTT_ID] ASC,
	[CMP_CPT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Consolidation].[trg_CloudMachinePricing_HistoryLogging]    Script Date: 6/8/2020 1:14:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Consolidation].[trg_CloudMachinePricing_HistoryLogging] ON [Consolidation].[CloudMachinePricing]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Consolidation.CloudMachinePricing' TabName, CMP_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.CMP_ID, 
					(SELECT CASE WHEN UPDATE(CMP_CRG_ID) Or @ChangeType = 'D' THEN
							(SELECT 'CMP_CRG_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMP_CRG_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMP_CRG_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMP_CMT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'CMP_CMT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMP_CMT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMP_CMT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMP_CRL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'CMP_CRL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMP_CRL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMP_CRL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMP_OST_ID) Or @ChangeType = 'D' THEN
							(SELECT 'CMP_OST_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMP_OST_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMP_OST_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMP_CHE_ID) Or @ChangeType = 'D' THEN
							(SELECT 'CMP_CHE_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMP_CHE_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMP_CHE_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMP_CPM_ID) Or @ChangeType = 'D' THEN
							(SELECT 'CMP_CPM_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMP_CPM_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMP_CPM_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMP_UpfrontPaymnetUSD) Or @ChangeType = 'D' THEN
							(SELECT 'CMP_UpfrontPaymnetUSD' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMP_UpfrontPaymnetUSD as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMP_UpfrontPaymnetUSD as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMP_MonthlyPaymentUSD) Or @ChangeType = 'D' THEN
							(SELECT 'CMP_MonthlyPaymentUSD' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMP_MonthlyPaymentUSD as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMP_MonthlyPaymentUSD as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMP_HourlyPaymentUSD) Or @ChangeType = 'D' THEN
							(SELECT 'CMP_HourlyPaymentUSD' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMP_HourlyPaymentUSD as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMP_HourlyPaymentUSD as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CMP_EffectiveHourlyPaymentUSD) Or @ChangeType = 'D' THEN
							(SELECT 'CMP_EffectiveHourlyPaymentUSD' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CMP_EffectiveHourlyPaymentUSD as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CMP_EffectiveHourlyPaymentUSD as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.CMP_ID = D.CMP_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Consolidation.CloudMachinePricing' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Consolidation].[CloudMachinePricing] DISABLE TRIGGER [trg_CloudMachinePricing_HistoryLogging]
GO
