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
/****** Object:  StoredProcedure [GUI].[usp_CollectionHealthReport]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_CollectionHealthReport]
--declare
	@ReportType	TINYINT = 3
AS
IF @ReportType = 1
BEGIN
	 if OBJECT_ID('tempdb..#TestRunSummary') is not null
		drop table #TestRunSummary

	 select 
			MOB_ID           as TRM_MOB_ID,
			TST_ID           as TRM_TST_ID, 
			TST_QRT_ID       as TRM_QRT_ID,
			trh.TRH_ID           as TRM_TRH_D, 
			trh.TRH_TRS_ID       as TRM_TRS_ID, 
			trh.TRH_EndDate      as TRM_Updated,
			trh.TRH_ErrorMessage as TRM_Message,
			iif(VER_ID is not null and EDT_ID is not null, 1, 0) as TRM_Resolved,
			iif(TSV_ID is not null, 1, 0)                        as TRM_Expected,
			iif(TST_MaxSuccessfulRuns = 0 or
				TST_IsActive = 0 or STO_IsExcluded = 1, 1, 0)    as TRM_Disabled,
			MOB_Name    as [Address],
			PLT_Name    as [Product],
			VER_Full    as [Version]
			,SHS_ShortName
			,FIRST_VALUE(TRH_CTR_ID) OVER (partition by MOB_ID Order by TRH_EndDate desc) AS TRH_CTR_ID
	into	#TestRunSummary
		from Inventory.MonitoredObjects
		OUTER APPLY (SELECT top 1 SHS_ShortName FROM Inventory.SystemHosts WHERE MOB_ID = SHS_MOB_ID)sh
		JOIN Management.ObjectOperationalStatuses on MOB_OOS_ID = OOS_ID and OOS_IsOperational = 1
		JOIN Management.PlatformTypes ON PLT_ID = MOB_PLT_ID
		left outer join Inventory.Versions on VER_PLT_ID = PLT_ID and VER_ID = MOB_VER_ID
		left outer join Inventory.Editions on EDT_PLT_ID = PLT_ID and EDT_ID = MOB_Engine_EDT_ID
		left outer join Collect.Tests on exists(
			select * from Collect.TestVersions
			where TST_ID = TSV_TST_ID and PLT_ID = TSV_PLT_ID)
		outer apply (
			select top(1) * from Collect.TestRunHistory with (nolock, forceseek)
			where MOB_ID = TRH_MOB_ID and TST_ID = TRH_TST_ID and TRH_TRS_ID in (3, 4)
			order by TRH_TST_ID, TRH_MOB_ID, TRH_EndDate desc) as trh
		outer apply (
			select top(1) * from Collect.SpecificTestObjects 
			where TST_ID = STO_TST_ID and MOB_ID = STO_MOB_ID) as sto
		outer apply (
			select top(1) * from Collect.TestVersions
			where TST_ID = TSV_TST_ID and PLT_ID = TSV_PLT_ID  AND(
					VER_Number >= TSV_MinVersion or TSV_MinVersion is null) and (
					VER_Number <= TSV_MaxVersion or TSV_MaxVersion is null) and (
					exists (select * from Infra.fn_SplitString(TSV_Editions, ';')
							where EDT_Name like '%' + Val + '%') or TSV_Editions is null)) as tsv
		 WHERE exists (select * from Management.OperationConfigurations where TST_OCF_BinConcat & OCF_ID > 0 and OCF_IsApply = 1 )
	
	;WITH
	TestRunSummary2 as (
		select 
			TRM_MOB_ID       as TRG_MOB_ID, 
			[Address],
			[Product],
			[Version],
			SHS_ShortName,
			max(TRM_Updated) as TRG_Updated,
			sum(iif(TRM_Disabled = 0 and TRM_TRS_ID = 3, 1, 0))     as TRG_SuccessCount,
			sum(iif(TRM_Disabled = 0 and TRM_TRS_ID = 4, 1, 0))     as TRG_FailureCount,
			sum(iif(TRM_Expected = 1 and
					TRM_Disabled = 0 and TRM_TRS_ID is null, 1, 0)) as TRG_MissingCount,
			sum(iif(TRM_Resolved = 0 and TRM_Expected = 0 and
					TRM_Disabled = 0 and TRM_TRS_ID is null, 1, 0)) as TRG_UnknownCount
			,TRH_CTR_ID
		from #TestRunSummary trs
		group by TRM_MOB_ID,[Address],[Product],[Version],SHS_ShortName,TRH_CTR_ID
		)
	select
		TRG_MOB_ID  AS MOB_ID,
		SHS_ShortName AS [Server Name],
		[Address] AS [Host],
		[Product],
		[Version],
		TRG_Updated as [Updated],
		case when TRG_FailureCount > 0 then 'FAILURE'
			 when TRG_MissingCount > 0 then 'MISSING'
			 when TRG_UnknownCount > 0 then 'UNKNOWN'
			 when TRG_SuccessCount = 0 then 'DISABLED'
			 else 'OK' end as [Outcome],
		stuff((select char(13) + char(10) + TRM_Message from #TestRunSummary
			   where TRM_MOB_ID = TRG_MOB_ID
			   order by TRM_Updated desc 
			   for xml path, type).value('.[1]', 'nvarchar(max)'), 1, 2, '') as [Message]
		,ISNULL(e.IsEnable,0) AS IsEnable
		,CTR_ID
		,CTR_Name
		,CTR_IsDeleted
	from TestRunSummary2
	LEFT JOIN Collect.Collectors on TRH_CTR_ID = CTR_ID
	OUTER APPLY 
	(SELECT top(1) 1 AS IsEnable FROM Collect.fn_GetObjectTests(NULL)f WHERE f.MOB_ID = TRG_MOB_ID)e
	
	
END

IF @ReportType = 2
BEGIN
	
	with TestRunSummary as (
		select 
			MOB_ID           as TRM_MOB_ID,
			TST_ID           as TRM_TST_ID, 
			TST_QRT_ID       as TRM_QRT_ID,
			TRH_ID           as TRM_TRH_D, 
			TRH_TRS_ID       as TRM_TRS_ID, 
			TRH_EndDate      as TRM_Updated,
			TRH_ErrorMessage as TRM_Message,
			iif(VER_ID is not null and EDT_ID is not null, 1, 0) as TRM_Resolved,
			iif(TSV_ID is not null, 1, 0)                        as TRM_Expected,
			iif(TST_MaxSuccessfulRuns = 0 or
				TST_IsActive = 0 or STO_IsExcluded = 1, 1, 0)    as TRM_Disabled,
			MOB_Name    as [Address],
			PLT_Name    as [Product],
			VER_Full    as [Version],
			SHS_ShortName,
			QRT_Name    as [Context]
			,CTR_ID
			,CTR_Name
			,CTR_IsDeleted
			,FIRST_VALUE(TRH_CTR_ID) OVER (partition by MOB_ID,QRT_ID Order by TRH_EndDate desc) AS TRH_CTR_ID
		from Inventory.MonitoredObjects
		OUTER APPLY (SELECT top 1 SHS_ShortName FROM Inventory.SystemHosts WHERE MOB_ID = SHS_MOB_ID)sh
		JOIN Management.ObjectOperationalStatuses on MOB_OOS_ID = OOS_ID and OOS_IsOperational = 1
		join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
		left outer join Inventory.Versions on VER_PLT_ID = PLT_ID and VER_ID = MOB_VER_ID
		left outer join Inventory.Editions on EDT_PLT_ID = PLT_ID and EDT_ID = MOB_Engine_EDT_ID
		left outer join Collect.Tests on exists(
			select * from Collect.TestVersions
			where TST_ID = TSV_TST_ID and PLT_ID = TSV_PLT_ID)
		join Collect.QueryTypes on QRT_ID = TST_QRT_ID
		outer apply (
			select top(1) * from Collect.TestRunHistory with (nolock, forceseek)
			where MOB_ID = TRH_MOB_ID and TST_ID = TRH_TST_ID and TRH_TRS_ID in (3, 4)
			order by TRH_TST_ID, TRH_MOB_ID, TRH_EndDate desc) as trh
		LEFT JOIN Collect.Collectors ON trh.TRH_CTR_ID = CTR_ID
		outer apply (
			select top(1) * from Collect.SpecificTestObjects 
			where TST_ID = STO_TST_ID and MOB_ID = STO_MOB_ID) as sto
		outer apply (
			select top(1) * from Collect.TestVersions
			where TST_ID = TSV_TST_ID and PLT_ID = TSV_PLT_ID and (
					VER_Number >= TSV_MinVersion or TSV_MinVersion is null) and (
					VER_Number <= TSV_MaxVersion or TSV_MaxVersion is null) and (
					exists (select * from Infra.fn_SplitString(TSV_Editions, ';')
							where EDT_Name like '%' + Val + '%') or TSV_Editions is null)) as tsv
		outer apply (
			select top 1 * from Collect.ScheduledTests WHERE TRH_SCT_ID = SCT_ID AND TRH_TRS_ID = 4)sct
		WHERE OOS_IsOperational = 1
		 and exists (select * from Management.OperationConfigurations where TST_OCF_BinConcat & OCF_ID > 0 and OCF_IsApply = 1 ) ),
	TestRunSummary2 as (
		select 
			TRM_MOB_ID       as TRG_MOB_ID, 
			TRM_QRT_ID       as TRG_QRT_ID,
			[Address],
			[Product],
			[Version],
			[Context],
			SHS_ShortName,
			max(TRM_Updated) as TRG_Updated,
			sum(iif(TRM_Disabled = 0 and TRM_TRS_ID = 3, 1, 0))     as TRG_SuccessCount,
			sum(iif(TRM_Disabled = 0 and TRM_TRS_ID = 4, 1, 0))     as TRG_FailureCount,
			sum(iif(TRM_Expected = 1 and
					TRM_Disabled = 0 and TRM_TRS_ID is null, 1, 0)) as TRG_MissingCount,
			sum(iif(TRM_Resolved = 0 and TRM_Expected = 0 and
					TRM_Disabled = 0 and TRM_TRS_ID is null, 1, 0)) as TRG_UnknownCount
			,TRH_CTR_ID
		from TestRunSummary trs
		group by TRM_MOB_ID, TRM_QRT_ID,
			[Address],
			[Product],
			[Version],
			[Context],
			SHS_ShortName
			,TRH_CTR_ID
			)
	select distinct 
		TRG_MOB_ID AS MOB_ID,
		TRG_QRT_ID AS QRT_ID,
		SHS_ShortName AS [Server Name],
		[Address] AS [Host],
		[Product],
		[Version],
		[Context],
		TRG_Updated as [Updated],
		case when TRG_FailureCount > 0 then 'FAILURE'
			 when TRG_MissingCount > 0 then 'MISSING'
			 when TRG_UnknownCount > 0 then 'UNKNOWN'
			 when TRG_SuccessCount = 0 then 'DISABLED'
			 else 'OK' end as [Outcome],
		stuff((select char(13) + char(10) + TRM_Message from TestRunSummary
			   where TRM_MOB_ID = TRG_MOB_ID and TRM_QRT_ID = TRG_QRT_ID
			   order by TRM_Updated desc 
			   for xml path, type).value('.[1]', 'nvarchar(max)'), 1, 2, '') as [Message]
		,ISNULL(e.IsEnable,0) AS IsEnable
		,CTR_ID
		,CTR_Name
		,CTR_IsDeleted
	from TestRunSummary2
	LEFT JOIN Collect.Collectors on TRH_CTR_ID = CTR_ID
	OUTER APPLY 
	(SELECT top(1) 1 AS IsEnable FROM Collect.fn_GetObjectTests(NULL)f WHERE f.MOB_ID = TRG_MOB_ID and f.TST_QRT_ID = TRG_QRT_ID)e
	order by [Address], [Product], [Context]
END

IF @ReportType = 3
BEGIN

	with TestRunSummary as (
		select 
			MOB_ID           as TRM_MOB_ID,
			TST_ID           as TRM_TST_ID, 
			TST_QRT_ID       as TRM_QRT_ID,
			TRH_ID           as TRM_TRH_D, 
			TRH_TRS_ID       as TRM_TRS_ID, 
			TRH_EndDate      as TRM_Updated,
			TRH_ErrorMessage as TRM_Message,
			iif(VER_ID is not null and EDT_ID is not null, 1, 0) as TRM_Resolved,
			iif(TSV_ID is not null, 1, 0)                        as TRM_Expected,
			iif(TST_MaxSuccessfulRuns = 0 or
				TST_IsActive = 0 or STO_IsExcluded = 1, 1, 0)    as TRM_Disabled,
			MOB_Name    as [Address],
			PLT_Name    as [Product],
			VER_Full    as [Version],
			QRT_Name    as [Context],
			TST_Name    as [Subject],
			SHS_ShortName
			,CTR_ID
			,CTR_Name
			,CTR_IsDeleted
			,TST_DontRunIfErrorIn_TST_ID as Parent_TST_ID
		from Inventory.MonitoredObjects
		OUTER APPLY (SELECT top 1 SHS_ShortName FROM Inventory.SystemHosts WHERE MOB_ID = SHS_MOB_ID)sh
		JOIN Management.ObjectOperationalStatuses on MOB_OOS_ID = OOS_ID and OOS_IsOperational = 1
		join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
		left outer join Inventory.Versions on VER_PLT_ID = PLT_ID and VER_ID = MOB_VER_ID
		left outer join Inventory.Editions on EDT_PLT_ID = PLT_ID and EDT_ID = MOB_Engine_EDT_ID
		left outer join Collect.Tests on exists(
			select * from Collect.TestVersions
			where TST_ID = TSV_TST_ID and PLT_ID = TSV_PLT_ID)
		join Collect.QueryTypes on QRT_ID = TST_QRT_ID
		outer apply (
			select top(1) * from Collect.TestRunHistory with (nolock, forceseek)
			where MOB_ID = TRH_MOB_ID and TST_ID = TRH_TST_ID and TRH_TRS_ID in (3, 4)
			order by TRH_TST_ID, TRH_MOB_ID, TRH_EndDate desc) as trh
		LEFT JOIN Collect.Collectors ON trh.TRH_CTR_ID = CTR_ID
		outer apply (
			select top(1) * from Collect.SpecificTestObjects 
			where TST_ID = STO_TST_ID and MOB_ID = STO_MOB_ID) as sto
		outer apply (
			select top(1) * from Collect.TestVersions
			where TST_ID = TSV_TST_ID and PLT_ID = TSV_PLT_ID and (
					VER_Number >= TSV_MinVersion or TSV_MinVersion is null) and (
					VER_Number <= TSV_MaxVersion or TSV_MaxVersion is null) and (
					exists (select * from Infra.fn_SplitString(TSV_Editions, ';')
							where EDT_Name like '%' + Val + '%') or TSV_Editions is null)) as tsv

		WHERE OOS_IsOperational = 1
		 and exists (select * from Management.OperationConfigurations where TST_OCF_BinConcat & OCF_ID > 0 and OCF_IsApply = 1 ) ),
	TestRunSummary2 as (
		select 
			TRM_MOB_ID       as TRG_MOB_ID, 
			TRM_QRT_ID       as TRG_QRT_ID,
			TRM_TST_ID       as TRG_TST_ID,
			[Address],
			[Product],
			[Version],
			[Context],
			[Subject],
			SHS_ShortName,
			max(TRM_Updated) as TRG_Updated,
			sum(iif(TRM_Disabled = 0 and TRM_TRS_ID = 3, 1, 0))     as TRG_SuccessCount,
			sum(iif(TRM_Disabled = 0 and TRM_TRS_ID = 4, 1, 0))     as TRG_FailureCount,
			sum(iif(TRM_Expected = 1 and
					TRM_Disabled = 0 and TRM_TRS_ID is null, 1, 0)) as TRG_MissingCount,
			sum(iif(TRM_Resolved = 0 and TRM_Expected = 0 and
					TRM_Disabled = 0 and TRM_TRS_ID is null, 1, 0)) as TRG_UnknownCount
			,CTR_ID
			,CTR_Name
			,CTR_IsDeleted
			,Parent_TST_ID as TRG_Parent_TST_ID
		from TestRunSummary trs
		group by TRM_MOB_ID, TRM_QRT_ID, TRM_TST_ID,[Address],
		[Product],
		[Version],
		[Context],
		[Subject],
    	SHS_ShortName
		,CTR_ID
		,CTR_Name
		,CTR_IsDeleted
		,Parent_TST_ID
		)
	select
		TRG_MOB_ID AS MOB_ID
		,TRG_TST_ID AS TST_ID,
		TRG_QRT_ID AS QRT_ID,
		SHS_ShortName AS [Server Name],
		[Address] AS [Host],
		[Product],
		[Version],
		[Context],
		[Subject],
		TRG_Updated AS [Updated],
		case when TRG_FailureCount > 0 then 'FAILURE'
			 when TRG_MissingCount > 0 then 'MISSING'
			 when TRG_UnknownCount > 0 then 'UNKNOWN'
			 when TRG_SuccessCount = 0 then 'DISABLED'
			 else 'OK' end as [Outcome],
		stuff((select char(13) + char(10) + TRM_Message from TestRunSummary
			   where TRM_MOB_ID = TRG_MOB_ID and TRM_TST_ID = TRG_TST_ID
			   order by TRM_Updated desc 
			   for xml path, type).value('.[1]', 'nvarchar(max)'), 1, 2, '') as [Message]
		,IIF(ISNULL(e.IsEnable,0) = 1 AND pt.TRM_TST_ID IS NULL, 1,0)  AS IsEnable
		,CTR_ID
		,CTR_Name
		,CTR_IsDeleted
		,TRM_TST_ID as Parent_TST_ID
	from TestRunSummary2 t
	OUTER APPLY 
	(SELECT top(1) 1 AS IsEnable FROM Collect.fn_GetObjectTests(TRG_TST_ID)f WHERE f.MOB_ID = TRG_MOB_ID)e
	OUTER APPLY (SELECT top 1 TRM_TST_ID FROM TestRunSummary WHERE TRM_Disabled = 0 and TRM_TRS_ID = 4 and TRM_TST_ID = TRG_Parent_TST_ID  and TRM_MOB_ID = TRG_MOB_ID)pt
	
	order by [Address], [Product], [Context], [Subject]


END
GO
