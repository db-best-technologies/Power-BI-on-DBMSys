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
/****** Object:  StoredProcedure [GUIObjects].[usp_GetMonitoredObjectsWithOpenAlerts]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUIObjects].[usp_GetMonitoredObjectsWithOpenAlerts]
	@ParentCode varchar(50) = null,
	@ParentID int = null,
	@ParentName varchar(900) = null,
	@SearchString varchar(1000) = null
as
set transaction isolation level read uncommitted
set nocount on
declare @SQL nvarchar(max)

set @SQL =
'select MOB_ID ID, MOB_Name + ''('' + PLT_Name + '')'' Name
from Inventory.MonitoredObjects
	inner join Management.PlatformTypes on MOB_PLT_ID = PLT_ID
where MOB_OOS_ID in (0, 1)
	and exists (select *
				from EventProcessing.TrappedEvents
				where TRE_IsClosed = 0
					and TRE_MOB_ID = MOB_ID)'
	+ case when @SearchString is not null
			then + char(13)+char(10)
				+ 'and (MOB_Name like ''%'' + @SearchString + ''%'')'
			else ''
		end + '
order by PLT_Name, MOB_Name'
exec sp_executesql @SQL,
					N'@SearchString varchar(1000)',
					@SearchString = @SearchString
GO
