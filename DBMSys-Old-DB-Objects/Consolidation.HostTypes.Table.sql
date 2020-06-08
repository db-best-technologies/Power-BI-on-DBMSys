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
/****** Object:  Table [Consolidation].[HostTypes]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Consolidation].[HostTypes](
	[HST_ID] [tinyint] NOT NULL,
	[HST_CLV_ID] [tinyint] NULL,
	[HST_Name] [varchar](100) NOT NULL,
	[HST_IsCloud] [bit] NOT NULL,
	[HST_NumberOfInstancesPerHost] [int] NULL,
	[HST_IsLimitedByDisk] [bit] NOT NULL,
	[HST_IsConsolidation] [bit] NOT NULL,
	[HST_UseMonthlyIOPS] [bit] NULL,
	[HST_IsSharingOS] [bit] NOT NULL,
	[HST_IsPerSingleDatabase] [bit] NOT NULL,
	[HST_ExclusivityGroupID] [tinyint] NULL,
	[HST_ReportName] [nvarchar](255) NULL,
 CONSTRAINT [PK_HostTypes] PRIMARY KEY CLUSTERED 
(
	[HST_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Trigger [Consolidation].[trg_HostTypes_HistoryLogging]    Script Date: 6/8/2020 1:14:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Consolidation].[trg_HostTypes_HistoryLogging] ON [Consolidation].[HostTypes]
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
	INSERT INTO Management.History(HIS_Type, HIS_Datetime, HIS_TableName, HIS_PK_1, 	HIS_Changes, HIS_UserName, HIS_AppName, HIS_HostName)
	SELECT *
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Consolidation.HostTypes' TabName, HST_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.HST_ID, 
					(SELECT CASE WHEN UPDATE(HST_CLV_ID) Or @ChangeType = 'D' THEN
							(SELECT 'HST_CLV_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.HST_CLV_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.HST_CLV_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(HST_Name) Or @ChangeType = 'D' THEN
							(SELECT 'HST_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.HST_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.HST_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(HST_IsCloud) Or @ChangeType = 'D' THEN
							(SELECT 'HST_IsCloud' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.HST_IsCloud as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.HST_IsCloud as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(HST_NumberOfInstancesPerHost) Or @ChangeType = 'D' THEN
							(SELECT 'HST_NumberOfInstancesPerHost' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.HST_NumberOfInstancesPerHost as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.HST_NumberOfInstancesPerHost as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(HST_IsLimitedByDisk) Or @ChangeType = 'D' THEN
							(SELECT 'HST_IsLimitedByDisk' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.HST_IsLimitedByDisk as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.HST_IsLimitedByDisk as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(HST_IsConsolidation) Or @ChangeType = 'D' THEN
							(SELECT 'HST_IsConsolidation' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.HST_IsConsolidation as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.HST_IsConsolidation as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(HST_UseMonthlyIOPS) Or @ChangeType = 'D' THEN
							(SELECT 'HST_UseMonthlyIOPS' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.HST_UseMonthlyIOPS as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.HST_UseMonthlyIOPS as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(HST_IsSharingOS) Or @ChangeType = 'D' THEN
							(SELECT 'HST_IsSharingOS' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.HST_IsSharingOS as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.HST_IsSharingOS as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(HST_IsPerSingleDatabase) Or @ChangeType = 'D' THEN
							(SELECT 'HST_IsPerSingleDatabase' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.HST_IsPerSingleDatabase as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.HST_IsPerSingleDatabase as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.HST_ID = D.HST_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Consolidation.HostTypes' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Consolidation].[HostTypes] DISABLE TRIGGER [trg_HostTypes_HistoryLogging]
GO
