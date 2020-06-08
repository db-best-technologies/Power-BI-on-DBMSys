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
/****** Object:  StoredProcedure [PresentationManagement].[usp_FormatPieChart]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [PresentationManagement].[usp_FormatPieChart]
	@PRN_ID int,
	@Code varchar(100),
	@InputQuery nvarchar(max)
as
set nocount on

if object_id('tempdb..#Input') is not null
	drop table #Input
create table #Input
	(MOB_ID int,
	Caption varchar(1000))

insert into #Input
exec sp_executesql @InputQuery,
				N'@PRN_ID int,
					@Code varchar(100)',
				@PRN_ID = @PRN_ID,
				@Code = @Code

select [Caption], count(*) [Count], cast(count(*)*100./sum(count(*)) over() as decimal(15, 1)) [Percentage]
from #Input Input
where exists (select *
				from Consolidation.ParticipatingDatabaseServers
				where PDS_Server_MOB_ID = MOB_ID
					or PDS_Database_MOB_ID = MOB_ID)
group by [Caption]
order by [Caption]
GO
