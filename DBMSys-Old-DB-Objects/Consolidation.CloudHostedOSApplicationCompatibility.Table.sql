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
/****** Object:  Table [Consolidation].[CloudHostedOSApplicationCompatibility]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[CloudHostedOSApplicationCompatibility](
	[COA_ID] [int] IDENTITY(1,1) NOT NULL,
	[COA_OST_ID] [tinyint] NOT NULL,
	[COA_CHA_ID] [tinyint] NOT NULL,
 CONSTRAINT [PK_CloudHostedOSApplicationCompatibility] PRIMARY KEY CLUSTERED 
(
	[COA_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_CloudHostedOSApplicationCompatibility_COA_OST_ID#COA_CHA_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_CloudHostedOSApplicationCompatibility_COA_OST_ID#COA_CHA_ID] ON [Consolidation].[CloudHostedOSApplicationCompatibility]
(
	[COA_OST_ID] ASC,
	[COA_CHA_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Consolidation].[trg_CloudHostedOSApplicationCompatibility_HistoryLogging]    Script Date: 6/8/2020 1:14:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Consolidation].[trg_CloudHostedOSApplicationCompatibility_HistoryLogging] ON [Consolidation].[CloudHostedOSApplicationCompatibility]
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
	INSERT INTO Internal.History(HIS_Type, HIS_Datetime, HIS_TableName, HIS_PK_1, 	HIS_Changes, HIS_UserName, HIS_AppName, HIS_HostName)
	SELECT *
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Consolidation.CloudHostedOSApplicationCompatibility' TabName, COA_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.COA_ID, 
					(SELECT CASE WHEN UPDATE(COA_OST_ID) Or @ChangeType = 'D' THEN
							(SELECT 'COA_OST_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.COA_OST_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.COA_OST_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(COA_CHA_ID) Or @ChangeType = 'D' THEN
							(SELECT 'COA_CHA_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.COA_CHA_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.COA_CHA_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.COA_ID = D.COA_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Consolidation.CloudHostedOSApplicationCompatibility' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Consolidation].[CloudHostedOSApplicationCompatibility] DISABLE TRIGGER [trg_CloudHostedOSApplicationCompatibility_HistoryLogging]
GO
