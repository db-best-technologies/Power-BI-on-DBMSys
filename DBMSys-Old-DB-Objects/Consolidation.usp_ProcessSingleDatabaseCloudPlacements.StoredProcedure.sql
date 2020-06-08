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
/****** Object:  StoredProcedure [Consolidation].[usp_ProcessSingleDatabaseCloudPlacements]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Consolidation].[usp_ProcessSingleDatabaseCloudPlacements]
as
declare @CPUBufferPercentage decimal(10, 2)

select @CPUBufferPercentage = CAST(SET_Value as decimal(10, 2))
from Management.Settings
where SET_Module = 'Consolidation'
	and SET_Key = 'CPU Buffer Percentage'

truncate table Consolidation.SingleDatabaseCloudLocations

insert into Consolidation.SingleDatabaseCloudLocations
select SDL_ID, SDL_HST_ID, CMT_ID, CRG_ID, MonthlyPrice
from Consolidation.SingleDatabaseLoadBlocks
	inner join Consolidation.ServerGrouping on SGR_MOB_ID = SDL_MOB_ID
	inner join Consolidation.ConsolidationGroups_CloudRegions on CGG_CGR_ID = SGR_CGR_ID
	inner join Consolidation.CloudRegions on CRG_ID = CGG_CRG_ID
	cross apply (select top 1 CMT_ID, CMP_EffectiveHourlyPaymentUSD*744 MonthlyPrice
					from Consolidation.HostTypes
						inner join Consolidation.CloudMachineTypes on CMT_CLV_ID = HST_CLV_ID
						inner join Consolidation.CloudMachinePricing on CMP_CMT_ID = CMT_ID
																		and CMP_CRG_ID = CRG_ID
					where HST_ID = SDL_HST_ID
						and CMT_IsActive = 1
						and CMT_DTUs >= (SDL_DTUs + SDL_DTUs*(@CPUBufferPercentage/100))
						and CMT_MaxStorageGB >= SDL_SizeGB
					order by CMP_EffectiveHourlyPaymentUSD) m
GO
