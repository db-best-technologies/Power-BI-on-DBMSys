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
/****** Object:  StoredProcedure [Collect].[usp_RescheduleTest]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collect].[usp_RescheduleTest]
	@SCT_ID int
as
set nocount on
declare
	@RescheduleDelayMin	int,
	@RescheduleDelayMax	int

select @RescheduleDelayMin = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Collect' and SET_Key = 'Reschedule Delay'

select @RescheduleDelayMax = CAST(SET_Value as int)
from Management.Settings
where SET_Module = 'Collect' and SET_Key = 'Reschedule Delay Maximum'

select
	@RescheduleDelayMin = isnull(@RescheduleDelayMin, 30),
	@RescheduleDelayMax = isnull(@RescheduleDelayMax, 60 * 15)

update ScheduledTests
set	SCT_STS_ID = 1 /*Scheduled*/,
	SCT_DateToRun = RescheduleBound.RescheduleDateToRun,
	SCT_RescheduledAtDate = sysdatetime(),
	SCT_RescheduledCount = isnull(SCT_RescheduledCount, 0) + 1,
	SCT_ProcessStartDate = null,
	SCT_ProcessEndDate = null,
	SCT_LaunchDate = null
from Collect.ScheduledTests ScheduledTests with (rowlock)
cross apply (
	select 
		dateadd(second, case
				when isnull(SCT_RescheduledCount, 0) >= 
						log(@RescheduleDelayMax / @RescheduleDelayMin, 2)
					then @RescheduleDelayMax
				else @RescheduleDelayMin * power(2, isnull(SCT_RescheduledCount, 0))
			end,
			SCT_DateToRun) as RescheduleDateToRun,
		dateadd(second, @RescheduleDelayMax, SCT_DateToRun) as RescheduleDateMax
	) as RescheduleRaw
cross apply (
	select
		case 
			when RescheduleDateToRun > RescheduleDateMax then RescheduleDateMax
			else RescheduleDateToRun
		end as RescheduleDateToRun) as RescheduleBound
where SCT_ID = @SCT_ID
GO
