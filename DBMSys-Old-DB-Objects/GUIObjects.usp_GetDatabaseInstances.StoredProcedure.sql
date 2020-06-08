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
/****** Object:  StoredProcedure [GUIObjects].[usp_GetDatabaseInstances]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUIObjects].[usp_GetDatabaseInstances]
	@ParentCode varchar(50) = null,
	@ParentID int = null,
	@ParentName varchar(900) = null,
	@SearchString varchar(1000) = null
as
set transaction isolation level read uncommitted
set nocount on
declare @SQL nvarchar(max)
set @SQL =
'select MOB_ID ID, DID_Name Name, PLT_Name [Database type], EDT_Name Edition, VER_Name [Version], PRL_Name [Product level],
		cast(DID_Architecture as varchar(10)) + ''bit'' [Architechture],
		OOS_Name [Operational status],
		case DID_IsClustered
			when 1 then ''Y''
			when 0 then ''N''
			else ''N/A''
		end [Clustered],
		case DID_IsIntegratedSecurityOnly
				when 1 then ''Integrated Security only''
				when 0 then ''Integrated Security and SQL Authentication''
				else ''N/A''
			end [Authentication method],
		isnull(DID_Port, DID_DynamicPort) Port,
		case when DID_DynamicPort is not null
			then ''Y''
			else ''N''
		end [Dynamic port],
		CLT_Name [Collation], 
		DID_LastRestartDate [Service start], 
		STUFF(case DID_IsTcpEnabled
						when 1 then '', TCP''
						else ''''
				end
				+ case DID_IsNamedPipesEnabled
						when 1 then '', Named Pipes''
						else ''''
					end
				+ case DID_IsNamedPipesEnabled
						when 1 then '', Named Pipes''
						else ''''
					end
				+ case DID_IsViaEnabled
						when 1 then '', Via''
						else ''''
					end, 1, 2, '''') [Enabled network protocols],
		DID_AllowLockPagesInMemory [Allow lock pages in memory]
from Inventory.DatabaseInstanceDetails
	inner join Management.DefinedObjects on DID_DFO_ID = DFO_ID
	inner join Management.PlatformTypes on DFO_PLT_ID = PLT_ID
	inner join Inventory.MonitoredObjects on MOB_PLT_ID = DFO_PLT_ID
											and MOB_Entity_ID = DID_DFO_ID
	inner join Management.ObjectOperationalStatuses on MOB_OOS_ID = OOS_ID
	inner join Inventory.Editions on DID_EDT_ID = EDT_ID
	inner join Inventory.Versions on MOB_VER_ID = VER_ID
	inner join Inventory.OSServers on DID_OSS_ID = OSS_ID
	inner join Inventory.ProductLevels on DID_PRL_ID = PRL_ID
	inner join Inventory.CollationTypes on DID_CLT_ID = CLT_ID'
+ case when @SearchString is not null
		then + char(13)+char(10) + 'where (DID_Name like ''%'' + @SearchString + ''%'')'
		else ''
	end
exec sp_executesql @SQL,
					N'@SearchString varchar(1000)',
					@SearchString = @SearchString
GO
