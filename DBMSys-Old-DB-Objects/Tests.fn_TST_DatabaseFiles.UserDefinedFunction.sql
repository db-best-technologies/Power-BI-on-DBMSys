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
/****** Object:  UserDefinedFunction [Tests].[fn_TST_DatabaseFiles]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Tests].[fn_TST_DatabaseFiles](@TST_ID int,
								@MOB_ID int,
								@Command nvarchar(max)) returns nvarchar(max)
begin
declare @ReturnValue nvarchar(max)
	if exists(select *
				from Collect.fn_GetObjectTests(default) dt
					inner join Inventory.MonitoredObjects w on w.MOB_PLT_ID = 2
															and dt.MOB_ID = w.MOB_ID
					JOIN Inventory.OSServers ON w.MOB_ID = OSS_MOB_ID
					inner join Inventory.DatabaseInstanceDetails on /*w.MOB_Entity_ID*/ OSS_ID = DID_OSS_ID
					inner join Inventory.MonitoredObjects d on d.MOB_PLT_ID = 1
															and DID_DFO_ID = d.MOB_Entity_ID
				where d.MOB_ID = @MOB_ID
					and TST_ID = 5
				)
		set @ReturnValue = Collect.fn_ForEachDBGenerator(@TST_ID, @MOB_ID, @Command)
	else
		set @ReturnValue = null
	return @ReturnValue
end
GO
