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
/****** Object:  StoredProcedure [ManagementInterface].[usp_DefinedObjects_Display]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ManagementInterface].[usp_DefinedObjects_Display]
	@Name nvarchar(128) = null
as
select DFO_Name ObjectName, PLT_Name [Platform],
	case DFO_IsWindowsAuthentication
		when 0 then 'User/Pass Authentication'
		when 1 then 'Windows Authentication'
	end AuthenticationMethod, SLG_Description CredentialName,
	EDT_Name EngineEdition, VER_Name [Version]
from Management.DefinedObjects
	inner join Management.PlatformTypes on DFO_PLT_ID = PLT_ID
	left join SYL.SecureLogins on DFO_SLG_ID = SLG_ID
	left join Inventory.MonitoredObjects on MOB_PLT_ID = PLT_ID
											and MOB_Entity_ID = DFO_ID
	left join Inventory.Versions on VER_ID = MOB_VER_ID
	left join Inventory.Editions on EDT_ID = MOB_Engine_EDT_ID
where DFO_Name like '%' + isnull(@Name, '%') + '%'
order by DFO_Name
GO
