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
/****** Object:  Table [EventProcessing].[EventIncludeExclude]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [EventProcessing].[EventIncludeExclude](
	[EIE_ID] [int] IDENTITY(1,1) NOT NULL,
	[EIE_MOV_ID] [int] NOT NULL,
	[EIE_IsInclude] [bit] NOT NULL,
	[EIE_MOB_ID] [int] NULL,
	[EIE_InstanceName] [varchar](850) NULL,
	[EIE_UseLikeForInstanceName] [bit] NULL,
	[EIE_InsertDate] [datetime2](3) NOT NULL,
	[EIE_ValidForMinutes] [int] NULL,
 CONSTRAINT [PK_EventIncludeExclude] PRIMARY KEY NONCLUSTERED 
(
	[EIE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_EventIncludeExclude_EIE_MOV_ID]    Script Date: 6/8/2020 1:14:32 PM ******/
CREATE UNIQUE CLUSTERED INDEX [IX_EventIncludeExclude_EIE_MOV_ID] ON [EventProcessing].[EventIncludeExclude]
(
	[EIE_MOV_ID] ASC,
	[EIE_IsInclude] ASC,
	[EIE_ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [EventProcessing].[EventIncludeExclude] ADD  CONSTRAINT [DF_EIE_InsertDate]  DEFAULT (sysdatetime()) FOR [EIE_InsertDate]
GO
ALTER TABLE [EventProcessing].[EventIncludeExclude]  WITH CHECK ADD  CONSTRAINT [CK_EventIncludeExclude_EIE_MOB_ID#OR#EIE_InstanceName#NOT#NULL] CHECK  (([EIE_MOB_ID] IS NOT NULL OR [EIE_InstanceName] IS NOT NULL))
GO
ALTER TABLE [EventProcessing].[EventIncludeExclude] CHECK CONSTRAINT [CK_EventIncludeExclude_EIE_MOB_ID#OR#EIE_InstanceName#NOT#NULL]
GO
/****** Object:  Trigger [EventProcessing].[trg_EventIncludeExclude_HistoryLogging]    Script Date: 6/8/2020 1:14:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [EventProcessing].[trg_EventIncludeExclude_HistoryLogging] ON [EventProcessing].[EventIncludeExclude]
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
	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], 'EventProcessing.EventIncludeExclude' TabName, EIE_ID, 
				CAST('<Changes>' + CAST(CAST(Changes AS XML).query('for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f') AS NVARCHAR(MAX)) + '</Changes>' AS XML) Changes, suser_sname() LoginName, app_name() AppName, host_name() HostName
			FROM (SELECT D.EIE_ID, 
					(SELECT CASE WHEN UPDATE(EIE_MOV_ID) Or @ChangeType = 'D' THEN
							(SELECT 'EIE_MOV_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EIE_MOV_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EIE_MOV_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EIE_IsInclude) Or @ChangeType = 'D' THEN
							(SELECT 'EIE_IsInclude' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EIE_IsInclude as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EIE_IsInclude as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EIE_MOB_ID) Or @ChangeType = 'D' THEN
							(SELECT 'EIE_MOB_ID' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EIE_MOB_ID as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EIE_MOB_ID as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EIE_InstanceName) Or @ChangeType = 'D' THEN
							(SELECT 'EIE_InstanceName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EIE_InstanceName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EIE_InstanceName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EIE_UseLikeForInstanceName) Or @ChangeType = 'D' THEN
							(SELECT 'EIE_UseLikeForInstanceName' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EIE_UseLikeForInstanceName as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EIE_UseLikeForInstanceName as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EIE_InsertDate) Or @ChangeType = 'D' THEN
							(SELECT 'EIE_InsertDate' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EIE_InsertDate as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EIE_InsertDate as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
						, CASE WHEN UPDATE(EIE_ValidForMinutes) Or @ChangeType = 'D' THEN
							(SELECT 'EIE_ValidForMinutes' [@Name],
								(SELECT Val from Infra.RemoveControlCharacters(cast(D.EIE_ValidForMinutes as nvarchar(max)))) [@OldValue],
								(SELECT Val from Infra.RemoveControlCharacters(cast(I.EIE_ValidForMinutes as nvarchar(max)))) [@NewValue]
							FOR XML PATH('Column'), TYPE) ELSE NULL END
					FOR XML PATH('')) [Changes]
	FROM Deleted D LEFT JOIN Inserted I ON I.EIE_ID = D.EIE_ID) t) t
	WHERE Changes.exist('Changes/Column[1]') = 1
END TRY
BEGIN CATCH
	SET @ErrorMessage = ERROR_MESSAGE()
	SET @Info = (select 'History Logging' [@Process], 'EventProcessing.EventIncludeExclude' [@TableName] for xml path('Info'))
	IF @@TRANCOUNT > 0
		ROLLBACK
	EXEC Internal.usp_LogError @Info, @ErrorMessage
END CATCH
GO
ALTER TABLE [EventProcessing].[EventIncludeExclude] DISABLE TRIGGER [trg_EventIncludeExclude_HistoryLogging]
GO
/****** Object:  Trigger [EventProcessing].[trg_EventIncludeExclude_Insert_Update]    Script Date: 6/8/2020 1:14:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [EventProcessing].[trg_EventIncludeExclude_Insert_Update] on [EventProcessing].[EventIncludeExclude]
	for insert, update
as
set nocount on
declare @ErrorMessage nvarchar(2000)
begin try
	begin transaction
		delete EventProcessing.EventDefinitionStatuses
		from EventProcessing.EventDefinitions
		where EDS_EDF_ID = EDF_ID
			and exists (select *
						from inserted
						where (dateadd(minute, EIE_ValidForMinutes, EIE_InsertDate) > SYSDATETIME()
								or EIE_ValidForMinutes is null)
							and EIE_MOV_ID = EDF_MOV_ID
							and EIE_IsInclude = 0
							and (EIE_MOB_ID = EDS_MOB_ID
									or EIE_MOB_ID is null)
							and (EIE_InstanceName = EDS_EventInstanceName
									or (EIE_UseLikeForInstanceName = 1
											and EDS_EventInstanceName like '%' + EIE_InstanceName + '%')
									or EIE_InstanceName is null
								)
					)

		update EventProcessing.TrappedEvents
		set TRE_IsClosed = 1,
			TRE_CloseDate = sysdatetime(),
			TRE_TEC_ID = 4
		where TRE_IsClosed = 0
			and exists (select *
							from inserted
							where (dateadd(minute, EIE_ValidForMinutes, EIE_InsertDate) > SYSDATETIME()
									or EIE_ValidForMinutes is null)
								and EIE_MOV_ID = TRE_MOV_ID
								and EIE_IsInclude = 0
								and (EIE_MOB_ID = TRE_MOB_ID
										or EIE_MOB_ID is null)
								and (EIE_InstanceName = TRE_EventInstanceName
										or (EIE_UseLikeForInstanceName = 1
												and TRE_EventInstanceName like '%' + EIE_InstanceName + '%')
										or EIE_InstanceName is null
									)
						)

		if exists (select *
					from inserted
					where EIE_IsInclude = 1)
		begin
			delete EventProcessing.EventDefinitionStatuses
			from EventProcessing.EventDefinitions
			where EDS_EDF_ID = EDF_ID
				and exists (select *
							from inserted
							where EIE_MOV_ID = EDF_MOV_ID)
				and not exists (select *
									from inserted
									where (dateadd(minute, EIE_ValidForMinutes, EIE_InsertDate) > SYSDATETIME()
											or EIE_ValidForMinutes is null)
										and EIE_MOV_ID = EDF_MOV_ID
										and EIE_IsInclude = 1
										and (EIE_MOB_ID = EDS_MOB_ID
												or EIE_MOB_ID is null)
										and (EIE_InstanceName = EDS_EventInstanceName
												or (EIE_UseLikeForInstanceName = 1
														and EDS_EventInstanceName like '%' + EIE_InstanceName + '%')
												or EIE_InstanceName is null
											)
								)

			update EventProcessing.TrappedEvents
			set TRE_IsClosed = 1,
				TRE_CloseDate = sysdatetime(),
				TRE_TEC_ID = 4
			where TRE_IsClosed = 0
				and exists (select *
							from inserted
							where EIE_MOV_ID = TRE_MOV_ID)
				and not exists (select *
									from inserted
									where (dateadd(minute, EIE_ValidForMinutes, EIE_InsertDate) > SYSDATETIME()
											or EIE_ValidForMinutes is null)
										and EIE_MOV_ID = TRE_MOV_ID
										and EIE_IsInclude = 1
										and (EIE_MOB_ID = TRE_MOB_ID
												or EIE_MOB_ID is null)
										and (EIE_InstanceName = TRE_EventInstanceName
												or (EIE_UseLikeForInstanceName = 1
														and TRE_EventInstanceName like '%' + EIE_InstanceName + '%')
												or EIE_InstanceName is null
											)
								)
		end
	commit transaction
end try
begin catch
	set @ErrorMessage = ERROR_MESSAGE()
	if @@TRANCOUNT > 0
		rollback
	raiserror(@ErrorMessage, 16, 1)
end catch
GO
ALTER TABLE [EventProcessing].[EventIncludeExclude] ENABLE TRIGGER [trg_EventIncludeExclude_Insert_Update]
GO
