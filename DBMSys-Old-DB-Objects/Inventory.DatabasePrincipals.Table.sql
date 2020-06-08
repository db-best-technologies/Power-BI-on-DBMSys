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
/****** Object:  Table [Inventory].[DatabasePrincipals]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[DatabasePrincipals](
	[DPP_ID] [int] IDENTITY(1,1) NOT NULL,
	[DPP_ClientID] [int] NOT NULL,
	[DPP_MOB_ID] [int] NOT NULL,
	[DPP_IDB_ID] [int] NOT NULL,
	[DPP_PrincipalName] [nvarchar](128) NOT NULL,
	[DPP_DPT_ID] [tinyint] NOT NULL,
	[DPP_Default_DSN_ID] [int] NULL,
	[DPP_INL_ID] [int] NULL,
	[DPP_IsOrphan] [bit] NULL,
	[DPP_HasConnectPermissions] [bit] NULL,
	[DPP_HasPermissions] [bit] NULL,
	[DPP_HasDirectTablePermissions] [bit] NULL,
	[DPP_IsMemberOfUserRoles] [bit] NULL,
	[DPP_IsDBOwner] [bit] NULL,
	[DPP_IsAccessAdmin] [bit] NULL,
	[DPP_IsSecurityAdmin] [bit] NULL,
	[DPP_IsDDLAdmin] [bit] NULL,
	[DPP_IsBackupOperator] [bit] NULL,
	[DPP_IsDataReader] [bit] NULL,
	[DPP_IsDataWriter] [bit] NULL,
	[DPP_IsDenydataReader] [bit] NULL,
	[DPP_IsDenyDataWriter] [bit] NULL,
	[DPP_InsertDate] [datetime2](3) NOT NULL,
	[DPP_LastSeenDate] [datetime2](3) NOT NULL,
	[DPP_Last_TRH_ID] [int] NOT NULL,
	[DPP_HasControlDatabase] [bit] NULL,
 CONSTRAINT [PK_DatabasePrincipals] PRIMARY KEY CLUSTERED 
(
	[DPP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_DatabasePrincipals_DPP_MOB_ID#DPP_IDB_ID#DPP_PrincipalName]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_DatabasePrincipals_DPP_MOB_ID#DPP_IDB_ID#DPP_PrincipalName] ON [Inventory].[DatabasePrincipals]
(
	[DPP_MOB_ID] ASC,
	[DPP_IDB_ID] ASC,
	[DPP_PrincipalName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_DatabasePrincipals_HistoryLogging]    Script Date: 6/8/2020 1:15:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_DatabasePrincipals_HistoryLogging] ON [Inventory].[DatabasePrincipals]
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
	INSERT INTO Inventory.History(HIS_Type, HIS_Datetime, HIS_TableName, HIS_PK_1, 	HIS_Changes, HIS_UserName, HIS_AppName, HIS_HostName)
	SELECT *
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.DatabasePrincipals' TabName, DPP_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.DPP_ID, 
					(SELECT CASE WHEN UPDATE(DPP_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'DPP_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DPP_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DPP_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DPP_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DPP_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DPP_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DPP_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DPP_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DPP_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DPP_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DPP_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DPP_PrincipalName) Or @ChangeType = 'D' THEN
							(SELECT 'DPP_PrincipalName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DPP_PrincipalName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DPP_PrincipalName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DPP_DPT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DPP_DPT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DPP_DPT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DPP_DPT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DPP_Default_DSN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DPP_Default_DSN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DPP_Default_DSN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DPP_Default_DSN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DPP_INL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'DPP_INL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DPP_INL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DPP_INL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DPP_IsOrphan) Or @ChangeType = 'D' THEN
							(SELECT 'DPP_IsOrphan' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DPP_IsOrphan as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DPP_IsOrphan as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DPP_HasConnectPermissions) Or @ChangeType = 'D' THEN
							(SELECT 'DPP_HasConnectPermissions' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DPP_HasConnectPermissions as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DPP_HasConnectPermissions as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DPP_HasPermissions) Or @ChangeType = 'D' THEN
							(SELECT 'DPP_HasPermissions' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DPP_HasPermissions as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DPP_HasPermissions as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DPP_HasDirectTablePermissions) Or @ChangeType = 'D' THEN
							(SELECT 'DPP_HasDirectTablePermissions' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DPP_HasDirectTablePermissions as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DPP_HasDirectTablePermissions as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DPP_IsMemberOfUserRoles) Or @ChangeType = 'D' THEN
							(SELECT 'DPP_IsMemberOfUserRoles' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DPP_IsMemberOfUserRoles as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DPP_IsMemberOfUserRoles as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DPP_IsDBOwner) Or @ChangeType = 'D' THEN
							(SELECT 'DPP_IsDBOwner' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DPP_IsDBOwner as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DPP_IsDBOwner as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DPP_IsAccessAdmin) Or @ChangeType = 'D' THEN
							(SELECT 'DPP_IsAccessAdmin' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DPP_IsAccessAdmin as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DPP_IsAccessAdmin as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DPP_IsSecurityAdmin) Or @ChangeType = 'D' THEN
							(SELECT 'DPP_IsSecurityAdmin' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DPP_IsSecurityAdmin as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DPP_IsSecurityAdmin as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DPP_IsDDLAdmin) Or @ChangeType = 'D' THEN
							(SELECT 'DPP_IsDDLAdmin' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DPP_IsDDLAdmin as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DPP_IsDDLAdmin as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DPP_IsBackupOperator) Or @ChangeType = 'D' THEN
							(SELECT 'DPP_IsBackupOperator' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DPP_IsBackupOperator as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DPP_IsBackupOperator as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DPP_IsDataReader) Or @ChangeType = 'D' THEN
							(SELECT 'DPP_IsDataReader' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DPP_IsDataReader as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DPP_IsDataReader as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DPP_IsDataWriter) Or @ChangeType = 'D' THEN
							(SELECT 'DPP_IsDataWriter' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DPP_IsDataWriter as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DPP_IsDataWriter as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DPP_IsDenydataReader) Or @ChangeType = 'D' THEN
							(SELECT 'DPP_IsDenydataReader' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DPP_IsDenydataReader as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DPP_IsDenydataReader as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DPP_IsDenyDataWriter) Or @ChangeType = 'D' THEN
							(SELECT 'DPP_IsDenyDataWriter' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DPP_IsDenyDataWriter as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DPP_IsDenyDataWriter as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(DPP_HasControlDatabase) Or @ChangeType = 'D' THEN
							(SELECT 'DPP_HasControlDatabase' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.DPP_HasControlDatabase as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.DPP_HasControlDatabase as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.DPP_ID = D.DPP_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.DatabasePrincipals' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[DatabasePrincipals] DISABLE TRIGGER [trg_DatabasePrincipals_HistoryLogging]
GO
