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
/****** Object:  Table [BusinessLogic].[RuleThresholds]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BusinessLogic].[RuleThresholds](
	[RTH_ID] [int] IDENTITY(1,1) NOT NULL,
	[RTH_RUL_ID] [int] NOT NULL,
	[RTH_PKG_ID] [int] NULL,
	[RTH_THL_ID] [tinyint] NOT NULL,
	[RTH_LowerValue] [decimal](18, 5) NULL,
	[RTH_UpperValue] [decimal](18, 5) NULL,
	[RTH_IsLowerBetter] [bit] NULL,
	[RTH_Status] [varchar](900) NULL,
	[RTH_IsDifferentThanStatus] [bit] NULL,
 CONSTRAINT [PK_RuleThresholds] PRIMARY KEY CLUSTERED 
(
	[RTH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_RuleThresholds_RTH_RUL_ID#RTH_PKG_ID#RTH_THL_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_RuleThresholds_RTH_RUL_ID#RTH_PKG_ID#RTH_THL_ID] ON [BusinessLogic].[RuleThresholds]
(
	[RTH_RUL_ID] ASC,
	[RTH_PKG_ID] ASC,
	[RTH_THL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [BusinessLogic].[trg_RuleThresholds_HistoryLogging]    Script Date: 6/8/2020 1:14:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [BusinessLogic].[trg_RuleThresholds_HistoryLogging] ON [BusinessLogic].[RuleThresholds]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'BusinessLogic.RuleThresholds' TabName, RTH_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.RTH_ID, 
					(SELECT CASE WHEN UPDATE(RTH_RUL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'RTH_RUL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RTH_RUL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RTH_RUL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(RTH_PKG_ID) Or @ChangeType = 'D' THEN
							(SELECT 'RTH_PKG_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RTH_PKG_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RTH_PKG_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(RTH_THL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'RTH_THL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RTH_THL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RTH_THL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(RTH_LowerValue) Or @ChangeType = 'D' THEN
							(SELECT 'RTH_LowerValue' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RTH_LowerValue as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RTH_LowerValue as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(RTH_UpperValue) Or @ChangeType = 'D' THEN
							(SELECT 'RTH_UpperValue' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RTH_UpperValue as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RTH_UpperValue as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(RTH_IsLowerBetter) Or @ChangeType = 'D' THEN
							(SELECT 'RTH_IsLowerBetter' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RTH_IsLowerBetter as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RTH_IsLowerBetter as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(RTH_Status) Or @ChangeType = 'D' THEN
							(SELECT 'RTH_Status' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RTH_Status as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RTH_Status as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(RTH_IsDifferentThanStatus) Or @ChangeType = 'D' THEN
							(SELECT 'RTH_IsDifferentThanStatus' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RTH_IsDifferentThanStatus as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RTH_IsDifferentThanStatus as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.RTH_ID = D.RTH_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'BusinessLogic.RuleThresholds' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [BusinessLogic].[RuleThresholds] DISABLE TRIGGER [trg_RuleThresholds_HistoryLogging]
GO
