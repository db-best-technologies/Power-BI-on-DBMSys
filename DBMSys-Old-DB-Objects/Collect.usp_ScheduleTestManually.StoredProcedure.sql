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
/****** Object:  StoredProcedure [Collect].[usp_ScheduleTestManually]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collect].[usp_ScheduleTestManually]
	@TST_ID int,
	@MOB_ID int,
	@DateToRun datetime2(3) = null,
	@RNR_ID int = 3,
	@SCT_ID int = null output
as
set nocount on
declare @TSV_ID int,
		@ClientID int,
		@TestName varchar(900),
		@ObjectName nvarchar(128)

select @TSV_ID = TSV_ID
from Collect.fn_GetObjectTests(@TST_ID)
where MOB_ID = @MOB_ID

if @TSV_ID is not null
begin
	select @ClientID = cast(SET_Value as int)
	from Management.Settings
	where SET_Module = 'Management'
		and SET_Key = 'Client ID'

	insert into Collect.ScheduledTests(SCT_ClientID, SCT_TST_ID, SCT_TSV_ID, SCT_MOB_ID, SCT_DateToRun, SCT_RNR_ID, SCT_InsertDate)
	values(@ClientID, @TST_ID, @TSV_ID, @MOB_ID, isnull(@DateToRun, GETUTCDATE()), @RNR_ID, GETUTCDATE())

	set @SCT_ID = SCOPE_IDENTITY()
end
else
begin
	select @TestName = TST_Name
	from Collect.Tests
	where TST_ID = @TST_ID

	select	@ObjectName = MOB_Name
	from Inventory.MonitoredObjects
	where MOB_ID = @MOB_ID

	if @TestName is null
		raiserror('Test ID %d is invalid', 16, 1, @TST_ID)
	else if @ObjectName is null
		raiserror('Monitored Object ID %d is invalid', 16, 1, @MOB_ID)
	else
		raiserror('Test %s is invalid for Monitored Object %s', 16, 1, @TestName, @ObjectName)
end
GO
