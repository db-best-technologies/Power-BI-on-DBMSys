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
/****** Object:  StoredProcedure [PresentationManagement].[usp_CreateColumnNamelessTable]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [PresentationManagement].[usp_CreateColumnNamelessTable]
	@PRN_ID int,
	@Code varchar(100),
	@InputQuery nvarchar(max)
as
set nocount on
declare @SQL nvarchar(max)

if object_id('tempdb..#Input') is not null
	drop table #Input

if object_id('tempdb..#PivotInput') is not null
	drop table #PivotInput

create table #Input
	(Value varchar(max))

insert into #Input
exec sp_executesql @InputQuery,
				N'@PRN_ID int,
					@Code varchar(100)',
				@PRN_ID = @PRN_ID,
				@Code = @Code

select c.Id ColumnID, r.Id RowID, r.Val Value
into #PivotInput
from #Input
	cross apply Infra.fn_SplitString(Value, ';') c
	cross apply Infra.fn_SplitString(c.Val, ',') r

set @SQL =
'select ' + stuff((select distinct ', ' + quotename(ColumnID) + ' + '''''
					from #PivotInput
					order by 1
					for xml path('')), 1, 2, '') + '
from #PivotInput
	pivot (max(Value) for ColumnID IN (' + stuff((select distinct ', ' + quotename(ColumnID)
					from #PivotInput
					order by 1
					for xml path('')), 1, 2, '') + ')) pvt
order by RowID'

exec(@SQL)
GO
