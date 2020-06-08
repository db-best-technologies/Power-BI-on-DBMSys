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
/****** Object:  View [Tests].[VW_TST_DatabaseInstanceSimpleQueryResponseTime]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Tests].[VW_TST_DatabaseInstanceSimpleQueryResponseTime]
as
select top 0 CAST(null as int) Metadata_TRH_ID,
			CAST(null as int) Metadata_ClientID
GO
/****** Object:  Trigger [Tests].[trg_VW_TST_DatabaseInstanceSimpleQueryResponseTime]    Script Date: 6/8/2020 1:15:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE trigger [Tests].[trg_VW_TST_DatabaseInstanceSimpleQueryResponseTime] on [Tests].[VW_TST_DatabaseInstanceSimpleQueryResponseTime]
	instead of insert
as
set nocount on
	
insert into Collect.VW_TST_PerformanceCounters(Category, [Counter], Instance, Value, [Status], Metadata_TRH_ID, Metadata_ClientID)
select 'Response Time (ms)' Category, 'Simple Query' [Counter], null Instance,
	case when TRH_ErrorMessage is not null
				then null
				else datediff(millisecond, TRH_StartDate,
												case when sysdatetime() < TRH_StartDate
														then TRH_StartDate
														else sysdatetime()
													end)
		end Value,
	case when TRH_ErrorMessage like '%Timeout expired%'
				then 'Timeout expired'
			when TRH_ErrorMessage is not null
				then 'Error'
			else 'Successful'
		end [Status], Metadata_TRH_ID, Metadata_ClientID
from inserted
	inner join Collect.TestRunHistory on Metadata_TRH_ID = TRH_ID
GO
