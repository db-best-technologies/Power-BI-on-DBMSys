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
/****** Object:  Table [Collect].[IngoreErrorMessages]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Collect].[IngoreErrorMessages](
	[IEM_ID] [int] IDENTITY(1,1) NOT NULL,
	[IEM_ErrorMessage] [nvarchar](2000) NOT NULL,
	[IEM_IsActive] [bit] NOT NULL,
 CONSTRAINT [PK_IngoreErrorMessages] PRIMARY KEY CLUSTERED 
(
	[IEM_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Trigger [Collect].[trg_IngoreErrorMessages_HistoryLogging]    Script Date: 6/8/2020 1:14:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Collect].[trg_IngoreErrorMessages_HistoryLogging] ON [Collect].[IngoreErrorMessages]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Collect.IngoreErrorMessages' TabName, IEM_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.IEM_ID, 
					(SELECT CASE WHEN UPDATE(IEM_ErrorMessage) Or @ChangeType = 'D' THEN
							(SELECT 'IEM_ErrorMessage' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IEM_ErrorMessage as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IEM_ErrorMessage as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IEM_IsActive) Or @ChangeType = 'D' THEN
							(SELECT 'IEM_IsActive' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IEM_IsActive as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IEM_IsActive as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.IEM_ID = D.IEM_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Collect.IngoreErrorMessages' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Collect].[IngoreErrorMessages] DISABLE TRIGGER [trg_IngoreErrorMessages_HistoryLogging]
GO