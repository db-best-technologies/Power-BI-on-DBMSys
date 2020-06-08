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
/****** Object:  UserDefinedFunction [Tests].[fn_TST_OperatingSystemEventLog]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [Tests].[fn_TST_OperatingSystemEventLog](@TST_ID int,
													@MOB_ID int,
													@Command nvarchar(max)) returns nvarchar(max)
begin
	declare @OutputCommand nvarchar(max)

	select @OutputCommand = replace(Collect.fn_InsertTestObjectLastValue(@TST_ID, @MOB_ID, @Command), 
									'%MACHINENAME%',
									MOB_Name)
	from Inventory.MonitoredObjects
	where MOB_ID = @MOB_ID
	
	return @OutputCommand
end
GO
