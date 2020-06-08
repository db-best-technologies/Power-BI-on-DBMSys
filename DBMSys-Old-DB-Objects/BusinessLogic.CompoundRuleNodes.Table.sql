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
/****** Object:  Table [BusinessLogic].[CompoundRuleNodes]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BusinessLogic].[CompoundRuleNodes](
	[CRN_ID] [int] IDENTITY(1,1) NOT NULL,
	[CRN_RUL_ID] [int] NOT NULL,
	[CRN_ExpressionID] [tinyint] NOT NULL,
	[CRN_ParentExpressionID] [tinyint] NULL,
	[CRN_MinVersion] [decimal](20, 10) NULL,
	[CRN_MaxVersion] [decimal](20, 10) NULL,
	[CRN_Editions] [varchar](1000) NULL,
	[CRN_MinThresholdLevel] [tinyint] NULL,
	[CRN_MaxThresholdLevel] [tinyint] NULL,
	[CRN_Ordinal] [tinyint] NOT NULL,
	[CRN_PreceedingOperator] [varchar](3) NULL,
	[CRN_IsNot] [bit] NOT NULL,
	[CRN_Node_RUL_ID] [int] NOT NULL,
	[CRN_Filter] [xml] NULL,
	[CRN_JoinOnColumns] [xml] NULL,
	[CRN_ExposeColumns] [xml] NULL,
	[CRN_IsActive] [bit] NULL,
 CONSTRAINT [PK_CompoundRuleNodes] PRIMARY KEY CLUSTERED 
(
	[CRN_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Index [IX_CompoundRuleNodes_CRN_RUL_ID#CRN_Ordinal]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_CompoundRuleNodes_CRN_RUL_ID#CRN_Ordinal] ON [BusinessLogic].[CompoundRuleNodes]
(
	[CRN_RUL_ID] ASC,
	[CRN_Ordinal] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [BusinessLogic].[trg_CompoundRuleNodes_HistoryLogging]    Script Date: 6/8/2020 1:14:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [BusinessLogic].[trg_CompoundRuleNodes_HistoryLogging] ON [BusinessLogic].[CompoundRuleNodes]
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
	INSERT INTO Internal.History(HIS_Type, HIS_Datetime, HIS_TableName, HIS_PK_1, 	HIS_Changes, HIS_UserName, HIS_AppName, HIS_HostName)
	SELECT *
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'BusinessLogic.CompoundRuleNodes' TabName, CRN_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.CRN_ID, 
					(SELECT CASE WHEN UPDATE(CRN_RUL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'CRN_RUL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CRN_RUL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CRN_RUL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CRN_ExpressionID) Or @ChangeType = 'D' THEN
							(SELECT 'CRN_ExpressionID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CRN_ExpressionID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CRN_ExpressionID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CRN_ParentExpressionID) Or @ChangeType = 'D' THEN
							(SELECT 'CRN_ParentExpressionID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CRN_ParentExpressionID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CRN_ParentExpressionID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CRN_MinVersion) Or @ChangeType = 'D' THEN
							(SELECT 'CRN_MinVersion' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CRN_MinVersion as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CRN_MinVersion as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CRN_MaxVersion) Or @ChangeType = 'D' THEN
							(SELECT 'CRN_MaxVersion' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CRN_MaxVersion as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CRN_MaxVersion as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CRN_Editions) Or @ChangeType = 'D' THEN
							(SELECT 'CRN_Editions' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CRN_Editions as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CRN_Editions as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CRN_MinThresholdLevel) Or @ChangeType = 'D' THEN
							(SELECT 'CRN_MinThresholdLevel' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CRN_MinThresholdLevel as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CRN_MinThresholdLevel as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CRN_MaxThresholdLevel) Or @ChangeType = 'D' THEN
							(SELECT 'CRN_MaxThresholdLevel' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CRN_MaxThresholdLevel as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CRN_MaxThresholdLevel as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CRN_Ordinal) Or @ChangeType = 'D' THEN
							(SELECT 'CRN_Ordinal' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CRN_Ordinal as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CRN_Ordinal as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CRN_PreceedingOperator) Or @ChangeType = 'D' THEN
							(SELECT 'CRN_PreceedingOperator' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CRN_PreceedingOperator as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CRN_PreceedingOperator as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CRN_IsNot) Or @ChangeType = 'D' THEN
							(SELECT 'CRN_IsNot' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CRN_IsNot as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CRN_IsNot as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CRN_Node_RUL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'CRN_Node_RUL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CRN_Node_RUL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CRN_Node_RUL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CRN_IsActive) Or @ChangeType = 'D' THEN
							(SELECT 'CRN_IsActive' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CRN_IsActive as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CRN_IsActive as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.CRN_ID = D.CRN_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'BusinessLogic.CompoundRuleNodes' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [BusinessLogic].[CompoundRuleNodes] DISABLE TRIGGER [trg_CompoundRuleNodes_HistoryLogging]
GO
