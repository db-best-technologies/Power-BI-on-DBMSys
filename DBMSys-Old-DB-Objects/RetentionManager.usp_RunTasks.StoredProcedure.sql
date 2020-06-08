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
/****** Object:  StoredProcedure [RetentionManager].[usp_RunTasks]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [RetentionManager].[usp_RunTasks]
	@ChunkSize int = 1000
AS
SET NOCOUNT ON
DECLARE @TAS_ID int,
		@TableName sysname,
		@DateColumn sysname,
		@KeepDays smallint,
		@WhereClause nvarchar(max),
		@MinRowsToKeep int,
		@MinRowsToKeepBy nvarchar(max),
		@IdentityColumnName nvarchar(128),
		@SQL nvarchar(max),
		@RowCount int,
		@ErrorCode int,
		@ErrorMessage nvarchar(2000),
		@PLG_ID int,
		@IndexName sysname

declare cur cursor fast_forward for
	select TAS_ID, TAS_TableName, TAS_DateColumn, cast(SET_Value as int) KeepDays,
			TAS_WhereClause, TAS_MinRowsToKeep, TAS_MinRowsToKeepBy
	from RetentionManager.Tasks
		inner join Management.Settings on SET_Module = 'Retention Manager'
											and SET_Key = TAS_RetentionPeriod_SET_Key
	where TAS_IsActive = 1
		and SET_Value is not null

open cur

fetch next from cur into @TAS_ID, @TableName, @DateColumn, @KeepDays, @WhereClause, @MinRowsToKeep, @MinRowsToKeepBy
while @@fetch_status = 0
begin
	select @RowCount = 0,
			@ErrorCode = null,
			@ErrorMessage = null,
			@IdentityColumnName = null

	insert into RetentionManager.PurgeLog(PLG_TAS_ID, PLG_StartDate)
	values(@TAS_ID, GETDATE())
	set @PLG_ID = SCOPE_IDENTITY()
	
	begin try
		select @IdentityColumnName = name
		from sys.identity_columns
		where object_id = object_id(@TableName)

		if @MinRowsToKeep is not null
				and @IdentityColumnName is null
			raiserror('Identity column not found', 16, 1)

		set @SQL = 'set nocount on' + CHAR(13)+CHAR(10)
					+ 'declare @LastRowCount int' + CHAR(13)+CHAR(10)
					+ iif(@MinRowsToKeep is null,
							'',
							'select ' + @MinRowsToKeepBy + ', max(' + @IdentityColumnName + ') KeepID' + CHAR(13)+CHAR(10)
							+ 'into #Keep' + CHAR(13)+CHAR(10)
							+ 'from ' + @TableName + CHAR(13)+CHAR(10)
							+ isnull('where (' + @WhereClause + ')' + CHAR(13)+CHAR(10), '')
							+ 'group by ' + @MinRowsToKeepBy + CHAR(13)+CHAR(10)
							+ 'create unique clustered index IX_#Keep on #Keep(KeepID)' + CHAR(13)+CHAR(10)
						)
					+ 'select ' + @IdentityColumnName + ' + 0 DeleteID' + CHAR(13)+CHAR(10)
					+ 'into #DeleteList' + CHAR(13)+CHAR(10)
					+ 'from ' + @TableName + ' with (readpast/*, forceseek*/)' + CHAR(13)+CHAR(10)
					+ 'where ' + @DateColumn + ' < dateadd(day, -@KeepDays, getdate())' + CHAR(13)+CHAR(10)
					+ isnull('	and (' + @WhereClause + ')' + CHAR(13)+CHAR(10), '')
					+ iif(@MinRowsToKeep is null,
							'',
							'	and not exists (select * from #Keep where KeepID = ' + @IdentityColumnName + ')' + CHAR(13)+CHAR(10)
						)
					+ 'create clustered index IX_#DeleteList on #DeleteList(DeleteID)' + CHAR(13)+CHAR(10)
					+ 'select DeleteID DID into #DeleteChunk from #DeleteList' + CHAR(13)+CHAR(10)
					+ 'create index IX_#DeleteChunk on #DeleteChunk(DID)' + CHAR(13)+CHAR(10)
					+ 'set @LastRowCount = 1' + CHAR(13)+CHAR(10)
					+ 'while @LastRowCount > 0' + CHAR(13)+CHAR(10)
					+ 'begin' + CHAR(13)+CHAR(10)
					+ '	truncate table #DeleteChunk' + CHAR(13)+CHAR(10)
					+ '	insert into #DeleteChunk' + CHAR(13)+CHAR(10)
					+ '	select top(@ChunkSize) DeleteID' + CHAR(13)+CHAR(10)
					+ '	from #DeleteList' + CHAR(13)+CHAR(10)
					+ '	delete ' + @TableName + CHAR(13)+CHAR(10)
					+ '	from #DeleteChunk' + CHAR(13)+CHAR(10)
					+ '	where DID = ' + @IdentityColumnName + CHAR(13)+CHAR(10)
					+ '	delete #DeleteList' + CHAR(13)+CHAR(10)
					+ '	from #DeleteChunk' + CHAR(13)+CHAR(10)
					+ '	where DeleteID = DID' + CHAR(13)+CHAR(10)
					+ '	set @LastRowCount = @@ROWCOUNT' + CHAR(13)+CHAR(10)
					+ '	set @RowCount += @LastRowCount' + CHAR(13)+CHAR(10)
					+ 'waitfor delay ''00:00:02'''
					+ 'end' + CHAR(13)+CHAR(10)
		print @sql
		exec sp_executesql @SQL,
							N'@ChunkSize int,
								@KeepDays smallint,
								@MinRowsToKeep int,
								@RowCount int output',
							@ChunkSize = @ChunkSize,
							@KeepDays = @KeepDays,
							@MinRowsToKeep = @MinRowsToKeep,
							@RowCount = @RowCount output
	end try
	begin catch
		select @ErrorCode = ERROR_NUMBER(),
				@ErrorMessage = ERROR_MESSAGE()
	end catch

	update RetentionManager.PurgeLog
	set PLG_EndDate = GETDATE(),
		PLG_RowCount = @RowCount,
		PLG_ErrorCode = @ErrorCode,
		PLG_ErrorMessage = @ErrorMessage
	where PLG_ID = @PLG_ID
	
	fetch next from cur into @TAS_ID, @TableName, @DateColumn, @KeepDays, @WhereClause, @MinRowsToKeep, @MinRowsToKeepBy
end
close cur
deallocate cur
GO
