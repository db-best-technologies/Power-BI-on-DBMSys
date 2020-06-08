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
/****** Object:  UserDefinedFunction [PerformanceData].[fn_GetPerformanceValue]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [PerformanceData].[fn_GetPerformanceValue](@MOB_ID int,
														@SystemID int,
														@CounterID int,
														@InstanceName varchar(900),
														@DateTime datetime2(3)) returns table
	return (select CRS_Value Value
		
	from PerformanceData.CounterResults
				left join PerformanceData.CounterInstances on CRS_InstanceID = CIN_ID
			where CRS_MOB_ID = @MOB_ID
				and CRS_SystemID = @SystemID
				and CRS_CounterID = @CounterID
				and CRS_DateTime = @DateTime
				and (CIN_Name = @InstanceName
						or (@InstanceName is  null
								and CRS_InstanceID is null)
						)
			)
GO
