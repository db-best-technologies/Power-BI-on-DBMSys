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
/****** Object:  Table [PerformanceData].[InternalPerformanceCounters]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PerformanceData].[InternalPerformanceCounters](
	[IPC_ID] [int] NOT NULL,
	[IPC_CSY_ID] [tinyint] NOT NULL,
	[IPC_CategoryName] [nvarchar](128) NOT NULL,
	[IPC_CounterName] [nvarchar](128) NOT NULL,
	[IPC_IsAggregative] [bit] NOT NULL,
	[IPC_IntervalType] [char](1) NOT NULL,
	[IPC_IntervalPeriod] [int] NOT NULL,
	[IPC_FunctionName] [nvarchar](257) NOT NULL,
	[IPC_TimestampTableName] [nvarchar](257) NULL,
	[IPC_IsFirstRunDry] [bit] NOT NULL,
	[IPC_IgnoreIfValueIsOrUnder] [int] NULL,
	[IPC_IsActive] [bit] NOT NULL,
	[IPC_MTR_ID] [int] NULL,
	[IPC_IgnoreIfValueIsOrAbove] [float] NULL,
 CONSTRAINT [PK_InternalPerformanceCounters] PRIMARY KEY CLUSTERED 
(
	[IPC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Trigger [PerformanceData].[trg_InternalPerformanceCounters_HistoryLogging]    Script Date: 6/8/2020 1:15:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [PerformanceData].[trg_InternalPerformanceCounters_HistoryLogging] ON [PerformanceData].[InternalPerformanceCounters]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'PerformanceData.InternalPerformanceCounters' TabName, IPC_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.IPC_ID, 
					(SELECT CASE WHEN UPDATE(IPC_CSY_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IPC_CSY_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPC_CSY_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPC_CSY_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IPC_CategoryName) Or @ChangeType = 'D' THEN
							(SELECT 'IPC_CategoryName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPC_CategoryName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPC_CategoryName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IPC_CounterName) Or @ChangeType = 'D' THEN
							(SELECT 'IPC_CounterName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPC_CounterName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPC_CounterName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IPC_IsAggregative) Or @ChangeType = 'D' THEN
							(SELECT 'IPC_IsAggregative' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPC_IsAggregative as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPC_IsAggregative as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IPC_IntervalType) Or @ChangeType = 'D' THEN
							(SELECT 'IPC_IntervalType' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPC_IntervalType as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPC_IntervalType as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IPC_IntervalPeriod) Or @ChangeType = 'D' THEN
							(SELECT 'IPC_IntervalPeriod' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPC_IntervalPeriod as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPC_IntervalPeriod as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IPC_FunctionName) Or @ChangeType = 'D' THEN
							(SELECT 'IPC_FunctionName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPC_FunctionName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPC_FunctionName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IPC_TimestampTableName) Or @ChangeType = 'D' THEN
							(SELECT 'IPC_TimestampTableName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPC_TimestampTableName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPC_TimestampTableName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IPC_IsFirstRunDry) Or @ChangeType = 'D' THEN
							(SELECT 'IPC_IsFirstRunDry' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPC_IsFirstRunDry as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPC_IsFirstRunDry as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IPC_IgnoreIfValueIsOrUnder) Or @ChangeType = 'D' THEN
							(SELECT 'IPC_IgnoreIfValueIsOrUnder' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPC_IgnoreIfValueIsOrUnder as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPC_IgnoreIfValueIsOrUnder as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IPC_IsActive) Or @ChangeType = 'D' THEN
							(SELECT 'IPC_IsActive' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPC_IsActive as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPC_IsActive as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.IPC_ID = D.IPC_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'PerformanceData.InternalPerformanceCounters' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [PerformanceData].[InternalPerformanceCounters] DISABLE TRIGGER [trg_InternalPerformanceCounters_HistoryLogging]
GO
