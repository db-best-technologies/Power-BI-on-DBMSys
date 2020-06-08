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
/****** Object:  StoredProcedure [GUI].[usp_HealthCheckRunningStatus]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [GUI].[usp_HealthCheckRunningStatus]
	@PackageRunID int = null
as
set nocount on
set transaction isolation level read uncommitted

if @PackageRunID is null
	select top 1 @PackageRunID = PKN_ID
	from BusinessLogic.PackageRuns
		inner join BusinessLogic.Packages on PKG_ID = PKN_PKG_ID
		inner join BusinessLogic.PackageTypes on PKT_ID = PKG_PKT_ID
	where PKT_Name = 'Health Check'
	order by PKN_ID desc

select PKN_StartDate StartDate,
	COUNT(distinct PRR_RUL_ID)*100/COUNT(distinct PKR_RUL_ID) PercentComplete
from BusinessLogic.PackageRuns
	inner join BusinessLogic.Packages_Rules on PKR_PKG_ID = PKN_PKG_ID
	inner join BusinessLogic.Rules on RUL_ID = PKR_RUL_ID
	left join BusinessLogic.PackageRunRules on PRR_PKN_ID = PKN_ID
												and PRR_RUL_ID = PKR_RUL_ID
where RUL_IsActive = 1
	and PKN_ID = @PackageRunID
group by PKN_StartDate
GO
