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
/****** Object:  View [Collect].[VW_TestMatrix]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Collect].[VW_TestMatrix]
as
select f.MOB_ID ObjectID, MOB_Name [Server], PLT_Name [Platform], coalesce(PLY_Name, VER_Name, '') [Version],
	QRT_Name CollectionType, f.TST_ID CollectionID, TST_Name [Collection], LastFailureDate, ErrorMessage, LastSuccessDate, Failed,
	case
		when TSV_MinVersion is not null then concat('For objects of versions ', TSV_MinVersion)
			+ case
				when TSV_MaxVersion is null then ' and above'
				else concat('-', TSV_MaxVersion)
			end
		when TSV_MinVersion is null and TSV_MaxVersion is not null then concat('For objects of versions ', TSV_MaxVersion, ' and earlier')
		else ''
	end
	+ iif(TSV_Editions is not null, iif(TSV_MinVersion is not null or TSV_MaxVersion is not null, ', ', 'For ') + 'editions ' + TSV_Editions, '') CollectionVersion
from Collect.fn_GetObjectTests(null) f
	inner join Collect.QueryTypes on QRT_ID = TST_QRT_ID
	inner join Collect.Tests t on t.TST_ID = f.TST_ID
	inner join Inventory.MonitoredObjects m on m.MOB_ID = f.MOB_ID
	inner join Management.PlatformTypes on MOB_PLT_ID = PLT_ID
	cross apply (select cast(TSV_MinVersion as decimal(10, 2)) TSV_MinVersion,
						cast(TSV_MaxVersion as decimal(10, 2)) TSV_MaxVersion,
						replace(TSV_Editions, ';', ', ') TSV_Editions
					from Collect.TestVersions tv
					where tv.TSV_ID = f.TSV_ID) tv
	full outer join (select top 1 TRH_StartDate LastCollectionDate
					from Collect.TestRunHistory
					where TRH_StartDate is not null
					order by TRH_ID desc) lc on 1 = 1
	left join inventory.Versions on MOB_VER_ID = VER_ID
	outer apply (select top 1 PLY_Name
					from ExternalData.ProductLifeCycles
					where PLY_MinVersionNumber < VER_Number
					order by PLY_MinVersionNumber) v
	outer apply (select top 1 TRH_EndDate LastSuccessDate
					from Collect.TestRunHistory with (forceseek)
					where TRH_MOB_ID = f.MOB_ID
						and TRH_TST_ID = f.TST_ID
						and TRH_TRS_ID = 3
					order by TRH_EndDate desc) s
	outer apply (select top 1 count(*) over() Failed, max(TRH_EndDate) over() LastFailureDate,
						'"' + iif(TRH_ErrorMessage like '%access%' or TRH_ErrorMessage like '%permission%', 'Insufficient Permission for collection login', TRH_ErrorMessage) + '"' ErrorMessage
					from Collect.TestRunHistory with (forceseek)
					where TRH_MOB_ID = f.MOB_ID
						and TRH_TST_ID = f.TST_ID
						and TRH_TRS_ID = 4
						and TRH_EndDate > isnull(LastSuccessDate, dateadd(day, -7, LastCollectionDate))
						and TRH_ErrorMessage not like '%availability group%'
					order by TRH_EndDate desc) l
GO
