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
/****** Object:  UserDefinedFunction [Reports].[fn_GetCostForRemainingServersForCloudDatabases]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Reports].[fn_GetCostForRemainingServersForCloudDatabases](@StandardCorePrice int,
																		@EnterpriseCorePrice int,
																		@OnPremServerYearlyOperationalCostUSD int,
																		@StandardEditionCoreLicensesOwned int,
																		@EnterpriseEditionCoreLicensesOwned int) returns table
as
return (with Srv as
				(select isnull(SQLEdition, '[No/Free SQL]') SQLEdition,
						count(*) ServerCount,
						sum(OPR_OriginalLicensingCoreCount) CoreCount,
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
					where exists (select *
									from Inventory.InstanceDatabases
										inner join Consolidation.ParticipatingDatabaseServers on PDS_Database_MOB_ID = IDB_MOB_ID
									where not exists (select *
														from Consolidation.SingleDatabaseLoadBlocks
															inner join Consolidation.SingleDatabaseCloudLocations on SDC_SDL_ID = SDL_ID
														where SDL_IDB_ID = IDB_ID)
										and IDB_Name not in ('master', 'tempdb', 'model', 'msdb', 'distribution')
									)
						and exists (select *
									from Consolidation.SingleDatabaseLoadBlocks
										inner join Consolidation.SingleDatabaseCloudLocations on SDC_SDL_ID = SDL_ID)
					group by isnull(SQLEdition, '[No/Free SQL]'), PricePerCore, LicensesOwned
				)
		select SQLEdition, ServerCount,
			cast(iif(PricePerCore > 0, CoreCount, 0) as int) CoreCount,
			ServerCount*@OnPremServerYearlyOperationalCostUSD*3 OperationalCostFor3YearsUSD,
			isnull((CoreCount - LicensesOwned)*PricePerCore, 0) LicensingPriceFor3YearsUSD,
			isnull(PricePerCore, 0) PricePerCore,
			isnull(LicensesOwned, 0) LicensesOwned
		from srv)
GO
