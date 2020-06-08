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
/****** Object:  StoredProcedure [GUIObjects].[usp_GetOSServers]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUIObjects].[usp_GetOSServers]
	@ParentCode varchar(50) = null,
	@ParentID int = null,
	@ParentName varchar(900) = null,
	@SearchString varchar(1000) = null
as
set transaction isolation level read uncommitted
set nocount on
declare @SQL nvarchar(max)
set @SQL =
'select MOB_ID ID, OSS_Name Name,
		PLT_Name [Operating System type],
		EDT_Name Edition,
		VER_Name [Version],
		PRL_Name [Product level],
		cast(OSS_Architecture as varchar(10)) + ''bit'' [Architechture],
		OOS_Name [Operational status],
		case OSS_IsClusterNode
				when 1 then ''Y''
				when 0 then ''N''
				else ''N/A''
			end [Cluster node],
		case OSS_IsVirtualServer
				when 1 then ''Y''
				when 0 then ''N''
				else ''N/A''
			end [Virtual Server],
		OSS_InstallDate [Install date], OSS_LastBootUpTime [Last boot time],
		cast(ceiling(OSS_TotalPhysicalMemoryMB/1024.) as varchar(10)) + ''GB'' [Physical memory],
		case when OSS_Architecture = 32
			then stuff(case OSS_IsPAEEnabled
								when 1 then '', PAE''
								else ''''
							end
						+ case when OSS_MaxProcessMemorySizeMB > 2150400
								then '', 3GB''
								else ''''
							end, 1, 2, '''')
		end [32bit memory flags],
		case OSS_IsAutomaticManagedPageFile
				when 1 then ''Y''
				when 0 then ''N''
				else ''N/A''
			end [Is Page File mananged by system],
		PPT_Name [Power Plan]
from Inventory.OSServers
	inner join Inventory.MonitoredObjects on MOB_ID = OSS_MOB_ID
	inner join Management.ObjectOperationalStatuses on MOB_OOS_ID = OOS_ID
	inner join Inventory.Editions on MOB_Engine_EDT_ID = EDT_ID
	inner join Inventory.Versions on MOB_VER_ID = VER_ID
	left join Inventory.ProductLevels on OSS_PRL_ID = PRL_ID
	inner join Management.PlatformTypes on OSS_PLT_ID = PLT_ID
	left join Inventory.OSProductTypes on OSS_OPT_ID = OPT_ID
	left join Inventory.PowerPlanTypes on OSS_PPT_ID = PPT_ID'
+ case when @SearchString is not null
		then + char(13)+char(10) + 'where (OSS_Name like ''%'' + @SearchString + ''%'')'
		else ''
	end
exec sp_executesql @SQL,
					N'@SearchString varchar(1000)',
					@SearchString = @SearchString
GO
