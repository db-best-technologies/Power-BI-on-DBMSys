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
/****** Object:  StoredProcedure [Reports].[usp_InstallationAgeBreakdownFacts]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_InstallationAgeBreakdownFacts]
as
set nocount on

;with Input as
		(select OSS_InstallDate, PLY_Name, PLY_ReleaseDate, NextReleaseDate, count(*) over() TotalCount
			from Inventory.MonitoredObjects
				inner join Inventory.Versions on VER_ID = MOB_VER_ID
				inner join Inventory.OSServers on OSS_MOB_ID = MOB_ID
				cross apply (select top 1 *
								from ExternalData.ProductLifeCycles
								where PLY_MinVersionNumber < VER_Number
								order by PLY_MinVersionNumber desc) v
				outer apply (select top 1 PLY_ReleaseDate NextReleaseDate
								from ExternalData.ProductLifeCycles vn
								where PLY_MinVersionNumber > VER_Number
									and PLY_ExtendedSupportEndDate > v.PLY_ExtendedSupportEndDate
								order by PLY_MinVersionNumber) vn
			where exists (select *
							from Consolidation.ParticipatingDatabaseServers
							where PDS_Server_MOB_ID = MOB_ID)
				and exists (select *
							from Management.PlatformTypes
							where PLT_ID = MOB_PLT_ID
								and PLT_PLC_ID = 2)
		)
	, AgeAgg as
		(select Num Age, count(*) Cnt, count(*)*100/isnull(nullif(TotalCount, 0), 1) Percentage, row_number() over(order by Num desc) AgeRank
			from Input
				inner join (select Num
								from Infra.Numbers
								where Num between 3 and 10) n on datediff(year, OSS_InstallDate, sysdatetime()) > Num
			group by Num, TotalCount
			having count(*)*100/isnull(nullif(TotalCount, 0), 1) > 0
		)
	, AgeResults as
		(select *, count(*) over() TotalCount
			from AgeAgg)
	, AgeFinal as
		(select *
			from AgeResults
			where AgeRank = 1
			union
			select *
			from (select top 1 *
					from AgeResults
					where AgeRank <= TotalCount/2
						or Age = 5
					order by AgeRank desc
				) t
		)
	, AgeFacts as
		(select top 3 concat(Percentage, '% (', format(Cnt, '##,##0'), ') of installations are older than ', Age, ' years') Fact, 1 Rnk
			from AgeFinal
			order by AgeRank desc
		)
	, InstallVersionFacts as
		(select top 1 'Some new installations of old operating systems' Fact, 2 Rnk
			from Input
			where OSS_InstallDate >= dateadd(year, 2, NextReleaseDate)
			union
			select *
			from (select top 3 concat('^', count(*), ' ', PLY_Name, ' server(s) were installed since ', datepart(year, min(OSS_InstallDate))) Fact, 3 Rnk
					from Input
					where OSS_InstallDate >= dateadd(year, 2, NextReleaseDate)
					group by PLY_Name, PLY_ReleaseDate
					order by PLY_ReleaseDate
				) t
		)
select top 15 Fact
from (select *
		from AgeFacts
		union all
		select *
		from InstallVersionFacts
	) t
order by Rnk
GO
