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
/****** Object:  StoredProcedure [GUI].[usp_GetHealthCheckResultHistory]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [GUI].[usp_GetHealthCheckResultHistory]
	@FromDate datetime2(3),
	@ToDate datetime2(3)
as
set nocount on
set transaction isolation level read uncommitted

select PKR_ID PackageRunID, PRR_ID RuleRunID, RUL_ID RuleID, RLV_InsertDate RunDate, RLV_MOB_ID MonitoredObjectID,
		ISNULL(PKR_Weight, RUL_Weight) RuleWeight, isnull(RTH_THL_ID, 10) RuleLevel,
		RLV_Info1 Info1, RLV_Info2 Info2, RLV_Info3 Info3, RLV_Info4 Info4, RLV_Info5 Info5, RLV_Info6 Info6, RLV_Info7 Info7, RLV_Info8 Info8, RLV_Info9 Info9,
		RLV_Info10 Info10, RLV_Info11 Info11, RLV_Info12 Info12, RLV_Info13 Info13, RLV_Info14 Info14, RLV_Info15 Info15, RLV_Info16 Info16, RLV_Info17 Info17,
		RLV_Info18 Info18, RLV_Info19 Info19, RLV_Info20 Info20
from BusinessLogic.RuleViolations v
	inner join BusinessLogic.PackageRunRules on PRR_ID = RLV_PRR_ID
	inner join BusinessLogic.PackageRuns on PKN_ID = PRR_PKN_ID
	inner join BusinessLogic.Rules on RUL_ID = PRR_RUL_ID
	inner join BusinessLogic.Packages_Rules on PKR_RUL_ID = RUL_ID
												and PKR_PKG_ID = PKN_PKG_ID
	left join BusinessLogic.RuleThresholds on RTH_ID = PRR_RTH_ID
where PKN_StartDate between @FromDate and @ToDate
order by RUL_ID
GO
