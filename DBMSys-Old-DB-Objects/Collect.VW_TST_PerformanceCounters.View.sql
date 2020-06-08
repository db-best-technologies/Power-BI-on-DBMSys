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
/****** Object:  View [Collect].[VW_TST_PerformanceCounters]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [Collect].[VW_TST_PerformanceCounters]
as
select CAST(null as nvarchar(128)) Category,
	CAST(null as nvarchar(128)) Counter,
	CAST(null as varchar(900)) Instance,
	CAST(null as nvarchar(128)) DatabaseName,
	CAST(null as decimal(28, 5)) Value,
	CAST(null as varchar(100)) Status,
	CAST(null as int) Metadata_TRH_ID,
	CAST(null as int) Metadata_ClientID,
	CAST(null as bit) IsInternal,
	CAST(null as datetime) DateTime
GO
/****** Object:  Trigger [Collect].[trg_VW_TST_PerformanceCounters]    Script Date: 6/8/2020 1:15:48 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Collect].[trg_VW_TST_PerformanceCounters] on [Collect].[VW_TST_PerformanceCounters]
	instead of insert
as
set nocount on

DECLARE 
		@cnt		SMALLINT
		,@nextval	SMALLINT
SELECT 
		@nextval = IDENT_CURRENT('PerformanceData.CounterResultStatuses')
IF @nextval>=32700
BEGIN
	SELECT 
			@cnt = ISNULL(MAX(CRT_ID),0) + 1 
	FROM	PerformanceData.CounterResultStatuses

	DBCC CHECKIDENT ('PerformanceData.CounterResultStatuses', reseed, @cnt)
END


SELECT 
		*
INTO	#PerfCount
FROM	inserted

create index #IDX_#PerfCount###Category#Counter#Instance#DatabaseName ON #PerfCount(Category,Counter,Instance,DatabaseName)


merge PerformanceData.CounterInstances d
	using (select distinct Metadata_ClientID, Instance
			from #PerfCount
			where Instance is not null and Instance <> '') s
		on Instance = CIN_Name
	when not matched then insert (CIN_ClientID, CIN_Name)
						values(Metadata_ClientID, Instance);

merge Inventory.InstanceDatabases d
	using (select distinct Metadata_ClientID, TRH_MOB_ID MOB_ID, DatabaseName, Metadata_TRH_ID
			from #PerfCount
				inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID
			where DatabaseName is not null) s
		on IDB_MOB_ID = MOB_ID
		and DatabaseName = IDB_Name
	when not matched then insert(IDB_ClientID, IDB_MOB_ID, IDB_Name, IDB_InsertDate, IDB_LastSeenDate, IDB_Last_TRH_ID)
							values(Metadata_ClientID, MOB_ID, DatabaseName, sysdatetime(), sysdatetime(), Metadata_TRH_ID);

merge PerformanceData.CounterResultStatuses d
	using (select distinct [Status]
			from #PerfCount
			where [Status] is not null and [Status] <> '') s
		on [Status] = CRT_Name
	when not matched then insert (CRT_Name)
						values([Status]);

insert into PerformanceData.CounterResults(CRS_MOB_ID, CRS_ClientID, CRS_TRH_ID, CRS_SystemID, CRS_CounterID, CRS_InstanceID,
											CRS_DateTime, CRS_Value, CRS_CRT_ID, CRS_IDB_ID)
select isnull(TRH_MOB_ID, 0), Metadata_ClientID, Metadata_TRH_ID,
		case when IsInternal = 1 then 2 else TST_CSY_ID end SystemID, CounterID, CIN_ID, coalesce([DateTime], TRH_StartDate, sysdatetime()),
		Value, CRT_ID, IDB_ID
from #PerfCount
	left join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID
	left join Collect.Tests on TRH_TST_ID = TST_ID
	left join PerformanceData.VW_Counters on ((isnull(IsInternal, 0) = 0 and SystemID = TST_CSY_ID)
												or (IsInternal = 1 and SystemID = 2))
												and Category = CategoryName
												and [Counter] = CounterName
	left join PerformanceData.CounterInstances on Instance = CIN_Name
	left join PerformanceData.CounterResultStatuses on [Status] = CRT_Name
	left join Inventory.InstanceDatabases on TRH_MOB_ID = IDB_MOB_ID
												and IDB_Name = DatabaseName
where (IgnoreIfValueIsOrUnder is null or Value > IgnoreIfValueIsOrUnder)
	and (IgnoreIfValueIsOrAbove IS NULL OR VALUE < IgnoreIfValueIsOrAbove)
GO
