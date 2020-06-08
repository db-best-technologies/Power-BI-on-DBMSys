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
/****** Object:  Table [ResponseProcessing].[ContactLists_Contacts]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ResponseProcessing].[ContactLists_Contacts](
	[CLC_ID] [int] IDENTITY(1,1) NOT NULL,
	[CLC_ClientID] [int] NOT NULL,
	[CLC_CLS_ID] [int] NOT NULL,
	[CLC_CON_ID] [int] NOT NULL,
 CONSTRAINT [PK_ContactLists_Contacts_1] PRIMARY KEY CLUSTERED 
(
	[CLC_CLS_ID] ASC,
	[CLC_CON_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Trigger [ResponseProcessing].[trg_ContactLists_Contacts_HistoryLogging]    Script Date: 6/8/2020 1:15:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [ResponseProcessing].[trg_ContactLists_Contacts_HistoryLogging] ON [ResponseProcessing].[ContactLists_Contacts]
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
	INSERT INTO Management.History(HIS_Type, HIS_Datetime, HIS_TableName, HIS_PK_1, HIS_PK_2, 	HIS_Changes, HIS_UserName, HIS_AppName, HIS_HostName)
	SELECT *
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'ResponseProcessing.ContactLists_Contacts' TabName, CLC_CLS_ID, CLC_CON_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.CLC_CLS_ID, D.CLC_CON_ID, 
					(SELECT CASE WHEN UPDATE(CLC_ID) Or @ChangeType = 'D' THEN
							(SELECT 'CLC_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CLC_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CLC_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CLC_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'CLC_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CLC_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CLC_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.CLC_CLS_ID = D.CLC_CLS_ID AND I.CLC_CON_ID = D.CLC_CON_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'ResponseProcessing.ContactLists_Contacts' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [ResponseProcessing].[ContactLists_Contacts] DISABLE TRIGGER [trg_ContactLists_Contacts_HistoryLogging]
GO
