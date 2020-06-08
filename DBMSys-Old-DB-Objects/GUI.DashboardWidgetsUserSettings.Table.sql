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
/****** Object:  Table [GUI].[DashboardWidgetsUserSettings]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [GUI].[DashboardWidgetsUserSettings](
	[DUS_ID] [int] IDENTITY(1,1) NOT NULL,
	[DUS_Name] [nvarchar](255) NOT NULL,
	[DUS_DWT_ID] [int] NOT NULL,
	[DUS_DWP_ID] [int] NOT NULL,
	[DUS_USR_ID] [int] NOT NULL,
	[DUS_CSY_ID] [int] NULL,
	[DUS_CounteID] [int] NULL,
	[DUS_IntervalTime] [int] NULL,
	[DUS_IntervalPeriod] [nvarchar](4) NULL,
	[DUS_AddDate] [datetime2](3) NOT NULL,
	[DUS_DCT_ID] [int] NOT NULL,
	[DUS_ThresholdType] [char](1) NULL,
	[DUS_ThresholdPerc] [float] NULL,
	[DUS_NegativeType] [char](1) NULL,
	[DUS_NegativeValue] [float] NULL,
	[DUS_NeutralType] [char](1) NULL,
	[DUS_NeutralValue] [float] NULL,
	[DUS_PositiveType] [char](1) NULL,
	[DUS_PositiveValue] [float] NULL,
	[DUS_DCC_ID] [int] NULL,
	[DUS_OrderId] [int] NOT NULL,
	[DUS_Width] [float] NOT NULL,
	[DUS_Height] [float] NOT NULL,
 CONSTRAINT [PK_DashboardWidgetsUserSettings] PRIMARY KEY CLUSTERED 
(
	[DUS_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [GUI].[DashboardWidgetsUserSettings] ADD  DEFAULT (getdate()) FOR [DUS_AddDate]
GO
ALTER TABLE [GUI].[DashboardWidgetsUserSettings] ADD  DEFAULT ((0)) FOR [DUS_OrderId]
GO
ALTER TABLE [GUI].[DashboardWidgetsUserSettings] ADD  DEFAULT ((0.0)) FOR [DUS_Width]
GO
ALTER TABLE [GUI].[DashboardWidgetsUserSettings] ADD  DEFAULT ((0.0)) FOR [DUS_Height]
GO
/****** Object:  Trigger [GUI].[trg_DashboardWidgetsUserSettings_HistoryLogging]    Script Date: 6/8/2020 1:14:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [GUI].[trg_DashboardWidgetsUserSettings_HistoryLogging] ON [GUI].[DashboardWidgetsUserSettings]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'GUI.DashboardWidgetsUserSettings' TabName, DUS_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.DUS_ID, 
					(SELECT CASE WHEN UPDATE(DUS_Name) Or @ChangeType = 'D' THEN
							(SELECT 'DUS_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DUS_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DUS_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DUS_DWT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DUS_DWT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DUS_DWT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DUS_DWT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DUS_DWP_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DUS_DWP_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DUS_DWP_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DUS_DWP_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DUS_USR_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DUS_USR_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DUS_USR_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DUS_USR_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DUS_CSY_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DUS_CSY_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DUS_CSY_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DUS_CSY_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DUS_CounteID) Or @ChangeType = 'D' THEN
							(SELECT 'DUS_CounteID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DUS_CounteID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DUS_CounteID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DUS_IntervalTime) Or @ChangeType = 'D' THEN
							(SELECT 'DUS_IntervalTime' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DUS_IntervalTime as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DUS_IntervalTime as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DUS_IntervalPeriod) Or @ChangeType = 'D' THEN
							(SELECT 'DUS_IntervalPeriod' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DUS_IntervalPeriod as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DUS_IntervalPeriod as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DUS_AddDate) Or @ChangeType = 'D' THEN
							(SELECT 'DUS_AddDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DUS_AddDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DUS_AddDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DUS_DCT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DUS_DCT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DUS_DCT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DUS_DCT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DUS_ThresholdType) Or @ChangeType = 'D' THEN
							(SELECT 'DUS_ThresholdType' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DUS_ThresholdType as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DUS_ThresholdType as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DUS_ThresholdPerc) Or @ChangeType = 'D' THEN
							(SELECT 'DUS_ThresholdPerc' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DUS_ThresholdPerc as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DUS_ThresholdPerc as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DUS_NegativeType) Or @ChangeType = 'D' THEN
							(SELECT 'DUS_NegativeType' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DUS_NegativeType as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DUS_NegativeType as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DUS_NegativeValue) Or @ChangeType = 'D' THEN
							(SELECT 'DUS_NegativeValue' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DUS_NegativeValue as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DUS_NegativeValue as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DUS_NeutralType) Or @ChangeType = 'D' THEN
							(SELECT 'DUS_NeutralType' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DUS_NeutralType as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DUS_NeutralType as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DUS_NeutralValue) Or @ChangeType = 'D' THEN
							(SELECT 'DUS_NeutralValue' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DUS_NeutralValue as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DUS_NeutralValue as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DUS_PositiveType) Or @ChangeType = 'D' THEN
							(SELECT 'DUS_PositiveType' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DUS_PositiveType as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DUS_PositiveType as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DUS_PositiveValue) Or @ChangeType = 'D' THEN
							(SELECT 'DUS_PositiveValue' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DUS_PositiveValue as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DUS_PositiveValue as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.DUS_ID = D.DUS_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'GUI.DashboardWidgetsUserSettings' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [GUI].[DashboardWidgetsUserSettings] DISABLE TRIGGER [trg_DashboardWidgetsUserSettings_HistoryLogging]
GO
