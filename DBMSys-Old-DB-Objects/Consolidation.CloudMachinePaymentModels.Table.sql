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
/****** Object:  Table [Consolidation].[CloudMachinePaymentModels]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[CloudMachinePaymentModels](
	[CPM_ID] [tinyint] NOT NULL,
	[CPM_Name] [varchar](200) NOT NULL,
	[CPM_NumberOfMonths] [tinyint] NOT NULL,
	[CPM_UpfrontType] [tinyint] NOT NULL,
 CONSTRAINT [PK_CloudMachinePaymentModels] PRIMARY KEY CLUSTERED 
(
	[CPM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_CloudMachinePaymentModels_CPM_Name]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_CloudMachinePaymentModels_CPM_Name] ON [Consolidation].[CloudMachinePaymentModels]
(
	[CPM_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Consolidation].[trg_CloudMachinePaymentModels_HistoryLogging]    Script Date: 6/8/2020 1:14:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Consolidation].[trg_CloudMachinePaymentModels_HistoryLogging] ON [Consolidation].[CloudMachinePaymentModels]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Consolidation.CloudMachinePaymentModels' TabName, CPM_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.CPM_ID, 
					(SELECT CASE WHEN UPDATE(CPM_Name) Or @ChangeType = 'D' THEN
							(SELECT 'CPM_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CPM_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CPM_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CPM_NumberOfMonths) Or @ChangeType = 'D' THEN
							(SELECT 'CPM_NumberOfMonths' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CPM_NumberOfMonths as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CPM_NumberOfMonths as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CPM_UpfrontType) Or @ChangeType = 'D' THEN
							(SELECT 'CPM_UpfrontType' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CPM_UpfrontType as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CPM_UpfrontType as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.CPM_ID = D.CPM_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Consolidation.CloudMachinePaymentModels' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Consolidation].[CloudMachinePaymentModels] DISABLE TRIGGER [trg_CloudMachinePaymentModels_HistoryLogging]
GO
