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
/****** Object:  StoredProcedure [EventProcessing].[usp_ProcessAnalyticalEvents]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [EventProcessing].[usp_ProcessAnalyticalEvents]
as
set nocount on
declare @MOV_ID int,
		@EventDescription nvarchar(1000),
		@ClientID int,
		@ProcedureName nvarchar(max),
		@PRC_ID int

update EventProcessing.TrappedEvents
set TRE_IsClosed = 1,
	TRE_CloseDate = sysdatetime(),
	TRE_TEC_ID = 2
from EventProcessing.AnalysisProcedures
where ANP_MOV_ID = TRE_MOV_ID
	and TRE_IsClosed = 0
	and ANP_AutoResolveMinutes is not null
	and TRE_OpenDate < DATEADD(minute, -ANP_AutoResolveMinutes, sysdatetime())

declare cAnalysisProcedures cursor static forward_only for
	select MOV_ID, MOV_Description, MOV_ClientID, ANP_ProcedureName
	from EventProcessing.MonitoredEvents
		inner join EventProcessing.AnalysisProcedures on MOV_ID = ANP_MOV_ID
		outer apply (select top 1 PRC_StartDate LastRunDate
						from EventProcessing.ProcessCycles
						where PRC_MOV_ID = MOV_ID
						order by PRC_StartDate desc) p
		cross apply (select cast(convert(char(11), sysdatetime(), 121) + MOV_FromHour as datetime) FromHour,
						cast(convert(char(11), sysdatetime(), 121) + MOV_ToHour as datetime) ToHourToday,
						cast(convert(char(11), dateadd(day, 1, sysdatetime()), 121) + MOV_ToHour as datetime) ToHourTomorrow
					) h
	where MOV_IsActive = 1
		and (ANP_RunningInterval <= DATEDIFF(minute, LastRunDate, SYSDATETIME())
				or LastRunDate is null)
		and (MOV_Weekdays is null
				or MOV_Weekdays like '%' + cast(datepart(weekday, sysdatetime()) as char(1)) + '%')
		and (MOV_FromHour is null
				or MOV_ToHour is null
				or (FromHour < ToHourToday
						and sysdatetime() between FromHour and ToHourToday)
				or (FromHour > ToHourToday
						and sysdatetime() between FromHour and ToHourTomorrow))

open cAnalysisProcedures
fetch next from cAnalysisProcedures into @MOV_ID, @EventDescription, @ClientID, @ProcedureName
while @@fetch_status = 0
begin
	insert into EventProcessing.ProcessCycles(PRC_ClientID, PRC_MOV_ID)
	values(@ClientID, @MOV_ID)
	set @PRC_ID = SCOPE_IDENTITY()

	exec EventProcessing.usp_RunAnalyticalProcedure @PRC_ID = @PRC_ID,
													@MOV_ID = @MOV_ID,
													@EventDescription = @EventDescription,
													@ClientID = @ClientID,
													@ProcedureName = @ProcedureName

	fetch next from cAnalysisProcedures into @MOV_ID, @EventDescription, @ClientID, @ProcedureName
end
close cAnalysisProcedures
deallocate cAnalysisProcedures
GO
