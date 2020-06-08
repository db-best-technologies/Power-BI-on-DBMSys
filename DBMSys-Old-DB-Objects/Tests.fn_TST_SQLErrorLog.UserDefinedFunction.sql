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
/****** Object:  UserDefinedFunction [Tests].[fn_TST_SQLErrorLog]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Tests].[fn_TST_SQLErrorLog](@TST_ID int,
								@MOB_ID int,
								@Command nvarchar(max)) returns nvarchar(max)
begin
	declare @OutputCommand nvarchar(max),
			@MaxAge int
	set @OutputCommand = Collect.fn_InsertTestObjectLastValue(@TST_ID, @MOB_ID, @Command)
	
	select @MaxAge = cast(SET_Value as int)
	from Management.Settings
	where SET_Module = 'Tests'
		and SET_Key = 'SQL ErrorLog Max Allowed Hours'

	set @OutputCommand = replace(@OutputCommand, '%MAXALLOWEDAGE%', isnull(cast(@MaxAge as nvarchar(max)), N'36'))
	return @OutputCommand
end
GO
