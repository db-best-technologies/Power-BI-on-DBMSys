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
/****** Object:  StoredProcedure [Collect].[usp_RetryFailedTests]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Collect].[usp_RetryFailedTests]
	@DaysBack int = 2
as
declare @SQL nvarchar(max)

set @SQL =
(select concat('exec Collect.usp_ScheduleTestManually ', TST_ID, ', ', MOB_ID, ';')
from Collect.fn_GetObjectTests(null)
	cross apply (select min(TRH_TRS_ID) TRH_TRS_ID
		from Collect.TestRunHistory with (forceseek, index=IX_TestRunHistory_TRH_TST_ID#TRH_MOB_ID#TRH_EndDate##TRH_TRS_ID###TRH_TRS_ID_IN_3_4)
		where TRH_TST_ID = TST_ID
			and TRH_MOB_ID = MOB_ID
			and TRH_TRS_ID in (3, 4)
			and TRH_EndDate > getdate() - @DaysBack
		having min(TRH_TRS_ID) = 4) h
where (TST_MaxSuccessfulRuns > 0
	or TST_MaxSuccessfulRuns is null)
	and not exists (select *
						from Collect.ScheduledTests
						where SCT_MOB_ID = MOB_ID
							and SCT_TST_ID = TST_ID
							and SCT_DateToRun <= getdate()
							and SCT_STS_ID < 3)
for xml path(''))
exec(@SQL)
GO
