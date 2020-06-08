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
/****** Object:  UserDefinedFunction [Tests].[fn_TST_DiskPerformanceCounters]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [Tests].[fn_TST_DiskPerformanceCounters](@TST_ID int,
								@MOB_ID int,
								@Command nvarchar(max)) returns nvarchar(max)
begin
	declare @OutputCommand nvarchar(max),
			@CustomInstances Collect.ttInstanceList,
			@ErrorMessage nvarchar(2000)

	select top 1 @ErrorMessage = TRH_ErrorMessage
	from Collect.TestRunHistory
	where TRH_TST_ID = 16
		and TRH_MOB_ID = @MOB_ID
		and TRH_TRS_ID in (3, 4)
	order by TRH_StartDate desc

	insert into @CustomInstances
	select case when DSK_Path like '%\' then left(DSK_Path, len(DSK_Path) - 1) else DSK_Path end
	from Inventory.Disks
	where DSK_MOB_ID = @MOB_ID
		and (@ErrorMessage not like '%Instance ''' + DSK_Path + ''' does not exist in the specified Category.%'
				or @ErrorMessage is null)
		and DSK_Path not like '%?%'
	
	set @OutputCommand = Collect.fn_GetWindowsPerformanceCountersQuery(@TST_ID, @CustomInstances)
	return @OutputCommand
end
GO
