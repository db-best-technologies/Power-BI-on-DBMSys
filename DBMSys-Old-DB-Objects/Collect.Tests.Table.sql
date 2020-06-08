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
/****** Object:  Table [Collect].[Tests]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Collect].[Tests](
	[TST_ID] [int] NOT NULL,
	[TST_Name] [varchar](900) NOT NULL,
	[TST_QRT_ID] [tinyint] NOT NULL,
	[TST_IntervalType] [char](1) NULL,
	[TST_IntervalPeriod] [int] NULL,
	[TST_RunFirstTimeImmediately] [bit] NOT NULL,
	[TST_DontRunIfErrorIn_TST_ID] [int] NULL,
	[TST_OutputTable] [nvarchar](257) NOT NULL,
	[TST_ConnectionTimeout] [int] NULL,
	[TST_QueryTimeout] [int] NULL,
	[TST_CSY_ID] [tinyint] NULL,
	[TST_DefaultLastValue] [nvarchar](max) NULL,
	[TST_DeleteObsoleteFromTables] [xml] NULL,
	[TST_InsertToOutputTableOnError] [bit] NOT NULL,
	[TST_IsActive] [bit] NOT NULL,
	[TST_MaxSuccessfulRuns] [int] NULL,
	[TST_OCF_BinConcat] [tinyint] NULL,
 CONSTRAINT [PK_Tests] PRIMARY KEY CLUSTERED 
(
	[TST_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_Tests_TST_Name]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Tests_TST_Name] ON [Collect].[Tests]
(
	[TST_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Collect].[trg_Tests_HistoryLogging]    Script Date: 6/8/2020 1:14:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Collect].[trg_Tests_HistoryLogging] ON [Collect].[Tests]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Collect.Tests' TabName, TST_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.TST_ID, 
					(SELECT CASE WHEN UPDATE(TST_Name) Or @ChangeType = 'D' THEN
							(SELECT 'TST_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TST_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TST_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TST_QRT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'TST_QRT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TST_QRT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TST_QRT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TST_IntervalType) Or @ChangeType = 'D' THEN
							(SELECT 'TST_IntervalType' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TST_IntervalType as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TST_IntervalType as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TST_IntervalPeriod) Or @ChangeType = 'D' THEN
							(SELECT 'TST_IntervalPeriod' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TST_IntervalPeriod as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TST_IntervalPeriod as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TST_RunFirstTimeImmediately) Or @ChangeType = 'D' THEN
							(SELECT 'TST_RunFirstTimeImmediately' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TST_RunFirstTimeImmediately as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TST_RunFirstTimeImmediately as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TST_DontRunIfErrorIn_TST_ID) Or @ChangeType = 'D' THEN
							(SELECT 'TST_DontRunIfErrorIn_TST_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TST_DontRunIfErrorIn_TST_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TST_DontRunIfErrorIn_TST_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TST_OutputTable) Or @ChangeType = 'D' THEN
							(SELECT 'TST_OutputTable' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TST_OutputTable as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TST_OutputTable as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TST_ConnectionTimeout) Or @ChangeType = 'D' THEN
							(SELECT 'TST_ConnectionTimeout' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TST_ConnectionTimeout as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TST_ConnectionTimeout as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TST_QueryTimeout) Or @ChangeType = 'D' THEN
							(SELECT 'TST_QueryTimeout' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TST_QueryTimeout as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TST_QueryTimeout as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TST_CSY_ID) Or @ChangeType = 'D' THEN
							(SELECT 'TST_CSY_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TST_CSY_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TST_CSY_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TST_InsertToOutputTableOnError) Or @ChangeType = 'D' THEN
							(SELECT 'TST_InsertToOutputTableOnError' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TST_InsertToOutputTableOnError as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TST_InsertToOutputTableOnError as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TST_IsActive) Or @ChangeType = 'D' THEN
							(SELECT 'TST_IsActive' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TST_IsActive as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TST_IsActive as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(TST_MaxSuccessfulRuns) Or @ChangeType = 'D' THEN
							(SELECT 'TST_MaxSuccessfulRuns' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.TST_MaxSuccessfulRuns as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.TST_MaxSuccessfulRuns as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.TST_ID = D.TST_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Collect.Tests' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Collect].[Tests] DISABLE TRIGGER [trg_Tests_HistoryLogging]
GO
/****** Object:  Trigger [Collect].[trg_Tests_UpdateIntervalSettings]    Script Date: 6/8/2020 1:14:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Collect].[trg_Tests_UpdateIntervalSettings] on [Collect].[Tests]
	after update
as
set nocount on
if exists (select *
			from inserted i
				inner join deleted d on i.TST_ID = d.TST_ID
			where i.TST_IntervalType <> d.TST_IntervalType
				or (i.TST_IntervalType is null
						and d.TST_IntervalType is not null)
				or (i.TST_IntervalType is not null
						and d.TST_IntervalType is null)
				or i.TST_IntervalPeriod <> d.TST_IntervalPeriod
				or (i.TST_IntervalPeriod is null
						and d.TST_IntervalPeriod is not null)
				or (i.TST_IntervalPeriod is not null
						and d.TST_IntervalPeriod is null)
			)
	delete Collect.ScheduledTests
	from inserted
	where SCT_TST_ID = TST_ID
		and SCT_STS_ID = 1
		and SCT_DateToRun > DATEADD(minute, 1, sysdatetime())
GO
ALTER TABLE [Collect].[Tests] ENABLE TRIGGER [trg_Tests_UpdateIntervalSettings]
GO
