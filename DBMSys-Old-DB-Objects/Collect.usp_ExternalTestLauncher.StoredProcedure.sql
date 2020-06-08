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
/****** Object:  StoredProcedure [Collect].[usp_ExternalTestLauncher]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Collect].[usp_ExternalTestLauncher]
as
set nocount on
declare @MaxSimTests int,
		@MaxSimTestsPerMonitoredObject int,
		@FirstRun bit = 1,
		@RowCount int

declare @Output table(O_SCT_ID int)

if exists (select *
			from Management.Settings
			where SET_Module = 'Collect'
				and SET_Key = 'Perform Collection'
				and CAST(SET_Value as bit) = 0)
	return

select @MaxSimTests = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Collect'
	and SET_Key = 'Max Simultaneous Tests'

select @MaxSimTestsPerMonitoredObject = CAST(SET_Value as int)
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

while (@RowCount > 0 or @FirstRun = 1)
	and (select [rows]
			from sys.partitions
			where [object_id] = object_id('Collect.RunningQueue')
				and index_id = 1) < @MaxSimTests

begin
	begin tran

	insert into Collect.RunningQueue
	output inserted.RNQ_SCT_ID into @Output
	select top(1) SCT_ID
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
					and a.SCT_MOB_ID = b.SCT_MOB_ID) < @MaxSimTestsPerMonitoredObject
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
	order by case when TST_DontRunIfErrorIn_TST_ID IS null then 0 else 1 end, SCT_RNR_ID desc, SCT_RescheduledCount, SCT_DateToRun, SCT_ID

	set @RowCount = @@rowcount

	update Collect.ScheduledTests
	set SCT_STS_ID = 2,
		SCT_LaunchDate = SYSDATETIME()
	where SCT_ID in (select O_SCT_ID from @Output)

	commit tran

	delete @Output

	if @FirstRun = 1
		set @FirstRun = 0
end
GO
