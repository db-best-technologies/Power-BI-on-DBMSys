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
/****** Object:  Table [Operational].[MaintenanceWindowGroups]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Operational].[MaintenanceWindowGroups](
	[MWG_ID] [int] IDENTITY(1,1) NOT NULL,
	[MWG_StartTime] [datetimeoffset](7) NOT NULL,
	[MWG_EndTime] [datetimeoffset](7) NOT NULL,
	[MWG_Description] [nvarchar](1000) NULL,
 CONSTRAINT [PK_MaintenanceWindowGroups] PRIMARY KEY CLUSTERED 
(
	[MWG_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Operational].[MaintenanceWindowGroups]  WITH CHECK ADD  CONSTRAINT [CK_MaintenanceWindowGroups_MWG_StartTime_MWG_EndTime] CHECK  (([MWG_StartTime]<[MWG_EndTime]))
GO
ALTER TABLE [Operational].[MaintenanceWindowGroups] CHECK CONSTRAINT [CK_MaintenanceWindowGroups_MWG_StartTime_MWG_EndTime]
GO
/****** Object:  Trigger [Operational].[trg_MaintenanceWindowGroups_HistoryLogging]    Script Date: 6/8/2020 1:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Operational].[trg_MaintenanceWindowGroups_HistoryLogging] ON [Operational].[MaintenanceWindowGroups]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Operational.MaintenanceWindowGroups' TabName, MWG_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.MWG_ID, 
					(SELECT CASE WHEN UPDATE(MWG_StartTime) Or @ChangeType = 'D' THEN
							(SELECT 'MWG_StartTime' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MWG_StartTime as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MWG_StartTime as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MWG_EndTime) Or @ChangeType = 'D' THEN
							(SELECT 'MWG_EndTime' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MWG_EndTime as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MWG_EndTime as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MWG_Description) Or @ChangeType = 'D' THEN
							(SELECT 'MWG_Description' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MWG_Description as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MWG_Description as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.MWG_ID = D.MWG_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Operational.MaintenanceWindowGroups' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Operational].[MaintenanceWindowGroups] DISABLE TRIGGER [trg_MaintenanceWindowGroups_HistoryLogging]
GO
