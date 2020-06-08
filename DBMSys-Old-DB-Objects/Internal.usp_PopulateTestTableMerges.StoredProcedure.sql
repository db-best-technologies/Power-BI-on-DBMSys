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
/****** Object:  StoredProcedure [Internal].[usp_PopulateTestTableMerges]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Internal].[usp_PopulateTestTableMerges]
as
set nocount on
truncate table Internal.TestTableMerges

;with Merges as
		(select TST_ID, s.name SchemaName, t.name TableName,
				replace(replace(replace(replace(replace(replace(SUBSTRING(m.[definition], CHARINDEX('merge ' + s.name + '.' + t.name, m.[definition], 1), 2000), CHAR(13), ' '), CHAR(10), ' '), CHAR(9), ' ')
							, '  ', ' ^'), '^ ', ''), '^', '')  Def
			from Collect.Tests
				inner join (sys.objects o
							inner join sys.schemas rs on rs.[schema_id] = o.[schema_id])
					on TST_OutputTable = rs.name + '.' + o.name
				inner join sys.triggers r on r.parent_id = o.[object_id]
				inner join sys.sql_modules m on m.[object_id] = r.[object_id]
				inner join (sys.tables t 
								inner join sys.schemas s on s.[schema_id] = t.[schema_id])
					on m.[definition] like '%merge ' + s.name + '.' + t.name + '%'
		)
		, Merges1 as
		(select TST_ID, SchemaName, TableName,
				case when (CHARINDEX('when not matched', Def, 1) < CHARINDEX('when matched', Def, 1)
								and CHARINDEX('when not matched', Def, 1) > 0)
							or CHARINDEX('when matched', Def, 1) = 0
					then LEFT(Def, CHARINDEX('when not matched', Def, 1) - 2)
					else LEFT(Def, CHARINDEX('when matched', Def, 1) - 2)
				end Def
			from Merges)
		, Merges2 as
		(select TST_ID, SchemaName, TableName, substring(Def, LEN(Def) - CHARINDEX(' no ', REVERSE(Def), 1) + 2, 1000) Def
			from Merges1)
		, Merges3 as
		(select TST_ID, SchemaName, TableName,
				' ' + replace(replace(replace(case when Def like '%when matched%'
													then left(Def, CHARINDEX('when matched', Def, 1) - 2)
													else Def
												end, '=' , ' '), '(', ' '), ')', ' ') + ' ' Def
			from Merges2
		)
insert into Internal.TestTableMerges(TTM_TST_ID, TTM_SchemaName, TTM_TableName, TTM_ColumnOrder, TTM_ColumnName)
select TST_ID, SchemaName, TableName, ROW_NUMBER() over (partition by TST_ID, SchemaName, TableName order by charindex(c.name, Def, 1)) Id, c.name ColumnName
from Merges3
	inner join sys.columns c on c.[object_id] = object_id(SchemaName + '.' + TableName)
												and Def like '% ' + c.name + ' %'
GO
