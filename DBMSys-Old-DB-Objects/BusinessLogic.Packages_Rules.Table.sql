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
/****** Object:  Table [BusinessLogic].[Packages_Rules]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [BusinessLogic].[Packages_Rules](
	[PKR_ID] [int] IDENTITY(1,1) NOT NULL,
	[PKR_PKG_ID] [int] NOT NULL,
	[PKR_RUL_ID] [int] NOT NULL,
	[PKR_Weight] [decimal](10, 2) NULL,
	[PKR_IsPresented] [bit] NOT NULL,
 CONSTRAINT [PK_Packages_Rules] PRIMARY KEY CLUSTERED 
(
	[PKR_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_Packages_Rules_PKR_PKG_ID#PKR_RUL_ID#PKR_Weight]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Packages_Rules_PKR_PKG_ID#PKR_RUL_ID#PKR_Weight] ON [BusinessLogic].[Packages_Rules]
(
	[PKR_PKG_ID] ASC,
	[PKR_RUL_ID] ASC,
	[PKR_Weight] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Trigger [BusinessLogic].[trg_Packages_Rules_HistoryLogging]    Script Date: 6/8/2020 1:14:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [BusinessLogic].[trg_Packages_Rules_HistoryLogging] ON [BusinessLogic].[Packages_Rules]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'BusinessLogic.Packages_Rules' TabName, PKR_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.PKR_ID, 
					(SELECT CASE WHEN UPDATE(PKR_PKG_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PKR_PKG_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PKR_PKG_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PKR_PKG_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PKR_RUL_ID) Or @ChangeType = 'D' THEN
							(SELECT 'PKR_RUL_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PKR_RUL_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PKR_RUL_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PKR_Weight) Or @ChangeType = 'D' THEN
							(SELECT 'PKR_Weight' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PKR_Weight as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PKR_Weight as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(PKR_IsPresented) Or @ChangeType = 'D' THEN
							(SELECT 'PKR_IsPresented' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.PKR_IsPresented as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.PKR_IsPresented as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.PKR_ID = D.PKR_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'BusinessLogic.Packages_Rules' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [BusinessLogic].[Packages_Rules] DISABLE TRIGGER [trg_Packages_Rules_HistoryLogging]
GO
