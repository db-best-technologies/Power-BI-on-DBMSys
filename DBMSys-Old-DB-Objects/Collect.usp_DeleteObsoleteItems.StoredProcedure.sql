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
/****** Object:  StoredProcedure [Collect].[usp_DeleteObsoleteItems]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Collect].[usp_DeleteObsoleteItems]
	@MOB_ID int,
	@TablesToDelete xml,
	@TRH_ID int
as
set nocount on
declare @TablePrefix varchar(10),
		@SQL nvarchar(max),
		@Last_TRH_ID int,
		@TableName nvarchar(257),
		@WhereClause nvarchar(max),
		@MOB_ID_ColumnName nvarchar(128)

declare cTable cursor static forward_only for
	select t.value('@Name', 'nvarchar(257)'),
		t.value('@WhereClause', 'nvarchar(max)'),
		isnull(t.value('@MOB_ID_Column', 'nvarchar(max)'), name)
	from @TablesToDelete.nodes('Tables/Table') x(t)
		cross apply (select top 1 name
						from sys.columns
						where object_id = object_id(t.value('@Name', 'nvarchar(257)'))
							and name like '%[_]MOB_ID'
						order by column_id) c

open cTable
fetch next from cTable into @TableName, @WhereClause, @MOB_ID_ColumnName
while @@fetch_status = 0
begin
	select @TablePrefix = left(name, charindex('_', name, 1))
	from sys.columns
	where object_id = object_id(@TableName)
		and column_id = 1

	set @SQL = 'delete ' + @TableName + CHAR(13) + CHAR(10)
				+ 'from ' + @TableName + ' with (forceseek)' + CHAR(13) + CHAR(10)
				+ 'where ' + @MOB_ID_ColumnName + ' = @MOB_ID' + CHAR(13) + CHAR(10)
				+ '	and ' + @TablePrefix + 'Last_TRH_ID < @TRH_ID' + CHAR(13) + CHAR(10)
				+ isnull(' and (' + @WhereClause + ')', '')
	--set @SQL = ';with ToDelete as' + CHAR(13)+CHAR(10)
	--			+ '	(select *, rank() over (order by ' + @TablePrefix + 'Last_TRH_ID desc) rn' + CHAR(13)+CHAR(10)
	--			+ '		from ' + @TableName + ' with (forceseek)' + CHAR(13)+CHAR(10)
	--			+ '		where ' + @MOB_ID_ColumnName + ' = @MOB_ID'
	--			+ isnull(' and ' + @WhereClause, '') + ')' + CHAR(13)+CHAR(10)
	--			+ 'delete ToDelete' + CHAR(13)+CHAR(10)
	--			+ 'where rn > 1'
	exec sp_executesql @SQL,
						N'@MOB_ID int,
							@TRH_ID int',
						@MOB_ID = @MOB_ID,
						@TRH_ID = @TRH_ID

	fetch next from cTable into @TableName, @WhereClause, @MOB_ID_ColumnName
end
close cTable
deallocate cTable
GO
