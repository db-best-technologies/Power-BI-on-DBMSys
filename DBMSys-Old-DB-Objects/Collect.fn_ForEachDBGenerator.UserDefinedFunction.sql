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
/****** Object:  UserDefinedFunction [Collect].[fn_ForEachDBGenerator]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Collect].[fn_ForEachDBGenerator](@TST_ID int,
											@MOB_ID int,
											@Command nvarchar(max)) returns nvarchar(max)
begin
	declare @TempTableCreation nvarchar(max),
			@CursorFilter nvarchar(max),
			@Query nvarchar(max),
			@CurrentSecondaryQuery nvarchar(max),
			@ReturnSelect nvarchar(max),
			@OutputCommand nvarchar(max)

		select @TempTableCreation = v.value('TempTableCreation[1]', 'nvarchar(max)'),
				@CursorFilter = v.value('CursorFilter[1]', 'nvarchar(max)'),
				@Query = replace(v.value('Query[1]', 'nvarchar(max)'), '''', ''''''),
				@CurrentSecondaryQuery = replace(v.value('CurrentSecondaryQuery[1]', 'nvarchar(max)'), '''', ''''''),
				@ReturnSelect = replace(v.value('ReturnSelect[1]', 'nvarchar(max)'), '''', '''''')
		from (select CAST(@Command as xml) cmd) c
			cross apply cmd.nodes('ForEachDBQuery') x(v)

		set @OutputCommand =	
		N'set nocount on
		' + @TempTableCreation + N'
		declare @DatabaseName NVARCHAR(128),
				@SQL NVARCHAR(max),
				@ErrorMessage nvarchar(2000),
				@len bigint

		CREATE TABLE #DB
		(
			name NVARCHAR(255)
		)

		IF LEFT(CONVERT(SYSNAME,SERVERPROPERTY(''ProductVersion'')), CHARINDEX(''.'', CONVERT(SYSNAME,SERVERPROPERTY(''ProductVersion'')), 0)-1) < 11
			INSERT INTO #DB(name)
			SELECT 
					name
			FROM	sys.databases
			WHERE	[state] = 0
					and user_access = 0
					and source_database_id is null ' + coalesce(N'and ' + @CursorFilter, N'') + N'
		ELSE 
			INSERT INTO #DB(name)
			SELECT 
					name
			FROM	sys.databases
			WHERE	[state] = 0
					and user_access = 0
					
					   and name NOT IN	( 
											select dbcs.database_name
											from sys.dm_hadr_database_replica_states dbr 
											join sys.dm_hadr_database_replica_cluster_states dbcs on dbr.replica_id = dbcs.replica_id and dbr.group_database_id = dbcs.group_database_id  
											join sys.availability_replicas ar on ar.replica_id = dbr.replica_id and ar.group_id = dbr.group_id
											join sys.dm_hadr_availability_replica_states ars on ars.replica_id = dbr.replica_id
											where dbr.is_local = 1 
												and ars.role_desc = ''SECONDARY''
												and ar.secondary_role_allow_connections_desc in(''NO'', ''READ_ONLY'')
										)
					and source_database_id is null ' + coalesce(N'and ' + @CursorFilter, N'') + N'


		declare cDB cursor local static forward_only for
			select 
					name
			from	#DB

		open cDB
		fetch next from cDB into @DatabaseName
		while @@fetch_status = 0
		begin
			set @SQL = N''use '' + quotename(@DatabaseName) + N''
			' + @Query + N'''
			begin try
				exec(@SQL)
			end try
			begin catch
				
				set @ErrorMessage = ERROR_MESSAGE()
				' + iif(@CurrentSecondaryQuery is null, N'',
						N'if @ErrorMessage like ''%The target database, %, is participating in an availability group and is currently not accessible for queries%''
							or @ErrorMessage like ''%The target database (''''%'''') is in an availability group%''
								' + @CurrentSecondaryQuery + N'
					else
					')
				+ 'if @ErrorMessage not like '''''
						+ isnull((select N' and @ErrorMessage not like ''' + IEM_ErrorMessage + N''''
									from Collect.IngoreErrorMessages
									where IEM_IsActive = 1), N'') + N'
				begin
					raiserror(''%s: %s'', 16, 1, @DatabaseName, @ErrorMessage)
				end
			end catch
			fetch next from cDB into @DatabaseName
		end
		close cDB
		deallocate cDB
		' + @ReturnSelect
	
	return @OutputCommand

end
GO
