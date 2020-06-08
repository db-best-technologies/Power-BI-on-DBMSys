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
/****** Object:  Table [GUIObjects].[InterestingPerformanceCounters]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [GUIObjects].[InterestingPerformanceCounters](
	[IPF_ID] [int] IDENTITY(1,1) NOT NULL,
	[IPF_Code] [varchar](50) NOT NULL,
	[IPF_SystemID] [int] NOT NULL,
	[IPF_CounterID] [int] NOT NULL,
	[IPF_InstanceName] [varchar](900) NULL,
	[IPF_DivideBy] [int] NULL,
	[IPF_IsVisible] [bit] NOT NULL,
 CONSTRAINT [PK_InterestingPerformanceCounters] PRIMARY KEY CLUSTERED 
(
	[IPF_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_InterestingPerformanceCounters_IPF_Code#IPF_SystemID#IPF_CounterID#IPF_InstanceName]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_InterestingPerformanceCounters_IPF_Code#IPF_SystemID#IPF_CounterID#IPF_InstanceName] ON [GUIObjects].[InterestingPerformanceCounters]
(
	[IPF_Code] ASC,
	[IPF_SystemID] ASC,
	[IPF_CounterID] ASC,
	[IPF_InstanceName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [GUIObjects].[trg_InterestingPerformanceCounters_HistoryLogging]    Script Date: 6/8/2020 1:14:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [GUIObjects].[trg_InterestingPerformanceCounters_HistoryLogging] ON [GUIObjects].[InterestingPerformanceCounters]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'GUIObjects.InterestingPerformanceCounters' TabName, IPF_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.IPF_ID, 
					(SELECT CASE WHEN UPDATE(IPF_Code) Or @ChangeType = 'D' THEN
							(SELECT 'IPF_Code' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPF_Code as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPF_Code as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IPF_SystemID) Or @ChangeType = 'D' THEN
							(SELECT 'IPF_SystemID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPF_SystemID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPF_SystemID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IPF_CounterID) Or @ChangeType = 'D' THEN
							(SELECT 'IPF_CounterID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPF_CounterID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPF_CounterID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IPF_InstanceName) Or @ChangeType = 'D' THEN
							(SELECT 'IPF_InstanceName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPF_InstanceName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPF_InstanceName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IPF_DivideBy) Or @ChangeType = 'D' THEN
							(SELECT 'IPF_DivideBy' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPF_DivideBy as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPF_DivideBy as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IPF_IsVisible) Or @ChangeType = 'D' THEN
							(SELECT 'IPF_IsVisible' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPF_IsVisible as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPF_IsVisible as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.IPF_ID = D.IPF_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'GUIObjects.InterestingPerformanceCounters' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [GUIObjects].[InterestingPerformanceCounters] DISABLE TRIGGER [trg_InterestingPerformanceCounters_HistoryLogging]
GO
