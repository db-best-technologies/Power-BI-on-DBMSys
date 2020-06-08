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
/****** Object:  StoredProcedure [RuleChecks].[usp_AgentLogError]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_AgentLogError]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

select @ClientID, @PRR_ID, SAL_MOB_ID, SAL_ErrorLevel,
	cast(ltrim(rtrim(replace(replace(replace(replace(replace(replace(SAL_ErrorMessage, CHAR(9), ' '), CHAR(13), ' '), CHAR(10), ' ')
											, ' ', ' ' + CHAR(3)), char(3) + ' ', ''), char(3), ''))) as varchar(8000)) ErrorMessage,
	COUNT(*) cnt, MIN(SAL_FirstErrorDate) FirstErrorDate, MAX(SAL_LastErrorDate) LastErrorDate
from Activity.SQLAgentErrorLog
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = SAL_MOB_ID
where SAL_FirstErrorDate between @FromDate and @ToDate
group by SAL_MOB_ID, SAL_ErrorLevel,
	cast(ltrim(rtrim(replace(replace(replace(replace(replace(replace(SAL_ErrorMessage, CHAR(9), ' '), CHAR(13), ' '), CHAR(10), ' ')
											, ' ', ' ' + CHAR(3)), char(3) + ' ', ''), char(3), ''))) as varchar(8000))
GO
