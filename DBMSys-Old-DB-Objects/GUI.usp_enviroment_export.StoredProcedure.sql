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
/****** Object:  StoredProcedure [GUI].[usp_enviroment_export]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUI].[usp_enviroment_export]
--declare 
	@HostList	Inventory.SystemHosts_List readonly
	,@exp_cred	bit = 0
as
set nocount on;

select 
		s.Sys_Name
		,SYS_Description
		,mob.MOB_Name
		,sh.SHS_ShortName
		,sht.PLT_Name as SHT_Name
		,slg.SLG_Description
		,slg.SLG_Login
		,slg.SLG_Password
		,slg.SLG_IsDefault
		,slg.SLG_LGY_ID
		,CTR_Name
from	Inventory.Systems s
join	Inventory.SystemHosts sh on s.SYS_ID = sh.SHS_SYS_ID
join	Inventory.MonitoredObjects MOB with (nolock) on sh.SHS_MOB_ID = MOB.MOB_ID
join	Management.PlatformTypes sht on mob.MOB_PLT_ID = sht.PLT_ID
join	@HostList SHS on sh.SHS_MOB_ID = SHS.SHS_MOB_ID
left join	syl.SecureLogins slg on mob.MOB_SLG_ID = slg.SLG_ID and @exp_cred = 1
LEFT JOIN Collect.Collectors on MOB_CTR_ID = CTR_ID
GO
