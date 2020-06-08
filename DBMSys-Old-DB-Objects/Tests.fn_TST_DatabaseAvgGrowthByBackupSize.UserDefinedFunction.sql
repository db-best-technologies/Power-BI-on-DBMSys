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
/****** Object:  UserDefinedFunction [Tests].[fn_TST_DatabaseAvgGrowthByBackupSize]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Tests].[fn_TST_DatabaseAvgGrowthByBackupSize](@TST_ID int,
								@MOB_ID int,
								@Command nvarchar(max)) returns nvarchar(max)
begin
declare @ReturnValue nvarchar(max),
		@MonthsBackToCheck int
	
	if exists(select *
				from Collect.TestRunHistory
				where TRH_TST_ID = 8
					and TRH_MOB_ID = @MOB_ID
					and TRH_TRS_ID = 3
				)
	begin
		select @MonthsBackToCheck = CAST(SET_Value as int)
		from Management.Settings
		where SET_Module = 'Tests'
			and SET_Key = 'Database Avg Growth By Backup Size Months Back To Check'

		set @ReturnValue = replace(@Command, '%MONTHSBACKTOCHECK%', cast(@MonthsBackToCheck as varchar(10)))
	end
	else
		set @ReturnValue = null
	return @ReturnValue
end
GO
