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
/****** Object:  StoredProcedure [Internal].[usp_CreateHistoryRetentionTrigger]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [Internal].[usp_CreateHistoryRetentionTrigger]
	@SourceSchemaName nvarchar(128),
	@SourceTableName nvarchar(128),
	@DestinationTableFullName  nvarchar(257),
	@Extract_MOB_ID bit = 0,
	@IgnoreColumnNamePatterns xml = null,
	@DropExistingTrigger bit = 1
as
set nocount on
set ansi_padding on
set quoted_identifier on

declare	@MaxNumberOfPrimaryKeyColumns int,
		@SourceTableFullName nvarchar(257),
		@MOB_ID_ColumnName nvarchar(128),
		@Sql nvarchar(max),
		@TriggerName sysname

declare @Columns table(name nvarchar(128),
						max_length int,
						column_id int,
						IsPK bit,
						key_ordinal int,
						column_type nvarchar(128))

set @MaxNumberOfPrimaryKeyColumns = 5

set @SourceTableFullName = @SourceSchemaName + '.' + @SourceTableName

insert into @Columns
select c.name, c.max_length, c.column_id,
		case when kc.name is null
				then 0
				else 1 end IsPK, key_ordinal, TYPE_NAME(system_type_id)
from sys.columns c
	left join (sys.index_columns ic	inner join sys.key_constraints kc on kc.type = 'PK'
									and ic.object_id = kc.parent_object_id
									and ic.index_id = kc.unique_index_id)
						on ic.object_id = c.object_id
						and ic.column_id = c.column_id
where c.object_id = object_id(@SourceTableFullName)
	and max_length <> -1
	and is_computed = 0
	and is_column_set = 0
	and not exists (select *
					from @IgnoreColumnNamePatterns.nodes('Columns/Column') t(c)
					where c.name like c.value('@Pattern', 'nvarchar(128)'))

if @Extract_MOB_ID = 1
	set @MOB_ID_ColumnName = ISNULL('D.' + (select top 1 name
									from @Columns
									where '_' + name like '%[_]MOB[_]ID'
									order by column_id), ' NULL')

if not exists (select * from @Columns where IsPK = 1)
begin
	raiserror('%s.%s has no primary key. DML audit trigger will not be created for it.', 16, 1, @SourceSchemaName, @SourceTableName)
	return
end

set @TriggerName = @SourceSchemaName + '.trg_' + @SourceTableName + '_HistoryLogging'

if @DropExistingTrigger = 1 and object_id(@TriggerName) is not null
begin
	set @Sql = 'DROP TRIGGER ' + @TriggerName
	exec sp_executesql @Sql
end

set @Sql =
	'CREATE TRIGGER ' + @TriggerName + ' ON ' + @SourceTableFullName + char(13)+char(10)
	+ 		'FOR UPDATE, DELETE' + char(13)+char(10)
	+ 		'NOT FOR REPLICATION' + char(13)+char(10)
	+ 		'AS' + char(13)+char(10)
	+ 'SET NOCOUNT ON' + char(13)+char(10)
	+ 'SET ANSI_PADDING ON' + char(13)+char(10)
	+ 'SET QUOTED_IDENTIFIER ON' + char(13)+char(10)
	+ 'DECLARE @ChangeType char(1),' + char(13)+char(10)
	+ '		@Info xml,' + char(13)+char(10)
	+ '		@ErrorMessage nvarchar(max)' + char(13)+char(10)
	+ char(13)+char(10)
	+ 'IF EXISTS (SELECT * FROM inserted)' + char(13)+char(10)
	+ '	SET @ChangeType = ''U''' + char(13)+char(10)
	+ 'ELSE' + char(13)+char(10)
	+ '	SET @ChangeType = ''D''' + char(13)+char(10)
	+ 'BEGIN TRY' + char(13)+char(10)
	+ '	INSERT INTO ' + @DestinationTableFullName + '(HIS_Type, HIS_Datetime, HIS_TableName, '
	+ 			case when @Extract_MOB_ID = 1 then 'HIS_MOB_ID, ' else '' end
	+ 			(select top(@MaxNumberOfPrimaryKeyColumns) 'HIS_PK_'
	+ 					cast(row_number() over(order by key_ordinal) as nchar(1)) + ', '
					from @Columns
					where IsPK = 1
					order by key_ordinal
					for xml path(''))
	+ 			char(9) + 'HIS_Changes, HIS_UserName, HIS_AppName, HIS_HostName)' + char(13)+char(10)
	+ '	SELECT *' + char(13)+char(10)
	+ '	FROM (SELECT @ChangeType ChangeType, sysdatetime() [Datetime], ''' + @SourceTableFullName + ''' TabName, '
	+ case when @Extract_MOB_ID = 1
				then 'C_MOB_ID, '
				else ''
		end
	+ (select name + ', '
			from @Columns
			where IsPK = 1
			order by key_ordinal
			for xml path('')) + char(13)+char(10)
	+ '				CAST(''<Changes>'' + '
	+	'CAST(CAST(Changes AS XML).query(''for $f in /Column
					where $f/@OldValue != $f/@NewValue
							or (empty($f/@OldValue) and not(empty($f/@NewValue)))
							or (empty($f/@NewValue) and not(empty($f/@OldValue)))
					 return $f'') AS NVARCHAR(MAX)) + ''</Changes>'' AS XML) Changes, '
	+ 		'suser_sname() LoginName, app_name() AppName, host_name() HostName' +
			char(13)+char(10)
	+ '			FROM '
	+ '(SELECT '
			+ case when @Extract_MOB_ID = 1
					then @MOB_ID_ColumnName + ' C_MOB_ID, '
					else ''
				end
			+ (select 'D.' + name + ', '
				from @Columns
				where IsPK = 1
				order by key_ordinal
				for xml path('')) + char(13)+char(10)
	+ '					(SELECT ' + stuff((select '						, CASE WHEN UPDATE(' + name + ') Or @ChangeType = ''D'' THEN' + char(13)+char(10)
	+ '							(SELECT ''' + name + ''' [@Name],' + char(13)+char(10)
	+ '								(SELECT Val from Infra.RemoveControlCharacters(' + case when column_type like '%binary'
																							then 'convert(nvarchar(max), D.' + name + ', 1)'
																							else 'cast(D.' + name + ' as nvarchar(max))'
																						end + ')) [@OldValue],' + char(13)+char(10)
	+ '								(SELECT Val from Infra.RemoveControlCharacters(' + case when column_type like '%binary'
																							then 'convert(nvarchar(max), I.' + name + ', 1)'
																							else 'cast(I.' + name + ' as nvarchar(max))'
																						end + ')) [@NewValue]' + char(13)+char(10)
	+ '							FOR XML PATH(''Column''), TYPE) ELSE NULL END' + char(13)+char(10)
				from @Columns
				where IsPK = 0
				for xml path('')), 1, 8, '')
	+ '					FOR XML PATH('''')) [Changes]' + char(13)+char(10)
	+ '	FROM Deleted D LEFT JOIN Inserted I ON ' +
			stuff(
					(select ' AND I.' + name + ' = ' + 'D.' + name
					from @Columns
					where IsPK = 1
					for xml path('')), 1, 5, '') + ') t) t' + char(13)+char(10)
	+ '	WHERE Changes.exist(''Changes/Column[1]'') = 1' + char(13)+char(10)
	+ 'END TRY' + char(13)+char(10)
	+ 'BEGIN CATCH' + char(13)+char(10)
	+ '	SET @ErrorMessage = ERROR_MESSAGE()' + char(13)+char(10)
	+ '	SET @Info = (select ''History Logging'' [@Process], ''' + @SourceTableFullName + ''' [@TableName] for xml path(''Info''))' + char(13)+char(10)
	+ '	IF @@TRANCOUNT > 0' + char(13)+char(10)
	+ '		ROLLBACK' + char(13)+char(10)
	+ '	EXEC Internal.usp_LogError @Info, @ErrorMessage' + char(13)+char(10)
	+ 'END CATCH'

set @Sql = replace(@Sql, '&#x0D;', CHAR(13))
exec(@Sql)
GO
