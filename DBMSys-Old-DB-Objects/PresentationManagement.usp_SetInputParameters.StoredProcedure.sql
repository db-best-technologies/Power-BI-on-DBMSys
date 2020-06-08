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
/****** Object:  StoredProcedure [PresentationManagement].[usp_SetInputParameters]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [PresentationManagement].[usp_SetInputParameters]
	@PRN_ID int,
	@Parameters PresentationManagement.ttInputParameters readonly
as
update PresentationManagement.InputParameters
set IPR_Value = iif(IPR_IPD_ID <> 3, Value, null),
	IPR_BinaryValue = iif(IPR_IPD_ID = 3, BinaryValue, null)
from @Parameters
where IPR_PRN_ID = @PRN_ID
	and IPR_Name = ParameterName
GO
