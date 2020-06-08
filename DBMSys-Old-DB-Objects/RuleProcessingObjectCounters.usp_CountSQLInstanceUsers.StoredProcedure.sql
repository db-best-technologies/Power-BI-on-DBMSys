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
/****** Object:  StoredProcedure [RuleProcessingObjectCounters].[usp_CountSQLInstanceUsers]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [RuleProcessingObjectCounters].[usp_CountSQLInstanceUsers]
	@ClientID int,
	@PKN_ID int,
	@OBT_ID tinyint,
	@PLC_ID int
as
set nocount on
set transaction isolation level read uncommitted
select @ClientID, @PKN_ID, @OBT_ID, COUNT(*)
from BusinessLogic.PackageRun_MonitoredObjects
	inner join Inventory.DatabasePrincipals on DPP_MOB_ID = PRM_MOB_ID
where PRM_PKN_ID = @PKN_ID
	and DPP_DPT_ID in (2, 3, 5, 6, 7)
GO
