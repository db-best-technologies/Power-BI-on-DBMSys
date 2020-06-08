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
/****** Object:  UserDefinedFunction [Collect].[fn_InsertTestObjectLastValue]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Collect].[fn_InsertTestObjectLastValue](@TST_ID int,
													@MOB_ID int,
													@Command nvarchar(max)) returns nvarchar(max)
begin
	declare @OutputCommand nvarchar(max),
			@LastValue nvarchar(max)

	select @LastValue = TOL_Value
	from Collect.TestObjectLastValues
	where TOL_TST_ID = @TST_ID
		and TOL_MOB_ID = @MOB_ID
	
	if @LastValue is null
		select @LastValue = TST_DefaultLastValue
		from Collect.Tests
		where TST_ID = @TST_ID
	
	set @OutputCommand = replace(@Command, '%LASTVALUE%', @LastValue)
	return @OutputCommand
end
GO
