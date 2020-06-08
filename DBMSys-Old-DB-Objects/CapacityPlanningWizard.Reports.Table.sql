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
/****** Object:  Table [CapacityPlanningWizard].[Reports]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CapacityPlanningWizard].[Reports](
	[RPT_ID] [int] IDENTITY(1,1) NOT NULL,
	[RPT_Ordinal] [int] NOT NULL,
	[RPT_Name] [varchar](200) NOT NULL,
	[RPT_ProcedureName] [nvarchar](257) NOT NULL,
	[RPT_ShowType] [tinyint] NULL,
	[RPT_DependencyQuery] [nvarchar](max) NULL,
	[RPT_IsActive] [bit] NOT NULL,
	[RPT_Description] [varchar](1000) NOT NULL,
 CONSTRAINT [PK_Reports] PRIMARY KEY CLUSTERED 
(
	[RPT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Reports_RPT_Name]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Reports_RPT_Name] ON [CapacityPlanningWizard].[Reports]
(
	[RPT_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [CapacityPlanningWizard].[trg_Reports_HistoryLogging]    Script Date: 6/8/2020 1:14:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [CapacityPlanningWizard].[trg_Reports_HistoryLogging] ON [CapacityPlanningWizard].[Reports]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'CapacityPlanningWizard.Reports' TabName, RPT_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.RPT_ID, 
					(SELECT CASE WHEN UPDATE(RPT_Ordinal) Or @ChangeType = 'D' THEN
							(SELECT 'RPT_Ordinal' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RPT_Ordinal as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RPT_Ordinal as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(RPT_Name) Or @ChangeType = 'D' THEN
							(SELECT 'RPT_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RPT_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RPT_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(RPT_ProcedureName) Or @ChangeType = 'D' THEN
							(SELECT 'RPT_ProcedureName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RPT_ProcedureName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RPT_ProcedureName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(RPT_ShowType) Or @ChangeType = 'D' THEN
							(SELECT 'RPT_ShowType' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RPT_ShowType as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RPT_ShowType as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(RPT_IsActive) Or @ChangeType = 'D' THEN
							(SELECT 'RPT_IsActive' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RPT_IsActive as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RPT_IsActive as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.RPT_ID = D.RPT_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'CapacityPlanningWizard.Reports' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [CapacityPlanningWizard].[Reports] DISABLE TRIGGER [trg_Reports_HistoryLogging]
GO
