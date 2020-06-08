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
/****** Object:  Table [PerformanceData].[PerformanceCounters]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PerformanceData].[PerformanceCounters](
	[PEC_ID] [int] NOT NULL,
	[PEC_TST_ID] [tinyint] NOT NULL,
	[PEC_PCG_ID] [tinyint] NOT NULL,
	[PEC_CSY_ID] [int] NULL,
	[PEC_CategoryName] [nvarchar](128) NOT NULL,
	[PEC_CounterName] [nvarchar](128) NOT NULL,
	[PEC_Instances] [xml] NULL,
	[PEC_IgnoreIfValueIsOrUnder] [int] NULL,
	[PEC_IsActive] [bit] NOT NULL,
	[PEC_OCF_BinConcat] [tinyint] NULL,
	[PEC_MTR_ID] [int] NULL,
	[PEC_IgnoreIfValueIsOrAbove] [float] NULL,
 CONSTRAINT [PK_PerformanceCounters] PRIMARY KEY CLUSTERED 
(
	[PEC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_PerformanceCounters_PEC_CategoryName#PEC_CounterName##PEC_CSY_ID#PEC_IsActive]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_PerformanceCounters_PEC_CategoryName#PEC_CounterName##PEC_CSY_ID#PEC_IsActive] ON [PerformanceData].[PerformanceCounters]
(
	[PEC_CategoryName] ASC,
	[PEC_CounterName] ASC
)
INCLUDE([PEC_CSY_ID],[PEC_IsActive]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [PerformanceData].[trg_PerformanceCounters_HistoryLogging]    Script Date: 6/8/2020 1:15:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [PerformanceData].[trg_PerformanceCounters_HistoryLogging] ON [PerformanceData].[PerformanceCounters]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'PerformanceData.PerformanceCounters' TabName, PEC_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.PEC_ID, 
					(SELECT CASE WHEN UPDATE(PEC_TST_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PEC_TST_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PEC_TST_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PEC_TST_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PEC_PCG_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PEC_PCG_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PEC_PCG_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PEC_PCG_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PEC_CSY_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PEC_CSY_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PEC_CSY_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PEC_CSY_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PEC_CategoryName) Or @ChangeType = 'D' THEN
							(SELECT 'PEC_CategoryName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PEC_CategoryName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PEC_CategoryName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PEC_CounterName) Or @ChangeType = 'D' THEN
							(SELECT 'PEC_CounterName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PEC_CounterName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PEC_CounterName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PEC_IgnoreIfValueIsOrUnder) Or @ChangeType = 'D' THEN
							(SELECT 'PEC_IgnoreIfValueIsOrUnder' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PEC_IgnoreIfValueIsOrUnder as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PEC_IgnoreIfValueIsOrUnder as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PEC_IsActive) Or @ChangeType = 'D' THEN
							(SELECT 'PEC_IsActive' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PEC_IsActive as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PEC_IsActive as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.PEC_ID = D.PEC_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'PerformanceData.PerformanceCounters' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [PerformanceData].[PerformanceCounters] DISABLE TRIGGER [trg_PerformanceCounters_HistoryLogging]
GO
