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
/****** Object:  StoredProcedure [RuleChecks].[usp_EventLogError]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_EventLogError]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted
declare @Status varchar(900),
		@IsDifferentThanStatus bit 

select @Status = RTH_Status,
	@IsDifferentThanStatus = RTH_IsDifferentThanStatus
from BusinessLogic.RuleThresholds
where RTH_ID = @RTH_ID

select @ClientID, @PRR_ID, EVL_MOB_ID, ELF_Name FileType, EET_Name EventType, ELC_Name Category, ESN_Name SourceName, EUN_Name UserName, EVL_EventCode,
		cast(EVL_Message as varchar(8000)) EventMessage, count(*) EventCount, min(EVL_TimeGenerated) FromDate, MAX(EVL_TimeGenerated) ToDate
from Activity.OperatingSystemEventLogEvents
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = EVL_MOB_ID
	inner join Activity.EventLogLogFileTypes on ELF_ID = EVL_ELF_ID
	inner join Activity.EventLogCategories on ELC_ID = EVL_ELC_ID
	inner join Activity.EventLogEventTypes on EET_ID = EVL_EET_ID
	inner join Activity.EventLogSourceNames on ESN_ID = EVL_ESN_ID
	inner join Activity.EventLogUserNames on EUN_ID = EVL_EUN_ID
where EVL_TimeWritten between @FromDate and @ToDate
	and ((@IsDifferentThanStatus = 0
			and EET_Name = @Status)
		or (@IsDifferentThanStatus = 1
					and EET_Name <> @Status)
		)
group by EVL_MOB_ID, ELF_Name, ELC_Name, EET_Name, ESN_Name, EUN_Name, EVL_EventCode, EVL_EventCode, cast(EVL_Message as varchar(8000))
GO
