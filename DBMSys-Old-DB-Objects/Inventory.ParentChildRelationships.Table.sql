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
/****** Object:  Table [Inventory].[ParentChildRelationships]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[ParentChildRelationships](
	[PCR_ID] [int] IDENTITY(1,1) NOT NULL,
	[PCR_ClientID] [int] NOT NULL,
	[PCR_Parent_MOB_ID] [int] NOT NULL,
	[PCR_Child_MOB_ID] [int] NOT NULL,
	[PCR_IsCurrentParent] [bit] NOT NULL,
	[PCR_InsertDate] [datetime2](3) NOT NULL,
	[PCR_LastSeenDate] [datetime2](3) NOT NULL,
	[PCR_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_ParentChildRelationships] PRIMARY KEY CLUSTERED 
(
	[PCR_Parent_MOB_ID] ASC,
	[PCR_Child_MOB_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_ParentChildRelationships_HistoryLogging]    Script Date: 6/8/2020 1:15:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_ParentChildRelationships_HistoryLogging] ON [Inventory].[ParentChildRelationships]
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
	INSERT INTO Inventory.History(HIS_Type, HIS_Datetime, HIS_TableName, HIS_MOB_ID, HIS_PK_1, HIS_PK_2, 	HIS_Changes, HIS_UserName, HIS_AppName, HIS_HostName)
	SELECT *
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.ParentChildRelationships' TabName, C_MOB_ID, PCR_Parent_MOB_ID, PCR_Child_MOB_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.PCR_Parent_MOB_ID C_MOB_ID, D.PCR_Parent_MOB_ID, D.PCR_Child_MOB_ID, 
					(SELECT CASE WHEN UPDATE(PCR_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PCR_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PCR_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PCR_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PCR_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'PCR_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PCR_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PCR_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PCR_IsCurrentParent) Or @ChangeType = 'D' THEN
							(SELECT 'PCR_IsCurrentParent' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PCR_IsCurrentParent as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PCR_IsCurrentParent as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.PCR_Parent_MOB_ID = D.PCR_Parent_MOB_ID AND I.PCR_Child_MOB_ID = D.PCR_Child_MOB_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.ParentChildRelationships' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[ParentChildRelationships] DISABLE TRIGGER [trg_ParentChildRelationships_HistoryLogging]
GO
