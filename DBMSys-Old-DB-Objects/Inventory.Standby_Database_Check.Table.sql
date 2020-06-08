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
/****** Object:  Table [Inventory].[Standby_Database_Check]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[Standby_Database_Check](
	[STC_ID] [int] IDENTITY(1,1) NOT NULL,
	[STC_Client_ID] [int] NOT NULL,
	[STC_MOB_ID] [int] NOT NULL,
	[STC_Warning_Message] [nvarchar](255) NOT NULL,
	[STC_InsertDate] [datetime2](3) NOT NULL,
	[STC_LastSeenDate] [datetime2](3) NOT NULL,
	[STC_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_Standby_Database_Check] PRIMARY KEY CLUSTERED 
(
	[STC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_Standby_Database_Check_HistoryLogging]    Script Date: 6/8/2020 1:15:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_Standby_Database_Check_HistoryLogging] ON [Inventory].[Standby_Database_Check]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.Standby_Database_Check' TabName, C_MOB_ID, STC_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.STC_MOB_ID C_MOB_ID, D.STC_ID, 
					(SELECT CASE WHEN UPDATE(STC_Client_ID) Or @ChangeType = 'D' THEN
							(SELECT 'STC_Client_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.STC_Client_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.STC_Client_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(STC_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'STC_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.STC_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.STC_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(STC_Warning_Message) Or @ChangeType = 'D' THEN
							(SELECT 'STC_Warning_Message' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.STC_Warning_Message as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.STC_Warning_Message as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.STC_ID = D.STC_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.Standby_Database_Check' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[Standby_Database_Check] DISABLE TRIGGER [trg_Standby_Database_Check_HistoryLogging]
GO