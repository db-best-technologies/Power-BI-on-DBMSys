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
/****** Object:  Table [Inventory].[AvailabilityGroupReplicas]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[AvailabilityGroupReplicas](
	[AGR_ID] [int] IDENTITY(1,1) NOT NULL,
	[AGR_ClientID] [int] NOT NULL,
	[AGR_GroupID] [uniqueidentifier] NOT NULL,
	[AGR_Name] [nvarchar](128) NULL,
	[AGR_AGL_ID] [tinyint] NULL,
	[AGR_HealthCheckTimeout] [int] NULL,
	[AGR_AGB_ID] [tinyint] NULL,
	[AGR_ReplicaID] [uniqueidentifier] NOT NULL,
	[AGR_MOB_ID] [int] NULL,
	[AGR_EndpointURL] [nvarchar](256) NULL,
	[AGR_AGA_ID] [tinyint] NULL,
	[AGR_AGF_ID] [tinyint] NULL,
	[AGR_Primary_AGN_ID] [tinyint] NULL,
	[AGR_Secondary_AGN_ID] [tinyint] NULL,
	[AGR_CreateDate] [datetime2](3) NULL,
	[AGR_InsertDate] [datetime2](3) NOT NULL,
	[AGR_LastSeenDate] [datetime2](3) NOT NULL,
	[AGR_Last_TRH_ID] [int] NOT NULL,
	[AGR_AGO_ID] [tinyint] NULL,
	[AGR_IsDeleted] [int] NOT NULL,
 CONSTRAINT [PK_AvailabilityGroupReplicas] PRIMARY KEY CLUSTERED 
(
	[AGR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_AvailabilityGroupReplicas_AGR_GroupID#AGR_ReplicaID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_AvailabilityGroupReplicas_AGR_GroupID#AGR_ReplicaID] ON [Inventory].[AvailabilityGroupReplicas]
(
	[AGR_GroupID] ASC,
	[AGR_ReplicaID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [Inventory].[AvailabilityGroupReplicas] ADD  DEFAULT ((0)) FOR [AGR_IsDeleted]
GO
/****** Object:  Trigger [Inventory].[trg_AvailabilityGroupReplicas_HistoryLogging]    Script Date: 6/8/2020 1:15:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_AvailabilityGroupReplicas_HistoryLogging] ON [Inventory].[AvailabilityGroupReplicas]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.AvailabilityGroupReplicas' TabName, C_MOB_ID, AGR_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.AGR_MOB_ID C_MOB_ID, D.AGR_ID, 
					(SELECT CASE WHEN UPDATE(AGR_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'AGR_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGR_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGR_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGR_GroupID) Or @ChangeType = 'D' THEN
							(SELECT 'AGR_GroupID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGR_GroupID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGR_GroupID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGR_Name) Or @ChangeType = 'D' THEN
							(SELECT 'AGR_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGR_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGR_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGR_AGL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'AGR_AGL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGR_AGL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGR_AGL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGR_HealthCheckTimeout) Or @ChangeType = 'D' THEN
							(SELECT 'AGR_HealthCheckTimeout' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGR_HealthCheckTimeout as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGR_HealthCheckTimeout as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGR_AGB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'AGR_AGB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGR_AGB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGR_AGB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGR_ReplicaID) Or @ChangeType = 'D' THEN
							(SELECT 'AGR_ReplicaID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGR_ReplicaID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGR_ReplicaID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGR_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'AGR_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGR_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGR_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGR_EndpointURL) Or @ChangeType = 'D' THEN
							(SELECT 'AGR_EndpointURL' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGR_EndpointURL as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGR_EndpointURL as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGR_AGA_ID) Or @ChangeType = 'D' THEN
							(SELECT 'AGR_AGA_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGR_AGA_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGR_AGA_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGR_AGF_ID) Or @ChangeType = 'D' THEN
							(SELECT 'AGR_AGF_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGR_AGF_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGR_AGF_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGR_Primary_AGN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'AGR_Primary_AGN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGR_Primary_AGN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGR_Primary_AGN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGR_Secondary_AGN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'AGR_Secondary_AGN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGR_Secondary_AGN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGR_Secondary_AGN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGR_CreateDate) Or @ChangeType = 'D' THEN
							(SELECT 'AGR_CreateDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGR_CreateDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGR_CreateDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(AGR_AGO_ID) Or @ChangeType = 'D' THEN
							(SELECT 'AGR_AGO_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGR_AGO_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGR_AGO_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.AGR_ID = D.AGR_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.AvailabilityGroupReplicas' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[AvailabilityGroupReplicas] DISABLE TRIGGER [trg_AvailabilityGroupReplicas_HistoryLogging]
GO
/****** Object:  Trigger [Inventory].[trg_AvailabilityGroupReplicas_LogRoleSwitches]    Script Date: 6/8/2020 1:15:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Inventory].[trg_AvailabilityGroupReplicas_LogRoleSwitches] on [Inventory].[AvailabilityGroupReplicas]
	for update
as
set nocount on
insert into Activity.AvailabilityGroupRoleSwitches(AGS_ClientID, AGS_MOB_ID, AGS_DateRecorded, AGS_AGR_ID, AGS_GroupID, AGS_GroupName)
select i.AGR_ClientID, i.AGR_MOB_ID, i.AGR_LastSeenDate, i.AGR_ID, i.AGR_GroupID, i.AGR_Name
from inserted i
	inner join deleted d on i.AGR_ID = d.AGR_ID
where i.AGR_AGO_ID = 1
	and d.AGR_AGO_ID = 2
GO
ALTER TABLE [Inventory].[AvailabilityGroupReplicas] ENABLE TRIGGER [trg_AvailabilityGroupReplicas_LogRoleSwitches]
GO
