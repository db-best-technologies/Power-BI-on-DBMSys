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
/****** Object:  StoredProcedure [Reports].[usp_CounterGraph]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_CounterGraph]
	@StartDate datetime2(3),
	@EndDate datetime2(3),
	@ServerList nvarchar(max),
	@SystemList nvarchar(max),
	@CounterList nvarchar(max),
	@InstanceList nvarchar(max),
	@DatabaseList nvarchar(max),
	@AggregationType varchar(10),
	@Resolution varchar(10)
with execute as owner
as
set nocount on
declare @SQL nvarchar(max)

if object_id('tempdb..#Servers') is not null
	drop table #Servers
if object_id('tempdb..#Systems') is not null
	drop table #Systems
if object_id('tempdb..#Counters') is not null
	drop table #Counters
if object_id('tempdb..#Instances') is not null
	drop table #Instances
if object_id('tempdb..#Databases') is not null
	drop table #Databases

create table #Servers(ServerID int)
create table #Systems(SystemID int)
create table #Counters(CounterID int)
create table #Instances(InstanceID int)
create table #Databases(DatabaseName nvarchar(128))

insert into #Servers
select Val
from Infra.fn_SplitString(@ServerList, ',')

insert into #Systems
select Val
from Infra.fn_SplitString(@SystemList, ',')

insert into #Counters
select Val
from Infra.fn_SplitString(@CounterList, ',')

insert into #Instances
select Val
from Infra.fn_SplitString(@InstanceList, ',')

insert into #Databases
select Val
from Infra.fn_SplitString(@DatabaseList, ',')

set @SQL =
'set transaction isolation level read uncommitted
select SnapshotDate [Date], ''('' + ServerName + '')'' + DisplayCounterName [Counter], '
	+ case @AggregationType
			when 'Min' then 'MinValue'
			when 'Avg' then 'AvgValue'
			when 'Max' then 'MaxValue'
			when 'Sum' then 'SumValue'
		end + ' Value' + char(13)+char(10)
	+ 'from '
	+ case @Resolution
			when 'Hourly' then 'PerformanceData.fn_CounterResults_Hourly'
			when 'Daily' then 'PerformanceData.fn_CounterResults_Daily'
		end + '(@StartDate, @EndDate) r ' + char(13)+char(10)
+ 'where exists (select * from #Servers where ServerID = CRS_MOB_ID)
	and exists (select * from #Systems where SystemID = CRS_SystemID)
	and exists (select * from #Counters where CounterID = CRS_CounterID)'
	+ case when @InstanceList <> '0' then char(13)+char(10)+char(9) + 'and exists (select * from #Instances where InstanceID = CRS_InstanceID)'
			else ''
		end
	+ case when @DatabaseList <> '' then char(13)+char(10)+char(9) + 'and exists (select * from #Databases d where d.DatabaseName = r.DatabaseName)'
			else ''
		end

exec sp_executesql @SQL,
					N'@StartDate datetime2(3),
						@EndDate datetime2(3)',
					@StartDate = @StartDate,
					@EndDate = @EndDate
GO
