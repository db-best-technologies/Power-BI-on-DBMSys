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
/****** Object:  StoredProcedure [GUIObjects].[usp_GetDatabaseFiles]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [GUIObjects].[usp_GetDatabaseFiles]
	@ParentCode varchar(50) = null,
	@ParentID int,
	@ParentName varchar(900) = null,
	@SearchString varchar(1000) = null
as
set transaction isolation level read uncommitted
set nocount on
declare @SQL nvarchar(max)
set @SQL =
'select DBF_ID ID, DBF_Name Name, DBF_FileID [File ID], DFT_Name [Type], DFS_Name [State], DFG_Name [File group], DBF_FileID [Path],
	case DBF_MaxSizeMB
		when 0 then ''Unlimited''
		else cast(DBF_MaxSizeMB as varchar(20)) + ''MB''
	end [Max size],
	cast(isnull(DBF_GrowthMB, DBF_GrowthPercent) as varchar(20))
		+ case when DBF_GrowthMB is null
				then ''%''
				else ''MB''
			end [Auto grow by],
	case DBF_IsReadOnly
		when 1 then ''Y''
		when 0 then ''N''
		else ''N/A''
	end [Read only]
from Inventory.DatabaseFiles
	inner join Inventory.DatabaseFileTypes on DFT_ID = DBF_DFT_ID
	inner join Inventory.DatabaseFileStates on DFS_ID = DBF_DFS_ID
	left join Inventory.DatabaseFileGroups on DFG_ID = DBF_DFG_ID
where DBF_IDB_ID = @ParentID'
+ case when @SearchString is not null
		then + char(13)+char(10) + '	and (DBF_Name like ''%'' + @SearchString + ''%'')'
		else ''
	end
+ char(13)+char(10) + 'order by Name'
exec sp_executesql @SQL,
					N'@ParentID int,
						@SearchString varchar(1000)',
					@ParentID = @ParentID,
					@SearchString = @SearchString
GO
