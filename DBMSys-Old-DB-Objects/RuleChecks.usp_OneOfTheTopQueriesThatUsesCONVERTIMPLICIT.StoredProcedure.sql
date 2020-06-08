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
/****** Object:  StoredProcedure [RuleChecks].[usp_OneOfTheTopQueriesThatUsesCONVERTIMPLICIT]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleChecks].[usp_OneOfTheTopQueriesThatUsesCONVERTIMPLICIT]
	@ClientID int,
	@PRR_ID int,
	@FromDate date,
	@ToDate date,
	@RTH_ID int
as
set nocount on
set transaction isolation level read uncommitted

select @ClientID, @PRR_ID, ITQ_MOB_ID, cast(SQS_Statement as varchar(8000)), ITQ_RankByReads, ITQ_RankByCPU, cast(ITQ_ImplicitlyConvertedColumns as varchar(8000))
from Inventory.InstanceTopQueries
	inner join BusinessLogic.PackageRunRules on PRR_ID = @PRR_ID
	inner join BusinessLogic.PackageRun_MonitoredObjects on PRM_PKN_ID = PRR_PKN_ID
														and PRM_MOB_ID = ITQ_MOB_ID
	inner join Activity.SQLStatements on SQS_ID = ITQ_SQS_ID
where ITQ_ImplicitlyConvertedColumns is not null
GO
