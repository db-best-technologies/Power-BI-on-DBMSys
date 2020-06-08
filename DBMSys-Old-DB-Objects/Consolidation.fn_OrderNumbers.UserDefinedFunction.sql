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
/****** Object:  UserDefinedFunction [Consolidation].[fn_OrderNumbers]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Consolidation].[fn_OrderNumbers](@CLB_ID int, @NewNumber int) returns table
as
	return select cast(stuff((select ',' + cast(Val as varchar(10))
								from (select CBL_LBL_ID Val
										from Consolidation.ConsolidationBlocks_LoadBlocks
										where CBL_CLB_ID = @CLB_ID
										union all
										select @NewNumber Val
										where @NewNumber is not null) t
								order by Val
								for xml path('')), 1, 1, '') as varchar(892)) Sorted --Sized to fit inside an index
GO
