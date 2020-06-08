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
/****** Object:  StoredProcedure [BusinessLogic].[usp_RunPackage]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [BusinessLogic].[usp_RunPackage]
	@PackageID int,
	@PeriodStartDate date = null,
	@PeriodEndDate date = null,
	@ValueAggregationType tinyint = 1, --Avg.
	@Percentile tinyint = null,
	@MonitoredObjectList nvarchar(max) = null,
	@IgnorePerformanceData bit = 0,
	@ClearHistory bit = 0,
	@PKN_ID int output
as
BEGIN
	set nocount on
	set transaction isolation level read uncommitted
	declare @ClientID int,
			@FirstDate date,
			@LastDate date,
			@OBT_ID tinyint,
			@PLC_ID tinyint,
			@ObjectCountProcedure nvarchar(257),
			@PRR_ID int,
			@RUL_ID int,
			@ProcedureName nvarchar(257),
			@ExtraParameterValues nvarchar(max),
			@InsertColumns nvarchar(max),
			@RTH_ID int,
			@SQL nvarchar(max),
			@RowCount bigint,
			@ErrorMessage nvarchar(2000),
			@TotalRulesQty	int

	if @ClearHistory = 1
	begin
		truncate table BusinessLogic.PackageRuns
		truncate table BusinessLogic.PackageRunRules
		truncate table BusinessLogic.PackageRun_MonitoredObjects
		truncate table BusinessLogic.RuleViolations
	end

	select @ClientID = CAST(SET_Value as int)
	from Management.Settings
	where SET_Module = 'Management'
		and SET_Key = 'Client ID'

	if @IgnorePerformanceData = 0
	begin
		select @FirstDate = cast(min(CRS_DateTime) as date),
			@LastDate = cast(max(CRS_DateTime) as date)
		from PerformanceData.CounterResults_Hourly

		if @FirstDate is null
			set @ErrorMessage = 'There is no available data'
		else if (@PeriodStartDate is not null
					and @FirstDate > @PeriodStartDate)
				or (@PeriodEndDate is not null
					and @LastDate < @PeriodEndDate)
			set @ErrorMessage = 'Data is only available between ' + CONVERT(char(10), @FirstDate, 121) + ' and ' + CONVERT(char(10), @LastDate, 121)

		if @ErrorMessage is not null
		begin
			raiserror(@ErrorMessage, 16, 1)
			return 1
		end
	end
	select @FirstDate = coalesce(@PeriodStartDate, @FirstDate, sysdatetime()),
		@LastDate = coalesce(@PeriodEndDate, @LastDate, sysdatetime())

	-- Calculate total rules quantity
	SELECT 
		@TotalRulesQty = COUNT(*)
	FROM
		BusinessLogic.Packages_Rules AS PRS
		INNER JOIN BusinessLogic.Rules AS R
		ON R.RUL_ID = PRS.PKR_RUL_ID
	WHERE
		PRS.PKR_PKG_ID = @PackageID
		AND R.RUL_IsActive = 1
	

	insert into BusinessLogic.PackageRuns(PKN_PKG_ID, PKN_ClientID, PKN_PeriodStartDate, PKN_PeriodEndDate, PKN_IsExplicitPeriod, PKN_StartDate, PKN_VAT_ID, PKN_PercentileIfNeeded, PKN_TotalRulesQty)
	values(@PackageID, @ClientID, @FirstDate, @LastDate, case when @PeriodStartDate is not null
														or @PeriodEndDate is not null 
													then 1
													else 0
												end, SYSDATETIME(), @ValueAggregationType, @Percentile, @TotalRulesQty)
	set @PKN_ID = SCOPE_IDENTITY()

	if @MonitoredObjectList is null
		insert into BusinessLogic.PackageRun_MonitoredObjects(PRM_ClientID, PRM_PKN_ID, PRM_MOB_ID)
		select DISTINCT @ClientID, @PKN_ID, MOB_ID
		from Inventory.MonitoredObjects
		where MOB_OOS_ID = 1
	else
		insert into BusinessLogic.PackageRun_MonitoredObjects(PRM_ClientID, PRM_PKN_ID, PRM_MOB_ID)
		select DISTINCT @ClientID, @PKN_ID, CAST(Val as int)
		from Infra.fn_SplitString(@MonitoredObjectList, ',')

	declare cObjectTypes cursor static forward_only for
		select OBT_ID, OBT_PLC_ID, OBT_ObjectCountProcedure
		from BusinessLogic.ObjectTypes
		where OBT_ObjectCountProcedure is not null

	open cObjectTypes
	fetch next from cObjectTypes into @OBT_ID, @PLC_ID, @ObjectCountProcedure
	while @@fetch_status = 0
	begin
		set @SQL = 'insert into BusinessLogic.PackageRunObjectCounts(PRO_ClientID, PRO_PKN_ID, PRO_OBT_ID, PRO_Count)' + CHAR(13)+CHAR(10)
					+ 'exec ' + @ObjectCountProcedure + ' @ClientID = @ClientID,'
														+ ' @PKN_ID = @PKN_ID,'
														+ ' @OBT_ID = @OBT_ID,'
														+ ' @PLC_ID = @PLC_ID'
		exec sp_executesql @SQL,
							N'@ClientID int,
								@PKN_ID int,
								@OBT_ID tinyint,
								@PLC_ID int',
							@ClientID = @ClientID,
							@PKN_ID = @PKN_ID,
							@OBT_ID = @OBT_ID,
							@PLC_ID = @PLC_ID

		fetch next from cObjectTypes into @OBT_ID, @PLC_ID, @ObjectCountProcedure
	end
	close cObjectTypes
	deallocate cObjectTypes

	declare cRules cursor static forward_only for
		select RUL_ID, RUL_ProcedureName, RUL_ExtraParameterValues,
			case OBT_IncludesMonitoredObjectID
				when 1 then ', RLV_MOB_ID'
			end 
			+ isnull((select ', RLV_' + c.value('@Name', 'varchar(10)')
							from RUL_ColumnMap.nodes('/Columns/Column') t(c)
							order by cast(substring(c.value('@Name', 'varchar(10)'), 5, 10) as int)
							for xml path('')), '') InsertColumns, RTH_ID
		from BusinessLogic.Packages
			inner join BusinessLogic.Packages_Rules on PKR_PKG_ID = PKG_ID
			inner join BusinessLogic.Rules on RUL_ID = PKR_RUL_ID
			inner join BusinessLogic.ObjectTypes on OBT_ID = RUL_Primary_OBT_ID
			outer apply (select RTH_ID, dense_rank() over (order by RTH_PKG_ID desc) rn
							from BusinessLogic.RuleThresholds
							where RTH_RUL_ID = RUL_ID
								and (RTH_PKG_ID = PKG_ID
										or RTH_PKG_ID is null)) t
		where PKG_ID = @PackageID
			and PKG_IsActive = 1
			and RUL_IsActive = 1
			and RUL_ProcedureName is not null
			and (rn = 1
					or rn is null)
			and not exists (select *
								from BusinessLogic.CompoundRuleNodes
								where CRN_RUL_ID = RUL_ID
									and CRN_IsActive = 1)
		order by RUL_ID

	open cRules
	fetch next from cRules into @RUL_ID, @ProcedureName, @ExtraParameterValues, @InsertColumns, @RTH_ID
	while @@fetch_status = 0
	begin
		select @RowCount = null,
				@ErrorMessage = null
		set @SQL = 'insert into BusinessLogic.RuleViolations(RLV_ClientID, RLV_PRR_ID' + isnull(@InsertColumns, '') + ')' + CHAR(13)+CHAR(10)
					+ 'exec ' + @ProcedureName + ' @ClientID = @ClientID,'
											+ ' @PRR_ID = @PRR_ID,'
											+ ' @FromDate = @FromDate,'
											+ ' @ToDate = @ToDate,'
											+ ' @RTH_ID = @RTH_ID'
											+ ISNULL(', ' + @ExtraParameterValues, '')

		insert into BusinessLogic.PackageRunRules(PRR_ClientID, PRR_PKN_ID, PRR_RUL_ID, PRR_RTH_ID, PRR_StartDate)
		values(@ClientID, @PKN_ID, @RUL_ID, @RTH_ID, SYSDATETIME())
		set @PRR_ID = SCOPE_IDENTITY()
		print @SQL

		begin try
			exec sp_executesql @SQL,
								N'@ClientID int,
									@PRR_ID int,
									@FromDate date,
									@ToDate date,
									@RTH_ID int',
								@ClientID = @ClientID,
								@PRR_ID = @PRR_ID,
								@FromDate = @FirstDate,
								@ToDate = @LastDate,
								@RTH_ID = @RTH_ID
			set @RowCount = @@ROWCOUNT
		end try
		begin catch
			set @ErrorMessage = ERROR_MESSAGE()
		end catch

		update BusinessLogic.PackageRunRules
		set PRR_EndDate = SYSDATETIME(),
			PRR_RowsReturned = @RowCount,
			PRR_ErrorMessage = @ErrorMessage
		where PRR_ID = @PRR_ID
	
		fetch next from cRules into @RUL_ID, @ProcedureName, @ExtraParameterValues, @InsertColumns, @RTH_ID
	end
	close cRules
	deallocate cRules

	declare cRules cursor static forward_only for
		select RUL_ID,
			case OBT_IncludesMonitoredObjectID
				when 1 then ', RLV_MOB_ID'
			end 
			+ isnull((select ', RLV_' + c.value('@Name', 'varchar(10)')
							from RUL_ColumnMap.nodes('/Columns/Column') t(c)
							order by cast(substring(c.value('@Name', 'varchar(10)'), 5, 10) as int)
							for xml path('')), '') InsertColumns
		from BusinessLogic.Packages
			inner join BusinessLogic.Packages_Rules on PKR_PKG_ID = PKG_ID
			inner join BusinessLogic.Rules on RUL_ID = PKR_RUL_ID
			inner join BusinessLogic.ObjectTypes on OBT_ID = RUL_Primary_OBT_ID
		where PKG_ID = @PackageID
			and PKG_IsActive = 1
			and RUL_IsActive = 1
			and exists (select *
							from BusinessLogic.CompoundRuleNodes
							where CRN_RUL_ID = RUL_ID
								and CRN_IsActive = 1)
		order by RUL_ID

	open cRules
	fetch next from cRules into @RUL_ID, @InsertColumns
	while @@fetch_status = 0
	begin
			set @SQL = 
		'if OBJECT_ID(''tempdb..#CompRules'') is not null
			drop table #CompRules
		if OBJECT_ID(''tempdb..#Nodes'') is not null
			drop table #Nodes
		if OBJECT_ID(''tempdb..#Cols'') is not null
			drop table #Cols
		if OBJECT_ID(''tempdb..#Allcolumns'') is not null
			drop table #Allcolumns

		;with CompRules as
				(select CRN_ID CRID, ''Node'' + cast(CRN_ID as nvarchar(100)) NodeName, CRN_Node_RUL_ID, CRN_Filter, CRN_JoinOnColumns, CRN_ExposeColumns,
							RUL_ColumnMap, CRN_ExpressionID, CRN_ParentExpressionID, CRN_Ordinal, CRN_PreceedingOperator, CRN_IsNot,
							DENSE_RANK() over(order by CRN_ParentExpressionID desc) ExpressionProcessingOrder,
							ROW_NUMBER() over(partition by CRN_ExpressionID order by CRN_Ordinal) ExpressionLevelOrdinal
					from BusinessLogic.CompoundRuleNodes
						inner join BusinessLogic.Rules on RUL_ID = CRN_Node_RUL_ID
					where CRN_RUL_ID = @RUL_ID
						and CRN_IsActive = 1
				)
		select *
		into #CompRules
		from CompRules

		;with Nodes1 as
				(select 1 NodeType, CRN_Ordinal NodeOrdinal, CRN_ExpressionID ParentID, CRID ID, NodeName,
							case when ExpressionLevelOrdinal = 1 then null else CRN_PreceedingOperator end PreceedingOperator,
							case when ExpressionLevelOrdinal = 1 then null else CRN_IsNot end IsNot
					from #CompRules
					union all
					select 2 NodeType, MIN(CRN_Ordinal) NodeOrdinal, CRN_ParentExpressionID ParentID, CRN_ExpressionID ID,
							''Expression'' + CAST(CRN_ExpressionID as nvarchar(100)) NodeName,
							max(case when ExpressionLevelOrdinal > 1 then null else CRN_PreceedingOperator end) PreceedingOperator,
							cast(max(case when ExpressionLevelOrdinal > 1 then null else cast(CRN_IsNot as int) end) as bit) IsNot
					from #CompRules
					group by CRN_ParentExpressionID, CRN_ExpressionID
				)
			, Nodes as
				(select *,
						ROW_NUMBER() over (partition by ParentID order by NodeType, NodeOrdinal) PerParentOrdinal
					from Nodes1
				)
		select *
		into #Nodes
		from Nodes

		;with Cols as
				(select CRN_Ordinal NodeOrdinal, CRN_ParentExpressionID, CRN_ExpressionID, CRID CompRulID, NodeName, OriginalName, Alias,
						cast(substring(Name, 5, 1000) as int) ColOrdinal, Aggregation, FilterExpression, JoinOrdinal, CRN_IsNot
					from #CompRules
						cross apply (select ''RLV_'' + m.value(''@Name'', ''nvarchar(1000)'') OriginalName,
											replace(m.value(''@Alias'', ''nvarchar(1000)''), '']'', '''') Alias
										from RUL_ColumnMap.nodes(''Columns/Column'') r(m)
										union
										select ''RLV_MOB_ID'', ''$MOB_ID$'') m
						outer apply (select e.value(''@Name'', ''nvarchar(128)'') Name, e.value(''@Aggregation'', ''varchar(100)'') Aggregation
										from CRN_ExposeColumns.nodes(''Columns/Column'') t(e) 
										where m.Alias in (e.value(''@Alias'', ''nvarchar(1000)''), e.value(''@Expression'', ''nvarchar(1000)''))) e
						outer apply (select f.value(''@Expression'', ''nvarchar(max)'') FilterExpression
										from CRN_Filter.nodes(''Columns/Column'') t1(f)
										where m.Alias in (f.value(''@Alias'', ''nvarchar(1000)''), f.value(''@Expression'', ''nvarchar(1000)''))) f
						outer apply (select j.value(''@Ordinal'', ''int'') JoinOrdinal
										from CRN_JoinOnColumns.nodes(''Columns/Column'') t2(j)
										where m.Alias in (j.value(''@Alias'', ''nvarchar(1000)''), j.value(''@Expression'', ''nvarchar(1000)''))) j
					where Name is not null
						or FilterExpression is not null
						or JoinOrdinal is not null)
		select *
		into #Cols
		from Cols

		;with Nodes as
				(select *
					from #Nodes)
			, Cols as
				(select *
					from #Cols)
			, NodeColumns as
				(select 1 NodeType, CompRulID ID, ColOrdinal, cast(null as varchar(100)) SourceTableName, OriginalName, Alias, JoinOrdinal
					from #Cols
					union all
					select distinct 2 NodeType, CRN_ExpressionID ID, ColOrdinal, NodeName SourceTableName, OriginalName, Alias, JoinOrdinal
					from #Cols
					where CRN_IsNot = 0
						and (ColOrdinal is not null
								or JoinOrdinal is not null))
			, InheritedColumns as
				(select n.NodeType, n.ParentID ID, ColOrdinal, n.NodeName, OriginalName, Alias, JoinOrdinal
					from Nodes n
						inner join NodeColumns c on n.NodeType = c.NodeType
														and n.ID = c.ID
					where n.NodeType = 2
						and IsNot = 0
						and not exists (select *
											from Nodes n1
											where n1.NodeType = 2
												and n1.ParentID = n.ID)
				union all
				select i.NodeType, n.ParentID, ColOrdinal, n.NodeName, OriginalName, Alias, JoinOrdinal
				from InheritedColumns i
					inner join Nodes n on i.ID = n.ID
				where n.NodeType = 2
					and IsNot = 0
				)
			, AllColumns2 as
				(select *
					from InheritedColumns
					union
					select *
					from NodeColumns
				)
			, AllColumns1 as
				(select *
					from AllColumns2
					union
					select a.NodeType, null ID, ColOrdinal, n.NodeName, OriginalName, Alias, JoinOrdinal
					from Nodes n
						inner join AllColumns2 a on a.NodeType = n.NodeType
													and a.ID = n.ID
					where IsNot = 0
						and ParentID is null
						and ColOrdinal is not null
				)
			, AllColumns as
				(select *, MAX(JoinOrdinal) over (partition by ID) MaxJoinOrdinal
					from AllColumns1
				)
		select *
		into #AllColumns
		from AllColumns

		;with Nodes as
				(select *
					from #Nodes)
			, Cols as
				(select *
					from #Cols)
			, AllColumns as
				(select *
					from #AllColumns)
			, UniqueAliases as
				(select ID, Alias, max(ColOrdinal) ColOrdinal, min(OriginalName) ColName,
						min(case when ColOrdinal is null then 1 else 0 end) JoinOnly
					from AllColumns a
					where NodeType = 2
						and (ColOrdinal is not null
								or JoinOrdinal is not null)
						and Alias <> ''$MOB_ID$''
					group by ID, Alias
				)
			, ExternalNodes as
				(select ParentID NodeID, isnull(p.NodeName, ''RootExp'') NodeName,
						max(case when PerParentOrdinal = 1 then n.NodeType end) FirstNodeType,
						max(case when PerParentOrdinal = 1 then n.ID end) FirstNodeID,
						max(case when PerParentOrdinal = 1 then n.NodeName end) FirstNodeName,
						case when exists (select *
												from Nodes n1
													inner join AllColumns c on c.NodeType = n1.NodeType
																				and c.ID = n1.ID
												where (n1.ParentID = n.ParentID
														or (n1.ParentID is null
															and n.ParentID is null)
														)
													and c.Alias = ''$MOB_ID$'')
								then 1
								else 0
							end Returns_MOB_ID,
						case when exists (select *
												from Nodes n1
													inner join AllColumns c on c.NodeType = n1.NodeType
																				and c.ID = n1.ID
												where (n1.ParentID = n.ParentID
														or (n1.ParentID is null
															and n.ParentID is null)
														)
													and n1.IsNot = 0
													and c.ColOrdinal is not null)
								then 1
								else 0
							end Returns_Info
					from Nodes n
						outer apply (select p.NodeName
										from Nodes p
										where p.NodeType = 2
											and p.ID = n.ParentID) p
					group by ParentID, p.NodeName
				)
		select @SQL = ''with ''
					+ replace(replace(replace(replace(
					stuff((select '', '' + NodeName + '' as (select ''
						+ stuff((select '', '' + isnull(Aggregation + ''(cast('' + OriginalName + '' as bigint))'', OriginalName) + '' '' + quotename(Alias)
								from Cols c
								where c.CompRulID = n.ID
									and (ColOrdinal is not null
										or JoinOrdinal is not null)
								for xml path('''')), 1, 2, '''') + CHAR(13)+CHAR(10)
						+ ''from BusinessLogic.CompoundRuleNodes
								inner join BusinessLogic.PackageRunRules on PRR_PKN_ID = @PKN_ID
																			and PRR_RUL_ID = CRN_Node_RUL_ID
								inner join BusinessLogic.RuleViolations on RLV_PRR_ID = PRR_ID
								left join BusinessLogic.RuleThresholds on PRR_RTH_ID = RTH_ID
								left join (Inventory.MonitoredObjects
											inner join Inventory.Versions on VER_ID = MOB_VER_ID
											inner join Inventory.Editions on MOB_Engine_EDT_ID = EDT_ID) on MOB_ID = RLV_MOB_ID'' + CHAR(13)+CHAR(10)
						+ ''where CRN_ID = '' + CAST(ID as nvarchar(100)) + ''
							and (CRN_MinThresholdLevel is null
								or RTH_THL_ID >= CRN_MinThresholdLevel)
							and (CRN_MaxThresholdLevel is null
								or RTH_THL_ID <= CRN_MaxThresholdLevel)
							and (CRN_MinVersion is null
									or VER_Number >= CRN_MinVersion)
							and  (CRN_MaxVersion is null
									or VER_Number <= CRN_MaxVersion)
							and (CRN_Editions is null
									or EDT_Name in (select Val
													from Infra.fn_SplitString(CRN_Editions, '''';''''))
								)''
						+ isnull(CHAR(13)+CHAR(10)
								+ (select ''and '' + OriginalName + '' '' + FilterExpression
									from Cols
									where CompRulID = ID
										and FilterExpression is not null
									for xml path('''')), '''') + CHAR(13)+CHAR(10)
						+ isnull(''group by ''
								+ stuff((select '', '' + isnull(Aggregation + ''('' + OriginalName + '') '', '''') + OriginalName
										from Cols
										where CompRulID = ID
											and (ColOrdinal is not null
												or JoinOrdinal is not null)
											and Aggregation is null
											and exists (select *
															from Cols
															where CompRulID = ID
																and Aggregation is not null)
										for xml path('''')), 1, 2, ''''), '''') + '')''
					from Nodes n
					where NodeType = 1
					order by NodeOrdinal
					for xml path('''')), 1, 2, '''')
					+ (select char(13)+char(10) + '', '' + e.NodeName + '' as'' + char(13) + CHAR(10)
							+ ''(select ''
							+ case when Returns_MOB_ID = 1
									then ''coalesce(null, '' + FirstNodeName + ''.[$MOB_ID$]''
										+ isnull((select '', '' + NodeName + ''.[$MOB_ID$]''
													from Nodes n
													where (n.ParentID = e.NodeID
															or (n.ParentID is null
																and e.NodeID is null)
															)
														and n.PreceedingOperator = ''OR''
														and n.IsNot = 0
													for xml path('''')), '''')
										+ '') [$MOB_ID$]''
									else ''''
								end
							+ case when e.NodeID is not null or Returns_Info = 1 then '', '' else '''' end
							+ STUFF((select '', coalesce(null''
												+ (select '', '' + a.NodeName + ''.'' + quotename(a.Alias)
													from AllColumns a
													where a.NodeType = 2
														and (a.ID = u.ID
																or (a.ID is null
																	and u.ID is null)
															)
														and a.Alias = u.Alias
													for xml path(''''))
															+ '') '' + quotename(Alias)
									from UniqueAliases u
									where (u.ID = e.NodeID
											or (u.ID is null
												and e.NodeID is null)
											)
										and (u.ID is not null
											or JoinOnly = 0)
									order by ColOrdinal
									for xml path('''')), 1, 2, '''') + CHAR(13)+CHAR(10)
							+ ''from '' + FirstNodeName
							+ isnull((select char(13) + CHAR(10) + ''	'' + case PreceedingOperator
																				when ''AND'' then ''inner''
																				when ''OR'' then ''full outer''
																			end + '' join '' + NodeName + '' on ''
											+ replace((select Script + ''''
													from (select distinct c1.JoinOrdinal,
																	case when c1.JoinOrdinal > 1 then char(13)+char(10) + ''				and '' else '''' end
																		+ FirstNodeName + ''.'' + quotename(c1.Alias) + '' = '' + n.NodeName + ''.'' + quotename(c2.Alias) Script
																from AllColumns c1
																	inner join AllColumns c2 on c1.NodeType = FirstNodeType
																								and c1.ID = FirstNodeID
																								and c2.NodeType = n.NodeType
																								and c2.ID = n.ID
																								and c1.JoinOrdinal = c2.JoinOrdinal
															) t
													order by JoinOrdinal
													for xml path('''')), ''&#x0D;'', char(13))
										from Nodes n
										where (n.ParentID = e.NodeID
												or (n.ParentID is null
													and e.NodeID is null)
												)
											and n.PerParentOrdinal > 1
											and n.IsNot = 0
											and n.ID <> e.FirstNodeID
										order by n.PerParentOrdinal
										for xml path('''')
										), '''') + CHAR(13)+CHAR(10)
							+ isnull(''where'' + nullif(
										isnull(stuff((select '' or '' + n.NodeName + ''.''
															+ (select top 1 quotename(a.Alias)
																from AllColumns a
																where a.ID = n.ID
																	and JoinOrdinal = 1)
															 + '' is not null'' + CHAR(13)+char(10)
													from Nodes n
													where (n.ParentID = e.NodeID
															or (n.ParentID is null
																and e.NodeID is null)
															)
														and ((n.PreceedingOperator = ''OR''
																and n.IsNot = 0)
															or (ID = FirstNodeID
																and exists (select *
																			from Nodes n1
																			where (n1.ParentID = e.NodeID
																					or (n1.ParentID is null
																						and e.NodeID is null)
																					)
																				and n1.PreceedingOperator = ''OR''
																				and n1.IsNot = 0))
															)
													for xml path('''')), 1, 3, ''''), '''')
										+ isnull(stuff((select case PreceedingOperator
																	when ''AND'' then '' and''
																	when ''OR'' then ''     or''
																end
														+ '' not exists (select *'' + char(13)+char(10)
														+ ''			from '' + n.NodeName + char(13)+char(10)
														+ ''			where ''
														+ (select Script + ''''
															from (select distinct c1.JoinOrdinal,
																			case when c1.JoinOrdinal > 1 then char(13)+char(10) + ''				and '' else '''' end
																				+ FirstNodeName + ''.'' + quotename(c1.Alias) + '' = '' + n.NodeName + ''.'' + quotename(c2.Alias)
																				+ case when c2.MaxJoinOrdinal = c2.JoinOrdinal
																							or c1.MaxJoinOrdinal = c1.JoinOrdinal
																						then '')''
																						else ''''
																					end Script
																		from AllColumns c1
																			inner join AllColumns c2 on c1.NodeType = FirstNodeType
																										and c1.ID = FirstNodeID
																										and c2.NodeType = n.NodeType
																										and c2.ID = n.ID
																										and c1.JoinOrdinal = c2.JoinOrdinal
																	) t
															order by JoinOrdinal
															for xml path(''''))
													from Nodes n
													where (n.ParentID = e.NodeID
															or (n.ParentID is null
																and e.NodeID is null)
															)
														and n.PerParentOrdinal > 1
														and n.IsNot = 1
													order by n.PerParentOrdinal
													for xml path('''')), 1, 4, ''''), ''''), ''''), '''') + '')''
					from ExternalNodes e
					order by e.NodeID desc
					for xml path(''''))
					, ''&amp;'', ''&'')
					, ''&gt;'', ''>''), ''&lt;'', ''<''), ''&#x0D;'', char(13)) + char(13)+char(10)
					+ ''insert into BusinessLogic.RuleViolations(RLV_ClientID, RLV_PRR_ID' + isnull(@InsertColumns, '') + ')''
					+ ''select @ClientID, @PRR_ID''
					+ (select top 1 '', *''
						from ExternalNodes
						where NodeID is null
							and (Returns_MOB_ID = 1
									or Returns_Info = 1)
						) + char(13)+char(10)
					+ ''from RootExp'''
	
		insert into BusinessLogic.PackageRunRules(PRR_ClientID, PRR_PKN_ID, PRR_RUL_ID, PRR_StartDate)
		values(@ClientID, @PKN_ID, @RUL_ID, SYSDATETIME())
		set @PRR_ID = SCOPE_IDENTITY()

		select @RowCount = null,
				@ErrorMessage = null
		begin try
			exec sp_executesql @SQL,
								N'@RUL_ID int,
									@SQL nvarchar(max) output',
								@RUL_ID = @RUL_ID,
								@SQL = @SQL output

			exec sp_executesql @SQL,
								N'@PKN_ID int,
									@ClientID int,
									@PRR_ID int',
								@PKN_ID = @PKN_ID,
								@ClientID = @ClientID,
								@PRR_ID = @PRR_ID
							
			set @RowCount = @@ROWCOUNT
		end try
		begin catch
			set @ErrorMessage = ERROR_MESSAGE()
		end catch

		update BusinessLogic.PackageRunRules
		set PRR_EndDate = SYSDATETIME(),
			PRR_RowsReturned = @RowCount,
			PRR_ErrorMessage = @ErrorMessage
		where PRR_ID = @PRR_ID
	
		fetch next from cRules into @RUL_ID, @InsertColumns
	end
	close cRules
	deallocate cRules

	update BusinessLogic.PackageRuns
	set PKN_EndDate = SYSDATETIME()
	where PKN_ID = @PKN_ID
END
GO
