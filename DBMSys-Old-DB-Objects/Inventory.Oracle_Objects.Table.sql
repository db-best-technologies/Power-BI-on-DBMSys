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
/****** Object:  Table [Inventory].[Oracle_Objects]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[Oracle_Objects](
	[OPC_ID] [int] IDENTITY(1,1) NOT NULL,
	[OPC_Client_ID] [int] NOT NULL,
	[OPC_MOB_ID] [int] NOT NULL,
	[OPC_Schema] [nvarchar](255) NOT NULL,
	[OPC_Object_Name] [nvarchar](255) NOT NULL,
	[OPC_OOT_ID] [int] NOT NULL,
	[OPC_CreateDate] [datetime2](3) NOT NULL,
	[OPC_Last_Upd_Date] [datetime2](3) NOT NULL,
	[OPC_TPS_ID] [int] NOT NULL,
	[OPC_Temporary] [bit] NOT NULL,
	[OPC_Generated] [bit] NOT NULL,
	[OPC_Secondary] [bit] NOT NULL,
	[OPC_Lines_Chars_Count] [int] NOT NULL,
	[OPC_IsWrapped] [bit] NOT NULL,
	[OPC_IsCharCount] [bit] NOT NULL,
	[OPC_InsertDate] [datetime2](3) NOT NULL,
	[OPC_LastSeenDate] [datetime2](3) NOT NULL,
	[OPC_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_Oracle_Procedures] PRIMARY KEY CLUSTERED 
(
	[OPC_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_Oracle_Objects_HistoryLogging]    Script Date: 6/8/2020 1:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_Oracle_Objects_HistoryLogging] ON [Inventory].[Oracle_Objects]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.Oracle_Objects' TabName, C_MOB_ID, OPC_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.OPC_MOB_ID C_MOB_ID, D.OPC_ID, 
					(SELECT CASE WHEN UPDATE(OPC_Client_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OPC_Client_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OPC_Client_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OPC_Client_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OPC_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OPC_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OPC_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OPC_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OPC_Schema) Or @ChangeType = 'D' THEN
							(SELECT 'OPC_Schema' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OPC_Schema as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OPC_Schema as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OPC_Object_Name) Or @ChangeType = 'D' THEN
							(SELECT 'OPC_Object_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OPC_Object_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OPC_Object_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OPC_OOT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OPC_OOT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OPC_OOT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OPC_OOT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OPC_CreateDate) Or @ChangeType = 'D' THEN
							(SELECT 'OPC_CreateDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OPC_CreateDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OPC_CreateDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OPC_Last_Upd_Date) Or @ChangeType = 'D' THEN
							(SELECT 'OPC_Last_Upd_Date' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OPC_Last_Upd_Date as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OPC_Last_Upd_Date as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OPC_TPS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'OPC_TPS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OPC_TPS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OPC_TPS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OPC_Temporary) Or @ChangeType = 'D' THEN
							(SELECT 'OPC_Temporary' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OPC_Temporary as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OPC_Temporary as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OPC_Generated) Or @ChangeType = 'D' THEN
							(SELECT 'OPC_Generated' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OPC_Generated as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OPC_Generated as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OPC_Secondary) Or @ChangeType = 'D' THEN
							(SELECT 'OPC_Secondary' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OPC_Secondary as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OPC_Secondary as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OPC_Lines_Chars_Count) Or @ChangeType = 'D' THEN
							(SELECT 'OPC_Lines_Chars_Count' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OPC_Lines_Chars_Count as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OPC_Lines_Chars_Count as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OPC_IsWrapped) Or @ChangeType = 'D' THEN
							(SELECT 'OPC_IsWrapped' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OPC_IsWrapped as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OPC_IsWrapped as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(OPC_IsCharCount) Or @ChangeType = 'D' THEN
							(SELECT 'OPC_IsCharCount' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.OPC_IsCharCount as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.OPC_IsCharCount as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.OPC_ID = D.OPC_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.Oracle_Objects' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[Oracle_Objects] DISABLE TRIGGER [trg_Oracle_Objects_HistoryLogging]
GO
