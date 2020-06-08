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
/****** Object:  Table [Inventory].[InstanceConfigurations]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[InstanceConfigurations](
	[ICF_ID] [int] IDENTITY(1,1) NOT NULL,
	[ICF_ClientID] [int] NOT NULL,
	[ICF_MOB_ID] [int] NOT NULL,
	[ICF_ICT_ID] [smallint] NOT NULL,
	[ICF_Value] [sql_variant] NULL,
	[ICF_ConfiguredValue] [sql_variant] NULL,
 CONSTRAINT [PK_InstanceConfigurations] PRIMARY KEY CLUSTERED 
(
	[ICF_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_InstanceConfigurations_ICF_MOB_ID#ICF_ICT_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_InstanceConfigurations_ICF_MOB_ID#ICF_ICT_ID] ON [Inventory].[InstanceConfigurations]
(
	[ICF_MOB_ID] ASC,
	[ICF_ICT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_InstanceConfigurations_HistoryLogging]    Script Date: 6/8/2020 1:15:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_InstanceConfigurations_HistoryLogging] ON [Inventory].[InstanceConfigurations]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.InstanceConfigurations' TabName, C_MOB_ID, ICF_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.ICF_MOB_ID C_MOB_ID, D.ICF_ID, 
					(SELECT CASE WHEN UPDATE(ICF_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'ICF_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ICF_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ICF_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ICF_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ICF_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ICF_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ICF_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ICF_ICT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ICF_ICT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ICF_ICT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ICF_ICT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ICF_Value) Or @ChangeType = 'D' THEN
							(SELECT 'ICF_Value' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ICF_Value as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ICF_Value as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ICF_ConfiguredValue) Or @ChangeType = 'D' THEN
							(SELECT 'ICF_ConfiguredValue' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ICF_ConfiguredValue as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ICF_ConfiguredValue as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.ICF_ID = D.ICF_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.InstanceConfigurations' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[InstanceConfigurations] DISABLE TRIGGER [trg_InstanceConfigurations_HistoryLogging]
GO
