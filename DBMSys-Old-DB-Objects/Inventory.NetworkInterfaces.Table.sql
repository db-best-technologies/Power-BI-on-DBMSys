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
/****** Object:  Table [Inventory].[NetworkInterfaces]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Inventory].[NetworkInterfaces](
	[NIN_ID] [int] IDENTITY(1,1) NOT NULL,
	[NIN_ClientID] [int] NOT NULL,
	[NIN_MOB_ID] [int] NOT NULL,
	[NIN_Index] [int] NOT NULL,
	[NIN_NIT_ID] [int] NOT NULL,
	[NIN_IsDHCPEnabled] [bit] NULL,
	[NIN_DHCPServer] [varchar](128) NULL,
	[NIN_DNSDomain] [varchar](128) NULL,
	[NIN_DNSDomainSuffixSearchOrder] [varchar](1000) NULL,
	[NIN_DNSServerSearchOrder] [varchar](1000) NULL,
	[NIN_MACAddress] [varchar](20) NULL,
	[NIN_TNB_ID] [tinyint] NULL,
	[NIN_TCPWindowSize] [int] NULL,
	[NIN_WINSEnableLMHostsLookup] [bit] NULL,
	[NIN_InsertDate] [datetime2](3) NOT NULL,
	[NIN_LastSeenDate] [datetime2](3) NOT NULL,
	[NIN_Last_TRH_ID] [int] NOT NULL,
	[NIN_IsActive] [bit] NULL,
	[NIN_LinkSpeed] [bigint] NULL,
 CONSTRAINT [PK_NetworkInterfaces] PRIMARY KEY CLUSTERED 
(
	[NIN_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_NetworkInterfaces_NIN_MOB_ID#NIN_Index]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_NetworkInterfaces_NIN_MOB_ID#NIN_Index] ON [Inventory].[NetworkInterfaces]
(
	[NIN_MOB_ID] ASC,
	[NIN_Index] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_NetworkInterfaces_NIN_MOB_ID#NIN_NIT_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE NONCLUSTERED INDEX [IX_NetworkInterfaces_NIN_MOB_ID#NIN_NIT_ID] ON [Inventory].[NetworkInterfaces]
(
	[NIN_MOB_ID] ASC,
	[NIN_NIT_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [Inventory].[trg_NetworkInterfaces_HistoryLogging]    Script Date: 6/8/2020 1:15:25 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Inventory].[trg_NetworkInterfaces_HistoryLogging] ON [Inventory].[NetworkInterfaces]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Inventory.NetworkInterfaces' TabName, C_MOB_ID, NIN_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.NIN_MOB_ID C_MOB_ID, D.NIN_ID, 
					(SELECT CASE WHEN UPDATE(NIN_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'NIN_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.NIN_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.NIN_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(NIN_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'NIN_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.NIN_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.NIN_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(NIN_Index) Or @ChangeType = 'D' THEN
							(SELECT 'NIN_Index' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.NIN_Index as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.NIN_Index as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(NIN_NIT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'NIN_NIT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.NIN_NIT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.NIN_NIT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(NIN_IsDHCPEnabled) Or @ChangeType = 'D' THEN
							(SELECT 'NIN_IsDHCPEnabled' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.NIN_IsDHCPEnabled as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.NIN_IsDHCPEnabled as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(NIN_DHCPServer) Or @ChangeType = 'D' THEN
							(SELECT 'NIN_DHCPServer' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.NIN_DHCPServer as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.NIN_DHCPServer as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(NIN_DNSDomain) Or @ChangeType = 'D' THEN
							(SELECT 'NIN_DNSDomain' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.NIN_DNSDomain as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.NIN_DNSDomain as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(NIN_DNSDomainSuffixSearchOrder) Or @ChangeType = 'D' THEN
							(SELECT 'NIN_DNSDomainSuffixSearchOrder' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.NIN_DNSDomainSuffixSearchOrder as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.NIN_DNSDomainSuffixSearchOrder as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(NIN_DNSServerSearchOrder) Or @ChangeType = 'D' THEN
							(SELECT 'NIN_DNSServerSearchOrder' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.NIN_DNSServerSearchOrder as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.NIN_DNSServerSearchOrder as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(NIN_MACAddress) Or @ChangeType = 'D' THEN
							(SELECT 'NIN_MACAddress' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.NIN_MACAddress as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.NIN_MACAddress as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(NIN_TNB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'NIN_TNB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.NIN_TNB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.NIN_TNB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(NIN_TCPWindowSize) Or @ChangeType = 'D' THEN
							(SELECT 'NIN_TCPWindowSize' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.NIN_TCPWindowSize as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.NIN_TCPWindowSize as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(NIN_WINSEnableLMHostsLookup) Or @ChangeType = 'D' THEN
							(SELECT 'NIN_WINSEnableLMHostsLookup' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.NIN_WINSEnableLMHostsLookup as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.NIN_WINSEnableLMHostsLookup as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(NIN_IsActive) Or @ChangeType = 'D' THEN
							(SELECT 'NIN_IsActive' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.NIN_IsActive as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.NIN_IsActive as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(NIN_LinkSpeed) Or @ChangeType = 'D' THEN
							(SELECT 'NIN_LinkSpeed' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.NIN_LinkSpeed as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.NIN_LinkSpeed as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.NIN_ID = D.NIN_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Inventory.NetworkInterfaces' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Inventory].[NetworkInterfaces] DISABLE TRIGGER [trg_NetworkInterfaces_HistoryLogging]
GO
