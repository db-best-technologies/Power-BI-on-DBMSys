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
/****** Object:  StoredProcedure [Consolidation].[usp_GetPriceIndex]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Consolidation].[usp_GetPriceIndex]
as
declare @CPUCap decimal(10, 2),
		@MemoryCap decimal(10, 2)

select @CPUCap = cast(SET_Value as decimal(10, 2))
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'CPU Cap Percentage'

select @MemoryCap = cast(SET_Value as decimal(10, 2))
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'Memory Cap Percentage'

;with Totals as
		(select HST_ID T_HST_ID,
				CLB_CGR_ID,
				CLB_OST_ID,
				sum(TotalCPU) TotalCPU,
				sum(TotalMemory) TotalMemory,
				sum(CLB_BasePricePerMonthUSD) TotalPrice,
				count(*) Machines
			from Consolidation.ConsolidationBlocks
				cross apply (select sum(CBL_BufferedCPUStrength)*100/@CPUCap TotalCPU,
									sum(CBL_BufferedMemoryMB)*100/@MemoryCap TotalMemory
								from Consolidation.ConsolidationBlocks_LoadBlocks
								where CBL_CLB_ID = CLB_ID
									and CBL_DLR_ID is null) l
				inner join Consolidation.HostTypes on HST_ID = CLB_HST_ID
			where CLB_DLR_ID is null
				and HST_IsCloud = 1
			group by HST_ID, CLB_CGR_ID, CLB_OST_ID
		)
	, GroupIndices as
		(select T_HST_ID, CLB_CGR_ID,
				TotalPrice/((TotalCPU + PSH_CPUStrength - 1)/PSH_CPUStrength*PSH_PricePerMonthUSD)*Machines/sum(Machines) over() CPUIndex,
				TotalPrice/((TotalMemory + PSH_MemoryMB - 1)/PSH_MemoryMB*PSH_PricePerMonthUSD)*Machines/sum(Machines) over() MemoryIndex
			from Totals
				cross apply (select PSH_CPUStrength, PSH_MemoryMB, PSH_PricePerMonthUSD, row_number() over(order by PSH_PricePerMonthUSD) rnk
								from Consolidation.PossibleHosts
								where PSH_HST_ID = T_HST_ID
									and (PSH_OST_ID = CLB_OST_ID
										or (PSH_OST_ID is null
											and CLB_OST_ID is null
											)
										)) p
			where rnk = 5

		)
	, Indices as
		(select T_HST_ID, sum(CPUIndex) CPUIndex, sum(MemoryIndex) MemoryIndex
			from GroupIndices
			group by T_HST_ID
		)
select HST_ID, HST_Name, cast(case when CPUIndex < MemoryIndex then CPUIndex else MemoryIndex end as decimal(10, 2)) [Index]
from Indices
	inner join Consolidation.HostTypes on HST_ID = T_HST_ID
order by HST_CLV_ID, HST_IsConsolidation desc
GO
