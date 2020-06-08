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
/****** Object:  StoredProcedure [RuleChecks].[usp_SQLInstanceWithOldJobHistory]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_SQLInstanceWithOldJobHistory]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted
declare @LowerValue decimal(18, 5),
		@UpperValue decimal(18, 5),
		@LastDate datetime

set @LastDate = RuleChecks.fn_GetLastDate()

select @LowerValue = RTH_LowerValue,
	@UpperValue = RTH_UpperValue
from BusinessLogic.RuleThresholds
where RTH_ID = @RTH_ID

select @ClientID, @PRR_ID, MOB_ID, datediff(day, DID_OldestJobHistory, @LastDate)
from Inventory.DatabaseInstanceDetails
	inner join Inventory.MonitoredObjects on MOB_PLT_ID = 1
												and MOB_Entity_ID = DID_DFO_ID
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = MOB_ID
where (@UpperValue is not null
		and DID_OldestJobHistory >= dateadd(day, -@UpperValue, @LastDate))
	and (@LowerValue is not null
		and DID_OldestJobHistory <= dateadd(day, -@LowerValue, @LastDate))
GO
