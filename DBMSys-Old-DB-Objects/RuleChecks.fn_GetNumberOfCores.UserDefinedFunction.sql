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
/****** Object:  UserDefinedFunction [RuleChecks].[fn_GetNumberOfCores]    Script Date: 6/8/2020 1:14:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [RuleChecks].[fn_GetNumberOfCores](@MOB_ID int) returns table
as
	return (select PSN_Name ProcessorName, min(PRS_ID) ProcessorID,
					sum(case when PRS_NumberOfCores is null
								or (PRS_NumberOfCores = 1
										and (PSN_Name like '%Quad%'
												or PSN_Name like '%Dual%')
									)
							then case when PSN_Name like '%Quad%' then 4
										when PSN_Name like '%Dual%' then 2
										else 1
									end
							else PRS_NumberOfCores
						end) Cores, COUNT(*) PhysicalSockets
				from Inventory.Processors
					inner join Inventory.ProcessorNames on PSN_ID = PRS_PSN_ID
				where PRS_MOB_ID = @MOB_ID
				group by PSN_Name)
GO
