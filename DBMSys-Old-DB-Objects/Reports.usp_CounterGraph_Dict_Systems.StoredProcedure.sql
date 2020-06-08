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
/****** Object:  StoredProcedure [Reports].[usp_CounterGraph_Dict_Systems]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_CounterGraph_Dict_Systems]
	@ServerList nvarchar(max) = null
as
set nocount on
declare @Servers table(ServerID int)

insert into @Servers
select Val
from Infra.fn_SplitString(@ServerList, ',')
union all
select cast(null as nvarchar(128))

select distinct CSY_ID SystemID, CSY_Name SystemName
from PerformanceData.CounterCombinations
	inner join @Servers on CCB_MOB_ID = ServerID
							or @ServerList is null
	inner join PerformanceData.CounterSystems on CSY_ID = CCB_CSY_ID
union all
select cast(null as int), ''
order by SystemName
GO
