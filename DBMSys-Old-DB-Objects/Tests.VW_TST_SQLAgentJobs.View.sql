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
/****** Object:  View [Tests].[VW_TST_SQLAgentJobs]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_SQLAgentJobs]
as
select top 0 CAST(null as nvarchar(128)) JobName,
			CAST(null as nvarchar(128)) Category,
			CAST(null as nvarchar(max)) Schedules,
			CAST(null as int) StepID,
			CAST(null as nvarchar(128)) StepName,
			CAST(null as nvarchar(40)) StepSubSystem,
			CAST(null as nvarchar(128)) StepDatabase,
			CAST(null as int) StartStepID,
			CAST(null as datetime) LastRunDate,
			CAST(null as int) MinRunDuration,
			CAST(null as int) AvgRunDuration,
			CAST(null as int) MaxRunDuration,
			CAST(null as int) MaxInstanceID,
			CAST(null as nvarchar(60)) LastStatus,
			CAST(null as nvarchar(128)) OwnerLogin,
			CAST(null as bit) IsEnabled,
			CAST(null as bit) HasSchedules,
			CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_SQLAgentJobs]    Script Date: 6/8/2020 1:16:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_SQLAgentJobs] on [Tests].[VW_TST_SQLAgentJobs]
	instead of insert
as
set nocount on
declare @MOB_ID int,
		@TST_ID int,
		@TRH_ID int,
		@CounterDate datetime2(3),
		@CollectionDate datetime2(3),
		@LastValue varchar(100)

select top 1 @MOB_ID = l.TRH_MOB_ID,
			@TST_ID = l.TRH_TST_ID,
			@TRH_ID = Metadata_TRH_ID,
			@CounterDate = ISNULL(StartDate, CalculatedDate),
			@CollectionDate = l.TRH_StartDate
from (select top 1 Metadata_TRH_ID
		from inserted) i
	inner join Collect.TestRunHistory l on Metadata_TRH_ID = l.TRH_ID
	outer apply (select top 1 s.TRH_StartDate StartDate
					from Collect.TestRunHistory s
					where l.TRH_MOB_ID = s.TRH_MOB_ID
							and l.TRH_TST_ID = s.TRH_TST_ID
							and s.TRH_ID < l.TRH_ID
					order by TRH_ID desc) s
	inner join Collect.Tests on l.TRH_TST_ID = TST_ID
	cross apply Collect.fn_CalculateDateOffset(TST_IntervalType, -TST_IntervalPeriod, l.TRH_StartDate)

merge Inventory.InstanceJobCategories d
	using (select distinct Metadata_ClientID, Category
			from inserted) s
		on Category = IJC_Name
	when not matched then insert(IJC_ClientID, IJC_Name)
							values(Metadata_ClientID, Category);

merge Inventory.InstanceSubSystems d
	using (select distinct StepSubSystem
			from inserted
			where StepSubSystem is not null) s
		on StepSubSystem = ISS_Name
	when not matched then insert(ISS_Name)
							values(StepSubSystem);

merge Inventory.InstanceLogins d
	using (select distinct OwnerLogin, Metadata_TRH_ID, Metadata_ClientID
			from inserted
			where OwnerLogin is not null) s
		on INL_MOB_ID = @MOB_ID
			and INL_Name = OwnerLogin
	when not matched then insert(INL_ClientID, INL_MOB_ID, INL_Name, INL_InsertDate, INL_LastSeenDate, INL_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, OwnerLogin, @CounterDate, @CounterDate, Metadata_TRH_ID);

merge Inventory.InstanceJobs d
	using (select distinct Metadata_ClientID, JobName, IJC_ID, Schedules, StartStepID, INL_ID, IsEnabled, HasSchedules
			from inserted
				inner join Inventory.InstanceJobCategories on Category = IJC_Name
				inner join Inventory.InstanceLogins on INL_MOB_ID = @MOB_ID
														and INL_Name = OwnerLogin) s
		on IJB_MOB_ID = @MOB_ID
			and IJB_Name = JobName
			and IJB_Owner_INL_ID = INL_ID
	when matched then update set
								IJB_IJC_ID = IJC_ID,
								IJB_Schedules = Schedules,
								IJB_StartStepID = StartStepID,
								IJB_LastSeenDate = @CollectionDate,
								IJB_Last_TRH_ID = @TRH_ID,
								IJB_Owner_INL_ID = INL_ID,
								IJB_IsEnabled = IsEnabled,
								IJB_HasSchedules = HasSchedules
	when not matched then insert(IJB_ClientID, IJB_MOB_ID, IJB_Name, IJB_IJC_ID, IJB_Schedules, IJB_StartStepID, IJB_InsertDate,
									IJB_LastSeenDate, IJB_Last_TRH_ID, IJB_Owner_INL_ID, IJB_IsEnabled, IJB_HasSchedules)
							values(Metadata_ClientID, @MOB_ID, JobName, IJC_ID, Schedules, StartStepID, @CollectionDate, @CollectionDate, @TRH_ID, INL_ID,
									IsEnabled, HasSchedules);

merge Inventory.InstanceJobSteps d
	using (select Metadata_ClientID, IJB_ID, StepID, StepName, ISS_ID, IDB_ID, LastRunDate, IJR_ID
			from inserted
				inner join Inventory.InstanceJobs on IJB_MOB_ID = @MOB_ID
														and IJB_Name = JobName
				inner join Inventory.InstanceSubSystems on StepSubSystem = ISS_Name
				left join Inventory.InstanceJobStepRunStatuses on LastStatus = IJR_Name
				left join Inventory.InstanceDatabases on IDB_MOB_ID = @MOB_ID
														and StepDatabase = IDB_Name
			where StepID is not null
				and StepID > 0) s
		on IJS_MOB_ID = @MOB_ID
			and IJB_ID = IJS_IJB_ID
			and StepID = IJS_StepID
	when matched then update set
						IJS_Name = StepName,
						IJS_ISS_ID = ISS_ID,
						IJS_IDB_ID = IDB_ID,
						IJS_LastRunDate = isnull(LastRunDate, IJS_LastRunDate),
						IJS_Last_IJR_ID = isnull(IJR_ID, IJS_Last_IJR_ID),
						IJS_LastSeenDate = @CollectionDate,
						IJS_Last_TRH_ID = @TRH_ID
	when not matched then insert(IJS_ClientID, IJS_MOB_ID, IJS_IJB_ID, IJS_StepID, IJS_Name, IJS_ISS_ID, IJS_IDB_ID, IJS_LastRunDate,
									IJS_Last_IJR_ID, IJS_InsertDate, IJS_LastSeenDate, IJS_Last_TRH_ID)
							values(Metadata_ClientID, @MOB_ID, IJB_ID, StepID, StepName, ISS_ID, IDB_ID, LastRunDate, IJR_ID, @CollectionDate, @CollectionDate, @TRH_ID);

insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Instance, Value, [Status], Metadata_TRH_ID, Metadata_ClientID)
select 'Job Step Running Time (Seconds)', GNC_CounterName,
		left(JobName + '\' + case when StepID > 0
									then StepName
									else '_Total'
								end, 850) Instance,
		case GNC_CounterName
				when 'Min.' then MinRunDuration
				when 'Avg.' then AvgRunDuration
				when 'Max.' then MaxRunDuration
		end Value, null [Status], Metadata_TRH_ID, Metadata_ClientID
from inserted
	cross join (select GNC_CounterName, GNC_CSY_ID, GNC_ID
				from PerformanceData.GeneralCounters
				where GNC_CategoryName = 'Job Step Running Time (Seconds)') g
where MinRunDuration is not null

select @LastValue = cast(MAX(MaxInstanceID) as varchar(100))
from inserted

exec Collect.usp_UpdateMaxValue @TST_ID, @MOB_ID, @LastValue
GO
