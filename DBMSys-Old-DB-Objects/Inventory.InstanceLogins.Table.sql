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
/****** Object:  Table [Inventory].[InstanceLogins]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[InstanceLogins](
	[INL_ID] [int] IDENTITY(1,1) NOT NULL,
	[INL_ClientID] [int] NOT NULL,
	[INL_MOB_ID] [int] NOT NULL,
	[INL_Name] [nvarchar](128) NOT NULL,
	[INL_SID] [varbinary](85) NULL,
	[INL_ILT_ID] [tinyint] NULL,
	[INL_IsDisabled] [bit] NULL,
	[INL_CreateDate] [datetime2](3) NULL,
	[INL_ModifyDate] [datetime2](3) NULL,
	[INL_Default_IDB_ID] [int] NULL,
	[INL_Default_LNG_ID] [smallint] NULL,
	[INL_IsSysAdmin] [bit] NULL,
	[INL_IsSecurityAdmin] [bit] NULL,
	[INL_IsServerdmin] [bit] NULL,
	[INL_IsSetupAdmin] [bit] NULL,
	[INL_IsProcessAdmin] [bit] NULL,
	[INL_IsDiskAdmin] [bit] NULL,
	[INL_IsDBCreator] [bit] NULL,
	[INL_IsBulkAdmin] [bit] NULL,
	[INL_InsertDate] [datetime2](3) NOT NULL,
	[INL_LastSeenDate] [datetime2](7) NOT NULL,
	[INL_Last_TRH_ID] [int] NOT NULL,
	[INL_PasswordHash] [varbinary](256) NULL,
	[INL_HasControlServer] [bit] NULL,
	[INL_IsLocked] [bit] NULL,
	[INL_IsPolicyChecked] [bit] NULL,
 CONSTRAINT [PK_InstanceLogins] PRIMARY KEY CLUSTERED 
(
	[INL_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_InstanceLogins_INL_MOB_ID#INL_Name]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_InstanceLogins_INL_MOB_ID#INL_Name] ON [Inventory].[InstanceLogins]
(
	[INL_MOB_ID] ASC,
	[INL_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_InstanceLogins_HistoryLogging]    Script Date: 6/8/2020 1:15:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_InstanceLogins_HistoryLogging] ON [Inventory].[InstanceLogins]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.InstanceLogins' TabName, C_MOB_ID, INL_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.INL_MOB_ID C_MOB_ID, D.INL_ID, 
					(SELECT CASE WHEN UPDATE(INL_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'INL_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.INL_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.INL_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(INL_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'INL_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.INL_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.INL_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(INL_Name) Or @ChangeType = 'D' THEN
							(SELECT 'INL_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.INL_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.INL_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(INL_SID) Or @ChangeType = 'D' THEN
							(SELECT 'INL_SID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(convert(nvarchar(max), D.INL_SID, 1))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(convert(nvarchar(max), I.INL_SID, 1))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(INL_ILT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'INL_ILT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.INL_ILT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.INL_ILT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(INL_IsDisabled) Or @ChangeType = 'D' THEN
							(SELECT 'INL_IsDisabled' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.INL_IsDisabled as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.INL_IsDisabled as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(INL_CreateDate) Or @ChangeType = 'D' THEN
							(SELECT 'INL_CreateDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.INL_CreateDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.INL_CreateDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(INL_ModifyDate) Or @ChangeType = 'D' THEN
							(SELECT 'INL_ModifyDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.INL_ModifyDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.INL_ModifyDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(INL_Default_IDB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'INL_Default_IDB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.INL_Default_IDB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.INL_Default_IDB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(INL_Default_LNG_ID) Or @ChangeType = 'D' THEN
							(SELECT 'INL_Default_LNG_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.INL_Default_LNG_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.INL_Default_LNG_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(INL_IsSysAdmin) Or @ChangeType = 'D' THEN
							(SELECT 'INL_IsSysAdmin' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.INL_IsSysAdmin as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.INL_IsSysAdmin as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(INL_IsSecurityAdmin) Or @ChangeType = 'D' THEN
							(SELECT 'INL_IsSecurityAdmin' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.INL_IsSecurityAdmin as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.INL_IsSecurityAdmin as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(INL_IsServerdmin) Or @ChangeType = 'D' THEN
							(SELECT 'INL_IsServerdmin' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.INL_IsServerdmin as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.INL_IsServerdmin as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(INL_IsSetupAdmin) Or @ChangeType = 'D' THEN
							(SELECT 'INL_IsSetupAdmin' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.INL_IsSetupAdmin as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.INL_IsSetupAdmin as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(INL_IsProcessAdmin) Or @ChangeType = 'D' THEN
							(SELECT 'INL_IsProcessAdmin' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.INL_IsProcessAdmin as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.INL_IsProcessAdmin as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(INL_IsDiskAdmin) Or @ChangeType = 'D' THEN
							(SELECT 'INL_IsDiskAdmin' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.INL_IsDiskAdmin as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.INL_IsDiskAdmin as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(INL_IsDBCreator) Or @ChangeType = 'D' THEN
							(SELECT 'INL_IsDBCreator' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.INL_IsDBCreator as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.INL_IsDBCreator as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(INL_IsBulkAdmin) Or @ChangeType = 'D' THEN
							(SELECT 'INL_IsBulkAdmin' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.INL_IsBulkAdmin as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.INL_IsBulkAdmin as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(INL_PasswordHash) Or @ChangeType = 'D' THEN
							(SELECT 'INL_PasswordHash' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(convert(nvarchar(max), D.INL_PasswordHash, 1))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(convert(nvarchar(max), I.INL_PasswordHash, 1))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(INL_HasControlServer) Or @ChangeType = 'D' THEN
							(SELECT 'INL_HasControlServer' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.INL_HasControlServer as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.INL_HasControlServer as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(INL_IsLocked) Or @ChangeType = 'D' THEN
							(SELECT 'INL_IsLocked' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.INL_IsLocked as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.INL_IsLocked as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(INL_IsPolicyChecked) Or @ChangeType = 'D' THEN
							(SELECT 'INL_IsPolicyChecked' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.INL_IsPolicyChecked as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.INL_IsPolicyChecked as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.INL_ID = D.INL_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.InstanceLogins' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[InstanceLogins] DISABLE TRIGGER [trg_InstanceLogins_HistoryLogging]
GO
