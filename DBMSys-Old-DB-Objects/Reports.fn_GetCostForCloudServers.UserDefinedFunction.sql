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
/****** Object:  UserDefinedFunction [Reports].[fn_GetCostForCloudServers]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Reports].[fn_GetCostForCloudServers](@StandardCorePrice int,
													@EnterpriseCorePrice int,
													@StandardEditionCoreLicensesOwnedWithSA int,
													@EnterpriseEditionCoreLicensesOwnedWithSA int) returns table
as
return (with CloudBlocks as
				(select CLB_ID, CLB_HST_ID, cast(iif(CMT_CoreCount < 4, 4, CMT_CoreCount) as int) CMT_CoreCount, CLB_BasePricePerMonthUSD, BlockMachines,
						isnull(SQLEdition, '[No/Free SQL]') SQLEdition,
						PricePerCore,
						isnull(LicensesOwnedWithSA, 0) LicensesOwnedWithSA
					from Consolidation.ConsolidationBlocks
						join Consolidation.HostTypes on CLB_HST_ID = HST_ID
						cross apply (select count(*) BlockMachines
										from Consolidation.ConsolidationBlocks_LoadBlocks
										where CBL_CLB_ID = CLB_ID
											and CBL_DLR_ID is null) m
						inner join Consolidation.PossibleHosts on PSH_ID = CLB_PSH_ID
						inner join Consolidation.CloudMachineTypes on CMT_ID = PSH_CMT_ID
						left join Consolidation.CloudHostedApplicationEditions on CHE_ID = CLB_CHE_ID
						left join (select cast('Standard' as varchar(100)) SQLEdition,
										@StandardCorePrice PricePerCore,
										@StandardEditionCoreLicensesOwnedWithSA LicensesOwnedWithSA
									union all
									select 'Enterprise' SQLEdition,
										@EnterpriseCorePrice PricePerCore,
										@EnterpriseEditionCoreLicensesOwnedWithSA LicensesOwnedWithSA) e on SQLEdition = CHE_Name
					where HST_IsCloud = 1 and HST_IsPerSingleDatabase = 0--CLB_HST_ID in (3, 5)
						and CLB_DLR_ID is null
				)
			, Agg as
				(select CLB_HST_ID HST_ID,
						SQLEdition,
						sum(iif(PricePerCore > 0, CMT_CoreCount, 0)) CoreCount,
						LicensesOwnedWithSA LicensesOwnedWithSA,
						sum(CLB_BasePricePerMonthUSD)*36 OperationalCostFor3YearsUSD,
						isnull((sum(CMT_CoreCount) - LicensesOwnedWithSA)*PricePerCore, 0) LicensingPriceFor3YearsUSD,
						count(*) ServerCount,
						sum(BlockMachines) MigratedServerCount,
						isnull(PricePerCore, 0) PricePerCore
					from CloudBlocks
					group by CLB_HST_ID,
						SQLEdition,
						PricePerCore,
						LicensesOwnedWithSA
				)
		select HST_ID,
			SQLEdition,
			CoreCount CoreCount,
			LicensesOwnedWithSA LicensesOwnedWithSA,
			OperationalCostFor3YearsUSD OperationalCostFor3YearsUSD,
			LicensingPriceFor3YearsUSD LicensingPriceFor3YearsUSD,
			ServerCount ServerCount,
			MigratedServerCount MigratedServerCount,
			PricePerCore
		from Agg
		)
GO
