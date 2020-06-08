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
/****** Object:  Table [ResponseProcessing].[EventSubscriptions]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [ResponseProcessing].[EventSubscriptions](
	[ESP_ID] [int] IDENTITY(1,1) NOT NULL,
	[ESP_ClientID] [int] NOT NULL,
	[ESP_MOV_ID] [int] NOT NULL,
	[ESP_RSP_ID] [int] NOT NULL,
	[ESP_Parameters] [xml] NULL,
	[ESP_EST_ID] [tinyint] NOT NULL,
	[ESP_IncludeOpenAndShut] [bit] NOT NULL,
	[ESP_MOB_ID] [int] NULL,
	[ESP_EventInstanceName] [varchar](850) NULL,
	[ESP_ProcessingInterval] [int] NOT NULL,
	[ESP_RGT_ID] [tinyint] NOT NULL,
	[ESP_RespondOnceForMultipleIdenticalEvents] [bit] NOT NULL,
	[ESP_RerunEveryXSeconds] [int] NULL,
	[ESP_RerunMaxNumberOfTimes] [int] NULL,
	[ESP_Priority] [int] NULL,
	[ESP_IsActive] [bit] NULL,
	[ESP_OCF_BinConcat] [tinyint] NULL,
 CONSTRAINT [PK_EventSubscriptions] PRIMARY KEY CLUSTERED 
(
	[ESP_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [ResponseProcessing].[EventSubscriptions]  WITH CHECK ADD  CONSTRAINT [FK_EventSubscriptions_MonitoredEvents] FOREIGN KEY([ESP_MOV_ID])
REFERENCES [EventProcessing].[MonitoredEvents] ([MOV_ID])
GO
ALTER TABLE [ResponseProcessing].[EventSubscriptions] CHECK CONSTRAINT [FK_EventSubscriptions_MonitoredEvents]
GO
ALTER TABLE [ResponseProcessing].[EventSubscriptions]  WITH CHECK ADD  CONSTRAINT [FK_EventSubscriptions_ResponseTypes] FOREIGN KEY([ESP_RSP_ID])
REFERENCES [ResponseProcessing].[ResponseTypes] ([RSP_ID])
GO
ALTER TABLE [ResponseProcessing].[EventSubscriptions] CHECK CONSTRAINT [FK_EventSubscriptions_ResponseTypes]
GO
/****** Object:  Trigger [ResponseProcessing].[trg_EventSubscriptions_HistoryLogging]    Script Date: 6/8/2020 1:15:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [ResponseProcessing].[trg_EventSubscriptions_HistoryLogging] ON [ResponseProcessing].[EventSubscriptions]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'ResponseProcessing.EventSubscriptions' TabName, ESP_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.ESP_ID, 
					(SELECT CASE WHEN UPDATE(ESP_ClientID) Or @ChangeType = 'D' THEN
							(SELECT 'ESP_ClientID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ESP_ClientID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ESP_ClientID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ESP_MOV_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ESP_MOV_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ESP_MOV_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ESP_MOV_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ESP_RSP_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ESP_RSP_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ESP_RSP_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ESP_RSP_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ESP_EST_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ESP_EST_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ESP_EST_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ESP_EST_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ESP_IncludeOpenAndShut) Or @ChangeType = 'D' THEN
							(SELECT 'ESP_IncludeOpenAndShut' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ESP_IncludeOpenAndShut as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ESP_IncludeOpenAndShut as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ESP_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ESP_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ESP_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ESP_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ESP_EventInstanceName) Or @ChangeType = 'D' THEN
							(SELECT 'ESP_EventInstanceName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ESP_EventInstanceName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ESP_EventInstanceName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ESP_ProcessingInterval) Or @ChangeType = 'D' THEN
							(SELECT 'ESP_ProcessingInterval' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ESP_ProcessingInterval as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ESP_ProcessingInterval as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ESP_RGT_ID) Or @ChangeType = 'D' THEN
							(SELECT 'ESP_RGT_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ESP_RGT_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ESP_RGT_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ESP_RespondOnceForMultipleIdenticalEvents) Or @ChangeType = 'D' THEN
							(SELECT 'ESP_RespondOnceForMultipleIdenticalEvents' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ESP_RespondOnceForMultipleIdenticalEvents as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ESP_RespondOnceForMultipleIdenticalEvents as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ESP_RerunEveryXSeconds) Or @ChangeType = 'D' THEN
							(SELECT 'ESP_RerunEveryXSeconds' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ESP_RerunEveryXSeconds as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ESP_RerunEveryXSeconds as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ESP_RerunMaxNumberOfTimes) Or @ChangeType = 'D' THEN
							(SELECT 'ESP_RerunMaxNumberOfTimes' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ESP_RerunMaxNumberOfTimes as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ESP_RerunMaxNumberOfTimes as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ESP_Priority) Or @ChangeType = 'D' THEN
							(SELECT 'ESP_Priority' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ESP_Priority as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ESP_Priority as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(ESP_IsActive) Or @ChangeType = 'D' THEN
							(SELECT 'ESP_IsActive' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.ESP_IsActive as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.ESP_IsActive as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.ESP_ID = D.ESP_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'ResponseProcessing.EventSubscriptions' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [ResponseProcessing].[EventSubscriptions] ENABLE TRIGGER [trg_EventSubscriptions_HistoryLogging]
GO
/****** Object:  Trigger [ResponseProcessing].[trg_EventSubscriptions_Insert_Update]    Script Date: 6/8/2020 1:15:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [ResponseProcessing].[trg_EventSubscriptions_Insert_Update] on [ResponseProcessing].[EventSubscriptions]
	for insert, update
as
set nocount on
declare @MOV_ID int,
		@RSP_ID int,
		@ParamName varchar(100),
		@ParamIsMandatory bit,
		@AllowMultiple bit,
		@ParamOptions nvarchar(max),
		@ParamOptionSourceTable nvarchar(257),
		@ParamOptionSourceColumn nvarchar(128),
		@ParamValue nvarchar(max),
		@ErrorMessage nvarchar(max),
		@SQL nvarchar(max),
		@FailTrigger bit = 0

declare @ProvidedValues table(StringValue nvarchar(max))
declare @PossibleValues table(StringValue nvarchar(max))
		
declare cSubscriptions cursor static forward_only for
	select ESP_MOV_ID, ESP_RSP_ID,
		Possible.value('@Name', 'varchar(100)') ParamName,
		Possible.value('@IsMandatory', 'bit') ParamIsMandatory,
		Possible.value('@AllowMultiple', 'bit') AllowMultiple,
		Possible.value('@Options', 'nvarchar(max)') ParamOptions,
		Possible.value('@OptionSourceTable', 'nvarchar(257)') ParamOptionSourceTable,
		Possible.value('@OptionSourceColumn', 'nvarchar(128)') ParamOptionSourceColumn,
		ParamValue
	from inserted
		inner join ResponseProcessing.ResponseTypes on ESP_RSP_ID = RSP_ID
		cross apply RSP_PossibleParameters.nodes('Parameters/Parameter') x(Possible)
		outer apply (select Provided.value('@Name', 'varchar(100)') ProvidedName,
							Provided.value('@Value', 'nvarchar(max)') ParamValue
						from ESP_Parameters.nodes('Parameters/Parameter') x1(Provided)
						where Possible.value('@Name', 'varchar(100)') = Provided.value('@Name', 'varchar(100)')) Provided
	
open cSubscriptions
fetch next from cSubscriptions into @MOV_ID, @RSP_ID, @ParamName, @ParamIsMandatory, @AllowMultiple, @ParamOptions,
										@ParamOptionSourceTable, @ParamOptionSourceColumn, @ParamValue
while @@fetch_status = 0
begin
	if @ParamIsMandatory = 1 and @ParamValue is null
		set @ErrorMessage = '	Mandatory parameter "' + @ParamName + '" was not defined.' + CHAR(13)+CHAR(10)
	else if @ParamValue is not null
	begin
		if @AllowMultiple = 1
			insert into @ProvidedValues
			select Val
			from Infra.fn_SplitString(@ParamValue, ';')
		else
			insert into @ProvidedValues
			values(@ParamValue)

		if @ParamOptions is not null
		begin
			insert into @PossibleValues
			select Val
			from Infra.fn_SplitString(@ParamOptions, ';')
			
			if exists (select *
						from @ProvidedValues pr
						where not exists (select *
											from @PossibleValues ps
											where pr.StringValue = ps.StringValue
										)
						)
				set @ErrorMessage = '	Wrong value provided for the "' + @ParamName + '" parameter. '
									+ 'Possible values are: ' + @ParamOptions + CHAR(13)+CHAR(10)
		end
		else if @ParamOptionSourceTable is not null
		begin
			set @SQL = 'select ' + @ParamOptionSourceColumn + char(13)+char(10)
						+ 'from ' + @ParamOptionSourceTable + char(13)+char(10)

			insert into @PossibleValues
			exec sp_executesql @SQL

			if exists (select *
						from @ProvidedValues pr
						where not exists (select *
											from @PossibleValues ps
											where pr.StringValue = ps.StringValue
										)
						)
				set @ErrorMessage = '	Wrong value provided for the "' + @ParamName + '" parameter. '
									+ 'Possible values can be retrieved from the following query:'
									+ '"select ' + @ParamOptionSourceColumn + ' from ' + @ParamOptionSourceTable + '"'
									+ CHAR(13)+CHAR(10)
									
		end
	end
	if @ErrorMessage is not null
	begin
		select @ErrorMessage = 'The "' + RSP_Name + '" Subscription definition for the "' + MOV_Description + '"'
								+ ' Event failed for the following reason(s):' + char(13)+char(10)
								+ @ErrorMessage
		from EventProcessing.MonitoredEvents
			cross join ResponseProcessing.ResponseTypes
		where MOV_ID = @MOV_ID
			and RSP_ID = @RSP_ID
		
		set @FailTrigger = 1
		raiserror(@ErrorMessage, 16, 1)
		set @ErrorMessage = null
	end
	delete @ProvidedValues
	delete @PossibleValues

	fetch next from cSubscriptions into @MOV_ID, @RSP_ID, @ParamName, @ParamIsMandatory, @AllowMultiple, @ParamOptions,
											@ParamOptionSourceTable, @ParamOptionSourceColumn, @ParamValue
end
close cSubscriptions
deallocate cSubscriptions 

if @FailTrigger = 1
	rollback
GO
ALTER TABLE [ResponseProcessing].[EventSubscriptions] ENABLE TRIGGER [trg_EventSubscriptions_Insert_Update]
GO
