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
/****** Object:  StoredProcedure [Collect].[usp_GetConfigTests]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Collect].[usp_GetConfigTests]
AS

	SET NOCOUNT ON;

	select
	    [Id] = cast(TST_ID as nvarchar(128)),
	    [Display] = TST_Name,
	    [Channel] = TST_OutputTable,
        [Process] = case TST_OutputTable
            when 'Tests.VW_TST_BaseSQLcollection'
            then 'Update-SqlVersion'
            when 'Tests.VW_TST_OperatingSystem'
            then 'Update-WinVersion'
            when 'Tests.VW_TST_AIXBase'
            then 'Update-AixVersion'
            when 'Tests.VW_TST_LinuxVersion'
            then 'Update-LinuxVersion'
            when 'Tests.VW_TST_SolarisBase'
            then 'Update-SolarisVersion'
            else null
            end,
        [Default] = TST_DefaultLastValue,
	    [Depends] = cast(TST_DontRunIfErrorIn_TST_ID as nvarchar(128)),
	    [Disabled] = case TST_IsActive 
            when 0 then cast(1 as bit)
            else cast(0 as bit)
            end,
	    [Interval] = case TST_IntervalType
	     when 's' then TST_IntervalPeriod 
	     when 'm' then TST_IntervalPeriod * 60
	     when 'h' then TST_IntervalPeriod * 60 * 60
	     when 'd' then TST_IntervalPeriod * 60 * 60 * 24
	     end,
	    [Quantity] = isnull(TST_MaxSuccessfulRuns, -1),
	    [ConnectTimeout] = TST_ConnectionTimeout,
	    [CommandTimeout] = TST_QueryTimeout,
		[Category] = TCA_Name
    from Collect.Tests
	LEFT JOIN (Collect.TestCategories_Tests JOIN Collect.TestCategories ON TCA_ID = TCS_TCA_ID) ON TCS_TST_ID = TST_ID
	WHERE	EXISTS (
					SELECT 
							* 
					FROM	Management.OperationConfigurations 
					WHERE	TST_OCF_BinConcat & OCF_ID <> 0 
							AND OCF_IsApply = 1
					)

    order by TST_ID

	select
        [Id] = cast(TSV_ID as nvarchar(128)),
	    [Product] = PLT_Name,
	    [Version] = case
	     when TSV_MinVersion is not null or TSV_MaxVersion is not null
	     then isnull(cast(TSV_MinVersion as nvarchar(128)), N'0.0') + N'-' + 
	       isnull(cast(TSV_MaxVersion as nvarchar(128)), N'')
	     else null
	     end,
	    [Edition] = replace(TSV_Editions, ';', ', '),
        [Collect] = cast(TST_ID as nvarchar(128)),
        [Channel] = TSV_OutputTable,
	    [Prepare] = case
            when TSV_QueryFunction = 'Tests.fn_TST_SQLDatabaseTopTables'
            then TSV_QueryFunction
	     when TSV_QueryFunction is not null and TSV_QueryExpanded is null
	     then TSV_QueryFunction
	     else null
	     end,
	    [CommandType] = case QRT_ID
	     when 1 then case PLT_ID
	      when 1 then N'SQL'
	      when 3 then N'ORA'
	      else N'Unknown (' + cast(QRT_ID as nvarchar(128)) + N')'
	      end
	     when 2 then N'WMI'
	     when 3 then N'WPC'
	     when 4 then N'NET'
	     when 5 then N'SSH'
	     else N'Unknown (' + cast(QRT_ID as nvarchar(128)) + N')'
	     end,
	    [CommandPath] = TSV_QueryRoot,
        [CommandText] = TSV_QueryText,
        [CommandArgs] = TSV_QueryParams
    from Collect.Tests
    join Collect.TestVersions on TST_ID = TSV_TST_ID
    join Collect.QueryTypes on TST_QRT_ID = QRT_ID
    join Management.PlatformTypes on TSV_PLT_ID = PLT_ID
    outer apply (select
	    TSV_QueryExpanded = case TSV_QueryFunction
	     when 'Collect.fn_GetSQLPerformanceCountersQueryWrapper'
	     then Collect.fn_GetSQLPerformanceCountersQueryWrapper(
	      TST_ID, -1, TSV_Query)
	     when 'Collect.fn_GetWindowsPerformanceCountersQueryWrapper'
	     then Collect.fn_GetWindowsPerformanceCountersQueryWrapper(
	      TST_ID, -1, TSV_Query)
	     when 'Tests.fn_TST_DiskPerformanceCounters'
	     then Tests.fn_TST_DiskPerformanceCounters(TST_ID, -1, TSV_Query)
	     when 'Tests.fn_TST_WindowsVolumes'
	     then Tests.fn_TST_WindowsVolumes(TST_ID, -1, TSV_Query)
	     when 'Collect.fn_ForEachDBGenerator'
	     then Collect.fn_ForEachDBGenerator(TST_ID, -1, TSV_Query)
	     when 'Tests.fn_TST_NetworkInterfaceSpeed'
	     then replace(TSV_Query, 'where %INTERFACENAMES%', '')
	     when 'Tests.fn_TST_PageFiles' /* Dependency on TST_ID=5 success */
	     then TSV_Query
            when 'Tests.fn_TST_SQLDatabaseTopTables'
            then Collect.fn_ForEachDBGenerator(TST_ID, -1, TSV_Query)
	     else null
	     end) as TestVersionQueryExpanded
    outer apply (select
	    TSV_QueryBase = case 
	     when TSV_QueryExpanded is not null
	     then TSV_QueryExpanded
	     else TSV_Query
	     end) as TestVersionQueryBase
    outer apply (select
	    TSV_QueryRoot = case 
	     when QRT_ID = 2 /* WQL */ and TSV_QueryBase like '%||%'
	     then substring(TSV_QueryBase, 1, patindex('%||%', TSV_QueryBase) - 1)
	     else null
	     end) as TestVersionQueryRoot
    outer apply (select
	    TSV_QueryText = case 
	     when QRT_ID = 2 /* WQL */ and TSV_QueryBase like '%||%'
	     then substring(
	      TSV_QueryBase, patindex('%||%', TSV_QueryBase) + 2, len(TSV_QueryBase))
	     when QRT_ID = 3 /* WPC */
	     then (select
	       N'\' + Category +
	       N'(' + isnull(Instance, '*') + N')' + 
	       N'\' + Property + ';'
	      from (select cast(TSV_QueryBase as xml)) as X(TSV_QueryXml)
	      outer apply TSV_QueryXml.nodes('/PerformanceRequest') as R(RequestXml)
	      outer apply RequestXml.nodes('Category')  as C(CategoryXml)
	      outer apply CategoryXml.nodes('Counter')  as P(PropertyXml)
	      outer apply PropertyXml.nodes('Instance') as I(InstanceXml)
	      outer apply (select
	       Category = CategoryXml.value('@Name', 'nvarchar(max)'),
	       Instance = InstanceXml.value('@Name', 'nvarchar(max)'),
	       Property = PropertyXml.value('@Name', 'nvarchar(max)')) as Q
	      for xml path(''))
	     when QRT_ID = 4 /* Ping */ then N'ping'
	     else TSV_QueryBase
	     end) as TestVersionQueryText
    outer apply (select
	    TSV_QueryParams = case 
	     when QRT_ID = 4 /* Ping */
	     then (select
	       cast(isnull(PacketSize, 32) as nvarchar(max))
	      from (select cast(TSV_QueryBase as xml)) as X(TSV_QueryXml)
	      outer apply TSV_QueryXml.nodes('/Ping') as R(RequestXml)
	      outer apply (select 
	       PacketSize = RequestXml.value('@PacketSize', 'int')) as Q)
	     else null --TSV_QueryArgs
	     end) as TestVersionQueryArgs
	WHERE	EXISTS (
					SELECT 
							* 
					FROM	Management.OperationConfigurations 
					WHERE	TST_OCF_BinConcat & OCF_ID <> 0 
							AND OCF_IsApply = 1
					)
    order by TSV_ID	
GO
