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
/****** Object:  StoredProcedure [CapacityPlanningWizard].[usp_GetReportList]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [CapacityPlanningWizard].[usp_GetReportList]
as
if object_id('tempdb..#Reports') is not null
	drop table #Reports

declare @ID int,
		@DependencyQuery nvarchar(max),
		@SQL nvarchar(max),
		@Result bit

create table #Reports
	(ID int,
	DependencyQuery nvarchar(max),
	IsEnabled bit)

insert into #Reports
select RPT_ID, RPT_DependencyQuery, 0
from CapacityPlanningWizard.Reports
where RPT_IsActive = 1

declare cReports cursor static forward_only for
	select ID, DependencyQuery
	from #Reports

open cReports

fetch next from cReports into @ID, @DependencyQuery
while @@FETCH_STATUS = 0
begin
	if @DependencyQuery is not null
	begin
		set @Result = 0
		set @SQL = 'if exists (' + replace(@DependencyQuery, '''', '''''') + ') set @Result = 1'
		exec sp_executesql @SQL,
							N'@Result bit output',
							@Result = @Result output
	end
	else
		set @Result = 1

	update #Reports
	set IsEnabled = @Result
	where ID = @ID
		and @Result = 1
	fetch next from cReports into @ID, @DependencyQuery
end
close cReports
deallocate cReports

select RPT_Ordinal Ordinal, RPT_Name [Report Name], RPT_Description [Description], RPT_ProcedureName [Procedure Name], RPT_ShowType [Show Type], IsEnabled [Is Enabled]
from #Reports
	inner join CapacityPlanningWizard.Reports on RPT_ID = ID
GO
