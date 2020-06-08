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
/****** Object:  StoredProcedure [Collect].[usp_ScheduleTestAndWaitForRun]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collect].[usp_ScheduleTestAndWaitForRun]
	@TST_ID int,
	@MOB_ID int,
	@RNR_ID int,
	@MaxWaitTimeSeconds int = null
as
declare @SCT_ID int,
		@WaitStart datetime2(3)

exec Collect.usp_ScheduleTestManually @TST_ID = @TST_ID,
										@MOB_ID = @MOB_ID,
										@RNR_ID = @RNR_ID,
										@SCT_ID = @SCT_ID output

set @WaitStart = sysdatetime()
while exists (select *
				from Collect.ScheduledTests
				where SCT_ID = @SCT_ID
					and SCT_STS_ID < 4)
			and (@WaitStart > dateadd(second, -@MaxWaitTimeSeconds, sysdatetime())
					or @MaxWaitTimeSeconds is null)
	waitfor delay '00:00:00.2'
GO
