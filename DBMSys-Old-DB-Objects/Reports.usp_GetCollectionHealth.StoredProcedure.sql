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
/****** Object:  StoredProcedure [Reports].[usp_GetCollectionHealth]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Reports].[usp_GetCollectionHealth]
--declare
	@IsDebug	bit = 0
AS
BEGIN
	set nocount on
	if object_id('tempdb..#ByQueryType') is not null
		drop table #ByQueryType
	if object_id('tempdb..#AllErrors') is not null
		drop table #AllErrors
	if object_id('tempdb..#GetObjectTests') is not null
		drop table #GetObjectTests
	if object_id('tempdb..#Succ') is not null
		drop table #Succ
	if object_id('tempdb..#rez') is not null
		drop table #rez

	DECLARE
		@Dta		datetime,
		@Step_ID	int = 0

	IF @IsDebug = 1
		SET @Dta = getdate()

	select * 
	into	#GetObjectTests
	from	Collect.fn_GetObjectTests_Operational(null)

	-- 1
	IF @IsDebug = 1
	BEGIN
		SET @Step_ID = @Step_ID + 1
		PRINT 'Step '+cast(@Step_ID as varchar(9))+': '+cast(datediff(ss, @Dta, getdate()) as varchar(16))+' second(s)'
		SET @Dta = getdate()
	END

	
	create index #idx_#GetObjectTests_MOB_ID on #GetObjectTests(MOB_ID)

	-- 2
	IF @IsDebug = 1
	BEGIN
		SET @Step_ID = @Step_ID + 1
		PRINT 'Step '+cast(@Step_ID as varchar(9))+': '+cast(datediff(ss, @Dta, getdate()) as varchar(16))+' second(s)'
		SET @Dta = getdate()
	END

	;with Obj as
		(select distinct MOB_ID, 
				--MOB_Name, 
				SH.SHS_ShortName AS MOB_Name,
				PLT_ID, PLT_Name, VER_Name, MOB_OOS_ID, QRT_ID, QRT_Name, S.OOS_ID, S.OOS_Name
			from Inventory.MonitoredObjects
				inner join Inventory.SystemHosts AS SH on MOB_ID = SH.SHS_MOB_ID
				inner join Collect.TestVersions on TSV_PLT_ID = MOB_PLT_ID
				inner join Collect.Tests on TST_ID = TSV_TST_ID
				inner join Collect.QueryTypes on QRT_ID = TST_QRT_ID
				inner join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
				inner join Management.ObjectOperationalStatuses AS S on MOB_OOS_ID = S.OOS_ID
				left join Inventory.Versions on VER_ID = MOB_VER_ID
			where OOS_IsOperational = 1
		)
	select *
	into #ByQueryType
	from Obj
		outer apply (select (select distinct TRH_ErrorMessage + ';'
								from (select top 5 TRH_ErrorMessage, h.TRH_TRS_ID
										from (select top 5 TRH_ErrorMessage, TRH_TRS_ID,TRH_SCT_ID from Collect.TestRunHistory h WITH (NOLOCK) where TRH_MOB_ID = MOB_ID order by /*TRH_EndDate*/ TRH_ID desc)h --with(nolock)
											inner join Collect.ScheduledTests s on h.TRH_SCT_ID = s.SCT_ID 
											inner join Collect.TestVersions v on v.TSV_ID = s.SCT_TSV_ID
											inner join Collect.Tests t on t.TST_ID = v.TSV_TST_ID
										where /*h.TRH_MOB_ID = MOB_ID
											and*/ t.TST_QRT_ID = QRT_ID
											and h.TRH_TRS_ID = 4
										--order by h.TRH_ID desc
									) h
								for xml path('')) ErrorMessage) his
	where 
		/*and */not exists (select *
						from Collect.TestRunHistory h WITH (NOLOCK)
							inner join Collect.Tests t on t.TST_ID = h.TRH_TST_ID
						where h.TRH_MOB_ID = MOB_ID
							and t.TST_QRT_ID = QRT_ID
							and h.TRH_TRS_ID = 3)

	-- 3
	IF @IsDebug = 1
	BEGIN
		SET @Step_ID = @Step_ID + 1
		PRINT 'Step '+cast(@Step_ID as varchar(9))+': '+cast(datediff(ss, @Dta, getdate()) as varchar(16))+' second(s)'
		SET @Dta = getdate()
	END

	select MOB_ID ObjectID, MOB_Name ObjectName, PLT_ID, PLT_Name PlatformName, VER_Name ProductVersion,
		QRT_Name CollectionType, cast(null as int) CollectionId, cast(null as varchar(100)) CollectionName,
		OOS_ID, OOS_Name,
		replace(replace(ErrorMessage, char(13), ' '), char(10), ' ') ErrorMessage
	into #AllErrors
	from #ByQueryType
	where ErrorMessage is not null
	union all
	select m.MOB_ID, 
		--MOB_Name, 
		SH.SHS_ShortName AS MOB_Name,
		PLT_ID, PLT_Name, VER_Name,
		QRT_Name, case when count(*) = 1 then max(t.TST_ID) else null end CollectionID,
		case when count(*) = 1 then max(t.TST_Name) else null end CollectionName,
		SO.OOS_ID, SO.OOS_Name,
		'"' + case when ErrorMessage like '%permission%' or ErrorMessage like '%access%' then 'Insufficient Permission for collection login' else ErrorMessage end + '"' ErrorMessage
	from 
		#GetObjectTests st
		inner join Inventory.MonitoredObjects m on m.MOB_ID = st.MOB_ID
		inner join Inventory.SystemHosts AS SH on m.MOB_ID = SH.SHS_MOB_ID
		inner join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
		inner join Collect.Tests t on t.TST_ID = st.TST_ID
		left join Inventory.Versions on VER_ID = MOB_VER_ID
		inner join Collect.QueryTypes qt on QRT_ID = st.TST_QRT_ID
		inner join (
						select 
							TRH_TST_ID,
							TRH_MOB_ID,
							COUNT(*) RunCount,
							MIN(TRH_StartDate) FirstRun,
							MAX(TRH_StartDate) LastRun
						from 
							(	SELECT 
									TRH_TST_ID,
									TRH_MOB_ID, 
									TRH_StartDate
								FROM
									#GetObjectTests st
									INNER JOIN Collect.TestRunHistory with (nolock)
									ON 
										TRH_TST_ID = st.TST_ID
										and TRH_MOB_ID = st.MOB_ID
										and TRH_TRS_ID = 3
							) AS G
						group by 
							TRH_TST_ID,
							TRH_MOB_ID) AS h
		on h.TRH_TST_ID = st.TST_ID
			and h.TRH_MOB_ID = st.MOB_ID
		outer apply (select top 1 TRH_ErrorMessage ErrorMessage,
							COUNT(*) over() ErrorCount,
							MIN(TRH_EndDate) over() FirstError,
							MAX(TRH_EndDate) over() LastError
						from Collect.TestRunHistory WITH (NOLOCK)
						where TRH_TST_ID = st.TST_ID
							and TRH_MOB_ID = st.MOB_ID
							and TRH_TRS_ID = 4
							and TRH_EndDate > DATEADD(hour, -200, getdate())
						order by TRH_ID desc) e
		outer apply (select top 1 SCT_DateToRun NextRunDate
						from Collect.ScheduledTests
						where SCT_TST_ID = st.TST_ID
							and SCT_MOB_ID = st.MOB_ID
							and SCT_STS_ID = 1
						order by SCT_ID) s
		inner join Management.ObjectOperationalStatuses AS SO on m.MOB_OOS_ID = SO.OOS_ID
	where OOS_IsOperational = 1
		and TST_IsActive = 1
		and TST_IsActive = 1
		and st.TST_ID <> 78
		and (RunCount = 0 or (LastError > LastRun or LastRun is null))
		and (st.TST_MaxSuccessfulRuns > 0
			or st.TST_MaxSuccessfulRuns is null)
		and RunCount = 0
		and ErrorMessage is not null
		and (LastError > LastRun or LastRun is null)
		and not exists (select *
							from #ByQueryType q
							where q.MOB_Name = m.MOB_Name
								and q.QRT_Name = qt.QRT_Name)
		and ErrorMessage not like 'Cannot insert duplicate key row%'
	group by m.MOB_ID, 
			--MOB_Name, 
			SH.SHS_ShortName,
			PLT_ID, PLT_Name, VER_Name, OOS_ID, OOS_Name,
		QRT_Name, case when ErrorMessage like '%permission%' or ErrorMessage like '%access%' then 'Insufficient Permission for collection login' else ErrorMessage end
	order by CollectionType, CollectionName, ErrorMessage
	option (maxdop 1)

	-- 4
	IF @IsDebug = 1
	BEGIN
		SET @Step_ID = @Step_ID + 1
		PRINT 'Step '+cast(@Step_ID as varchar(9))+': '+cast(datediff(ss, @Dta, getdate()) as varchar(16))+' second(s)'
		SET @Dta = getdate()
	END


	select TST_ID, TST_QRT_ID, TST_IntervalType, TST_IntervalPeriod, TST_MaxSuccessfulRuns, MOB_ID, SuccessfulRuns, FirstDate, LastDate
	into #Succ
	from #GetObjectTests AS t
		LEFT JOIN (select 
							TRH_TST_ID,
							TRH_MOB_ID,
							count(*) SuccessfulRuns,
							min(TRH_EndDate) FirstDate,
							max(TRH_EndDate) LastDate
						from Collect.TestRunHistory WITH (NOLOCK) --with (forceseek)
						where TRH_TRS_ID = 3
						GROUP BY 
							TRH_TST_ID,
							TRH_MOB_ID) AS h
		ON t.tst_ID = TRH_TST_ID AND t.MOB_ID = TRH_MOB_ID

	-- 5
	IF @IsDebug = 1
	BEGIN
		SET @Step_ID = @Step_ID + 1
		PRINT 'Step '+cast(@Step_ID as varchar(9))+': '+cast(datediff(ss, @Dta, getdate()) as varchar(16))+' second(s)'
		SET @Dta = getdate()
	END



	;with SuccessStats as
			(select MOB_ID, SuccessfulRuns, (case TST_IntervalType
							when 's' then datediff(second, FirstDate, LastDate)
							when 'm' then datediff(minute, FirstDate, LastDate)
							when 'h' then datediff(hour, FirstDate, LastDate)
							when 'd' then datediff(day, FirstDate, LastDate)
						end/TST_IntervalPeriod) ExpectedSuccessfulRuns, TST_MaxSuccessfulRuns
				from
					#Succ
			)
		, SuccessStats1 as
			(select MOB_ID,
					case when TST_MaxSuccessfulRuns <= SuccessfulRuns then 100
						--when SuccessfulRuns = 0 then 0
						when ExpectedSuccessfulRuns = 0 then 0
						else SuccessfulRuns*100/ExpectedSuccessfulRuns
					end SuccessPercentage
				from SuccessStats
			)
		, SuccessRatio as
			(select distinct MOB_ID S_MOB_ID, percentile_disc(0.2) within group (order by iif(SuccessPercentage > 100, 100, SuccessPercentage)) over (partition by MOB_ID) SuccessPercentage
				from SuccessStats1
			)
	select 
		s.SYS_ID as System_id,
		s.SYS_Name as System_Name,
		MOB_ID, 
		--MOB_Name [Object Name],
		sh.SHS_ShortName AS [Object Name],
		PLT_ID, PLT_Name [Platform Name], 
		isnull(iif(ErrorSeverity is null and ISNULL(SuccessPercentage, 0) = 0, 0, ErrorSeverity), 1) [Object Status],
		CASE isnull(iif(ErrorSeverity is null and ISNULL(SuccessPercentage, 0) = 0, 0, ErrorSeverity), 1)
			WHEN 0 THEN 'Collection has never run on the database'
			WHEN 1 THEN 'Collection is running fine'
			WHEN 2 THEN 'Collection is failing for a few specific collections'
			WHEN 3 THEN 'Collection is failing for entire collection types (WMI/Performance counters/SSH)'
			WHEN 4 THEN 'Unable to connect to object'
		END AS [Object Status Name],
		SO.OOS_ID, SO.OOS_Name,
		iif(SuccessPercentage > 90, 100, ISNULL(SuccessPercentage, 0)) [Success %]
	into #rez
	from 
		Inventory.Systems s
		inner join Inventory.SystemHosts sh on s.SYS_ID = sh.SHS_SYS_ID	
		inner join Inventory.MonitoredObjects
		ON sh.SHS_MOB_ID = MOB_ID
		inner join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
		outer apply (select top 1 case when CollectionName is not null then 2
									when CollectionType in ('PING', 'TSQL') then 4
									else 3
								end ErrorSeverity
						from #AllErrors
						where ObjectID = MOB_ID
						order by ErrorSeverity desc
					) t
		inner join SuccessRatio on S_MOB_ID = MOB_ID
		inner join Management.ObjectOperationalStatuses AS SO on MOB_OOS_ID = SO.OOS_ID
	where OOS_IsOperational = 1
	order by SuccessPercentage, [Object Status] desc, [Success %], [Object Name]

	select * from #rez
	-- 6
	IF @IsDebug = 1
	BEGIN
		SET @Step_ID = @Step_ID + 1
		PRINT 'Step '+cast(@Step_ID as varchar(9))+': '+cast(datediff(ss, @Dta, getdate()) as varchar(16))+' second(s)'
		SET @Dta = getdate()
	END

	select case when CollectionName is not null then 2
									when CollectionType in ('PING', 'TSQL') then 4
									else 3
								end [Object Status],
		ObjectID MOB_ID, ObjectName [Object Name], PLT_ID, PlatformName [Platform Name], CollectionType [Collection Type],
		isnull(CollectionName, '<All>') [Collection Name], ErrorMessage [Error Message],
		OOS_ID, OOS_Name
	from #AllErrors
	order by [Object Status] desc, [Object Name]


	-- 7
	IF @IsDebug = 1
	BEGIN
		SET @Step_ID = @Step_ID + 1
		PRINT 'Step '+cast(@Step_ID as varchar(9))+': '+cast(datediff(ss, @Dta, getdate()) as varchar(16))+' second(s)'
		SET @Dta = getdate()
	END

	declare 
			@IsConfigure	BIT = 0
			,@IsNotRunTests	BIT = 1

	SELECT 
			@IsConfigure = 1 
	FROM	#rez a
	join	Management.ObjectOperationalStatuses s on a.OOS_ID = s.OOS_ID
	WHERE	OOS_IsOperational = 1		----------------------------------------
	
	if @IsConfigure = 1
	BEGIN
		select 
				@IsNotRunTests = 0
		from	(select distinct MOB_ID AS ObjectID from #rez where MOB_ID is not null)t
		JOIN	EventProcessing.TrappedEvents ON ObjectID = TRE_MOB_ID

		IF @IsNotRunTests = 1
		SELECT 	
				@IsNotRunTests = 0
		FROM	(select distinct MOB_ID AS ObjectID from #rez where MOB_ID is not null)t
		JOIN	Collect.TestRunHistory ON ObjectID = TRH_MOB_ID
	--WHERE	--NOT EXISTS (SELECT * FROM  with(nolock) WHERE MOB_ID = TRH_MOB_ID and TRH_MOB_ID IS NOT NULL)
	
	END		


	SELECT 
			@IsConfigure	as IsConfigure
			,@IsNotRunTests	as IsNotRunTests

END
GO
