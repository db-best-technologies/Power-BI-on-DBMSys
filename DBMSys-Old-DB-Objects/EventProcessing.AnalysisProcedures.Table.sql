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
/****** Object:  Table [EventProcessing].[AnalysisProcedures]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [EventProcessing].[AnalysisProcedures](
	[ANP_ID] [int] IDENTITY(1,1) NOT NULL,
	[ANP_MOV_ID] [int] NOT NULL,
	[ANP_RunningInterval] [int] NOT NULL,
	[ANP_ProcedureName] [nvarchar](257) NOT NULL,
	[ANP_AutoResolveMinutes] [int] NULL,
 CONSTRAINT [PK_AnalysisProcedures] PRIMARY KEY CLUSTERED 
(
	[ANP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Trigger [EventProcessing].[trg_AnalysisProcedures_HistoryLogging]    Script Date: 6/8/2020 1:14:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [EventProcessing].[trg_AnalysisProcedures_HistoryLogging] ON [EventProcessing].[AnalysisProcedures]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'EventProcessing.AnalysisProcedures' TabName, ANP_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.ANP_ID, 
					(SELECT CASE WHEN UPDATE(ANP_MOV_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ANP_MOV_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ANP_MOV_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ANP_MOV_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ANP_RunningInterval) Or @ChangeType = 'D' THEN
							(SELECT 'ANP_RunningInterval' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ANP_RunningInterval as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ANP_RunningInterval as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ANP_ProcedureName) Or @ChangeType = 'D' THEN
							(SELECT 'ANP_ProcedureName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ANP_ProcedureName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ANP_ProcedureName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ANP_AutoResolveMinutes) Or @ChangeType = 'D' THEN
							(SELECT 'ANP_AutoResolveMinutes' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ANP_AutoResolveMinutes as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ANP_AutoResolveMinutes as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.ANP_ID = D.ANP_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'EventProcessing.AnalysisProcedures' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [EventProcessing].[AnalysisProcedures] DISABLE TRIGGER [trg_AnalysisProcedures_HistoryLogging]
GO
/****** Object:  Trigger [EventProcessing].[trg_AnalysisProcedures_Insert_Update]    Script Date: 6/8/2020 1:14:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [EventProcessing].[trg_AnalysisProcedures_Insert_Update] on [EventProcessing].[AnalysisProcedures]
	for insert, update
as
set nocount on
if exists (select *
			from inserted
				inner join EventProcessing.EventDefinitions on ANP_MOV_ID = EDF_MOV_ID)
begin
	rollback
	raiserror('The same Monitored Event can''t hold both Analytical and Online Event Definitions.', 16, 1)
	return
end

if exists (select ANP_MOV_ID
			from EventProcessing.AnalysisProcedures
			group by ANP_MOV_ID
			having COUNT(*) > 1)
begin
	rollback
	raiserror('The same Monitored Event can''t have more than one Analytical Event Definition.', 16, 1)
end
GO
ALTER TABLE [EventProcessing].[AnalysisProcedures] ENABLE TRIGGER [trg_AnalysisProcedures_Insert_Update]
GO
