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
/****** Object:  StoredProcedure [Collect].[usp_RunSingleTest]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collect].[usp_RunSingleTest]
	@SCT_ID int
as
set nocount on
declare @TST_ID int,
		@MOB_ID int,
		@ReSchedule bit,
		@RNR_ID tinyint,
		@QueryType int,
		@Servername nvarchar(128),
		@PlatformType int,
		@ServerList nvarchar(max),
		@Command nvarchar(max),
		@QueryFunction nvarchar(257),
		@OutputTable nvarchar(257),
		@ClientID int,
		@ConnectionTimeout int,
		@QueryTimeout int,
		@DeleteObsoleteFromTables xml,
		@InsertToOutputTableOnError bit,
		@SQL nvarchar(max),
		@TRH_ID int,
		@RUN_ID int,
		@Info xml,
		@ErrorMessage nvarchar(max),
		@ContextInfo binary(4),
		@MetaDataColumns nvarchar(4000)

set @ContextInfo = cast(@SCT_ID as binary(4))
set context_info @ContextInfo
	
select @TST_ID = TST_ID,
		@MOB_ID = MOB_ID,
		@ReSchedule = case when TST_DontRunIfErrorIn_TST_ID is null
								or (TRH_TRS_ID is not null
										and TRH_TRS_ID = 3)
							then 0
							else 1
						end,		@RNR_ID = SCT_RNR_ID,
		@QueryType = TST_QRT_ID,
		@Servername = MOB_Name,
		@PlatformType = MOB_PLT_ID,
		@Command = TSV_Query,
		@QueryFunction = TSV_QueryFunction,
		@OutputTable = ISNULL(TSV_OutputTable, TST_OutputTable),
		@ConnectionTimeout = TST_ConnectionTimeout,
		@QueryTimeout = TST_QueryTimeout,
		@DeleteObsoleteFromTables = TST_DeleteObsoleteFromTables,
		@InsertToOutputTableOnError = TST_InsertToOutputTableOnError
from Collect.ScheduledTests
	inner join Collect.Tests on SCT_TST_ID = TST_ID
	inner join Collect.TestVersions on SCT_TSV_ID = TSV_ID
	inner join Inventory.MonitoredObjects on SCT_MOB_ID = MOB_ID
	outer apply (select top 1 TRH_TRS_ID
					from Collect.TestRunHistory with (forceseek)
					where TRH_TST_ID = TST_DontRunIfErrorIn_TST_ID
						and TRH_MOB_ID = SCT_MOB_ID
						and TRH_EndDate is not null
							and TRH_TRS_ID > 2
					order by TRH_ID desc) h
where SCT_ID = @SCT_ID
	and SCT_STS_ID = 2

if @TST_ID is null return
begin try

	select @ClientID = cast(SET_Value as int)
	from Management.Settings
	where SET_Module = 'Management'
		and SET_Key = 'Client ID'

	begin transaction
		insert into Collect.TestRunHistory(TRH_ClientID, TRH_TST_ID, TRH_MOB_ID, TRH_RNR_ID, TRH_SCT_ID, TRH_TRS_ID)
		values(@ClientID, @TST_ID, @MOB_ID, @RNR_ID, @SCT_ID, 1)
		
		set @TRH_ID = scope_identity()
	
		update Collect.ScheduledTests
		set SCT_ProcessStartDate = sysdatetime(),
			SCT_STS_ID = 3
		where SCT_ID = @SCT_ID
	commit transaction

	if @ReSchedule = 1
	begin
		begin transaction
			exec Collect.usp_RescheduleTest @SCT_ID
			
			update Collect.TestRunHistory
			set TRH_TRS_ID = 5
			where TRH_ID = @TRH_ID
		commit transaction
		return
	end

	if @QueryFunction is not null
	begin
		set @SQL = 'set @Command = ' + @QueryFunction + '(@TST_ID, @MOB_ID, @Command)'
		exec sp_executesql @SQL,
							N'@TST_ID int,
								@MOB_ID int,
								@Command nvarchar(max) output',
							@TST_ID = @TST_ID,
							@MOB_ID = @MOB_ID,
							@Command = @Command output
		
		if @Command is null
		begin
			begin transaction
				exec Collect.usp_RescheduleTest @SCT_ID
				
				update Collect.TestRunHistory
				set TRH_TRS_ID = 5
				where TRH_ID = @TRH_ID
			commit transaction
			return
		end
	end

	if @Command like '%^~%~^%'
	begin
		declare @Formula nvarchar(max)
		create table #FormulaResult(Result nvarchar(1000))

		begin try
			declare cFormulas cursor static forward_only for
				select distinct Formula
				from (select case when Val like '%~^%'
									then LEFT(Val, charindex('~^', Val, 1) - 1)
									else null
								end Formula
						from Infra.fn_SplitString(@Command, '^~')
						where Id > 1) f
				where Formula is not null

			open cFormulas
			fetch next from cFormulas into @Formula
			while @@fetch_status = 0
			begin
				insert into #FormulaResult
				exec(@Formula)
				
				select top 1 @Command = replace(@Command, '^~' + @Formula + '~^', Result)
				from #FormulaResult

				truncate table #FormulaResult
				fetch next from cFormulas into @Formula
			end
			close cFormulas
			deallocate cFormulas
		end try
		begin catch
			close cFormulas
			deallocate cFormulas
			set @ErrorMessage = 'Error applying formula - ' + ERROR_MESSAGE()
			raiserror(@ErrorMessage, 16, 1)
		end catch
		
		if @Command is null
			raiserror('NULL command after applying formula', 16, 1)
	end

	if @ConnectionTimeout is null
		select @ConnectionTimeout = cast(SET_Value as int)
		from Management.Settings
		where SET_Module = 'Collect'
			and SET_Key = 'Default Connection Timeout'

	if @QueryTimeout is null
		select @QueryTimeout = cast(SET_Value as int)
		from Management.Settings
		where SET_Module = 'Collect'
			and SET_Key = 'Default Query Timeout'

	update Collect.TestRunHistory
	set TRH_TRS_ID = 2,
		TRH_StartDate = SYSDATETIME()
	where TRH_ID = @TRH_ID

	set @MetaDataColumns = (select Name, [Type], [Value]
								from (values('Metadata_ClientID', 'System.Int32', cast(@ClientID as nvarchar(128))),
											('Metadata_Servername', 'System.String', @ServerName),
											('Metadata_TRH_ID', 'System.Int32', cast(@TRH_ID as nvarchar(128)))
									) [Column](Name, [Type], [Value])
								for xml auto, root('Columns'))

	set @RUN_ID = 0
	set @ServerList = @ServerName + '|' + cast(@PlatformType as nvarchar(10))

	exec SYL.usp_RunCommand
		@QueryType = @QueryType,
		@ServerList = @ServerList,
		@Command = @Command,
		@RUN_ID = @RUN_ID output,
		@IsResultExpected = 1,
		@OutputTables = @OutputTable,
		@ConnectionTimeout = @ConnectionTimeout,
		@QueryTimeout = @QueryTimeout,
		@MetaDataColumns = @MetaDataColumns
end try
begin catch
	set @ErrorMessage = ERROR_MESSAGE()
	if @@TRANCOUNT > 0
		rollback
end catch

select @ErrorMessage = coalesce(SRR_ErrorMessage, RUN_ErrorMessage, @ErrorMessage)
from SYL.Runs
	inner join SYL.ServerRunResult on RUN_ID = SRR_RUN_ID
where RUN_ID = @RUN_ID

if exists (select *
			from Collect.IngoreErrorMessages
			where IEM_IsActive = 1
				and @ErrorMessage like IEM_ErrorMessage)
	set @ErrorMessage = null

begin try
	begin transaction
		update Collect.TestRunHistory
		set TRH_TRS_ID = case when @ErrorMessage is null
								then 3
								else 4
							end,
			TRH_EndDate = case when TRH_StartDate is not null
								then sysdatetime()
								else null
							end,
			TRH_RUN_ID = @RUN_ID,
			TRH_ErrorMessage = @ErrorMessage
		where TRH_ID = @TRH_ID

		update Collect.ScheduledTests
		set SCT_ProcessEndDate = sysdatetime(),
			SCT_STS_ID = 4
		where SCT_ID = @SCT_ID
	commit transaction

	if @ErrorMessage is not null and @InsertToOutputTableOnError = 1
	begin
		set @SQL = 'insert into ' + @OutputTable + '(Metadata_TRH_ID, Metadata_ClientID)' + CHAR(13)+CHAR(10)
					+ 'values(@TRH_ID, @ClientID)'
		exec sp_executesql @SQL,
							N'@TRH_ID int,
								@ClientID int',
							@TRH_ID = @TRH_ID,
							@ClientID = @ClientID
	end
	if @ErrorMessage is null
		exec Collect.usp_DeleteObsoleteItems @MOB_ID, @DeleteObsoleteFromTables, @TRH_ID
end try
begin catch
	set @ErrorMessage = ERROR_MESSAGE()
	if @@TRANCOUNT > 0
		rollback
	set @Info = (select 'Test Running' [@Process], @TST_ID [@TestID], @MOB_ID [@MOB_ID]
					for xml path('Info'))
	exec Internal.usp_LogError @Info,
								@ErrorMessage
end catch

set context_info 0x0
GO
