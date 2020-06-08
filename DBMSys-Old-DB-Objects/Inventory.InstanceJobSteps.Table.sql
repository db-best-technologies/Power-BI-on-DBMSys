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
/****** Object:  Table [Inventory].[InstanceJobSteps]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[InstanceJobSteps](
	[IJS_ID] [int] IDENTITY(1,1) NOT NULL,
	[IJS_ClientID] [int] NOT NULL,
	[IJS_MOB_ID] [int] NOT NULL,
	[IJS_IJB_ID] [int] NOT NULL,
	[IJS_StepID] [int] NOT NULL,
	[IJS_Name] [nvarchar](128) NOT NULL,
	[IJS_ISS_ID] [tinyint] NOT NULL,
	[IJS_IDB_ID] [int] NULL,
	[IJS_LastRunDate] [datetime] NULL,
	[IJS_Last_IJR_ID] [tinyint] NULL,
	[IJS_InsertDate] [datetime2](3) NOT NULL,
	[IJS_LastSeenDate] [datetime2](3) NOT NULL,
	[IJS_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_InstanceJobSteps] PRIMARY KEY CLUSTERED 
(
	[IJS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_InstanceJobSteps_IJS_IJB_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_InstanceJobSteps_IJS_IJB_ID] ON [Inventory].[InstanceJobSteps]
(
	[IJS_IJB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_InstanceJobSteps_IJS_MOB_ID#IJS_IJB_ID#IJS_StepID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_InstanceJobSteps_IJS_MOB_ID#IJS_IJB_ID#IJS_StepID] ON [Inventory].[InstanceJobSteps]
(
	[IJS_MOB_ID] ASC,
	[IJS_IJB_ID] ASC,
	[IJS_StepID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_InstanceJobSteps_IJS_MOB_ID#IJS_Last_TRH_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_InstanceJobSteps_IJS_MOB_ID#IJS_Last_TRH_ID] ON [Inventory].[InstanceJobSteps]
(
	[IJS_MOB_ID] ASC,
	[IJS_Last_TRH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Inventory].[InstanceJobSteps]  WITH CHECK ADD  CONSTRAINT [FK_InstanceJobSteps_InstanceJobs] FOREIGN KEY([IJS_IJB_ID])
REFERENCES [Inventory].[InstanceJobs] ([IJB_ID])
ON DELETE CASCADE
GO
ALTER TABLE [Inventory].[InstanceJobSteps] CHECK CONSTRAINT [FK_InstanceJobSteps_InstanceJobs]
GO
/****** Object:  Trigger [Inventory].[trg_InstanceJobSteps_HistoryLogging]    Script Date: 6/8/2020 1:15:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_InstanceJobSteps_HistoryLogging] ON [Inventory].[InstanceJobSteps]
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
	INSERT INTO Inventory.History(HIS_Type, HIS_Datetime, HIS_TableName, HIS_MOB_ID, HIS_PK_1, 	HIS_Changes, HIS_UserName, HIS_AppName, HIS_HostName)
	SELECT *
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.InstanceJobSteps' TabName, C_MOB_ID, IJS_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.IJS_MOB_ID C_MOB_ID, D.IJS_ID, 
					(SELECT CASE WHEN UPDATE(IJS_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'IJS_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IJS_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IJS_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IJS_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IJS_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IJS_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IJS_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IJS_IJB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IJS_IJB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IJS_IJB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IJS_IJB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IJS_StepID) Or @ChangeType = 'D' THEN
							(SELECT 'IJS_StepID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IJS_StepID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IJS_StepID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IJS_Name) Or @ChangeType = 'D' THEN
							(SELECT 'IJS_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IJS_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IJS_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IJS_ISS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IJS_ISS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IJS_ISS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IJS_ISS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IJS_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IJS_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IJS_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IJS_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.IJS_ID = D.IJS_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.InstanceJobSteps' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[InstanceJobSteps] DISABLE TRIGGER [trg_InstanceJobSteps_HistoryLogging]
GO
