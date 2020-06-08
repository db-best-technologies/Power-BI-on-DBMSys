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
/****** Object:  Table [Inventory].[InstanceJobs]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[InstanceJobs](
	[IJB_ID] [int] IDENTITY(1,1) NOT NULL,
	[IJB_ClientID] [int] NOT NULL,
	[IJB_MOB_ID] [int] NOT NULL,
	[IJB_Name] [nvarchar](128) NOT NULL,
	[IJB_IJC_ID] [int] NULL,
	[IJB_Schedules] [nvarchar](max) NULL,
	[IJB_StartStepID] [int] NULL,
	[IJB_InsertDate] [datetime2](3) NOT NULL,
	[IJB_LastSeenDate] [datetime2](3) NOT NULL,
	[IJB_Last_TRH_ID] [int] NOT NULL,
	[IJB_Owner_INL_ID] [int] NULL,
	[IJB_IsEnabled] [bit] NULL,
	[IJB_HasSchedules] [bit] NULL,
 CONSTRAINT [PK_InstanceJobs] PRIMARY KEY CLUSTERED 
(
	[IJB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_InstanceJobs_IJB_MOB_ID#IJB_Name]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_InstanceJobs_IJB_MOB_ID#IJB_Name] ON [Inventory].[InstanceJobs]
(
	[IJB_MOB_ID] ASC,
	[IJB_Name] ASC,
	[IJB_Owner_INL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_InstanceJobs_HistoryLogging]    Script Date: 6/8/2020 1:15:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_InstanceJobs_HistoryLogging] ON [Inventory].[InstanceJobs]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.InstanceJobs' TabName, C_MOB_ID, IJB_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.IJB_MOB_ID C_MOB_ID, D.IJB_ID, 
					(SELECT CASE WHEN UPDATE(IJB_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'IJB_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IJB_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IJB_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IJB_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IJB_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IJB_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IJB_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IJB_Name) Or @ChangeType = 'D' THEN
							(SELECT 'IJB_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IJB_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IJB_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IJB_IJC_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IJB_IJC_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IJB_IJC_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IJB_IJC_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IJB_StartStepID) Or @ChangeType = 'D' THEN
							(SELECT 'IJB_StartStepID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IJB_StartStepID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IJB_StartStepID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IJB_Owner_INL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IJB_Owner_INL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IJB_Owner_INL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IJB_Owner_INL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IJB_IsEnabled) Or @ChangeType = 'D' THEN
							(SELECT 'IJB_IsEnabled' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IJB_IsEnabled as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IJB_IsEnabled as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IJB_HasSchedules) Or @ChangeType = 'D' THEN
							(SELECT 'IJB_HasSchedules' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IJB_HasSchedules as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IJB_HasSchedules as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.IJB_ID = D.IJB_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.InstanceJobs' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[InstanceJobs] DISABLE TRIGGER [trg_InstanceJobs_HistoryLogging]
GO
