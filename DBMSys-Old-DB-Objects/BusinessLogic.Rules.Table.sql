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
/****** Object:  Table [BusinessLogic].[Rules]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BusinessLogic].[Rules](
	[RUL_ID] [int] NOT NULL,
	[RUL_Primary_OBT_ID] [tinyint] NOT NULL,
	[RUL_Secondary_OBT_ID] [tinyint] NULL,
	[RUL_Name] [varchar](200) NOT NULL,
	[RUL_Description] [varchar](1000) NOT NULL,
	[RUL_ProcedureName] [nvarchar](257) NULL,
	[RUL_ExtraParameterValues] [nvarchar](max) NULL,
	[RUL_RecommendedFix] [varchar](1000) NULL,
	[RUL_ColumnMap] [xml] NULL,
	[RUL_Weight] [decimal](10, 2) NOT NULL,
	[RUL_IsOneResultPerLastCountableObject] [bit] NOT NULL,
	[RUL_IsActive] [bit] NOT NULL,
	[RUL_HyperLink] [varchar](500) NULL,
	[RUL_IndustryStandard] [varchar](max) NULL,
 CONSTRAINT [PK_Rules] PRIMARY KEY CLUSTERED 
(
	[RUL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Trigger [BusinessLogic].[trg_Rules_HistoryLogging]    Script Date: 6/8/2020 1:14:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [BusinessLogic].[trg_Rules_HistoryLogging] ON [BusinessLogic].[Rules]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'BusinessLogic.Rules' TabName, RUL_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.RUL_ID, 
					(SELECT CASE WHEN UPDATE(RUL_Primary_OBT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'RUL_Primary_OBT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RUL_Primary_OBT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RUL_Primary_OBT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(RUL_Secondary_OBT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'RUL_Secondary_OBT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RUL_Secondary_OBT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RUL_Secondary_OBT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(RUL_Name) Or @ChangeType = 'D' THEN
							(SELECT 'RUL_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RUL_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RUL_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(RUL_Description) Or @ChangeType = 'D' THEN
							(SELECT 'RUL_Description' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RUL_Description as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RUL_Description as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(RUL_ProcedureName) Or @ChangeType = 'D' THEN
							(SELECT 'RUL_ProcedureName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RUL_ProcedureName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RUL_ProcedureName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(RUL_RecommendedFix) Or @ChangeType = 'D' THEN
							(SELECT 'RUL_RecommendedFix' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RUL_RecommendedFix as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RUL_RecommendedFix as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(RUL_Weight) Or @ChangeType = 'D' THEN
							(SELECT 'RUL_Weight' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RUL_Weight as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RUL_Weight as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(RUL_IsOneResultPerLastCountableObject) Or @ChangeType = 'D' THEN
							(SELECT 'RUL_IsOneResultPerLastCountableObject' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RUL_IsOneResultPerLastCountableObject as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RUL_IsOneResultPerLastCountableObject as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(RUL_IsActive) Or @ChangeType = 'D' THEN
							(SELECT 'RUL_IsActive' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RUL_IsActive as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RUL_IsActive as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.RUL_ID = D.RUL_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'BusinessLogic.Rules' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [BusinessLogic].[Rules] DISABLE TRIGGER [trg_Rules_HistoryLogging]
GO
