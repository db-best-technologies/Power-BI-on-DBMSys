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
/****** Object:  StoredProcedure [Reports].[usp_ExcludedFromAzureAssessmentFacts]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_ExcludedFromAzureAssessmentFacts]
as
set nocount on

;With ExpAgg as
		(select max(EXP_Reason) CloudException
			from Consolidation.Exceptions
			where EXP_EXT_ID = 3
				and EXP_HST_ID in (3, 5)
			group by EXP_MOB_ID
		)
	, Facts as
		(select concat(cast(count(*)*100./isnull(nullif(TotalServerCount, 0), 1) as decimal(10, 1)), '% (', format(count(*), '##,##0'),
						') of the servers cannot move to Azure IaaS because the maximal ', Issue, ' available is insufficient*') Fact, count(*) Rnk
			from (select 'CPU strength' Issue
					from ExpAgg
					where CloudException like '%CPU Strength%'
					union all
					select 'memory size' Issue
					from ExpAgg
					where CloudException like '%Memory (MB) needed%'
					union all
					select 'disk size' Issue
					from ExpAgg
					where CloudException like '%Disk Size%'
					union all
					select 'disk throughput' Issue
					from ExpAgg
					where CloudException like '%Disk IOPS%'
						or CloudException like '%Disk MB/sec%'
					union all
					select 'network bandwidth' Issue
					from ExpAgg
					where CloudException like '%Network bandwidth%'
				) e
				cross join (select count(*) TotalServerCount
								from Consolidation.LoadBlocks
								where exists (select *
												from Consolidation.ServerPossibleHostTypes
												where SHT_MOB_ID = LBL_MOB_ID
													and SHT_HST_ID = 4)
							) l
			group by Issue, TotalServerCount
			union all
			select concat(CombinationOfIssues*100/isnull(nullif(TotalServerCount, 0), 1), '% (', format(CombinationOfIssues, '##,##0'),
							') of the servers cannot move to Azure IaaS due to a combination of the necessary resources is unavailable in Azure') Fact, CombinationOfIssues Rnk
			from (select count(*) CombinationOfIssues
					from ExpAgg
					where CloudException like '%No hosting possibility%'
				) e
				cross join (select count(*) TotalServerCount
								from Consolidation.LoadBlocks
								where exists (select *
												from Consolidation.ServerPossibleHostTypes
												where SHT_MOB_ID = LBL_MOB_ID
													and SHT_HST_ID = 4)
							) l
			where CombinationOfIssues > 0
		)
select Fact
from Facts
order by Rnk desc
GO
