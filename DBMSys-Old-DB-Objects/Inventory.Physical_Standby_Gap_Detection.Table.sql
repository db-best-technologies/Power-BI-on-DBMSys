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
/****** Object:  Table [Inventory].[Physical_Standby_Gap_Detection]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[Physical_Standby_Gap_Detection](
	[PSG_ID] [int] IDENTITY(1,1) NOT NULL,
	[PSG_Client_ID] [int] NOT NULL,
	[PSG_MOB_ID] [int] NOT NULL,
	[PSG_Warning_Message] [nvarchar](1024) NULL,
	[PSG_InsertDate] [datetime2](3) NOT NULL,
	[PSG_LastSeenDate] [datetime2](3) NOT NULL,
	[PSG_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_Physical_Standby_Gap_Detection] PRIMARY KEY CLUSTERED 
(
	[PSG_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_Physical_Standby_Gap_Detection_HistoryLogging]    Script Date: 6/8/2020 1:15:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_Physical_Standby_Gap_Detection_HistoryLogging] ON [Inventory].[Physical_Standby_Gap_Detection]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.Physical_Standby_Gap_Detection' TabName, C_MOB_ID, PSG_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.PSG_MOB_ID C_MOB_ID, D.PSG_ID, 
					(SELECT CASE WHEN UPDATE(PSG_Client_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PSG_Client_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PSG_Client_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PSG_Client_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PSG_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PSG_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PSG_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PSG_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PSG_Warning_Message) Or @ChangeType = 'D' THEN
							(SELECT 'PSG_Warning_Message' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PSG_Warning_Message as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PSG_Warning_Message as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.PSG_ID = D.PSG_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.Physical_Standby_Gap_Detection' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[Physical_Standby_Gap_Detection] DISABLE TRIGGER [trg_Physical_Standby_Gap_Detection_HistoryLogging]
GO
