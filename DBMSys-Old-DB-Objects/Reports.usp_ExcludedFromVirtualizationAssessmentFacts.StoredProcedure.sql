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
/****** Object:  StoredProcedure [Reports].[usp_ExcludedFromVirtualizationAssessmentFacts]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_ExcludedFromVirtualizationAssessmentFacts]
as
set nocount on

;with Facts as
		(select concat(sum(cast(LBL_IsVM as int))*100/count(*), '% (', format(count(*), '##,##0'), ') of the servers are already virtual and were not considered for re-virtualization') Fact, 1 Rnk
			from Consolidation.LoadBlocks
				cross join (select cast(SET_Value as bit) ExcludeVirtual
								from Management.Settings
								where SET_Module = 'Consolidation'
									and SET_Key = 'Virtualization - Exclude Currently Virtualized') s
			where exists (select *
							from Consolidation.ServerPossibleHostTypes
							where SHT_MOB_ID = LBL_MOB_ID
								and SHT_HST_ID = 4)
				and ExcludeVirtual = 1
			having sum(cast(LBL_IsVM as int)) > 0
			union
			select concat(count(*)*100/isnull(nullif(TotalServerCount, 0), 1), '% (', format(count(*), '##,##0'), ') of the servers cannot be virtualized because the virtualization host''s ', Issue, '*') Fact, 2 Rnk
			from (select 'CPU is not strong enough' Issue
					from Consolidation.Exceptions
					where EXP_EXT_ID = 2
						and EXP_Reason like '%Number of cores%'
					union all
					select concat('memory (', format(VES_MemoryMB/1024, '##,##0'), 'GB RAM) is insufficient') Issue
					from Consolidation.Exceptions
						cross join Consolidation.VirtualizationESXServers
					where EXP_EXT_ID = 2
						and EXP_Reason like '%Memory required%'
					union all
					select concat('network speed (', format(VES_NetworkSpeedMbit/1024, '##,##0'), 'Gbit) network speed is insufficient') Issue
					from Consolidation.Exceptions
						cross join Consolidation.VirtualizationESXServers
					where EXP_EXT_ID = 2
						and EXP_Reason like '%Network speed%'
				) e
				cross join (select count(*) TotalServerCount
								from Consolidation.LoadBlocks
								where exists (select *
												from Consolidation.ServerPossibleHostTypes
												where SHT_MOB_ID = LBL_MOB_ID
													and SHT_HST_ID = 4)
							) l
			group by Issue, TotalServerCount
		)
select Fact
from Facts
order by Rnk
GO
