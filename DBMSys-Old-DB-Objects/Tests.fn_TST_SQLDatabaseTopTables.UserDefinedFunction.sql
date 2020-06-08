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
/****** Object:  UserDefinedFunction [Tests].[fn_TST_SQLDatabaseTopTables]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Tests].[fn_TST_SQLDatabaseTopTables](@TST_ID int,
								@MOB_ID int,
								@Command nvarchar(max)) returns nvarchar(max)
begin
	declare @Top int
	select @Top = CAST(SET_Value as int)
	from Management.Settings
	where SET_Module = 'Tests'
		and SET_Key = 'Top Database Tables Count Per Database'

	return replace(replace(Collect.fn_ForEachDBGenerator(@TST_ID, @MOB_ID, @Command), '%COMPRESSION%',
						case when (select VER_Number
									from Inventory.MonitoredObjects
										inner join Inventory.Versions on MOB_VER_ID = VER_ID
									where MOB_ID = @MOB_ID) >= 10
							then 'sum(case when p.data_compression > 0 and p.index_id = 1 and a.type = 1 then 1 else 0 end)*100/(sum(case when p.index_id = 1 then 1 else 0 end) + 1)'
							else '0'
						end), '%TOP%', cast(@Top as nvarchar(10)))
end
GO
