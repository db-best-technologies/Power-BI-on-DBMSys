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
/****** Object:  Table [Inventory].[RecommendedIndexes]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[RecommendedIndexes](
	[RCI_ID] [int] IDENTITY(1,1) NOT NULL,
	[RCI_ClientID] [int] NOT NULL,
	[RCI_MOB_ID] [int] NOT NULL,
	[RCI_ITQ_ID] [int] NOT NULL,
	[RCI_Impact] [decimal](10, 2) NOT NULL,
	[RCI_IndexScript] [nvarchar](max) NOT NULL,
	[RCI_HashedIndexScript]  AS (hashbytes('MD5',left(CONVERT([varchar](max),[RCI_IndexScript],(0)),(8000)))),
	[RCI_InsertDate] [datetime2](3) NOT NULL,
	[RCI_LastSeenDate] [datetime2](3) NOT NULL,
	[RCI_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_RecommendedIndexes] PRIMARY KEY CLUSTERED 
(
	[RCI_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET NUMERIC_ROUNDABORT OFF
GO
/****** Object:  Index [IX_RecommendedIndexes_RCI_MOB_ID#RCI_ITQ_ID#RCI_HashedIndexScript]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_RecommendedIndexes_RCI_MOB_ID#RCI_ITQ_ID#RCI_HashedIndexScript] ON [Inventory].[RecommendedIndexes]
(
	[RCI_MOB_ID] ASC,
	[RCI_ITQ_ID] ASC,
	[RCI_HashedIndexScript] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_RecommendedIndexes_HistoryLogging]    Script Date: 6/8/2020 1:15:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_RecommendedIndexes_HistoryLogging] ON [Inventory].[RecommendedIndexes]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.RecommendedIndexes' TabName, C_MOB_ID, RCI_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.RCI_MOB_ID C_MOB_ID, D.RCI_ID, 
					(SELECT CASE WHEN UPDATE(RCI_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'RCI_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RCI_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RCI_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(RCI_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'RCI_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RCI_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RCI_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(RCI_ITQ_ID) Or @ChangeType = 'D' THEN
							(SELECT 'RCI_ITQ_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RCI_ITQ_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RCI_ITQ_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(RCI_Impact) Or @ChangeType = 'D' THEN
							(SELECT 'RCI_Impact' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.RCI_Impact as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.RCI_Impact as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.RCI_ID = D.RCI_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.RecommendedIndexes' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[RecommendedIndexes] DISABLE TRIGGER [trg_RecommendedIndexes_HistoryLogging]
GO
