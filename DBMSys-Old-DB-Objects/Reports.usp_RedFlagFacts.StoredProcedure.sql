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
/****** Object:  StoredProcedure [Reports].[usp_RedFlagFacts]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Reports].[usp_RedFlagFacts]
	@ResourceName varchar(50)
as
set nocount on

;with Alerts as
		(select top 3 concat(format(count(*), '##,##0'), ' server(s) are showing issues ', iif(Val = 100, '', 'over '), Val, '% of the time') Fact, Val
			from Consolidation.RedFlagsByResourceType
				inner join PerformanceData.PerformanceCounterGroups on PCG_ID = RFR_PCG_ID
				inner join (select Val
								from (values(10),
											(50),
											(80),
											(100)) v(Val)
								) v on RFR_PercentOverThreshold >= Val
			where PCG_Name = @ResourceName
			group by Val
			order by Val desc
		)
select Fact
from Alerts
order by Val
GO
