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
/****** Object:  StoredProcedure [Responses].[usp_RunSQLCommand]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Responses].[usp_RunSQLCommand]
	@SPH_ID int,
	@Parameters xml,
	@Events ResponseProcessing.ttResponseEvents readonly,
	@IsClose bit,
	@IsRerun bit,
	@BlackBoxes xml
as
set nocount on
declare @EventInstanceCommand nvarchar(max),
		@SiblingObjectsCommand nvarchar(max),
		@OtherMonitoredObjectNames nvarchar(max),
		@OtherMonitoredObjectPlatformCategory varchar(50),
		@OtherMonitoredObjectsCommand nvarchar(max),
		@CommandTimeout int,
		@Command nvarchar(max),
		@InstanceName nvarchar(128),
		@RUN_ID int,
		@ErrorMessage nvarchar(max)

declare @CommandsToRun table(Command nvarchar(max),
								MOB_ID int,
								AllEventData nvarchar(max))

select @EventInstanceCommand = nullif(max(isnull(p.value('(.[@Name="Event Instance Command"]/@Value)', 'nvarchar(max)'), '')), ''),
		@SiblingObjectsCommand = nullif(max(isnull(p.value('(.[@Name="Sibling Objects Command"]/@Value)', 'nvarchar(max)'), '')), ''),
		@OtherMonitoredObjectNames = nullif(max(isnull(p.value('(.[@Name="Other Monitored Object names"]/@Value)', 'nvarchar(max)'), '')), ''),
		@OtherMonitoredObjectPlatformCategory = nullif(max(isnull(p.value('(.[@Name="Other Monitored Object Platform Category"]/@Value)', 'varchar(50)'), '')), ''),
		@OtherMonitoredObjectsCommand = nullif(max(isnull(p.value('(.[@Name="Other Monitored Objects Command"]/@Value)', 'nvarchar(max)'), '')), ''),
		@CommandTimeout = nullif(max(isnull(p.value('(.[@Name="Command timeout"]/@Value)', 'int'), -55)), '')
from @Parameters.nodes('Parameters/Parameter') t(p)

if @EventInstanceCommand is not null
	insert into @CommandsToRun
	select distinct @EventInstanceCommand, MOB_ID, cast(AllEventData as nvarchar(max))
	from @Events

if @SiblingObjectsCommand is not null
	insert into @CommandsToRun
	select @SiblingObjectsCommand, c.PCR_Child_MOB_ID, cast(AllEventData as nvarchar(max))
	from @Events
		inner join Inventory.ParentChildRelationships p on MOB_ID = PCR_Child_MOB_ID
		inner join Inventory.ParentChildRelationships c on c.PCR_Parent_MOB_ID = p.PCR_Parent_MOB_ID
																and c.PCR_Child_MOB_ID <> MOB_ID

if @OtherMonitoredObjectNames is not null
begin
	if @OtherMonitoredObjectsCommand is null
	begin
		raiserror('"Other Monitored Object names" was defined, but "Other Monitored Objects Command" is missing.', 16, 1)
		return
	end
	insert into @CommandsToRun
	select @OtherMonitoredObjectsCommand, m.MOB_ID, cast(AllEventData as nvarchar(max))
	from Infra.fn_SplitString(@OtherMonitoredObjectNames, ';') s
		inner join Inventory.MonitoredObjects m on Val = MOB_Name
		inner join Management.PlatformTypes on m.MOB_PLT_ID = PLT_ID
		cross join @Events
	where PLT_PLC_ID = 1
end

if @CommandTimeout is null or @CommandTimeout = -55
	select @CommandTimeout = CAST(SET_Value as int)
	from Management.Settings
	where SET_Key = 'Default Query Timeout'

declare cCommandsToRun cursor static forward_only for
	select distinct replace(Command, '%EVENTDATA%', isnull(replace(AllEventData, '''', ''''''), '')), MOB_Name
	from @CommandsToRun c
		inner join Inventory.MonitoredObjects m on c.MOB_ID = m.MOB_ID
		
open cCommandsToRun
fetch next from cCommandsToRun into @Command, @InstanceName
while @@fetch_status = 0
begin
	begin try
		set @RUN_ID = 0
		exec SYL.usp_RunCommand
			@QueryType = 1,
			@ServerList = @InstanceName,
			@Command = @Command,
			@RUN_ID = @RUN_ID output,
			@IsResultExpected = 0,
			@QueryTimeout = @CommandTimeout
	end try
	begin catch
		set @ErrorMessage = ERROR_MESSAGE()
	end catch

	select @ErrorMessage = coalesce(SRR_ErrorMessage, RUN_ErrorMessage, @ErrorMessage)
	from SYL.Runs
		inner join SYL.ServerRunResult on RUN_ID = SRR_RUN_ID
	where RUN_ID = @RUN_ID
	fetch next from cCommandsToRun into @Command, @InstanceName
	
	if @ErrorMessage is not null
	begin
		raiserror('Error running command "%s" on "%s". Error Message: %s', 16, 1, @Command, @InstanceName, @ErrorMessage)
		close cCommandsToRun
		deallocate cCommandsToRun
		return
	end
end
close cCommandsToRun
deallocate cCommandsToRun
GO
