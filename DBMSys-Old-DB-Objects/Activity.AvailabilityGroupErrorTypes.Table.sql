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
/****** Object:  Table [Activity].[AvailabilityGroupErrorTypes]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Activity].[AvailabilityGroupErrorTypes](
	[AGT_ID] [tinyint] NOT NULL,
	[AGT_Name] [varchar](50) NOT NULL,
 CONSTRAINT [PK_AvailabilityGroupErrorTypes] PRIMARY KEY CLUSTERED 
(
	[AGT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Trigger [Activity].[trg_AvailabilityGroupErrorTypes_HistoryLogging]    Script Date: 6/8/2020 1:14:34 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Activity].[trg_AvailabilityGroupErrorTypes_HistoryLogging] ON [Activity].[AvailabilityGroupErrorTypes]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Activity.AvailabilityGroupErrorTypes' TabName, AGT_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.AGT_ID, 
					(SELECT CASE WHEN UPDATE(AGT_Name) Or @ChangeType = 'D' THEN
							(SELECT 'AGT_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.AGT_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.AGT_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.AGT_ID = D.AGT_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Activity.AvailabilityGroupErrorTypes' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Activity].[AvailabilityGroupErrorTypes] DISABLE TRIGGER [trg_AvailabilityGroupErrorTypes_HistoryLogging]
GO
