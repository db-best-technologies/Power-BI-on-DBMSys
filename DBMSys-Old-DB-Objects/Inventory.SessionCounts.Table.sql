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
/****** Object:  Table [Inventory].[SessionCounts]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[SessionCounts](
	[SSC_ID] [int] IDENTITY(1,1) NOT NULL,
	[SSC_Client_ID] [int] NOT NULL,
	[SSC_MOB_ID] [int] NOT NULL,
	[SSC_Inst_ID] [int] NOT NULL,
	[SSC_Active] [int] NOT NULL,
	[SSC_Killed] [int] NOT NULL,
	[SSC_Total] [int] NOT NULL,
	[SSC_db_max_sessions] [int] NOT NULL,
	[SSC_pct_used] [numeric](9, 2) NOT NULL,
	[SSC_InsertDate] [datetime2](3) NOT NULL,
	[SSC_LastSeenDate] [datetime2](3) NOT NULL,
	[SSC_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_SessionCounts] PRIMARY KEY CLUSTERED 
(
	[SSC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_SessionCounts_HistoryLogging]    Script Date: 6/8/2020 1:15:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_SessionCounts_HistoryLogging] ON [Inventory].[SessionCounts]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.SessionCounts' TabName, C_MOB_ID, SSC_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.SSC_MOB_ID C_MOB_ID, D.SSC_ID, 
					(SELECT CASE WHEN UPDATE(SSC_Client_ID) Or @ChangeType = 'D' THEN
							(SELECT 'SSC_Client_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SSC_Client_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SSC_Client_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SSC_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'SSC_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SSC_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SSC_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SSC_Inst_ID) Or @ChangeType = 'D' THEN
							(SELECT 'SSC_Inst_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SSC_Inst_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SSC_Inst_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SSC_Active) Or @ChangeType = 'D' THEN
							(SELECT 'SSC_Active' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SSC_Active as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SSC_Active as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SSC_Killed) Or @ChangeType = 'D' THEN
							(SELECT 'SSC_Killed' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SSC_Killed as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SSC_Killed as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SSC_Total) Or @ChangeType = 'D' THEN
							(SELECT 'SSC_Total' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SSC_Total as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SSC_Total as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SSC_db_max_sessions) Or @ChangeType = 'D' THEN
							(SELECT 'SSC_db_max_sessions' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SSC_db_max_sessions as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SSC_db_max_sessions as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SSC_pct_used) Or @ChangeType = 'D' THEN
							(SELECT 'SSC_pct_used' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SSC_pct_used as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SSC_pct_used as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.SSC_ID = D.SSC_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.SessionCounts' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[SessionCounts] DISABLE TRIGGER [trg_SessionCounts_HistoryLogging]
GO
