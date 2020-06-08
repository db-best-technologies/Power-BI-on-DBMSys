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
/****** Object:  Table [SYL].[SecureLogins]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [SYL].[SecureLogins](
	[SLG_ID] [int] IDENTITY(1,1) NOT NULL,
	[SLG_Description] [varchar](1000) NOT NULL,
	[SLG_Login] [nvarchar](255) NOT NULL,
	[SLG_Password] [nvarchar](2000) NOT NULL,
	[SLG_IsDefault] [bit] NOT NULL,
	[SLG_LGY_ID] [tinyint] NOT NULL,
 CONSTRAINT [PK_SecureLogins] PRIMARY KEY CLUSTERED 
(
	[SLG_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Trigger [SYL].[trg_SecureLogins]    Script Date: 6/8/2020 1:15:47 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [SYL].[trg_SecureLogins] on [SYL].[SecureLogins]
	for insert,update
as
set nocount on
if (select count(*) from SYL.SecureLogins where SLG_IsDefault = 1) > 1
begin
	rollback
	raiserror('Default logins are very much Like immortals. There can be only one.', 16, 1)
end
GO
ALTER TABLE [SYL].[SecureLogins] ENABLE TRIGGER [trg_SecureLogins]
GO
/****** Object:  Trigger [SYL].[trg_SecureLogins_HistoryLogging]    Script Date: 6/8/2020 1:15:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [SYL].[trg_SecureLogins_HistoryLogging] ON [SYL].[SecureLogins]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'SYL.SecureLogins' TabName, SLG_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.SLG_ID, 
					(SELECT CASE WHEN UPDATE(SLG_Description) Or @ChangeType = 'D' THEN
							(SELECT 'SLG_Description' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SLG_Description as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SLG_Description as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SLG_Login) Or @ChangeType = 'D' THEN
							(SELECT 'SLG_Login' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SLG_Login as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SLG_Login as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SLG_Password) Or @ChangeType = 'D' THEN
							(SELECT 'SLG_Password' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SLG_Password as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SLG_Password as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SLG_IsDefault) Or @ChangeType = 'D' THEN
							(SELECT 'SLG_IsDefault' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SLG_IsDefault as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SLG_IsDefault as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SLG_LGY_ID) Or @ChangeType = 'D' THEN
							(SELECT 'SLG_LGY_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SLG_LGY_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SLG_LGY_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.SLG_ID = D.SLG_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'SYL.SecureLogins' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [SYL].[SecureLogins] DISABLE TRIGGER [trg_SecureLogins_HistoryLogging]
GO
