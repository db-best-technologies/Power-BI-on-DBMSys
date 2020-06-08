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
/****** Object:  Table [Inventory].[ConnectedIPCClasses]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[ConnectedIPCClasses](
	[CIC_ID] [int] IDENTITY(1,1) NOT NULL,
	[CIC_ClientID] [int] NOT NULL,
	[CIC_MOB_ID] [int] NOT NULL,
	[CIC_CClass] [varchar](11) NOT NULL,
	[CIC_InsertDate] [datetime2](3) NOT NULL,
	[CIC_LastSeenDate] [datetime2](3) NOT NULL,
	[CIC_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_ConnectedIPCClasses] PRIMARY KEY CLUSTERED 
(
	[CIC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_ConnectedIPCClasses_CIC_MOB_ID#CIC_CClass]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_ConnectedIPCClasses_CIC_MOB_ID#CIC_CClass] ON [Inventory].[ConnectedIPCClasses]
(
	[CIC_MOB_ID] ASC,
	[CIC_CClass] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_ConnectedIPCClasses_HistoryLogging]    Script Date: 6/8/2020 1:15:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_ConnectedIPCClasses_HistoryLogging] ON [Inventory].[ConnectedIPCClasses]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.ConnectedIPCClasses' TabName, CIC_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.CIC_ID, 
					(SELECT CASE WHEN UPDATE(CIC_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'CIC_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CIC_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CIC_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CIC_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'CIC_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CIC_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CIC_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CIC_CClass) Or @ChangeType = 'D' THEN
							(SELECT 'CIC_CClass' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CIC_CClass as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CIC_CClass as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.CIC_ID = D.CIC_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.ConnectedIPCClasses' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[ConnectedIPCClasses] DISABLE TRIGGER [trg_ConnectedIPCClasses_HistoryLogging]
GO
