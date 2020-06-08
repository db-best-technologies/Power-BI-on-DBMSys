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
/****** Object:  StoredProcedure [GUI].[usp_GetPerformanceCounters]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUI].[usp_GetPerformanceCounters]
AS
;with cat as 
(
	select distinct CategoryName from PerformanceData.VW_Counters
)
select 
		CSY_ID
		,CSY_Name
		,CatID
		,CategoryName
		,CounterID
		,CounterName
		,IIF(ASCII(C_MTR_ID)=2,1,0) AS IsPercent
from	PerformanceData.VW_Counters
join	PerformanceData.CounterSystems on SystemID = CSY_ID
join	(select ROW_NUMBER() over(order by CategoryName) + 1000 as CatID,CategoryName as CatName from cat) t on CategoryName = CatName
order by CSY_Name, CategoryName, CounterName
GO
