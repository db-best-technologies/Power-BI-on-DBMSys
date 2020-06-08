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
/****** Object:  StoredProcedure [RuleChecks].[usp_StaleStatistic]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_StaleStatistic]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted
declare @LowerValue decimal(18, 5),
		@UpperValue decimal(18, 5),
		@LastDate datetime

set @LastDate = RuleChecks.fn_GetLastDate()

select @LowerValue = RTH_LowerValue,
	@UpperValue = RTH_UpperValue
from BusinessLogic.RuleThresholds
where RTH_ID = @RTH_ID

select @ClientID, @PRR_ID, IDB_MOB_ID, IDB_ID, IDB_Name, DOT_DisplayName, DSN_Name, DON_Name, DTN_ID, SAS_RowCount, datediff(day, SAS_StatisticsUpdateDate, @LastDate), SAS_ModifyCount,
	case when SAS_IsIndex = 0
		then 'Yes'
		else 'No'
	end,
	case when SAS_IsAutoCreated = 0
		then 'Yes'
		else 'No'
	end,
	case when SAS_IsNoRecompute = 0
		then 'Yes'
		else 'No'
	end,
	case when SAS_HasFilter = 0
		then 'Yes'
		else 'No'
	end
from Inventory.StaleStatistics
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = SAS_MOB_ID
	inner join Inventory.InstanceDatabases on IDB_ID = SAS_IDB_ID
	inner join Inventory.DatabaseObjectTypes on DOT_ID = SAS_DOT_ID
	inner join Inventory.DatabaseSchemaNames on DSN_ID = SAS_DSN_ID
	inner join Inventory.DatabaseObjectNames on DON_ID = SAS_DON_ID
	inner join Inventory.DatabaseStatisticsNames on DTN_ID = SAS_DTN_ID
where (@UpperValue is not null
		and SAS_StatisticsUpdateDate >= dateadd(day, -@UpperValue, @LastDate))
	and (@LowerValue is not null
		and SAS_StatisticsUpdateDate <= dateadd(day, -@LowerValue, @LastDate))
GO
