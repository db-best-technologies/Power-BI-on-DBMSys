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
/****** Object:  StoredProcedure [Reports].[usp_CounterGraph_Dict_Counters]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_CounterGraph_Dict_Counters]
	@ServerList nvarchar(max) = null,
	@SystemList nvarchar(max) = null
as
set nocount on
declare @Servers table(ServerID int)
declare @Systems table(SystemID int)

insert into @Servers
select Val
from Infra.fn_SplitString(@ServerList, ',')
union all
select cast(null as nvarchar(128))

insert into @Systems
select Val
from Infra.fn_SplitString(@SystemList, ',')
union all
select cast(null as nvarchar(128))

select distinct CounterID CounterID, CategoryName + '\' + CounterName CounterName
from PerformanceData.CounterCombinations
	inner join @Servers on CCB_MOB_ID = ServerID
							or @ServerList is null
	inner join @Systems s on CCB_CSY_ID = SystemID
							or @SystemList is null
	inner join PerformanceData.VW_Counters c on c.SystemID = CCB_CSY_ID
order by CounterName
GO
