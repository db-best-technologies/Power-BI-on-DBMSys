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
/****** Object:  StoredProcedure [Collect].[usp_StartExternalCollection]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Collect].[usp_StartExternalCollection]
as
set nocount on

declare
	@TST_ID				int,
	@SCT_ID				int,
	@TRH_ID				int,
	@MOB_ID				int,
	@RNR_ID				tinyint,
	@ReSchedule			bit

declare
	@ClientID			int,
	@ServerName			nvarchar(128),
	@ServerAuthType		int,
	@ServerUserName		nvarchar(255),
	@ServerPassword		nvarchar(2000),
	@PlatformType		int,
	@PlatformMetadata	nvarchar(max),
	@ConnectionTimeout	int,
	@Command			nvarchar(max),
	@QueryType			int,
	@QueryFunction		nvarchar(257),
	@OutputTable		nvarchar(257),
	@QueryTimeout		int,
	@OutputMetadata		nvarchar(max)

declare
	@SQL				nvarchar(max),
	@ErrorMessage		nvarchar(max)

declare
	@PerformCollection				bit,
	@UseExternalCollector			bit, 
	@MaxSimTestsPerMonitoredObject	int,
	@DefaultConnectionTimeout		int,
	@DefaultQueryTimeout			int

select @PerformCollection = CAST(SET_Value as bit)
from Management.Settings
where SET_Module = 'Collect' and SET_Key = 'Perform Collection'

if (@PerformCollection = 0) return

select @UseExternalCollector = cast(SET_Value as bit)
from Management.Settings
where SET_Module = 'Collect' and SET_Key = 'Use External Collector'

if (@UseExternalCollector = 0) return

select @MaxSimTestsPerMonitoredObject = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Collect' and SET_Key = 'Max Simultaneous Tests Per Monitored Object'

select @DefaultConnectionTimeout = cast(SET_Value as int)
from Management.Settings
where SET_Module = 'Collect' and SET_Key = 'Default Connection Timeout'

select @DefaultQueryTimeout = cast(SET_Value as int)
from Management.Settings
where SET_Module = 'Collect' and SET_Key = 'Default Query Timeout'

while 1 = 1
begin
	select @SCT_ID = null

	;with ScheduledTests as (
		select top(1) *
		from Collect.ScheduledTests with (rowlock, readpast)
		inner join Collect.Tests
			on SCT_TST_ID = TST_ID
		inner join Collect.TestVersions
			on SCT_TSV_ID = TSV_ID
		inner join Inventory.MonitoredObjects
			on SCT_MOB_ID = MOB_ID and MOB_OOS_ID in (0, 1)
		inner join Management.PlatformTypes
			on MOB_PLT_ID = PLT_ID
		left outer join Management.DefinedObjects
			on MOB_PLT_ID = DFO_PLT_ID and MOB_Entity_ID = DFO_ID
		left outer join SYL.SecureLogins
			on MOB_SLG_ID = SLG_ID
			or MOB_SLG_ID is null
				and isnull(DFO_IsWindowsAuthentication, 1) = 0
				and SLG_IsDefault = 1
		outer apply (
			select top (1) TRH_TRS_ID
			from Collect.TestRunHistory with (forceseek)
			where TRH_TST_ID = TST_DontRunIfErrorIn_TST_ID
				and TRH_MOB_ID = SCT_MOB_ID
				and TRH_TRS_ID in (3 /*Successful*/, 4 /*Error*/ )
			order by TRH_EndDate desc) h
		where SCT_STS_ID = 1 /*Scheduled*/
			and TST_IsActive = 1
			and SCT_DateToRun <= SYSDATETIME()
			and @MaxSimTestsPerMonitoredObject > (
				select count(*)
				from Collect.ScheduledTests b
				where SCT_STS_ID in (2, 3) and ScheduledTests.SCT_MOB_ID = b.SCT_MOB_ID)
		order by SCT_STS_ID, SCT_RNR_ID desc, SCT_DateToRun)
	update ScheduledTests
	set @SCT_ID				= SCT_ID,
		@TST_ID				= SCT_TST_ID,
		@MOB_ID				= SCT_MOB_ID,
		@RNR_ID				= SCT_RNR_ID,
		@ReSchedule			= case 
			when TST_DontRunIfErrorIn_TST_ID is null then 0
			when TRH_TRS_ID is not null and TRH_TRS_ID = 3 /*Success*/ then 0
			else 1
		end,
		@ClientID			= SCT_ClientID,
		@ServerName			= MOB_Name,
		@ServerAuthType		= SLG_LGY_ID,
		@ServerUserName		= SLG_Login,
		@ServerPassword		= SLG_Password,
		@PlatformType		= MOB_PLT_ID,
		@PlatformMetadata	= PLT_MetaData,
		@ConnectionTimeout	= isnull(TST_ConnectionTimeout, @DefaultConnectionTimeout),
		@Command			= TSV_Query,
		@QueryType			= TST_QRT_ID,
		@QueryFunction		= TSV_QueryFunction,
		@QueryTimeout		= isnull(TST_QueryTimeout, @DefaultQueryTimeout),
		@OutputTable		= isnull(TSV_OutputTable, TST_OutputTable),
		SCT_STS_ID			= 2 /*Launched*/,
		SCT_LaunchDate		= sysdatetime()

	if @SCT_ID is null -- no scheduled tests to launch
		return

	if @ReSchedule = 1
	begin
		begin transaction
		begin try
			exec Collect.usp_RescheduleTest @SCT_ID
			commit transaction
		end try
		begin catch
			rollback transaction
			throw
		end catch

		continue
	end
	else
	begin
		begin transaction
		begin try
			insert into Collect.TestRunHistory(
				TRH_ClientID, 
				TRH_TST_ID, TRH_MOB_ID, TRH_RNR_ID, TRH_SCT_ID, TRH_TRS_ID)
			values(
				@ClientID,
				@TST_ID, @MOB_ID, @RNR_ID, @SCT_ID, 1 /*Initializing*/)
		
			set @TRH_ID = scope_identity()

			update Collect.ScheduledTests
			set SCT_STS_ID				= 3 /*Running*/,
				SCT_LaunchDate			= sysdatetime(),
				SCT_ProcessStartDate	= sysdatetime()
			where SCT_ID = @SCT_ID

			commit transaction
		end try
		begin catch
			rollback transaction
			throw
		end catch
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
			begin try
				exec Collect.usp_RescheduleTest @SCT_ID
				
				update Collect.TestRunHistory
				set TRH_TRS_ID = 5
				where TRH_ID = @TRH_ID
				
				commit transaction
			end try
			begin catch
				rollback transaction
				throw
			end catch

			continue
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


	update Collect.TestRunHistory
	set TRH_TRS_ID = 2,
		TRH_StartDate = SYSDATETIME()
	where TRH_ID = @TRH_ID

	select @OutputMetadata =
		(select OutputTableName [Name], (select [Name], [Type], [Length], Value
											from (select cols.name [Name], type_name(cols.user_type_id) [Type], cols.max_length [Length], Value
													from sys.columns cols
														left join (values
															('Metadata_ClientID',	cast(@ClientID as nvarchar(128))),
															('Metadata_Servername', @ServerName),
															('Metadata_TRH_ID',		cast(@TRH_ID as nvarchar(128)))) MetaDataCol(Name, Value) on MetaDataCol.Name = cols.Name
													where object_id = object_id(OutputTableName)
													) [Column]
											for xml auto, type
											)
			from (select Id, Val OutputTableName
					from Infra.fn_SplitString(@OutputTable, ';')) [Table]
			order by Id
			for xml auto, root('Tables')
		)

	select 
		@TRH_ID				as TRH_ID,
		@ClientID			as ClientID,
		@PlatformType		as PlatformType,
		@PlatformMetadata	as PlatformMetadata,
		@ServerName			as ServerName,
		@ServerAuthType		as ServerAuthType,
		@ServerUserName		as ServerUserName,
		@ServerPassword		as ServerPassword,
		@ConnectionTimeout  as ConnectionTimeout,
		@Command			as QueryText,
		@QueryType			as QueryType,
		@QueryTimeout		as QueryTimeout,
		@OutputTable		as OutputTable,
		@OutputMetadata		as OutputMetadata

	return
end
GO
