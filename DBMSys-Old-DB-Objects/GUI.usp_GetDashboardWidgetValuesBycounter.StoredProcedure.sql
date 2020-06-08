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
/****** Object:  StoredProcedure [GUI].[usp_GetDashboardWidgetValuesBycounter]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_GetDashboardWidgetValuesBycounter] --271
--declare 
		@DUS_ID				INT				--= 321
		,@FromDate			DATETIME2(3)	= NULL
		,@ToDate			DATETIME2(3)	= NULL
		,@IntervalTime		INT				= NULL
		,@IntervalPeriod	NVARCHAR(4)		= NULL
		
AS
DECLARE
		@CounterId			INT			
		,@SystemId			INT			
		,@OnlyLast			BIT									
		,@CalcValType		NVARCHAR(10)
		,@DCC_ID			INT = -1
		,@DCC_WidgetPermission	NVARCHAR(100)
		,@DWT_ID				INT
		
select @ToDate = ISNULL(@ToDate,GETUTCDATE())
					

SELECT	@CounterId			= DUS_CounteID
		,@SystemId			= DUS_CSY_ID
		,@OnlyLast			= DWT_IsOnlyLast
		,@Fromdate			= ISNULL(@Fromdate,case DWP_IntervalType when 'mi' then DATEADD(MI,-DWP_IntervalTime,@ToDate) when 'd' then DATEADD(D,-DWP_IntervalTime,@ToDate) when 'h' then DATEADD(HH,-DWP_IntervalTime,@ToDate) when 'm' then DATEADD(M,-DWP_IntervalTime,@ToDate) else  @ToDate end)
		,@IntervalTime		= ISNULL(@IntervalTime,DUS_IntervalTime)
		,@IntervalPeriod	= ISNULL(@IntervalPeriod,DUS_IntervalPeriod)
		,@CalcValType		= DCT_Name
		,@DCC_ID			= DUS_DCC_ID
		,@DCC_WidgetPermission	= ISNULL(DCC_WidgetPermission,'')
		,@DWT_ID				= DUS_DWT_ID
FROM	GUI.DashboardWidgetsUserSettings
JOIN	GUI.DashboardWidgetPeriodTypes ON DWP_ID = DUS_DWP_ID
JOIN	GUI.DashboardWidgetType ON DWT_ID = DUS_DWT_ID
JOIN	GUI.DashboradCalculateValueTypes ON DCT_ID = DUS_DCT_ID
LEFT JOIN GUI.DashboardWidgetCustomQuery ON DUS_DCC_ID = DCC_ID
WHERE	DUS_ID = @DUS_ID


declare @CMD NVARCHAR(MAX)

IF @IntervalPeriod = 'h'
	SET @IntervalPeriod = 'hh'

IF @OnlyLast = 1
BEGIN
	SET @CMD = '
	SELECT 
			top 1
			MOB_ID
			,MOB_Name
			,SystemID
			,CounterID
			,CounterName + ''('' + MTR_NameUp + IIF(MTR_NameDown = '''','''',''/'' + MTR_NameDown) + '')'' AS CounterName
			,@ToDate as CRS_DateTime
			,CIN_Name
			,CRT_Name
			,ROUND(CRS_Value / ISNULL(MCV_Factor,1),2) AS CRS_Value
			,ISNULL(MCV_Prefix,'''') + MTR_VNameUp + IIF(MTR_VNameDown = '''','''',''/'' + MTR_VNameDown) /*ISNULL(MCV_Target,MetricUp) + IIF(MCV_Target='''','''',ISNULL(''/'' + MetricDown,''''))*/ as UFT_Name
			,NULL AS TST_IntervalType
			,NULL AS TST_IntervalPeriod
			,ROUND(CRS_Value,2) AS CRS_Value_Eth
			,MTR_NameUp + IIF(MTR_NameDown = '''','''',''/'' + MTR_NameDown) /*ISNULL(''/'' + MetricDown,'''')*/ as UFT_Name_Eth
	from	PerformanceData.CounterResults with(nolock)
	JOIN	PerformanceData.VW_Counters on CRS_SystemID = SystemID and CRS_CounterID = CounterID
	JOIN	Inventory.MonitoredObjects on CRS_MOB_ID = MOB_ID
	JOIN	GUI.DashboradWidgetHostsInstances on MOB_ID = DWH_MOB_ID AND DWH_DUS_ID = @DUS_ID and ISNULL(CRS_InstanceID,0) = ISNULL(DWH_CIN_ID,0)
	JOIN	(select * from Collect.TestRunHistory with(nolock) where TRH_TRS_ID = 3)TestRunHistory on TRH_ID = CRS_TRH_ID
	JOIN	collect.Tests on TST_ID = TRH_TST_ID
	JOIN	PerformanceData.Metrics on C_MTR_ID = MTR_ID
	LEFT JOIN	PerformanceData.MetricConversions ON MTR_ConversionID = MCV_ConversionID AND CRS_Value BETWEEN MCV_Min AND MCV_Max
	LEFT join	PerformanceData.CounterResultStatuses on CRT_ID =  CRS_CRT_ID
	LEFT join PerformanceData.CounterInstances on CRS_InstanceID = CIN_ID
	
	where	CounterID =  @CounterId and SystemID =  @SystemId
	order by PerformanceData.CounterResults.CRS_DateTime desc
	'		

	print @cmd

	exec sp_executesql @CMD
	,N'	@CounterId			INT			
		,@SystemId			INT
		,@DUS_ID			INT
		,@ToDate			DATETIME2(3)'
	,@CounterId = @CounterId
	,@SystemId	= @SystemId
	,@DUS_ID	= @DUS_ID
	,@ToDate	= @ToDate

			
	

END
ELSE
BEGIN

	DECLARE @x XML 
	SELECT @x = CAST('<A>'+ REPLACE(@DCC_WidgetPermission,',','</A><A>')+ '</A>' AS XML)
	
	IF EXISTS (SELECT 1 FROM @x.nodes('/A') AS x(t)	WHERE	t.value('.', 'int') = @DWT_ID)
	BEGIN
		IF @DWT_ID = 1 AND @DCC_ID > 0 
		BEGIN
				SELECT 
						@CMD = 'exec '+ DCC_ProcedureName + ' ' + CAST(@DUS_ID AS NVARCHAR(32)) + ', ''' + cast(@FromDate as nvarchar(32)) + ''', ''' + cast(@ToDate as nvarchar(32)) + ''',' + IIF(DCC_Parameters IS NULL,'NULL','''' + CAST(DCC_Parameters AS NVARCHAR(MAX)) + '''')
				FROM	GUI.DashboardWidgetCustomQuery
				WHERE	DCC_ID = @DCC_ID
				
				exec	(@CMD)
				
		END
		ELSE

		IF @DCC_ID > 0
		BEGIN

				SELECT 
						@CMD = '
								CREATE TABLE #CQ
								(
									MOB_ID			INT
									,MOB_Name		NVARCHAR(255)
									,SystemID		INT
									,CounterID		INT
									,CounterName	NVARCHAR(255)
									,CRS_DateTime	DATETIME2(3)
									,CIN_Name		NVARCHAR(255)
									,CRT_Name		NVARCHAR(255)
									,CRS_Value		FLOAT
									,UFT_Name		NVARCHAR(255)
									,Per			INT
								)

								INSERT INTO #CQ
								exec '+ DCC_ProcedureName + ' ' + CAST(@DUS_ID AS NVARCHAR(32)) + ', ''' + cast(@FromDate as nvarchar(32)) + ''', ''' + cast(@ToDate as nvarchar(32)) + ''',' + IIF(DCC_Parameters IS NULL,'NULL','''' + CAST(DCC_Parameters AS NVARCHAR(MAX)) + '''')
				FROM	GUI.DashboardWidgetCustomQuery
				WHERE	DCC_ID = @DCC_ID

				--SET @CMD +=';WITH all_val as ( SELECT * FROM #CQ)
				SET @CMD += ' SELECT *,CRS_Value AS CRS_Value_Eth,UFT_Name AS UFT_Name_Eth FROM #CQ'
				--select @CMD
				exec (@CMD)
		END
	END
	ELSE
	BEGIN
	
		set @CMD = '
		;WITH all_val as (
		select 
				/*top 100 */
				MOB_ID
				,MOB_Name
				,SystemID
				,CounterID
				,CounterName
				,/*CONVERT(NVARCHAR(33),CRS_DateTime,126) as*/ CRS_DateTime
				,CIN_Name
				,CRT_Name
				,CRS_Value
				,CIN_ID
				,DATEDIFF(' /*+ case @InetrvalType when 'd' then D when 'm' then MI when 'h' then HH else YEAR end*/+@IntervalPeriod + ',CRS_DateTime,''' + cast(@ToDate as nvarchar(32)) + ''') / ' + cast(@IntervalTime as nvarchar(4)) + ' as Per
		from	PerformanceData.CounterResults
		JOIN	PerformanceData.VW_Counters on CRS_SystemID = SystemID and CRS_CounterID = CounterID
		JOIN	Inventory.MonitoredObjects on CRS_MOB_ID = MOB_ID
		JOIN	GUI.DashboradWidgetHostsInstances on MOB_ID = DWH_MOB_ID AND DWH_DUS_ID = ' + cast(@DUS_ID as nvarchar(10)) + ' and ISNULL(CRS_InstanceID,0) = ISNULL(DWH_CIN_ID,0)
		JOIN	Collect.TestRunHistory on TRH_ID = CRS_TRH_ID
		JOIN	collect.Tests on TST_ID = TRH_TST_ID
		
		LEFT join	PerformanceData.CounterResultStatuses on CRT_ID =  CRS_CRT_ID
		LEFT join PerformanceData.CounterInstances on CRS_InstanceID = CIN_ID
		
		where	CounterID =  ' + cast(@CounterId  as nvarchar(10)) + 'and SystemID =  ' + cast(@SystemId  as nvarchar(10)) + '
				and TRH_TRS_ID = 3
				and CRS_DateTime >= ISNULL(''' + cast(@Fromdate as nvarchar(32)) + ''',cast(''19700101'' as datetime2))
				and CRS_DateTime < ''' + cast(@ToDate as nvarchar(32)) + '''' + 
		--		+ case when @CIN_ID IS NULL then '' else 'and CIN_ID = ' + cast(@CIN_ID as nvarchar(10)) end + '
		/*order by MOB_ID,CRS_DateTime*/
		')'

	SET @CMD += ', grp_val as (SELECT 

			MOB_ID
			,MOB_Name
			,SystemID AS CRS_SystemID
			,CounterID as CRS_CounterId
			,CounterName
			,DATEADD(' + @IntervalPeriod + ',-Per * ' + cast(@IntervalTime as nvarchar(4)) + ',''' + cast(@ToDate as nvarchar(32)) + ''') as CRS_DateTime
			,' + cast(@IntervalTime as nvarchar(4)) + ' as TST_IntervalType
			,''' + @IntervalPeriod + ''' as TST_IntervalPeriod
			,CIN_Name
			,CIN_ID
			,CRT_Name
			,' + @CalcValType + '(CRS_Value) as CRS_Value
			
			
	FROM	all_val
	GROUP BY 
			MOB_ID
			,MOB_Name
			,SystemID
			,CounterID
			,CounterName
			,DATEADD(' + @IntervalPeriod + ',-Per * ' + cast(@IntervalTime as nvarchar(4)) + ',''' + cast(@ToDate as nvarchar(32)) + ''')
			,CIN_Name
			,CRT_Name
			,CIN_ID
			
		)
		select
				IIF(CIN_NAME IS NOT NULL,CAST(MOB_ID AS NVARCHAR(10)) + ''_'' + CAST(CIN_ID AS NVARCHAR(10)),CAST(MOB_ID AS NVARCHAR(10))) AS MOB_ID
				,IIF(CIN_NAME IS NOT NULL,MOB_Name + '' ['' + CIN_Name + '']'',MOB_Name) AS MOB_Name
				,SystemID
				,CounterID
				,v.CounterName + IIF(MTR_ID = 1,'''',''('' + MTR_NameUp + IIF(MTR_NameDown = '''','''',''/'' + MTR_NameDown) + '')'') AS CounterName
				,CRS_DateTime
				,CIN_Name
				,CRT_Name
				,CAST(ROUND(CRS_Value / ISNULL(MCV_Factor,1),5) AS DECIMAL(30,5)) AS CRS_Value
				,CRS_Value AS CRS_Value_Eth
				,ISNULL(MCV_Prefix,'''') + MTR_VNameUp + IIF(MTR_VNameDown = '''','''',''/'' + MTR_VNameDown) /*ISNULL(MCV_Target,MetricUp) + IIF(MCV_Target='''','''',ISNULL(''/'' + MetricDown,''''))*/ as UFT_Name
				,MTR_NameUp + IIF(MTR_NameDown = '''','''',''/'' + MTR_NameDown) /*ISNULL(''/'' + MetricDown,'''')*/ as UFT_Name_Eth
		from	grp_val v
		JOIN	PerformanceData.VW_Counters on CRS_SystemID = SystemID and CRS_CounterID = CounterID
		JOIN	PerformanceData.Metrics on C_MTR_ID = MTR_ID
		LEFT JOIN	PerformanceData.MetricConversions ON MTR_ConversionID = MCV_ConversionID AND CRS_Value BETWEEN MCV_Min AND MCV_Max


	'
	print @cmd
	exec (@cmd)
	END
END
GO
