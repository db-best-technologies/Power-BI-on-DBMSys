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
/****** Object:  Table [Management].[Settings]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Management].[Settings](
	[SET_Module] [varchar](100) NOT NULL,
	[SET_Key] [varchar](100) NOT NULL,
	[SET_Description] [varchar](1000) NOT NULL,
	[SET_Value] [sql_variant] NULL,
	[SET_Category] [varchar](100) NULL,
 CONSTRAINT [PK_Settings] PRIMARY KEY CLUSTERED 
(
	[SET_Module] ASC,
	[SET_Key] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Trigger [Management].[trg_Settings_HandleSpecificChanges]    Script Date: 6/8/2020 1:15:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create trigger [Management].[trg_Settings_HandleSpecificChanges] on [Management].[Settings]
	for insert, update
as
if @@ROWCOUNT > 1 and exists (select * from deleted)
begin
	raiserror('Can''t update more than one value at a time in the Management.Settings table', 16, 1)
	rollback
	return
end
declare @Value int,
		@SQL nvarchar(max),
		@Identity int

set nocount on

select @Value = cast(SET_Value as int)
from inserted
where SET_Module = 'Collect'
	and SET_Key = 'Max Simultaneous Tests'

if @@ROWCOUNT > 0
begin
	if exists (select * from sys.service_queues where name = 'qRunScheduledTestReceive')
	begin
		set @SQL = 'ALTER QUEUE qRunScheduledTestReceive' + CHAR(13)+CHAR(10)
					+ 'WITH ACTIVATION (MAX_QUEUE_READERS = ' + CAST(CAST(@Value as int) as nvarchar(10)) + ')'
		exec(@SQL)
	end
	else
	begin
		raiserror('The Test Running Service Broker Queue hasn''t been created yet', 16, 1)
		rollback
		return
	end
end

select @Value = cast(SET_Value as int)
from inserted
where SET_Module = 'Response Processing'
	and SET_Key = 'Max Simultaneous Subscription Processes'

if @@ROWCOUNT > 0
begin
	if exists (select * from sys.service_queues where name = 'qRunResponseReceive')
	begin
		set @SQL = 'ALTER QUEUE qRunResponseReceive' + CHAR(13)+CHAR(10)
					+ 'WITH ACTIVATION (MAX_QUEUE_READERS = ' + CAST(CAST(@Value as int) as nvarchar(10)) + ')'
		exec(@SQL)
	end
	else
	begin
		raiserror('The Subscription Processesing Service Broker Queue hasn''t been created yet', 16, 1)
		rollback
		return
	end
end

select @Value = cast(SET_Value as int)
from inserted
where SET_Module = 'Management'
	and SET_Key = 'Database ID'

if @@ROWCOUNT > 0
begin
	if @Value < 1
		or @Value > 1000
	begin
		raiserror('Value must be between 1 and 1000)', 16, 1)
		rollback
		return
	end
	set @Identity = 1000000*(@Value - 1)

	select @Identity = iif(max(MOB_ID) < @Identity or max(MOB_ID) is null, @Identity, max(MOB_ID))
	from Inventory.MonitoredObjects with (nolock)

	set @SQL = concat('DBCC CHECKIDENT(''Inventory.MonitoredObjects'', ''RESEED'', ', @Identity, ')')
	exec(@SQL)
end
GO
ALTER TABLE [Management].[Settings] ENABLE TRIGGER [trg_Settings_HandleSpecificChanges]
GO
/****** Object:  Trigger [Management].[trg_Settings_HistoryLog_Enable]    Script Date: 6/8/2020 1:15:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Management].[trg_Settings_HistoryLog_Enable] ON [Management].[Settings]
AFTER UPDATE
AS
BEGIN

	DECLARE 
		@SQL		nvarchar(max),
		@IsEnabled	nvarchar(7)

	SELECT @IsEnabled = CAST(SET_Value AS nvarchar(7))
	FROM inserted
	WHERE 
		SET_Module = 'History Logging'
		AND SET_Key = 'Is Enabled'
	
	IF @IsEnabled = N'0'
	BEGIN
		SET @SQL = 	
			 (
				SELECT 'exec(''disable trigger ' + t.name + ' on ' + schema_name(b.schema_id) + '.' + b.name + ''');'
				FROM 
					sys.triggers AS t
					INNER JOIN sys.tables AS b 
					ON b.object_id = t.parent_id
				WHERE 
					t.name like '%HistoryLogging'
					AND t.is_disabled = 0
				FOR XML PATH(''))

		EXEC(@SQL)
	END

	IF @IsEnabled = N'1'
	BEGIN
		SET @SQL = 	
			 (
				SELECT 'exec(''enable trigger ' + t.name + ' on ' + schema_name(b.schema_id) + '.' + b.name + ''');'
				FROM 
					sys.triggers AS t
					INNER JOIN sys.tables AS b 
					ON b.object_id = t.parent_id
				WHERE 
					t.name like '%HistoryLogging'
					AND t.is_disabled = 1
				FOR XML PATH(''))

		EXEC(@SQL)
	END

END
GO
ALTER TABLE [Management].[Settings] ENABLE TRIGGER [trg_Settings_HistoryLog_Enable]
GO
/****** Object:  Trigger [Management].[trg_Settings_HistoryLogging]    Script Date: 6/8/2020 1:15:40 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [Management].[trg_Settings_HistoryLogging] ON [Management].[Settings]
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
	INSERT INTO Management.History(HIS_Type, HIS_Datetime, HIS_TableName, HIS_PK_1, HIS_PK_2, 	HIS_Changes, HIS_UserName, HIS_AppName, HIS_HostName)
	SELECT *
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'Management.Settings' TabName, SET_Module, SET_Key, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.SET_Module, D.SET_Key, 
					(SELECT CASE WHEN UPDATE(SET_Description) Or @ChangeType = 'D' THEN
							(SELECT 'SET_Description' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SET_Description as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SET_Description as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(SET_Value) Or @ChangeType = 'D' THEN
							(SELECT 'SET_Value' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.SET_Value as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.SET_Value as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.SET_Module = D.SET_Module AND I.SET_Key = D.SET_Key) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'Management.Settings' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [Management].[Settings] DISABLE TRIGGER [trg_Settings_HistoryLogging]
GO
