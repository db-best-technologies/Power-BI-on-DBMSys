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
/****** Object:  Table [Inventory].[QueryResourceSemaphores]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[QueryResourceSemaphores](
	[QRS_ID] [int] IDENTITY(1,1) NOT NULL,
	[QRS_ClientID] [int] NOT NULL,
	[QRS_MOB_ID] [int] NOT NULL,
	[QRS_PoolID] [int] NULL,
	[QRS_ResourceSemaphoreID] [smallint] NOT NULL,
	[QRS_TargetMemoryKB] [bigint] NULL,
	[QRS_MaxTargetMemoryKB] [bigint] NULL,
	[QRS_TotalMemoryKB] [bigint] NULL,
	[QRS_AvailableMemoryKB] [bigint] NULL,
	[QRS_GrantedMemoryKB] [bigint] NULL,
	[QRS_UsedMemoryKB] [bigint] NULL,
	[QRS_GranteeCount] [int] NULL,
	[QRS_WaiterCount] [int] NULL,
	[QRS_TimeoutErrorCount] [bigint] NULL,
	[QRS_ForcedGrantCount] [bigint] NULL,
	[QRS_InsertDate] [datetime2](3) NOT NULL,
	[QRS_LastSeenDate] [datetime2](3) NOT NULL,
	[QRS_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_QueryResourceSemaphores] PRIMARY KEY CLUSTERED 
(
	[QRS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_QueryResourceSemaphores_QRS_MOB_ID#QRS_PoolID#QRS_ResourceSemaphoreID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_QueryResourceSemaphores_QRS_MOB_ID#QRS_PoolID#QRS_ResourceSemaphoreID] ON [Inventory].[QueryResourceSemaphores]
(
	[QRS_MOB_ID] ASC,
	[QRS_PoolID] ASC,
	[QRS_ResourceSemaphoreID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_QueryResourceSemaphores_HistoryLogging]    Script Date: 6/8/2020 1:15:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_QueryResourceSemaphores_HistoryLogging] ON [Inventory].[QueryResourceSemaphores]
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
	INSERT INTO Inventory.History(HIS_Type, HIS_Datetime, HIS_TableName, HIS_PK_1, 	HIS_Changes, HIS_UserName, HIS_AppName, HIS_HostName)
	SELECT *
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.QueryResourceSemaphores' TabName, QRS_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.QRS_ID, 
					(SELECT CASE WHEN UPDATE(QRS_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'QRS_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.QRS_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.QRS_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(QRS_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'QRS_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.QRS_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.QRS_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(QRS_PoolID) Or @ChangeType = 'D' THEN
							(SELECT 'QRS_PoolID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.QRS_PoolID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.QRS_PoolID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(QRS_ResourceSemaphoreID) Or @ChangeType = 'D' THEN
							(SELECT 'QRS_ResourceSemaphoreID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.QRS_ResourceSemaphoreID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.QRS_ResourceSemaphoreID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(QRS_TargetMemoryKB) Or @ChangeType = 'D' THEN
							(SELECT 'QRS_TargetMemoryKB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.QRS_TargetMemoryKB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.QRS_TargetMemoryKB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(QRS_MaxTargetMemoryKB) Or @ChangeType = 'D' THEN
							(SELECT 'QRS_MaxTargetMemoryKB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.QRS_MaxTargetMemoryKB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.QRS_MaxTargetMemoryKB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(QRS_TotalMemoryKB) Or @ChangeType = 'D' THEN
							(SELECT 'QRS_TotalMemoryKB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.QRS_TotalMemoryKB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.QRS_TotalMemoryKB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(QRS_AvailableMemoryKB) Or @ChangeType = 'D' THEN
							(SELECT 'QRS_AvailableMemoryKB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.QRS_AvailableMemoryKB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.QRS_AvailableMemoryKB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(QRS_GrantedMemoryKB) Or @ChangeType = 'D' THEN
							(SELECT 'QRS_GrantedMemoryKB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.QRS_GrantedMemoryKB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.QRS_GrantedMemoryKB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(QRS_UsedMemoryKB) Or @ChangeType = 'D' THEN
							(SELECT 'QRS_UsedMemoryKB' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.QRS_UsedMemoryKB as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.QRS_UsedMemoryKB as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(QRS_GranteeCount) Or @ChangeType = 'D' THEN
							(SELECT 'QRS_GranteeCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.QRS_GranteeCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.QRS_GranteeCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(QRS_WaiterCount) Or @ChangeType = 'D' THEN
							(SELECT 'QRS_WaiterCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.QRS_WaiterCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.QRS_WaiterCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(QRS_TimeoutErrorCount) Or @ChangeType = 'D' THEN
							(SELECT 'QRS_TimeoutErrorCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.QRS_TimeoutErrorCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.QRS_TimeoutErrorCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(QRS_ForcedGrantCount) Or @ChangeType = 'D' THEN
							(SELECT 'QRS_ForcedGrantCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.QRS_ForcedGrantCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.QRS_ForcedGrantCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.QRS_ID = D.QRS_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.QueryResourceSemaphores' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[QueryResourceSemaphores] DISABLE TRIGGER [trg_QueryResourceSemaphores_HistoryLogging]
GO
