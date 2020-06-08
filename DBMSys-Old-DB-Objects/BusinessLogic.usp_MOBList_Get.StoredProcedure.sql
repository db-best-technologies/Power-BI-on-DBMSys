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
/****** Object:  StoredProcedure [BusinessLogic].[usp_MOBList_Get]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [BusinessLogic].[usp_MOBList_Get]
	@HCH_ID		int,
	@ReportDate	datetime,
	@Rule_List	BusinessLogic.PresentationRules readonly
AS
BEGIN
	WITH R AS
	(
		SELECT
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
		FROM	
			Inventory.Systems AS s
			join	Inventory.SystemHosts sh on s.Sys_ID = sh.SHS_Sys_Id
			join	Inventory.MonitoredObjects MOB on sh.SHS_MOB_ID = mob.MOB_ID
			join	Management.PlatformTypes on MOB_PLT_ID = PLT_ID
			left join	SYL.SecureLogins SLG on MOB.MOB_SLG_ID = SLG.SLG_ID
			join	Management.ObjectOperationalStatuses on OOS_ID = MOB_OOS_ID
		where	
			(OOS_IsOperational = 1 OR OOS_ID = 6)
	), G AS
	(
		SELECT DISTINCT
			RW.RLV_MOB_ID AS MOB_ID
		FROM
			BusinessLogic.Rules AS R
			INNER JOIN BusinessLogic.PackageRunRules AS PR
			ON PR.PRR_RUL_ID = R.RUL_ID
			INNER JOIN BusinessLogic.RuleViolations AS RW
			ON RW.RLV_PRR_ID = PR.PRR_ID
			INNER JOIN @Rule_List AS RL
			ON PR.PRR_RUL_ID = RL.RUL_ID
			INNER JOIN BusinessLogic.PackageRuns AS P
			ON P.PKN_ID = PR.PRR_PKN_ID
			INNER JOIN BusinessLogic.HealthChecks_History AS RH
			ON RH.HCY_PKN_ID = P.PKN_ID
		WHERE
			RH.HCY_HCH_ID = @HCH_ID
			AND RH.HCY_StartDate = @ReportDate
	)
	SELECT
		R.*
	FROM
		R INNER JOIN G ON R.SystemHost_Id = G.MOB_ID
		
END
GO
