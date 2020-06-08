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
/****** Object:  UserDefinedFunction [Reports].[fn_GetCostForCurrentServerState]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Reports].[fn_GetCostForCurrentServerState](@StandardCorePrice int,
														@EnterpriseCorePrice int,
														@OnPremServerYearlyOperationalCostUSD int,
														@StandardEditionCoreLicensesOwned int,
														@EnterpriseEditionCoreLicensesOwned int) returns table
as
	return (with Srv as
					(select isnull(SQLEdition, '[No/Free SQL]') SQLEdition,
							cast(OPR_OriginalLicensingCoreCount as int) CoreCount,
							PricePerCore,
							LicensesOwned
						from Consolidation.VW_OnPrem
							left join (select cast('Standard' as varchar(100)) SQLEdition,
														@StandardCorePrice PricePerCore,
														@StandardEditionCoreLicensesOwned LicensesOwned
													union all
													select 'Enterprise' SQLEdition,
														@EnterpriseCorePrice PricePerCore,
														@EnterpriseEditionCoreLicensesOwned LicensesOwned) e on SQLEdition = OPR_Edition
					)
			select SQLEdition,
				isnull(PricePerCore, 0) PricePerCore,
				isnull(LicensesOwned, 0) LicensesOwned,
				count(*) ServerCount,
				sum(iif(PricePerCore > 0, CoreCount, 0)) CoreCount,
				count(*)*@OnPremServerYearlyOperationalCostUSD*3 OperationalCostFor3YearsUSD,
				isnull((sum(CoreCount) - LicensesOwned)*PricePerCore, 0) LicensingPriceFor3YearsUSD
			from Srv
			group by SQLEdition, PricePerCore, LicensesOwned
			)
GO
