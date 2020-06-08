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
/****** Object:  StoredProcedure [GUIObjects].[usp_GetOpenAlerts]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUIObjects].[usp_GetOpenAlerts]
	@ParentCode varchar(50) = null,
	@ParentID int = null,
	@ParentName varchar(900) = null,
	@SearchString varchar(1000) = null
as
set transaction isolation level read uncommitted
set nocount on
declare @SQL nvarchar(max)

set @SQL =
'select TRE_ID [Alert ID],'
	+ case @ParentCode
				when 'AlertEventTypes'
					then ''
					else 'MOV_Description [Event Type], '
				end
	+ case @ParentCode
				when 'AlertMonitoredObjects'
					then ''
					else 'MOB_Name [Object Name], PLT_Name [Platform],'
				end
	+ 'TRE_OpenDate [Date], TRE_AlertMessage [Message]
from EventProcessing.TrappedEvents
	inner join Inventory.MonitoredObjects on MOB_ID = TRE_MOB_ID
											and MOB_OOS_ID in (0, 1)
	inner join Management.PlatformTypes on MOB_PLT_ID = PLT_ID
	inner join EventProcessing.MonitoredEvents on MOV_ID = TRE_MOV_ID
where TRE_IsClosed = 0'
	+ case @ParentCode
			when 'AlertEventTypes'
				then char(13)+char(10) + 'and TRE_MOV_ID = @ParentID'
			when 'AlertMonitoredObjects'
				then char(13)+char(10) + 'and TRE_MOB_ID = @ParentID'
			else ''
		end
	+ case when @SearchString is not null
			then + char(13)+char(10)
				+ 'and (' + case @ParentCode
								when 'AlertEventTypes'
									then 'MOB_Name like ''%'' + @SearchString + ''%'' or TRE_AlertMessage like ''%'' + @SearchString + ''%'''
								when 'AlertMonitoredObjects'
									then 'MOV_Description like ''%'' + @SearchString + ''%'' or TRE_AlertMessage like ''%'' + @SearchString + ''%'''
								else 'MOB_Name like ''%'' + @SearchString + ''%'' or MOV_Description like ''%'' + @SearchString + ''%'' or TRE_AlertMessage like ''%'' + @SearchString + ''%'''
							end
						+ ')'
			else ''
		end + '
order by [Date] desc'
exec sp_executesql @SQL,
					N'@ParentID int,
						@SearchString varchar(1000)',
					@ParentID = @ParentID,
					@SearchString = @SearchString
GO
