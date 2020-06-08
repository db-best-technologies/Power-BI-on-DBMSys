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
/****** Object:  UserDefinedFunction [Tests].[fn_TST_WindowsVolumes]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Tests].[fn_TST_WindowsVolumes](@TST_ID int,
								@MOB_ID int,
								@Command nvarchar(max)) returns nvarchar(max)
begin
declare @ReturnValue nvarchar(max)
	if not exists(select *
					from Collect.fn_GetObjectTests(4)
					where not exists (select *
										from Collect.TestRunHistory
										where TST_ID = TRH_TST_ID
											and MOB_ID = TRH_MOB_ID
											and TRH_EndDate is not null)
					)
		set @ReturnValue = @Command
	else
		set @ReturnValue = null
	return @ReturnValue
end
GO
