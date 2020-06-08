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
/****** Object:  Table [Inventory].[InstanceEndPoints]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[InstanceEndPoints](
	[IEP_ID] [int] IDENTITY(1,1) NOT NULL,
	[IEP_ClientID] [int] NOT NULL,
	[IEP_MOB_ID] [int] NOT NULL,
	[IEP_EPN_ID] [int] NOT NULL,
	[IEP_Owner_INL_ID] [int] NOT NULL,
	[IEP_EPP_ID] [tinyint] NOT NULL,
	[IEP_EPT_ID] [tinyint] NOT NULL,
	[IEP_EPS_ID] [tinyint] NOT NULL,
	[IEP_IsAdminEndPoint] [bit] NOT NULL,
	[IEP_InsertDate] [datetime2](3) NOT NULL,
	[IEP_LastSeenDate] [datetime2](3) NOT NULL,
	[IEP_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_InstanceEndPoints] PRIMARY KEY CLUSTERED 
(
	[IEP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_InstanceEndPoints_IEP_MOB_ID#IEP_EPN_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_InstanceEndPoints_IEP_MOB_ID#IEP_EPN_ID] ON [Inventory].[InstanceEndPoints]
(
	[IEP_MOB_ID] ASC,
	[IEP_EPN_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_InstanceEndPoints_HistoryLogging]    Script Date: 6/8/2020 1:15:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_InstanceEndPoints_HistoryLogging] ON [Inventory].[InstanceEndPoints]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.InstanceEndPoints' TabName, C_MOB_ID, IEP_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.IEP_MOB_ID C_MOB_ID, D.IEP_ID, 
					(SELECT CASE WHEN UPDATE(IEP_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'IEP_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IEP_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IEP_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IEP_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IEP_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IEP_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IEP_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IEP_EPN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IEP_EPN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IEP_EPN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IEP_EPN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IEP_Owner_INL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IEP_Owner_INL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IEP_Owner_INL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IEP_Owner_INL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IEP_EPP_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IEP_EPP_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IEP_EPP_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IEP_EPP_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IEP_EPT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IEP_EPT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IEP_EPT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IEP_EPT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IEP_EPS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IEP_EPS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IEP_EPS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IEP_EPS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IEP_IsAdminEndPoint) Or @ChangeType = 'D' THEN
							(SELECT 'IEP_IsAdminEndPoint' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IEP_IsAdminEndPoint as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IEP_IsAdminEndPoint as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.IEP_ID = D.IEP_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.InstanceEndPoints' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[InstanceEndPoints] DISABLE TRIGGER [trg_InstanceEndPoints_HistoryLogging]
GO
