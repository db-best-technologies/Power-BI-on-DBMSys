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
/****** Object:  UserDefinedFunction [Tests].[fn_TST_PossibleIndexProblems]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [Tests].[fn_TST_PossibleIndexProblems](@TST_ID int,
											@MOB_ID int,
											@Command nvarchar(max)) returns nvarchar(max)
begin
	declare @OutputCommand nvarchar(max)

	set @OutputCommand = REPLACE(Collect.fn_ForEachDBGenerator(@TST_ID, @MOB_ID, @Command), '%MONITORINGDATABASENAME%', DB_NAME())
	
	return @OutputCommand
end
GO
