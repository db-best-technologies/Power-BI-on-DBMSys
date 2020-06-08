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
/****** Object:  StoredProcedure [GUIObjects].[usp_GetEventTypes]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [GUIObjects].[usp_GetEventTypes]
	@ParentCode varchar(50) = null,
	@ParentID int = null,
	@ParentName varchar(900) = null,
	@SearchString varchar(1000) = null
as
set transaction isolation level read uncommitted
set nocount on
declare @SQL nvarchar(max)

set @SQL =
'select MOV_ID ID, MOV_Description Name
from EventProcessing.MonitoredEvents'
+ case when @SearchString is not null
		then + char(13)+char(10)
			+ 'where (MOV_Description like ''%'' + @SearchString + ''%'')'
		else ''
	end + '
order by MOV_Description'
exec sp_executesql @SQL,
					N'@SearchString varchar(1000)',
					@SearchString = @SearchString
GO
