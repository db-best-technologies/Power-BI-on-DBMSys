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
/****** Object:  View [Tests].[VW_TST_FailedJobs]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_FailedJobs]
as
select top 0 cast(null as nvarchar(128)) JobName,
			cast(null as nvarchar(128)) StepName,
			cast(null as datetime) FirstFailureDate,
			cast(null as datetime) LastFailureDate,
			cast(null as int) FailureCount,
			cast(null as nvarchar(max)) LastErrorMessage,
			cast(null as datetime) FirstSuccessDate,
			cast(null as datetime) LastSuccessDate,
			cast(null as int) SuccessCount,
			cast(null as int) MaxInstanceID,
			cast(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_FailedJobs]    Script Date: 6/8/2020 1:16:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_FailedJobs] on [Tests].[VW_TST_FailedJobs]
	instead of insert
as
set nocount on
declare @MOB_ID int,
		@TST_ID int,
		@StartDate datetime2(3),
		@LastValue varchar(100)

select top 1 @MOB_ID = TRH_MOB_ID,
			@TST_ID = TRH_TST_ID,
			@StartDate = TRH_StartDate
from inserted inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID

merge Activity.FailedJobs d
	using (select Metadata_ClientID, JobName, StepName, FirstFailureDate, LastFailureDate, FailureCount, LastErrorMessage, Metadata_TRH_ID TRH_ID
			from inserted
			where FirstFailureDate is not null
				and JobName is not null) s
		on FLJ_MOB_ID = @MOB_ID
			and JobName = FLJ_JobName
			and StepName = FLJ_StepName
			and FLJ_IsClosed = 0
	when matched then update set
						FLJ_LastFailureDate = LastFailureDate,
						FLJ_FailureCount += FailureCount,
						FLJ_LastErrorMessage = LastErrorMessage,
						FLJ_LastSeenDate = @StartDate,
						FLJ_Last_TRH_ID = TRH_ID
	when not matched then insert(FLJ_ClientID, FLJ_MOB_ID, FLJ_JobName, FLJ_StepName, FLJ_FirstFailureDate, FLJ_LastFailureDate, FLJ_FailureCount,
									FLJ_LastErrorMessage, FLJ_JobDeleted, FLJ_IsClosed, FLJ_InsertDate, FLJ_LastSeenDate,
									FLJ_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, JobName, StepName, FirstFailureDate, LastFailureDate, FailureCount, LastErrorMessage,  
									0, 0, @StartDate, @StartDate, TRH_ID);

;with LastFailedJobs as
		(select FirstSuccessDate, LastSuccessDate, SuccessCount, Metadata_TRH_ID, LastID
			from inserted
				cross apply (select top 1 FLJ_ID LastID
								from Activity.FailedJobs
								where FLJ_MOB_ID = @MOB_ID
									and FLJ_JobName = JobName
									and FLJ_StepName = StepName
								order by FLJ_ID desc) L
			where LastFailureDate is null
				and JobName is not null
		)
update Activity.FailedJobs
set FLJ_FirstSuccessDate = ISNULL(FLJ_FirstSuccessDate, FirstSuccessDate),
	FLJ_LastSuccessDate = ISNULL(LastSuccessDate, FLJ_LastSuccessDate),
	FLJ_SuccessCount = ISNULL(FLJ_SuccessCount, 0) + isnull(SuccessCount, 0),
	FLJ_IsClosed = case when FirstSuccessDate is not null
								and FirstSuccessDate > FLJ_LastFailureDate
							then 1
							else 0
						end,
	FLJ_LastSeenDate = @StartDate,
	FLJ_Last_TRH_ID = Metadata_TRH_ID
from LastFailedJobs
where FLJ_ID = LastID

select @LastValue = cast(MAX(MaxInstanceID) as varchar(100))
from inserted
where JobName is null

if @LastValue is not null
	exec Collect.usp_UpdateMaxValue @TST_ID, @MOB_ID, @LastValue
GO
