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
/****** Object:  StoredProcedure [Consolidation].[usp_GenerateDTUCalculatorInputFiles]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Consolidation].[usp_GenerateDTUCalculatorInputFiles]
	@OutputPath varchar(1000) = 'C:\Temp\AzureCalculatorData'
as
set nocount on

declare @MOB_ID int,
		@ServerName nvarchar(128),
		@Cores int,
		@SQL nvarchar(max),
		@FirstDate datetime2(3),
		@FileName varchar(1000),
		@CMD varchar(2000),
		@IsXPCMDShellOn bit,
		@IsShowAdvancedOptionsOn bit,
		@TempFolder varchar(500)
exec master..xp_regread	@rootkey='HKEY_CURRENT_USER',
						@key='Environment',
						@value_name='TEMP',
						@value= @TempFolder output

if OBJECT_ID('tempdb..#Counters') is not null
	drop table #Counters
if OBJECT_ID('tempdb..#PerformanceData') is not null
	drop table #PerformanceData
if OBJECT_ID('tempdb..#Input') is not null
	drop table #Input
if OBJECT_ID('TempData.ExportResults') is not null
	drop table TempData.ExportResults
if OBJECT_ID('tempdb..#ColumnNames') is not null
	drop table #ColumnNames
if OBJECT_ID('tempdb..#Results') is not null
	drop table #Results

truncate table DTUCalculator.TextData
truncate table DTUCalculator.PieChart
truncate table DTUCalculator.PieChart
truncate table DTUCalculator.DTUGraph

select @IsXPCMDShellOn = cast(value_in_use as bit)
from sys.configurations
where name = 'xp_cmdshell'

if @IsXPCMDShellOn = 0
begin
	select @IsShowAdvancedOptionsOn = cast(value_in_use as bit)
	from sys.configurations
	where name = 'show advanced options'

	if @IsShowAdvancedOptionsOn = 0
	begin
		exec sp_configure 'show advanced options', 1
		reconfigure with override
	end
	exec sp_configure 'xp_cmdshell', 1
	reconfigure with override
end

set @CMD = 'md ' + @OutputPath
exec xp_cmdshell @CMD, no_output

set @CMD = 'del /Q ' + @OutputPath + '\.'
exec xp_cmdshell @CMD, no_output

set @CMD = 'md ' + @OutputPath + '\Done'
exec xp_cmdshell @CMD, no_output

set @CMD = 'del /Q ' + @OutputPath + '\Done\.'
exec xp_cmdshell @CMD, no_output

create table #Results(ServerName nvarchar(128),
						Line varchar(1000))

select PEC_ID, PEC_CSY_ID, PEC_CategoryName, PEC_CounterName
into #Counters
from PerformanceData.PerformanceCounters
where (PEC_CategoryName = 'Processor' and PEC_CounterName = '% Processor Time')
	or (PEC_CategoryName = 'LogicalDisk' and PEC_CounterName = 'Disk Reads/sec')
	or (PEC_CategoryName = 'LogicalDisk' and PEC_CounterName = 'Disk Writes/sec')
	or (PEC_CategoryName = 'Databases' and PEC_CounterName = 'Log Bytes Flushed/sec')

select @FirstDate = min(TRH_StartDate)
from Collect.TestRunHistory
where TRH_TST_ID = 101
	and TRH_TRS_ID = 3

declare cServers cursor static forward_only for
	select distinct MOB_ID, MOB_Name, Cores
	from Consolidation.ParticipatingDatabaseServers
		inner join Inventory.MonitoredObjects on MOB_ID = PDS_Server_MOB_ID
		cross apply (select sum(coalesce(PRS_NumberOfLogicalProcessors, PRS_NumberOfCores, 1)) Cores
				from Inventory.Processors
				where PRS_MOB_ID = MOB_ID) p
	where Cores is not null
		and PDS_Database_MOB_ID is not null

open cServers
fetch next from cServers into @MOB_ID, @ServerName, @Cores
while @@FETCH_STATUS = 0
begin
	select cast(convert(char(14), CRS_DateTime, 121) + '00' as datetime) DT, PEC_ID CounterID, CRS_InstanceID InstanceID, avg(CRS_Value) Value --iif(PEC_ID = 1, avg(CRS_Value)/@Cores, avg(CRS_Value)) Value
	into #PerformanceData
	from PerformanceData.CounterResults
		inner join #Counters on PEC_CSY_ID = CRS_SystemID
								and PEC_ID = CRS_CounterID
	where CRS_MOB_ID = @MOB_ID
		and PEC_CSY_ID = 4
		and CRS_DateTime > @FirstDate
	group by cast(convert(char(14), CRS_DateTime, 121) + '00' as datetime), PEC_ID, CRS_InstanceID
	union
	select cast(convert(char(14), CRS_DateTime, 121) + '00' as datetime), PEC_ID, CRS_InstanceID, avg(CRS_Value)/1000
	from PerformanceData.CounterResults
		inner join Consolidation.ParticipatingDatabaseServers on PDS_Database_MOB_ID = CRS_MOB_ID
		inner join #Counters on PEC_CSY_ID = CRS_SystemID
								and PEC_ID = CRS_CounterID
	where PDS_Server_MOB_ID = @MOB_ID
		and PEC_CSY_ID = 1
	group by cast(convert(char(14), CRS_DateTime, 121) + '00' as datetime),  PEC_ID, CRS_InstanceID
	
	select DT, concat('\\', MOB_Name, '\', iif(PEC_CSY_ID = 1, 'SQLServer:', ''), PEC_CategoryName, '(', rtrim(CIN_Name), ')\', PEC_CounterName) CounterName, Value
	into #Input
	from #PerformanceData
		inner join Inventory.MonitoredObjects on MOB_ID = @MOB_ID
		inner join #Counters on PEC_ID = CounterID
		inner join PerformanceData.CounterInstances on CIN_ID = InstanceID

	select distinct CounterName
	into #ColumnNames
	from #Input
	order by CounterName

	set @SQL = 'select ''(PDH-CSV 4.0) (Pacific Daylight Time)(420)''' + quotename('(PDH-CSV 4.0) (Pacific Daylight Time)(420)')
		+ (select ',''' + CounterName + '''' + quotename(CounterName)
			from #ColumnNames
			order by CounterName
			for xml path('')) + '
		into TempData.ExportResults
		union all
		select convert(char(19), DT, 121) [(PDH-CSV 4.0) (Pacific Daylight Time)(420)]'
		+ (select ', cast(isnull(' + quotename(CounterName) + ', 0) as varchar(1000)) ' + quotename(CounterName)
			from #ColumnNames
			order by CounterName
			for xml path('')) + '
		from #Input
		pivot 
			(avg(Value) for CounterName in (' + stuff((select ',' + quotename(CounterName)
														from #ColumnNames
														order by 1
														for xml path('')), 1, 1, '') + ')) p'
	exec(@SQL)

	set @FileName = concat(@OutputPath, iif(@OutputPath like '%\', '', '\'), @ServerName, '^', @Cores, '.csv')

	set @CMD = concat('BCP "select * from ', db_name(), '.TempData.ExportResults" queryout "', @FileName, '" -S ', @@SERVERNAME, ' -T -c -t,')

	insert #Results(Line)
	exec xp_cmdshell @CMD

	update #Results
	set ServerName = @ServerName
	where ServerName is null

	drop table #Input
	drop table #PerformanceData
	if object_id('TempData.ExportResults') is not null
		drop table TempData.ExportResults
	drop table #ColumnNames

	fetch next from cServers into @MOB_ID, @ServerName, @Cores
end
close cServers
deallocate cServers

if @IsXPCMDShellOn = 0
begin
	exec sp_configure 'xp_cmdshell', 0
	reconfigure with override

	if @IsShowAdvancedOptionsOn = 0
	begin
		exec sp_configure 'show advanced options', 0
		reconfigure with override
	end
end
GO
