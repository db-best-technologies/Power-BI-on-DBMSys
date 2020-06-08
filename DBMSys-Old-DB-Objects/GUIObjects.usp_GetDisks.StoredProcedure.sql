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
/****** Object:  StoredProcedure [GUIObjects].[usp_GetDisks]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUIObjects].[usp_GetDisks]
	@ParentCode varchar(50) = null,
	@ParentID int = null,
	@ParentName varchar(900) = null,
	@SearchString varchar(1000) = null
as
set transaction isolation level read uncommitted
set nocount on
declare @SQL nvarchar(max)
set @SQL =
'select DSK_ID ID, DSK_Path Name, FST_Name [File System],
	cast(DSK_TotalSpaceMB/1024 as varchar(100)) + ''GB'' [Total space],
	cast(DSK_BlockSize/1024 as varchar(10)) + ''KB'' [Block size],
	case DSK_IsCompressed
			when 1 then ''Y''
			when 0 then ''N''
			else ''N/A''
		end [Compressed]
from Inventory.Disks
	inner join Inventory.FileSystems on DSK_FST_ID = FST_ID
where DSK_MOB_ID = @ParentID'
+ case when @SearchString is not null
		then + char(13)+char(10) + '	and (DSK_Name like ''%'' + @SearchString + ''%'')'
		else ''
	end
exec sp_executesql @SQL,
					N'@ParentID int,
						@SearchString varchar(1000)',
					@ParentID = @ParentID,
					@SearchString = @SearchString
GO
