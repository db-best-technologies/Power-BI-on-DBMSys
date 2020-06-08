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
/****** Object:  StoredProcedure [Internal].[usp_GenerateJoin]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Internal].[usp_GenerateJoin]
	@TableName nvarchar(257)
as
select concat('from ', @TableName) Script
union all
select *
from (select top 1024 concat('	inner join ', s.name + '.' + t.name, ' on ', c2.name, ' = ', c1.name) Script
		from sys.columns c1
			inner join sys.columns c2 on c2.column_id = 1
											and c2.name = right(c1.name, 6)
											and c2.name <> c1.name
			inner join sys.tables t on t.object_id = c2.object_id
			inner join sys.schemas s on s.schema_id = t.schema_id
		where c1.object_id = object_id(@TableName)
		order by c1.column_id) t
GO
