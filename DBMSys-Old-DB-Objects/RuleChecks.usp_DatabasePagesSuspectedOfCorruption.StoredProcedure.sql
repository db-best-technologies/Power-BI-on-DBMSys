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
/****** Object:  StoredProcedure [RuleChecks].[usp_DatabasePagesSuspectedOfCorruption]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_DatabasePagesSuspectedOfCorruption]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

select @ClientID, @PRR_ID, SSP_MOB_ID, IDB_ID, IDB_Name, DBF_ID, DBF_FileName,
	case SSP_EventType
		when 1 then 'An 823 error that causes a suspect page (such as a disk error) or an 824 error other than a bad checksum or a torn page (such as a bad page ID)'
		when 2 then 'Bad checksum'
		when 3 then 'Torn page'
		when 4 then 'Restored (page was restored after it was marked bad)'
		when 5 then 'Repaired (DBCC repaired the page)'
		when 7 then 'Deallocated by DBCC'
	end, SSP_ErrorCount
from Inventory.SuspectPages
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = SSP_MOB_ID
	inner join Inventory.InstanceDatabases on IDB_ID = SSP_IDB_ID
	left join Inventory.DatabaseFiles on DBF_MOB_ID = SSP_MOB_ID
											and DBF_IDB_ID = SSP_IDB_ID
											and DBF_FileID = DBF_FileID
GO
