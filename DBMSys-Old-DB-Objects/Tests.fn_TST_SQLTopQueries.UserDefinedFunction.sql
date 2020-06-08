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
/****** Object:  UserDefinedFunction [Tests].[fn_TST_SQLTopQueries]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Tests].[fn_TST_SQLTopQueries](@TST_ID int,
								@MOB_ID int,
								@Command nvarchar(max)) returns nvarchar(max)
begin
	declare @NumberOfTopQueriesPerInstance int,
			@MinServerOnlineHours int

	select @NumberOfTopQueriesPerInstance = cast(SET_Value as int)
	from Management.Settings
	where SET_Module = 'Tests'
		and SET_Key = 'Top Queries Number of Per Instance and Resource Type'

	select @MinServerOnlineHours = cast(SET_Value as int)
	from Management.Settings
	where SET_Module = 'Tests'
		and SET_Key = 'Top Queries Minimal Number of Online Hours'

	return replace(replace(@Command, '%NUMBEROFTOPQUERIESPERINSTANCE%', isnull(cast(@NumberOfTopQueriesPerInstance as nvarchar(max)), N'10')),
														'%MINSERVERONLINEHOURS%', isnull(cast(@MinServerOnlineHours as nvarchar(max)), N'24'))
end
GO
