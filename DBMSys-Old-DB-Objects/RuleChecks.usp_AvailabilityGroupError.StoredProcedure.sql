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
/****** Object:  StoredProcedure [RuleChecks].[usp_AvailabilityGroupError]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_AvailabilityGroupError]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

select @ClientID, @PRR_ID, AGE_MOB_ID, AGR_GroupID, AGR_Name, AGT_Name, AGE_ErrorDescription, SUM(AGE_NumberOfOccurences) Cnt,
	min(AGE_FirstOccurence) FirstOccurence, min(AGE_LastOccurence) LastOccurence
from Activity.AvailabilityGroupErrors
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = AGE_MOB_ID
	inner join Inventory.AvailabilityGroupReplicas on AGR_GroupID = AGE_GroupID
														and AGR_MOB_ID = AGE_MOB_ID
	inner join Activity.AvailabilityGroupErrorTypes on AGT_ID = AGE_AGT_ID
where AGE_LastOccurence between @FromDate and @ToDate
group by AGE_MOB_ID, AGR_Name, AGR_GroupID, AGT_Name, AGE_ErrorDescription
GO
