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
/****** Object:  StoredProcedure [Collect].[usp_TestLauncher]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collect].[usp_TestLauncher]
as
set nocount on
declare @UseExternalCollector bit,
		@MaxSimTests int,
		@FirstRun bit = 1,
		@SCT_ID int,
		@handle uniqueidentifier,
		@Message xml,
		@ErrorMessage nvarchar(2000),
		@Info xml

select @UseExternalCollector = cast(SET_Value as bit)
from Management.Settings
where SET_Module = 'Collect'
	and SET_Key = 'Use External Collector'

if @UseExternalCollector = 1
begin
	return
end

if exists (select *
			from Management.Settings
			where SET_Module = 'Collect'
				and SET_Key = 'Perform Collection'
				and CAST(SET_Value as bit) = 0)
	return

select @MaxSimTests = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Collect'
	and SET_Key = 'Max Simultaneous Tests Per Monitored Object'


update Collect.ScheduledTests
set SCT_STS_ID = 6
from Collect.SpecificTestObjects
where STO_TST_ID = SCT_TST_ID
	and STO_MOB_ID = SCT_MOB_ID
	and SCT_STS_ID = 1
	and STO_IsExcluded = 1

begin dialog conversation @handle
	from service srvRunScheduledTestSend
	to service 'srvRunScheduledTestReceive'
	on contract conRunScheduledTest
	with encryption = off,
		lifetime = 3600
	
while @SCT_ID is not null or @FirstRun = 1
begin
	set @SCT_ID = null

	select top 1 @SCT_ID = SCT_ID
		from Collect.ScheduledTests a
			inner join Collect.Tests on SCT_TST_ID = TST_ID
			outer apply (select top 1 TRH_TRS_ID Last_TRS_ID
							from Collect.TestRunHistory
							where TRH_TST_ID = TST_DontRunIfErrorIn_TST_ID
								and TRH_MOB_ID = SCT_MOB_ID
								and TRH_TRS_ID in (3, 4)
							order by TRH_EndDate desc) h
		where SCT_STS_ID = 1
			and TST_IsActive = 1
			and SCT_DateToRun <= SYSDATETIME()
			and (select COUNT(*)
					from Collect.ScheduledTests b
					where SCT_STS_ID in (2, 3)
						and a.SCT_MOB_ID = b.SCT_MOB_ID) < @MaxSimTests
			and exists (select *
						from Inventory.MonitoredObjects with (forcescan)
						where SCT_MOB_ID = MOB_ID
							and MOB_OOS_ID in (0, 1))
			and not exists (select *
							from Collect.TestRunHistory
							where TRH_TST_ID = a.SCT_TST_ID
								and TRH_MOB_ID = a.SCT_MOB_ID
								and TRH_TRS_ID in (1, 2))
			and (Last_TRS_ID = 3
					or TST_DontRunIfErrorIn_TST_ID is null)
	order by SCT_STS_ID, SCT_RNR_ID desc, SCT_DateToRun

	if @SCT_ID is not null
	begin
		select @Message = (select @SCT_ID ScheduleID for xml path(''))
		begin try
			begin transaction
				;send on conversation @handle
					message type msgRunScheduledTest(@Message)
				
				update Collect.ScheduledTests
				set SCT_STS_ID = 2,
					SCT_LaunchDate = SYSDATETIME()
				where SCT_ID = @SCT_ID
			commit transaction
		end try
		begin catch
			set @ErrorMessage = ERROR_MESSAGE()
			if @@TRANCOUNT > 0
				rollback
			set @Info = (select 'Test Launcher' [@Process], 'Launch a Test' [@Task], @SCT_ID [@SCT_ID] for xml path('Info'))
			exec Internal.usp_LogError @Info, @ErrorMessage

			begin try
				select @Message = (select null ScheduleID for xml path(''))
				;send on conversation @handle
					message type msgRunScheduledTest(@Message)
			end try
			begin catch
			end catch
			begin try
				end conversation @handle
			end try
			begin catch
			end catch
			
			return
		end catch
	end
	if @FirstRun = 1
		set @FirstRun = 0
end

select @Message = (select null ScheduleID for xml path(''))
;send on conversation @handle
	message type msgRunScheduledTest(@Message)

end conversation @handle
GO
