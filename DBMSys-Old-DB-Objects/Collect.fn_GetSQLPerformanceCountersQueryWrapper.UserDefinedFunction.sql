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
/****** Object:  UserDefinedFunction [Collect].[fn_GetSQLPerformanceCountersQueryWrapper]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Collect].[fn_GetSQLPerformanceCountersQueryWrapper](@TST_ID int,
																@MOB_ID int,
																@Command nvarchar(max)) returns nvarchar(max)
as
begin
declare @cmd nvarchar(max) =
'declare @WaitTime char(8)
set @WaitTime = ''00:00:05''
set nocount on
set transaction isolation level read uncommitted

declare @PerformanceCounters table(ID int not null identity,
									Category nvarchar(128) not null,
									[Counter] nvarchar(128) not null)
declare @FirstCollection table(ID int not null,
								Instance nvarchar(128) null,
								cntr_value bigint null,
								CollectionTime datetime not null)
declare @SecondCollection table(ID int not null,
								Instance nvarchar(128) null,
								cntr_value bigint null,
								CollectionTime datetime not null)
' + Collect.fn_GetSQLPerformanceCountersQuery(@TST_ID) + '

insert into @FirstCollection(ID, Instance, cntr_value, CollectionTime)
select ID, instance_name, cntr_value, GETDATE() CollectionTime
from master.dbo.sysperfinfo
	inner join @PerformanceCounters on object_name collate database_default like ''%:'' + Category + ''%'' collate database_default
											and rtrim(counter_name) collate database_default = [Counter] collate database_default
where cntr_type in (272696576, 272696320)

if @@ROWCOUNT > 0
	waitfor delay @WaitTime

insert into @SecondCollection(ID, Instance, cntr_value, CollectionTime)
select ID, instance_name, cntr_value, GETDATE() CollectionTime
from master.dbo.sysperfinfo
	inner join @PerformanceCounters on object_name like ''%:'' collate database_default + Category + ''%'' collate database_default
											and rtrim(counter_name) collate database_default = [Counter] collate database_default
where cntr_type in (272696576, 65792, 272696320, 65536)

select P.Category, P.[Counter], S.Instance,
	case when F.ID is null
		then S.cntr_value
		else (S.cntr_value - F.cntr_value)/datediff(second, F.CollectionTime, S.CollectionTime)
	end Value
from @PerformanceCounters P
	inner join @SecondCollection S on P.ID = S.ID
	left join @FirstCollection F on S.ID = F.ID
									and (S.Instance = F.Instance
											or (S.Instance is null
												and F.Instance is null))'
	return @cmd
end
GO
