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
/****** Object:  StoredProcedure [BusinessLogic].[usp_BasicViolationDisplay]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [BusinessLogic].[usp_BasicViolationDisplay]
	@PKG_ID int = 2,
	@ViolationsPerRule int = 5,
	@JsonOutput bit = 0,
	@IncludeJsonWrapper bit = 1
as
declare @RUL_ID int,
		@PKN_ID int,
		@ColumnMap xml,
		@SQL nvarchar(max),
		@Violations xml,
		@Results nvarchar(max) = '',
		@RuleName varchar(200),
		@Description varchar(1000)

select top 1 @PKN_ID = PKN_ID
from BusinessLogic.PackageRuns
where PKN_PKG_ID = @PKG_ID
order by PKN_ID desc

declare cRules cursor static forward_only for
	select RUL_ID
	from BusinessLogic.Packages_Rules
		inner join BusinessLogic.Rules on RUL_ID = PKR_RUL_ID
	where PKR_PKG_ID = @PKG_ID
		and PKR_IsPresented = 1
		and RUL_IsActive = 1

open cRules

fetch next from cRules into @RUL_ID
while @@FETCH_STATUS = 0
begin
	select @ColumnMap = RUL_ColumnMap,
		@RuleName = RUL_Name,
		@Description = RUL_Description
	from BusinessLogic.Rules
	where RUL_ID = @RUL_ID

	set @Violations = null

	if @JsonOutput = 0
	begin
		;with Cols as
				(select 'RLV_' + c.value('@Name', 'nvarchar(128)') ColumnName, c.value('@Alias', 'nvarchar(255)') ColumnAlias,
						ROW_NUMBER() over(order by cast(substring(c.value('@Name', 'nvarchar(128)'), 5, 100) as int)) rn
					from @ColumnMap.nodes('Columns/Column') t(c)
				)
		select @SQL = ';with PRRs as
							(select PRR_ID
								from BusinessLogic.PackageRunRules
									inner join BusinessLogic.Rules on PRR_RUL_ID = RUL_ID
								where PRR_PKN_ID = @PKN_ID
									and RUL_ID = @RUL_ID
							)
						select @Violations = (select (select ''Server'' [@Name], '
										+ 'cast(MOB_Name as nvarchar(128)) '
										+ 'for xml path(''Col''), type)'
					+ (select ', (select ' + '''' + c.ColumnAlias + ''' [@Name], '
										+ 'cast(' + c.ColumnName + ' as sql_variant) '
										+ 'for xml path(''Col''), type)'
							from Cols c
								left join Cols t on c.rn = t.rn + 1
														and t.ColumnAlias like '~%'
							where c.ColumnAlias not like '~%'
							for xml path(''))
					+ 'from (select top(@ViolationsPerRule) *
								from BusinessLogic.RuleViolations
									inner join Inventory.MonitoredObjects on MOB_ID = RLV_MOB_ID
								where exists (select *
												from PRRs
												where RLV_PRR_ID = PRR_ID)
								) [Violation]
						for xml auto, root(''Violations''), elements, type)'
		exec sp_executesql @SQL,
							N'@PKN_ID int,
								@RUL_ID int,
								@ViolationsPerRule int,
								@Violations xml output',
							@PKN_ID = @PKN_ID,
							@RUL_ID = @RUL_ID,
							@ViolationsPerRule = @ViolationsPerRule,
							@Violations = @Violations output

		set @Results += 
					isnull((select RUL_Description Name,
									@Violations
								from BusinessLogic.Rules [Rule]
								where RUL_ID = @RUL_ID
									and @Violations is not null
								for xml auto), '')
	end
	else
	begin
		;with Cols as
				(select 'MOB_Name' ColumnName, 'Server name' ColumnAlias, 1 rn, 0 Revrn
				union
				select 'RLV_' + c.value('@Name', 'nvarchar(128)') ColumnName, c.value('@Alias', 'nvarchar(255)') ColumnAlias,
						ROW_NUMBER() over(order by cast(substring(c.value('@Name', 'nvarchar(128)'), 5, 100) as int)) + 1 rn,
						ROW_NUMBER() over(order by cast(substring(c.value('@Name', 'nvarchar(128)'), 5, 100) as int) desc) Revrn
					from @ColumnMap.nodes('Columns/Column') t(c)
					where exists (select *
									from BusinessLogic.PackageRunRules
									where PRR_PKN_ID = @PKN_ID
										and PRR_RUL_ID = @RUL_ID
										and PRR_RowsReturned > 0
								)
				)
		select @SQL = 'set @Violations =
							(select top(@ViolationsPerRule) '
							+ stuff((select ',' + iif(rn = 1, ''', {''', ''',''') + ' + ''"'' + ' + '''' + replace(replace(ColumnAlias, '"', '""'), '\', '\\')
											+ '": "'' + isnull(replace(replace(cast(' + ColumnName + ' as nvarchar(max)), ''"'', ''""''), ''\'', ''\\''), '''') + ''"'' + '
											+ iif(Revrn = 1 or not exists (select * from Cols where Revrn = 1), '''}'' + ', '') + ' char(13) + char(10)'
												from Cols
												where ColumnAlias not like '~%'
												order by rn
												for xml path('')), 1, 1, '') + char(13)+char(10)
							+ 'from BusinessLogic.PackageRunRules
									inner join BusinessLogic.RuleViolations on RLV_PRR_ID = PRR_ID
									inner join Inventory.MonitoredObjects on MOB_ID = RLV_MOB_ID
								where PRR_RUL_ID = @RUL_ID
								for xml path(''''))'

		exec sp_executesql @SQL,
							N'@RUL_ID int,
								@ViolationsPerRule int,
								@Violations xml output',
							@RUL_ID = @RUL_ID,
							@ViolationsPerRule = @ViolationsPerRule,
							@Violations = @Violations output
		if @Violations is not null
			set @Results += ', {"Rule": "' + replace(replace(@RuleName, '"', '""'), '\', '\\') + '",' + char(13)+char(10)
								+ '"Description": "' + replace(replace(@Description, '"', '""'), '\', '\\') + '",' + char(13)+char(10)
								+ '"Violation": [' + char(13)+char(10)
								+ replace(stuff(cast(@Violations as nvarchar(max)), 1, 2, ''), '&#x0D;', char(13)) + ']}' + char(13)+char(10)
	end
	fetch next from cRules into @RUL_ID
end
close cRules
deallocate cRules

if @JsonOutput = 0
	select cast(@Results as xml) Violations
	for xml path(''), root('Rules')
else
	select
		case @IncludeJsonWrapper
			when 1 then '/**
 * Created by antonbatalin
 */
(function(){
    "use strict";
    angular
        .module(''app'')
        .constant(''jsonData'', {
            data :
            //----------------------------------------------------

'
			else ''
		end
		+ '[' + char(13)+char(10)
		+ stuff(@Results, 1, 2, '')
		+ ']'
		+ case @IncludeJsonWrapper
			when 1 then '

            //----------------------------------------------------
        });
    

})();'
			else ''
		end
GO
