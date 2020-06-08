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
/****** Object:  View [PerformanceData].[VW_Counters]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [PerformanceData].[VW_Counters]
as
select PEC_CSY_ID SystemID, PEC_ID CounterID, PEC_CategoryName CategoryName, PEC_CounterName CounterName, cast(0 as bit) IsAggregative,
		PEC_IgnoreIfValueIsOrUnder IgnoreIfValueIsOrUnder, PEC_PCG_ID PerformanceGroupID,PEC_MTR_ID AS C_MTR_ID--PEC_MetricUp AS MetricUp,PEC_MetricDown AS MetricDown
		,PEC_IgnoreIfValueIsOrAbove AS IgnoreIfValueIsOrAbove
from PerformanceData.PerformanceCounters
where PEC_IsActive = 1
union all
select GNC_CSY_ID SystemID, GNC_ID CounterID, GNC_CategoryName CategoryName, GNC_CounterName CounterName, GNC_IsAggregative IsAggregative,
		GNC_IgnoreIfValueIsOrUnder IgnoreIfValueIsOrUnder, GNC_PCG_ID PerformanceGroupID,GNC_MTR_ID AS C_MTR_ID--,GNC_MetricUp AS MetricUp,GNC_MetricDown AS MetricDown
		,GNC_IgnoreIfValueIsOrAbove AS IgnoreIfValueIsOrAbove
from PerformanceData.GeneralCounters
union all
select IPC_CSY_ID SystemID, IPC_ID CounterID, IPC_CategoryName CategoryName, IPC_CounterName CounterName, IPC_IsAggregative IsAggregative,
		IPC_IgnoreIfValueIsOrUnder IgnoreIfValueIsOrUnder, CAST(null as tinyint) PerformanceGroupID,IPC_MTR_ID AS C_MTR_ID--,IPC_MetricUp AS MetricUp,IPC_MetricDown AS MetricDown
		,IPC_IgnoreIfValueIsOrAbove AS IgnoreIfValueIsOrAbove
from PerformanceData.InternalPerformanceCounters
GO
