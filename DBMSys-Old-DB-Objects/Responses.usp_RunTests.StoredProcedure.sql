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
/****** Object:  StoredProcedure [Responses].[usp_RunTests]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Responses].[usp_RunTests]
	@SPH_ID int,
	@Parameters xml,
	@Events ResponseProcessing.ttResponseEvents readonly,
	@IsClose bit,
	@IsRerun bit,
	@BlackBoxes xml
as
set nocount on
declare @EventObjectTestList varchar(max),
		@ParentObjectTestList varchar(max),
		@OtherParentObjectsTestList varchar(max),
		@ChildObjectsTestList varchar(max),
		@OtherChildObjectsTestList varchar(max),
		@SiblingObjectsTestList varchar(max),
		@OtherMonitoredObjectNames nvarchar(max),
		@OtherMonitoredObjectPlatformCategory varchar(50),
		@OtherMonitoredObjectsTestList varchar(max),
		@TST_ID int,
		@MOB_ID int

declare @TestsToRun table(TestNames varchar(max),
							MOB_ID int)

select @EventObjectTestList = nullif(max(isnull(p.value('(.[@Name="Event Object Test list"]/@Value)', 'varchar(max)'), '')), ''),
		@ParentObjectTestList = nullif(max(isnull(p.value('(.[@Name="Parent Object Test list"]/@Value)', 'varchar(max)'), '')), ''),
		@OtherParentObjectsTestList = nullif(max(isnull(p.value('(.[@Name="Other parent Objects Test list"]/@Value)', 'varchar(max)'), '')), ''),
		@ChildObjectsTestList = nullif(max(isnull(p.value('(.[@Name="Child Objects Test list"]/@Value)', 'varchar(max)'), '')), ''),
		@OtherChildObjectsTestList = nullif(max(isnull(p.value('(.[@Name="Other child Objects Test list"]/@Value)', 'varchar(max)'), '')), ''),
		@SiblingObjectsTestList = nullif(max(isnull(p.value('(.[@Name="Sibling Objects Test list"]/@Value)', 'varchar(max)'), '')), ''),
		@OtherMonitoredObjectNames = nullif(max(isnull(p.value('(.[@Name="Other Monitored Object names"]/@Value)', 'nvarchar(max)'), '')), ''),
		@OtherMonitoredObjectPlatformCategory = nullif(max(isnull(p.value('(.[@Name="Other Monitored Object Platform Category"]/@Value)', 'varchar(50)'), '')), ''),
		@OtherMonitoredObjectsTestList = nullif(max(isnull(p.value('(.[@Name="Other Monitored Objects Test list"]/@Value)', 'varchar(max)'), '')), '')
from @Parameters.nodes('Parameters/Parameter') t(p)

if @EventObjectTestList is not null
	insert into @TestsToRun
	select distinct @EventObjectTestList, MOB_ID
	from @Events

if @ParentObjectTestList is not null
	insert into @TestsToRun
	select @ParentObjectTestList, PCR_Parent_MOB_ID
	from @Events
		inner join Inventory.ParentChildRelationships on MOB_ID = PCR_Child_MOB_ID
	where PCR_IsCurrentParent = 1

if @OtherParentObjectsTestList is not null
	insert into @TestsToRun
	select @OtherParentObjectsTestList, PCR_Parent_MOB_ID
	from @Events
		inner join Inventory.ParentChildRelationships on MOB_ID = PCR_Child_MOB_ID
	where PCR_IsCurrentParent = 0

if @ChildObjectsTestList is not null
	insert into @TestsToRun
	select @ChildObjectsTestList, PCR_Child_MOB_ID
	from @Events
		inner join Inventory.ParentChildRelationships on MOB_ID = PCR_Parent_MOB_ID
	where PCR_IsCurrentParent = 1

if @OtherChildObjectsTestList is not null
	insert into @TestsToRun
	select @OtherChildObjectsTestList, PCR_Child_MOB_ID
	from @Events
		inner join Inventory.ParentChildRelationships on MOB_ID = PCR_Parent_MOB_ID
	where PCR_IsCurrentParent = 0

if @SiblingObjectsTestList is not null
	insert into @TestsToRun
	select @SiblingObjectsTestList, c.PCR_Child_MOB_ID
	from @Events
		inner join Inventory.ParentChildRelationships p on MOB_ID = PCR_Child_MOB_ID
		inner join Inventory.ParentChildRelationships c on c.PCR_Parent_MOB_ID = p.PCR_Parent_MOB_ID
																and c.PCR_Child_MOB_ID <> MOB_ID

if @OtherMonitoredObjectNames is not null
begin
	if @OtherMonitoredObjectsTestList is null
			or @OtherMonitoredObjectPlatformCategory is null
	begin
		raiserror('"Other Monitored Object names" was defined, but "Other Monitored Objects Test list" or "Other Monitored Object Platform Category" is missing.', 16, 1)
		return
	end
	insert into @TestsToRun
	select @OtherMonitoredObjectsTestList, MOB_ID
	from Infra.fn_SplitString(@OtherMonitoredObjectNames, ';') s
		inner join Inventory.MonitoredObjects on Val = MOB_Name
		inner join Management.PlatformTypes on MOB_PLT_ID = PLT_ID
		inner join Management.PlatformCategories on PLT_PLC_ID = PLC_ID
	where PLC_Name = @OtherMonitoredObjectPlatformCategory
end

declare cTestsToRun cursor static forward_only for
	select distinct TST_ID, MOB_ID
	from @TestsToRun
		cross apply Infra.fn_SplitString(TestNames, ';') t
		inner join Collect.Tests on Val = TST_Name

open cTestsToRun
fetch next from cTestsToRun into @TST_ID, @MOB_ID
while @@fetch_status = 0
begin
	exec Collect.usp_ScheduleTestManually @TST_ID = @TST_ID,
											@MOB_ID = @MOB_ID,
											@RNR_ID = 4
	fetch next from cTestsToRun into @TST_ID, @MOB_ID
end
close cTestsToRun
deallocate cTestsToRun
GO
