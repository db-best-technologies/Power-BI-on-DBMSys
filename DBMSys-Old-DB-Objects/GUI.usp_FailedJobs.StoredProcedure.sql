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
/****** Object:  StoredProcedure [GUI].[usp_FailedJobs]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [GUI].[usp_FailedJobs]
	@DUS_ID				INT	
	,@FromDate			DATETIME2(3)
	,@ToDate			DATETIME2(3)
	,@Param				XML NULL
	
AS
	DECLARE @IntervalTime		INT				
			,@IntervalPeriod	NVARCHAR(4)	
	SELECT 
			@IntervalPeriod = DUS_IntervalPeriod
			,@IntervalTime = DUS_IntervalTime
	FROM	GUI.DashboardWidgetsUserSettings
	WHERE	DUS_ID = @DUS_ID

	IF @IntervalPeriod = 'h'
	SET @IntervalPeriod = 'hh'

	DECLARE @PRM_STR NVARCHAR(max) = ''
	IF @Param IS NOT NULL
		
		SELECT @PRM_STR = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ISNULL((
		SELECT	 
				' and ' + 
				c.value('@Name', 'varchar(32)') + ' ' +	
				c.value('@Operator', 'varchar(32)') + ' ' 
				 + '''' + c.value('@Value', 'varchar(32)') + ''''
		FROM	@Param.nodes('/Info/Item') t(c)
		for xml path('')), ''),'&amp;','&'),'&lt;','<'),'&gt;','>'),'&apos;',' '),'&quot;','"')


	DECLARE @CMD NVARCHAR(MAX) = ''
	SET @CMD = '
				SELECT 
						MOB_ID
						,MOB_Name
						,NULL AS SystemID
						,NULL AS CounterID
						,NULL AS CounterName
						,FLJ_LastFailureDate AS CRS_DateTime
						,NULL AS CIN_Name
						,''Successful'' AS CRT_Name
						,1 AS CRS_Value
						,''COUNT'' AS UFT_Name
						,DATEDIFF(' /*+ case @InetrvalType when 'd' then D when 'm' then MI when 'h' then HH else YEAR end*/+@IntervalPeriod + ',FLJ_LastFailureDate,''' + cast(@ToDate as nvarchar(32)) + ''') / ' + cast(@IntervalTime as nvarchar(4)) + ' as Per
			
				FROM	Activity.FailedJobs
				JOIN	Inventory.MonitoredObjects on MOB_ID = FLJ_MOB_ID
				JOIN	GUI.DashboradWidgetHostsInstances on MOB_ID = DWH_MOB_ID and DWH_DUS_ID = @DUS_ID
				
				WHERE	FLJ_LastFailureDate>=''' + cast(@FromDate as nvarchar(32)) + '''
						AND FLJ_LastFailureDate < ''' + cast(@ToDate as nvarchar(32)) + '''
				
				' + @PRM_STR
				


	print @cmd
	exec sp_executesql @CMD
	,N'	@DUS_ID			INT'
	,@DUS_ID	= @DUS_ID
GO
