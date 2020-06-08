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
/****** Object:  StoredProcedure [GUI].[usp_Get_SystemHosts]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUI].[usp_Get_SystemHosts]
--declare 
	@Sys_Id INT --= 41
	,@MOBID	INT = NULL
as
set nocount on

select
		s.Sys_ID as System_id
		,s.Sys_Name as System_Name
		,MOB.MOB_ID as SystemHost_Id
		,MOB.MOB_Name as SystemHost_Name
		,sh.SHS_ShortName as SystemHost_ShortName
		,MOB.MOB_PLT_ID as SystemHostType_Id
		,PLT_Name as SystemHostType_Name
		,SLG.SLG_ID		as Login_Id
		,SLG.SLG_Login	as Login
		,SLG.SLG_LGY_ID as Login_type
		,MOB_OOS_ID
		,CTR_ID
		,CTR_Name
		,CTR_IsDefault
from	Inventory.Systems s
join	Inventory.SystemHosts sh on s.Sys_ID = sh.SHS_Sys_Id
join	Inventory.MonitoredObjects MOB on sh.SHS_MOB_ID = mob.MOB_ID
join	Management.PlatformTypes on MOB_PLT_ID = PLT_ID
left join	SYL.SecureLogins SLG on MOB.MOB_SLG_ID = SLG.SLG_ID
join	Management.ObjectOperationalStatuses on OOS_ID = MOB_OOS_ID
LEFT JOIN Collect.COllectors ON MOB_CTR_ID = CTR_ID
where	(OOS_IsOperational = 1 OR OOS_ID = 6)
		and (
				s.Sys_ID = @Sys_Id AND @MOBID IS NULL
				OR
				MOB_ID = @MOBID 
			)
GO
