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
/****** Object:  StoredProcedure [Reports].[usp_VirtualizationHostSpecificationFacts]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Reports].[usp_VirtualizationHostSpecificationFacts]
as
set nocount on

;with Facts as
		(select concat(VES_ServerType, ' server') Fact, 1 Rnk
			from Consolidation.VirtualizationESXServers
			union all
			select concat(iif(VES_NumberOfCPUSockets > 1, concat(VES_NumberOfCPUSockets, ' x '), ''), VES_CPUName, ' - A total of ', CPF_CPUCount/CPUStretchRatio, ' physical cores') Fact, 2 Rnk
			from Consolidation.VirtualizationESXServers
				inner join Consolidation.CPUFactoring on CPF_VES_ID = VES_ID
				cross join (select cast(SET_Value as int) CPUStretchRatio
								from Management.Settings
								where SET_Module = 'Consolidation'
									and SET_Key = 'Virtualization - CPU Core Stretch Ratio') s
			union all
			select concat(format(VES_MemoryMB/1024, '##,##0'), 'GB RAM') Fact, 3 Rnk
			from Consolidation.VirtualizationESXServers
			union all
			select concat(format(VES_NetworkSpeedMbit/1024, '##,##0'), 'Gbit network speed') Fact, 4 Rnk
			from Consolidation.VirtualizationESXServers
		)
select Fact
from Facts
order by Rnk
GO
