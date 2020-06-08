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
/****** Object:  Table [Inventory].[InstanceOperators]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[InstanceOperators](
	[IOP_ID] [int] IDENTITY(1,1) NOT NULL,
	[IOP_MOB_ID] [int] NOT NULL,
	[IOP_Name] [nvarchar](128) NOT NULL,
	[IOP_Enabled] [tinyint] NOT NULL,
	[IOP_email_address] [nvarchar](100) NULL,
	[IOP_last_email_date] [int] NOT NULL,
	[IOP_last_email_time] [int] NOT NULL,
	[IOP_pager_address] [nvarchar](100) NULL,
	[IOP_last_pager_date] [int] NOT NULL,
	[IOP_last_pager_time] [int] NOT NULL,
	[IOP_weekday_pager_start_time] [int] NOT NULL,
	[IOP_weekday_pager_end_time] [int] NOT NULL,
	[IOP_saturday_pager_start_time] [int] NOT NULL,
	[IOP_saturday_pager_end_time] [int] NOT NULL,
	[IOP_sunday_pager_start_time] [int] NOT NULL,
	[IOP_sunday_pager_end_time] [int] NOT NULL,
	[IOP_pager_days] [tinyint] NOT NULL,
	[IOP_netsend_address] [nvarchar](100) NULL,
	[IOP_last_netsend_date] [int] NOT NULL,
	[IOP_last_netsend_time] [int] NOT NULL,
	[IOP_category_id] [int] NOT NULL,
	[IOP_InsertDate] [datetime2](3) NOT NULL,
	[IOP_LastSeenDate] [datetime2](3) NOT NULL,
	[IOP_Last_TRH_ID] [int] NOT NULL,
	[IOP_ClientID] [int] NOT NULL,
 CONSTRAINT [PK_InstanceOperators] PRIMARY KEY CLUSTERED 
(
	[IOP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_InstanceOperators]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IDX_InstanceOperators] ON [Inventory].[InstanceOperators]
(
	[IOP_MOB_ID] ASC,
	[IOP_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_InstanceOperators_HistoryLogging]    Script Date: 6/8/2020 1:15:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_InstanceOperators_HistoryLogging] ON [Inventory].[InstanceOperators]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.InstanceOperators' TabName, C_MOB_ID, IOP_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.IOP_MOB_ID C_MOB_ID, D.IOP_ID, 
					(SELECT CASE WHEN UPDATE(IOP_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IOP_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IOP_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IOP_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IOP_Name) Or @ChangeType = 'D' THEN
							(SELECT 'IOP_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IOP_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IOP_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IOP_Enabled) Or @ChangeType = 'D' THEN
							(SELECT 'IOP_Enabled' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IOP_Enabled as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IOP_Enabled as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IOP_email_address) Or @ChangeType = 'D' THEN
							(SELECT 'IOP_email_address' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IOP_email_address as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IOP_email_address as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IOP_last_email_date) Or @ChangeType = 'D' THEN
							(SELECT 'IOP_last_email_date' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IOP_last_email_date as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IOP_last_email_date as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IOP_last_email_time) Or @ChangeType = 'D' THEN
							(SELECT 'IOP_last_email_time' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IOP_last_email_time as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IOP_last_email_time as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IOP_pager_address) Or @ChangeType = 'D' THEN
							(SELECT 'IOP_pager_address' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IOP_pager_address as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IOP_pager_address as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IOP_last_pager_date) Or @ChangeType = 'D' THEN
							(SELECT 'IOP_last_pager_date' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IOP_last_pager_date as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IOP_last_pager_date as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IOP_last_pager_time) Or @ChangeType = 'D' THEN
							(SELECT 'IOP_last_pager_time' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IOP_last_pager_time as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IOP_last_pager_time as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IOP_weekday_pager_start_time) Or @ChangeType = 'D' THEN
							(SELECT 'IOP_weekday_pager_start_time' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IOP_weekday_pager_start_time as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IOP_weekday_pager_start_time as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IOP_weekday_pager_end_time) Or @ChangeType = 'D' THEN
							(SELECT 'IOP_weekday_pager_end_time' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IOP_weekday_pager_end_time as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IOP_weekday_pager_end_time as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IOP_saturday_pager_start_time) Or @ChangeType = 'D' THEN
							(SELECT 'IOP_saturday_pager_start_time' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IOP_saturday_pager_start_time as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IOP_saturday_pager_start_time as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IOP_saturday_pager_end_time) Or @ChangeType = 'D' THEN
							(SELECT 'IOP_saturday_pager_end_time' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IOP_saturday_pager_end_time as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IOP_saturday_pager_end_time as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IOP_sunday_pager_start_time) Or @ChangeType = 'D' THEN
							(SELECT 'IOP_sunday_pager_start_time' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IOP_sunday_pager_start_time as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IOP_sunday_pager_start_time as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IOP_sunday_pager_end_time) Or @ChangeType = 'D' THEN
							(SELECT 'IOP_sunday_pager_end_time' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IOP_sunday_pager_end_time as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IOP_sunday_pager_end_time as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IOP_pager_days) Or @ChangeType = 'D' THEN
							(SELECT 'IOP_pager_days' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IOP_pager_days as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IOP_pager_days as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IOP_netsend_address) Or @ChangeType = 'D' THEN
							(SELECT 'IOP_netsend_address' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IOP_netsend_address as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IOP_netsend_address as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IOP_last_netsend_date) Or @ChangeType = 'D' THEN
							(SELECT 'IOP_last_netsend_date' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IOP_last_netsend_date as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IOP_last_netsend_date as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IOP_last_netsend_time) Or @ChangeType = 'D' THEN
							(SELECT 'IOP_last_netsend_time' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IOP_last_netsend_time as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IOP_last_netsend_time as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IOP_category_id) Or @ChangeType = 'D' THEN
							(SELECT 'IOP_category_id' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IOP_category_id as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IOP_category_id as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IOP_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'IOP_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IOP_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IOP_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.IOP_ID = D.IOP_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.InstanceOperators' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[InstanceOperators] DISABLE TRIGGER [trg_InstanceOperators_HistoryLogging]
GO
