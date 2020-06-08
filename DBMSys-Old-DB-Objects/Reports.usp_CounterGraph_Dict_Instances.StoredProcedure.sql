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
/****** Object:  StoredProcedure [Reports].[usp_CounterGraph_Dict_Instances]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_CounterGraph_Dict_Instances]
	@ServerList nvarchar(max) = null,
	@SystemList nvarchar(max) = null,
	@CounterList nvarchar(max) = null
as
set nocount on
declare @Servers table(ServerID int)
declare @Systems table(SystemID int)
declare @Counters table(CounterID int)

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

insert into @Counters
select Val
from Infra.fn_SplitString(@CounterList, ',')
union all
select cast(null as nvarchar(128))

select distinct CIN_ID InstanceID, CIN_Name InstanceName
from PerformanceData.CounterCombinations
	inner join @Servers on CCB_MOB_ID = ServerID
							or @ServerList is null
	inner join @Systems on CCB_CSY_ID = SystemID
							or @SystemList is null
	inner join @Counters on CCB_CounterID = CounterID
							or @CounterList is null
	inner join PerformanceData.CounterInstances on CIN_ID = CCB_CIN_ID
union all
select 0, ''
order by InstanceName
GO
