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
/****** Object:  UserDefinedFunction [EventProcessing].[fn_ParseEventFilter]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [EventProcessing].[fn_ParseEventFilter](@PossibleFilters xml,
													@FilterDefinition xml) returns nvarchar(max)
as
begin
	declare @FilterString nvarchar(max)
	;with PossibleFilters as
			(select f.value('@Name', 'nvarchar(128)') FilterName,
					f.value('@IsQuoted', 'bit') IsQuoted,
					f.value('@ColumnName', 'nvarchar(128)') ColumnName
				from @PossibleFilters.nodes('FilterCollection/Filter') t(f))
		, DefinedFilters as
			(select d.value('@Name', 'nvarchar(128)') FilterName,
						d.value('@Operator', 'varchar(100)') Operator,
						d.value('@Value', 'nvarchar(max)') Value
				from @FilterDefinition.nodes('FilterCollection/Filter') t(d))
	select @FilterString = replace(replace(replace(stuff(
			(select ' and '
						+ p.ColumnName + ' '
						+ d.Operator + ' '
						+ isnull(case when p.IsQuoted = 1 then '''' else '' end
									+ d.Value
									+ case when p.IsQuoted = 1 then '''' else '' end, 'null')
				from PossibleFilters p
					inner join DefinedFilters d on p.FilterName = d.FilterName
				where d.FilterName is not null
					and d.Operator is not null
				for xml path('')), 1, 5, ''), '&gt;', '>'), '&lt;', '<'), '&amp;', '&')

	return @FilterString
end
GO
