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
/****** Object:  Table [Inventory].[InstanceCredential]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[InstanceCredential](
	[CRD_ID] [int] IDENTITY(1,1) NOT NULL,
	[CRD_MOB_ID] [int] NOT NULL,
	[CRD_Name] [nvarchar](128) NOT NULL,
	[CRD_CredentialIdentity] [nvarchar](4000) NULL,
	[CRD_CreateDate] [datetime] NOT NULL,
	[CRD_ModifyDate] [datetime] NULL,
	[CRD_TargetType] [nvarchar](100) NULL,
	[CRD_TargetName] [nvarchar](128) NULL,
	[CRD_InsertDate] [datetime2](3) NOT NULL,
	[CRD_LastSeenDate] [datetime2](3) NOT NULL,
	[CRD_Last_TRH_ID] [int] NOT NULL,
	[CRD_ClientID] [int] NOT NULL,
 CONSTRAINT [PK_InstanceCredential] PRIMARY KEY CLUSTERED 
(
	[CRD_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IDX_InstanceCredential]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IDX_InstanceCredential] ON [Inventory].[InstanceCredential]
(
	[CRD_MOB_ID] ASC,
	[CRD_Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_InstanceCredential_HistoryLogging]    Script Date: 6/8/2020 1:15:16 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_InstanceCredential_HistoryLogging] ON [Inventory].[InstanceCredential]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.InstanceCredential' TabName, C_MOB_ID, CRD_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.CRD_MOB_ID C_MOB_ID, D.CRD_ID, 
					(SELECT CASE WHEN UPDATE(CRD_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'CRD_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CRD_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CRD_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CRD_Name) Or @ChangeType = 'D' THEN
							(SELECT 'CRD_Name' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CRD_Name as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CRD_Name as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CRD_CredentialIdentity) Or @ChangeType = 'D' THEN
							(SELECT 'CRD_CredentialIdentity' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CRD_CredentialIdentity as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CRD_CredentialIdentity as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CRD_CreateDate) Or @ChangeType = 'D' THEN
							(SELECT 'CRD_CreateDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CRD_CreateDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CRD_CreateDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CRD_ModifyDate) Or @ChangeType = 'D' THEN
							(SELECT 'CRD_ModifyDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CRD_ModifyDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CRD_ModifyDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CRD_TargetType) Or @ChangeType = 'D' THEN
							(SELECT 'CRD_TargetType' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CRD_TargetType as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CRD_TargetType as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CRD_TargetName) Or @ChangeType = 'D' THEN
							(SELECT 'CRD_TargetName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CRD_TargetName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CRD_TargetName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(CRD_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'CRD_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.CRD_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.CRD_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.CRD_ID = D.CRD_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.InstanceCredential' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[InstanceCredential] DISABLE TRIGGER [trg_InstanceCredential_HistoryLogging]
GO
