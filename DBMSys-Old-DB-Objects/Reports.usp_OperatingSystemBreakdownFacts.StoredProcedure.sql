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
/****** Object:  StoredProcedure [Reports].[usp_OperatingSystemBreakdownFacts]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Reports].[usp_OperatingSystemBreakdownFacts]
as
set nocount on

;with Results as
		(select PLY_Name, OSS_InstallDate, PLY_MainstreamSupportEndDate, PLY_ExtendedSupportEndDate, count(*) over() TotalCount,
				stuff(convert(char(20), PLY_ExtendedSupportEndDate, 107), 4, charindex(',', convert(char(20), PLY_ExtendedSupportEndDate, 107), 1) - 3, '') NiceExtendedSupportEndDate
			from Inventory.MonitoredObjects
				inner join Inventory.Versions on VER_ID = MOB_VER_ID
				inner join Inventory.OSServers on OSS_MOB_ID = MOB_ID
				cross apply (select top 1 *
								from ExternalData.ProductLifeCycles
								where PLY_MinVersionNumber < VER_Number
								order by PLY_MinVersionNumber desc) v
			where exists (select *
							from Consolidation.ParticipatingDatabaseServers
							where PDS_Server_MOB_ID = MOB_ID)
		)
select concat(ceiling(count(*)*100.0/isnull(nullif(TotalCount, 0), 1)), '% (', format(count(*), '##,##0'), ') of the server are ', PLY_Name,
	iif(PLY_ExtendedSupportEndDate < sysdatetime(), ' which is past EOS', concat(' - EOS on ', NiceExtendedSupportEndDate))) Fact
from Results
where PLY_MainstreamSupportEndDate < sysdatetime()
group by PLY_Name, TotalCount, NiceExtendedSupportEndDate, PLY_ExtendedSupportEndDate
order by PLY_ExtendedSupportEndDate
GO
