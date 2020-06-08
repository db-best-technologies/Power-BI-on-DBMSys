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
/****** Object:  Table [Inventory].[InstanceClusterSharedDrives]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[InstanceClusterSharedDrives](
	[ICD_ID] [int] IDENTITY(1,1) NOT NULL,
	[ICD_ClientID] [int] NOT NULL,
	[ICD_MOB_ID] [int] NOT NULL,
	[ICD_DriveName] [nchar](1) NOT NULL,
	[ICD_InsertDate] [datetime2](3) NOT NULL,
	[ICD_LastSeenDate] [datetime2](3) NOT NULL,
	[ICD_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_InstanceClusterDisks] PRIMARY KEY CLUSTERED 
(
	[ICD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_InstanceClusterSharedDrives_ICD_MOB_ID#ICD_DriveName]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_InstanceClusterSharedDrives_ICD_MOB_ID#ICD_DriveName] ON [Inventory].[InstanceClusterSharedDrives]
(
	[ICD_MOB_ID] ASC,
	[ICD_DriveName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_InstanceClusterSharedDrives_HistoryLogging]    Script Date: 6/8/2020 1:15:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_InstanceClusterSharedDrives_HistoryLogging] ON [Inventory].[InstanceClusterSharedDrives]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.InstanceClusterSharedDrives' TabName, C_MOB_ID, ICD_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.ICD_MOB_ID C_MOB_ID, D.ICD_ID, 
					(SELECT CASE WHEN UPDATE(ICD_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'ICD_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ICD_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ICD_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ICD_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ICD_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ICD_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ICD_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ICD_DriveName) Or @ChangeType = 'D' THEN
							(SELECT 'ICD_DriveName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ICD_DriveName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ICD_DriveName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.ICD_ID = D.ICD_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.InstanceClusterSharedDrives' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[InstanceClusterSharedDrives] DISABLE TRIGGER [trg_InstanceClusterSharedDrives_HistoryLogging]
GO
