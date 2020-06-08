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
/****** Object:  StoredProcedure [Collect].[usp_GetConfigMobs]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Collect].[usp_GetConfigMobs]
	@CTR_ID INT
AS
BEGIN
	SET NOCOUNT ON;


	select
	    [Id] = MOM_ObjGUID,--cast(MOB_ID as nvarchar(128)),
	    [Address] = MOB_Name,
	    [Product] = PLT_Name,
	    [Version] = VER_Number,
	    [Edition] = EDT_Name,
	    [Account] = cast(MOB_SLG_ID as nvarchar(128)),
		[ShortName] = SHS_ShortName
    from Inventory.MonitoredObjects
	join Inventory.MonitoringObectMapping ON MOB_ID = MOM_MOB_ID
	JOIN Inventory.SystemHosts ON SHS_MOB_ID = MOB_ID
	JOIN Collect.Collectors on MOB_CTR_ID = CTR_ID
    join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
    left outer join Management.DefinedObjects 
	    on PLT_ID = DFO_PLT_ID and MOB_Name = DFO_Name--DFO_ID = MOB_Entity_ID
    left outer join Inventory.Versions on VER_ID = MOB_VER_ID
    left outer join Inventory.Editions on EDT_ID = MOB_Engine_EDT_ID
    left outer join SYL.SecureLogins
	    on SLG_ID = MOB_SLG_ID 
	    or MOB_SLG_ID is null
	     and isnull(DFO_IsWindowsAuthentication, 1) = 0
	     and SLG_IsDefault = 1
	WHERE MOB_OOS_ID in (0, 1)
			AND MOB_CTR_ID = @CTR_ID
			AND CTR_IsDeleted = 0
    order by MOB_ID

	UPDATE	Collect.Collectors
	SET		CTR_LastConfigGetDate = GETUTCDATE()
	WHERE	CTR_ID = @CTR_ID

END
GO
