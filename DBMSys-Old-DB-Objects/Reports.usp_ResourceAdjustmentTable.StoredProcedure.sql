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
/****** Object:  StoredProcedure [Reports].[usp_ResourceAdjustmentTable]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Reports].[usp_ResourceAdjustmentTable]
as
set nocount on

if object_id('tempdb..#ResourceRecommendations') is not null
	drop table #ResourceRecommendations

create table #ResourceRecommendations
	(ServerName nvarchar(128),
	ServerType varchar(100),
	CoreCount int,
	MemoryGB bigint,
	AlertType varchar(100),
	PercentageOfResourceUsed bigint,
	Recommendation varchar(100),
	ResourceCount int,
	ResourceType varchar(100))

exec [Consolidation].[usp_Reports_ResourceUtilization] @ReturnResults = 0

select AlertType [Findings], count(*) [Servers], concat(format(abs(sum(ResourceCount)), '##,##0'), iif(ResourceType = 'Memory', 'GB', ' cores')) [Total change]
from #ResourceRecommendations
group by AlertType, ResourceType
order by ResourceType, AlertType
GO
