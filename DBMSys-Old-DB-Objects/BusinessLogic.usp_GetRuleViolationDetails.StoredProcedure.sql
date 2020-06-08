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
/****** Object:  StoredProcedure [BusinessLogic].[usp_GetRuleViolationDetails]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [BusinessLogic].[usp_GetRuleViolationDetails]
	@PKG_ID int,
	@RUL_ID int,
	@RuleViolations xml = null output,
	@ReturnSelect bit = 1
as
declare @ColumnMap xml,
		@SQL nvarchar(max)

select @ColumnMap = RUL_ColumnMap
from BusinessLogic.Rules
where RUL_ID = @RUL_ID

;with Cols as
		(select 'RLV_' + c.value('@Name', 'nvarchar(128)') ColumnName, c.value('@Alias', 'nvarchar(255)') ColumnAlias,
				ROW_NUMBER() over(order by cast(substring(c.value('@Name', 'nvarchar(128)'), 5, 100) as int)) rn
			from @ColumnMap.nodes('Columns/Column') t(c)
		)
select @SQL = ';with PRRs as
					(select PRR_ID, RTH_THL_ID ThresholdLevel
						from BusinessLogic.Packages
							cross apply (select top 1 PKN_ID
											from BusinessLogic.PackageRuns
											where PKN_PKG_ID = PKG_ID
											order by PKN_ID desc) n
							inner join BusinessLogic.PackageRunRules on PRR_PKN_ID = PKN_ID
							inner join BusinessLogic.Rules on PRR_RUL_ID = RUL_ID
							left join BusinessLogic.RuleThresholds on RTH_ID = PRR_RTH_ID
						where PKG_ID = @PKG_ID
							and RUL_ID = @RUL_ID
					)
				select @RuleViolations = (select ThresholdLevel [@ThresholdLevel],'
								+ '(select ''~MonitoredObjectID'' [@ObjectType], '
								+ ' RLV_MOB_ID [@ObjectID],'
								+ '''Monitored Object'' [@Name], '
								+ 'cast(MOB_Name as nvarchar(128)) '
								+ 'for xml path(''Col''), type)'
			+ (select ', (select ' + isnull('''' + t.ColumnAlias + ''' [@ObjectType], ', '')
								+ isnull(' ' + t.ColumnName + ' [@ObjectID], ', '')
								+ '''' + c.ColumnAlias + ''' [@Name], '
								+ 'cast(' + c.ColumnName + ' as sql_variant) '
								+ 'for xml path(''Col''), type)'
					from Cols c
						left join Cols t on c.rn = t.rn + 1
												and t.ColumnAlias like '~%'
					where c.ColumnAlias not like '~%'
					for xml path('')) + CHAR(13)+CHAR(10)
			+ 'from (select *
						from BusinessLogic.RuleViolations
							inner join Inventory.MonitoredObjects on MOB_ID = RLV_MOB_ID
							inner join PRRs on RLV_PRR_ID = PRR_ID
						) [Row]
				for xml path, root(''Rows''), elements, type)'
print @SQL
exec sp_executesql @SQL,
					N'@PKG_ID int,
						@RUL_ID int,
						@RuleViolations xml output',
					@PKG_ID = @PKG_ID,
					@RUL_ID = @RUL_ID,
					@RuleViolations = @RuleViolations output
if @ReturnSelect = 1
	select @RuleViolations RuleViolations
GO
