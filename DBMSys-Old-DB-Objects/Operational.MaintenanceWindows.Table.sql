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
/****** Object:  Table [Operational].[MaintenanceWindows]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Operational].[MaintenanceWindows](
	[MTW_ID] [int] IDENTITY(1,1) NOT NULL,
	[MTW_MOB_ID] [int] NOT NULL,
	[MTW_IsDeleted] [bit] NOT NULL,
	[MTW_MWG_ID] [int] NULL,
 CONSTRAINT [PK_MaintenanceWindows] PRIMARY KEY CLUSTERED 
(
	[MTW_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [Operational].[MaintenanceWindows] ADD  DEFAULT ((0)) FOR [MTW_IsDeleted]
GO
/****** Object:  Trigger [Operational].[trg_MaintenanceWindows_HistoryLogging]    Script Date: 6/8/2020 1:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Operational].[trg_MaintenanceWindows_HistoryLogging] ON [Operational].[MaintenanceWindows]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Operational.MaintenanceWindows' TabName, MTW_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.MTW_ID, 
					(SELECT CASE WHEN UPDATE(MTW_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'MTW_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MTW_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MTW_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MTW_IsDeleted) Or @ChangeType = 'D' THEN
							(SELECT 'MTW_IsDeleted' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MTW_IsDeleted as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MTW_IsDeleted as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(MTW_MWG_ID) Or @ChangeType = 'D' THEN
							(SELECT 'MTW_MWG_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.MTW_MWG_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.MTW_MWG_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.MTW_ID = D.MTW_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Operational.MaintenanceWindows' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Operational].[MaintenanceWindows] DISABLE TRIGGER [trg_MaintenanceWindows_HistoryLogging]
GO
/****** Object:  Trigger [Operational].[trg_MaintenanceWindows_Validate]    Script Date: 6/8/2020 1:15:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Operational].[trg_MaintenanceWindows_Validate] on [Operational].[MaintenanceWindows]
	for insert, update
as
set nocount on

if exists (select *
			from Operational.MaintenanceWindows m
			join Operational.MaintenanceWindowGroups g on m.MTW_MWG_ID = g.MWG_ID
			where exists (select *
							from inserted i
							join Operational.MaintenanceWindowGroups ig on i.MTW_MWG_ID = ig.MWG_ID
							where m.MTW_MOB_ID = i.MTW_MOB_ID
								and (g.MWG_StartTime between ig.MWG_StartTime and ig.MWG_EndTime
										or ig.MWG_StartTime between g.MWG_StartTime and g.MWG_EndTime)

								and m.MTW_ID <> i.MTW_ID
							)
			)
begin
	raiserror('Overlapping Maintenance Windows are not permitted.', 16, 1)
	rollback
end
GO
ALTER TABLE [Operational].[MaintenanceWindows] DISABLE TRIGGER [trg_MaintenanceWindows_Validate]
GO
