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
/****** Object:  StoredProcedure [RuleChecks].[usp_SQLInstanceWithTooManyEndpoints]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_SQLInstanceWithTooManyEndpoints]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

select @ClientID, @PRR_ID, IEP_MOB_ID, IEP_ID, EPN_Name, EPT_Name 
from Inventory.InstanceEndPoints
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = IEP_MOB_ID
	inner join Inventory.EndpointNames on EPN_ID = IEP_EPN_ID
	inner join Inventory.EndpointTypes on EPT_ID = IEP_EPT_ID
where EPN_Name not in ('Dedicated Admin Connection',
						'TSQL Local Machine',
						'TSQL Named Pipes',
						'TSQL Default TCP',
						'TSQL Default VIA')
		and EPT_Name not in ('TSQL',
							'DATABASE_MIRRORING')
GO
