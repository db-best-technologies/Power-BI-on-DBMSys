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
/****** Object:  Table [Inventory].[LogShippingInstances]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[LogShippingInstances](
	[LSI_ID] [int] IDENTITY(1,1) NOT NULL,
	[LSI_ClientID] [int] NOT NULL,
	[LSI_Primary_MOB_ID] [int] NOT NULL,
	[LSI_Primary_IDB_ID] [int] NOT NULL,
	[LSI_Secondary_MOB_ID] [int] NOT NULL,
	[LSI_Secondary_IDB_ID] [int] NOT NULL,
	[LSI_IsReportedFromPrimary] [bit] NOT NULL,
	[LSI_IsReportedFromSecondary] [bit] NOT NULL,
	[LSI_InsertDate] [datetime2](3) NOT NULL,
	[LSI_LastSeenDate] [datetime2](3) NOT NULL,
	[LSI_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_LogShippingConfigurations] PRIMARY KEY CLUSTERED 
(
	[LSI_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_LogShippingInstances_LSI_Primary_MOB_ID#LSI_Last_TRH_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_LogShippingInstances_LSI_Primary_MOB_ID#LSI_Last_TRH_ID] ON [Inventory].[LogShippingInstances]
(
	[LSI_Primary_MOB_ID] ASC,
	[LSI_Last_TRH_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_LogShippingInstances_LSI_Primary_MOB_ID#LSI_Primary_IDB_ID#LSI_Secondary_MOB_ID#LSI_Secondary_IDB_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_LogShippingInstances_LSI_Primary_MOB_ID#LSI_Primary_IDB_ID#LSI_Secondary_MOB_ID#LSI_Secondary_IDB_ID] ON [Inventory].[LogShippingInstances]
(
	[LSI_Primary_MOB_ID] ASC,
	[LSI_Primary_IDB_ID] ASC,
	[LSI_Secondary_MOB_ID] ASC,
	[LSI_Secondary_IDB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_LogShippingInstances_HistoryLogging]    Script Date: 6/8/2020 1:15:21 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_LogShippingInstances_HistoryLogging] ON [Inventory].[LogShippingInstances]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.LogShippingInstances' TabName, C_MOB_ID, LSI_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.LSI_Primary_MOB_ID C_MOB_ID, D.LSI_ID, 
					(SELECT CASE WHEN UPDATE(LSI_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'LSI_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LSI_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LSI_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LSI_Primary_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'LSI_Primary_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LSI_Primary_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LSI_Primary_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LSI_Primary_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'LSI_Primary_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LSI_Primary_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LSI_Primary_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LSI_Secondary_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'LSI_Secondary_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LSI_Secondary_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LSI_Secondary_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LSI_Secondary_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'LSI_Secondary_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LSI_Secondary_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LSI_Secondary_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LSI_IsReportedFromPrimary) Or @ChangeType = 'D' THEN
							(SELECT 'LSI_IsReportedFromPrimary' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LSI_IsReportedFromPrimary as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LSI_IsReportedFromPrimary as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(LSI_IsReportedFromSecondary) Or @ChangeType = 'D' THEN
							(SELECT 'LSI_IsReportedFromSecondary' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.LSI_IsReportedFromSecondary as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.LSI_IsReportedFromSecondary as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.LSI_ID = D.LSI_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.LogShippingInstances' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[LogShippingInstances] DISABLE TRIGGER [trg_LogShippingInstances_HistoryLogging]
GO
