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
/****** Object:  Table [Inventory].[DTSPackages]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[DTSPackages](
	[DTP_ID] [int] IDENTITY(1,1) NOT NULL,
	[DTP_ClientID] [int] NOT NULL,
	[DTP_MOB_ID] [int] NOT NULL,
	[DTP_Name] [nvarchar](128) NOT NULL,
	[DTP_CreateDate] [datetime2](3) NOT NULL,
	[DTP_IsPartOfAnActiveJob] [bit] NOT NULL,
	[DTP_InsertDate] [datetime2](3) NOT NULL,
	[DTP_LastSeenDate] [datetime2](3) NOT NULL,
	[DTP_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_DTSPackages] PRIMARY KEY CLUSTERED 
(
	[DTP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_DTSPackages_DTP_MOB_ID#DTP_Name]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_DTSPackages_DTP_MOB_ID#DTP_Name] ON [Inventory].[DTSPackages]
(
	[DTP_MOB_ID] ASC,
	[DTP_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_DTSPackages_HistoryLogging]    Script Date: 6/8/2020 1:15:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_DTSPackages_HistoryLogging] ON [Inventory].[DTSPackages]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.DTSPackages' TabName, C_MOB_ID, DTP_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.DTP_MOB_ID C_MOB_ID, D.DTP_ID, 
					(SELECT CASE WHEN UPDATE(DTP_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'DTP_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DTP_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DTP_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DTP_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DTP_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DTP_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DTP_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DTP_Name) Or @ChangeType = 'D' THEN
							(SELECT 'DTP_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DTP_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DTP_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DTP_CreateDate) Or @ChangeType = 'D' THEN
							(SELECT 'DTP_CreateDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DTP_CreateDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DTP_CreateDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DTP_IsPartOfAnActiveJob) Or @ChangeType = 'D' THEN
							(SELECT 'DTP_IsPartOfAnActiveJob' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DTP_IsPartOfAnActiveJob as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DTP_IsPartOfAnActiveJob as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.DTP_ID = D.DTP_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.DTSPackages' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[DTSPackages] DISABLE TRIGGER [trg_DTSPackages_HistoryLogging]
GO
