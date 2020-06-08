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
/****** Object:  StoredProcedure [Collect].[usp_GetConfigMobCredentials]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Collect].[usp_GetConfigMobCredentials]
	@CTR_ID	INT
AS
BEGIN
	SET NOCOUNT ON;

	select
			[Id] = cast(SLG_ID as nvarchar(128)),
			[AuthType] = case LGY_ID
							when 1 then N'Generic'
							when 2 then N'Windows'
							else N'Unknown (' + cast(LGY_ID as nvarchar(128)) + N')'
							end,
			[UserName] = SLG_Login,
			[Password] = SLG_Password
	from	SYL.SecureLogins
	join	SYL.LoginTypes on LGY_ID = SLG_LGY_ID
	WHERE	EXISTS (
					SELECT 
							* 
					FROM	Inventory.MonitoredObjects 
					JOIN	Collect.Collectors on MOB_CTR_ID = CTR_ID
					WHERE	SLG_ID = MOB_SLG_ID 
							AND CTR_ID = @CTR_ID
							AND CTR_IsDeleted = 0
					)
	order by SLG_ID

	UPDATE	Collect.Collectors
	SET		CTR_LastConfigGetDate = GETUTCDATE()
	WHERE	CTR_ID = @CTR_ID

END
GO
