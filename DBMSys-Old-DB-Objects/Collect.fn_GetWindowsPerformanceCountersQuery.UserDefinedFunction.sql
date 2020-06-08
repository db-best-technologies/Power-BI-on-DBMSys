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
/****** Object:  UserDefinedFunction [Collect].[fn_GetWindowsPerformanceCountersQuery]    Script Date: 6/8/2020 1:14:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [Collect].[fn_GetWindowsPerformanceCountersQuery](@TST_ID int,
														@CustomInstances Collect.ttInstanceList readonly) returns nvarchar(max)
as
begin
	declare @Command nvarchar(max)
	;with CounterData as
			(select PEC_CategoryName Category, PEC_CounterName [Counter], PEC_Instances Instances
				 from PerformanceData.PerformanceCounters
				where PEC_TST_ID = @TST_ID
					and PEC_IsActive = 1)
		, Category as
			(select distinct Category Name
				from CounterData)
		, [Counter] as
			(select distinct Category, [Counter] Name
				from CounterData)
		, Instance as
			(select Category, [Counter], Instance.value('@Name', 'nvarchar(128)') Name
				from CounterData
						cross apply Instances.nodes('Instances/Instance') x(Instance)
				union
				select distinct Category, [Counter].Name [Counter], I.Name
				from [Counter]
					cross join @CustomInstances I)
	select @Command =
			(select Name,
					(select Name,
							(select Name
								from Instance
								where Instance.Category = Category.Name
									and Instance.[Counter] = [Counter].Name
								for xml auto, type)
						from [Counter]
						where [Counter].Category = Category.Name
						for xml auto, type)
				from Category
				for xml auto, root('PerformanceRequest'))

	return @Command
end
GO
