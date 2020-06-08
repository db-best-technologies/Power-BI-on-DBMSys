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
/****** Object:  StoredProcedure [SYL].[usp_GetServersList]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [SYL].[usp_GetServersList]
	@ServerList nvarchar(max),
	@LicensingKey varchar(100) = null output
as
set nocount on
set transaction isolation level  read uncommitted

;with SplitList as
		(select left(Val, charindex('|', Val, 1) - 1) ServerName,
				substring(Val, charindex('|', Val, 1) + 1, 1000) PlatformType
			from Infra.fn_SplitString(@ServerList, ';')
		)
	, Srvs as
		(select ServerName, ISNULL(DFO_IsWindowsAuthentication, 1) IsWindowsAuthentication, MOB_SLG_ID S_SLG_ID, PLT_MetaData Provider
			from SplitList
				inner join Inventory.MonitoredObjects on MOB_Name = ServerName
															and MOB_PLT_ID = PlatformType
				left join Management.DefinedObjects on DFO_PLT_ID = MOB_PLT_ID
														and MOB_Entity_ID = DFO_ID
				left join Management.PlatformTypes on PLT_ID = MOB_PLT_ID
		)
select ServerName, IsWindowsAuthentication, SLG_Login LoginName, SLG_Password [Password], Provider
from Srvs
	left join SYL.SecureLogins on (IsWindowsAuthentication  = 1
									and S_SLG_ID = SLG_ID
									and SLG_LGY_ID = 2)
								or (IsWindowsAuthentication  = 0
									and ((S_SLG_ID = SLG_ID
											and SLG_LGY_ID = 1)
										or
										(S_SLG_ID is null
											and SLG_IsDefault = 1)
										)
									)

select @LicensingKey = cast(SET_Value as varchar(100))
from Management.Settings
where SET_Module = 'Management'
	and SET_Key = 'Licensing Key'
GO
