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
/****** Object:  Table [Inventory].[IPAddresses]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[IPAddresses](
	[IPA_ID] [int] IDENTITY(1,1) NOT NULL,
	[IPA_ClientID] [int] NOT NULL,
	[IPA_MOB_ID] [int] NOT NULL,
	[IPA_NIN_ID] [int] NULL,
	[IPA_IPT_ID] [tinyint] NOT NULL,
	[IPA_Address] [varchar](50) NOT NULL,
	[IPA_Subnet] [varchar](50) NULL,
	[IPA_DefaultGateway] [varchar](50) NULL,
	[IPA_ALS_ID] [int] NULL,
	[IPA_IPS_ID] [tinyint] NULL,
	[IPA_InsertDate] [datetime2](3) NOT NULL,
	[IPA_LastSeenDate] [datetime2](3) NOT NULL,
	[IPA_Last_TRH_ID] [int] NOT NULL,
 CONSTRAINT [PK_IPAddresses] PRIMARY KEY CLUSTERED 
(
	[IPA_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_IPAddresses_IPA_MOB_ID#IPA_NIN_ID#IPA_ALS_ID#IPA_Address]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_IPAddresses_IPA_MOB_ID#IPA_NIN_ID#IPA_ALS_ID#IPA_Address] ON [Inventory].[IPAddresses]
(
	[IPA_MOB_ID] ASC,
	[IPA_NIN_ID] ASC,
	[IPA_ALS_ID] ASC,
	[IPA_Address] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_IPAddresses_HistoryLogging]    Script Date: 6/8/2020 1:15:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_IPAddresses_HistoryLogging] ON [Inventory].[IPAddresses]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.IPAddresses' TabName, C_MOB_ID, IPA_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.IPA_MOB_ID C_MOB_ID, D.IPA_ID, 
					(SELECT CASE WHEN UPDATE(IPA_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'IPA_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPA_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPA_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IPA_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IPA_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPA_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPA_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IPA_NIN_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IPA_NIN_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPA_NIN_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPA_NIN_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IPA_IPT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IPA_IPT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPA_IPT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPA_IPT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IPA_Address) Or @ChangeType = 'D' THEN
							(SELECT 'IPA_Address' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPA_Address as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPA_Address as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IPA_Subnet) Or @ChangeType = 'D' THEN
							(SELECT 'IPA_Subnet' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPA_Subnet as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPA_Subnet as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IPA_DefaultGateway) Or @ChangeType = 'D' THEN
							(SELECT 'IPA_DefaultGateway' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPA_DefaultGateway as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPA_DefaultGateway as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IPA_ALS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IPA_ALS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPA_ALS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPA_ALS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(IPA_IPS_ID) Or @ChangeType = 'D' THEN
							(SELECT 'IPA_IPS_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.IPA_IPS_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.IPA_IPS_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.IPA_ID = D.IPA_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.IPAddresses' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[IPAddresses] DISABLE TRIGGER [trg_IPAddresses_HistoryLogging]
GO
