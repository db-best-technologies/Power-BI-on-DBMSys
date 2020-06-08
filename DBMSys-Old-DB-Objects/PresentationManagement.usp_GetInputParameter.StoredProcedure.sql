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
/****** Object:  StoredProcedure [PresentationManagement].[usp_GetInputParameter]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [PresentationManagement].[usp_GetInputParameter]
	@PRN_ID int,
	@Code varchar(100)
as
declare @SQL nvarchar(max)
set @SQL =
'select ' + iif(exists (select *
						from PresentationManagement.InputParameters
						where IPR_PRN_ID = @PRN_ID
							and IPR_Code = @Code
							and IPR_IPD_ID <> 3), 'IPR_Value', 'IPR_BinaryValue') + ' [Value]
from PresentationManagement.InputParameters
where IPR_PRN_ID = @PRN_ID
	and IPR_Code = @Code'

exec sp_executesql @SQL,
				N'@PRN_ID int,
					@Code varchar(100)',
				@PRN_ID = @PRN_ID,
				@Code = @Code
GO
