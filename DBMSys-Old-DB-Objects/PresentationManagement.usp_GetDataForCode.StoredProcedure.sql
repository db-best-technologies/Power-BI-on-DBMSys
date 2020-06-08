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
/****** Object:  StoredProcedure [PresentationManagement].[usp_GetDataForCode]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [PresentationManagement].[usp_GetDataForCode]
	@PRN_ID int,
	@Code varchar(100),
	@QueryOutputType tinyint = null output,
	@Header varchar(250) = null output
as
set nocount on
declare @Query nvarchar(max),
		@FormattingProcedure nvarchar(257),
		@SQL nvarchar(max)

select @Query = PCQ_Query,
	@FormattingProcedure = QOT_FormattingProcedure,
	@QueryOutputType = QOT_ID,
	@Header = PCQ_Header
from PresentationManagement.PresentationCodeToQueryMapping
	inner join PresentationManagement.QueryOutputTypes on QOT_ID = PCQ_QOT_ID
where PCQ_PRN_ID = @PRN_ID
	and PCQ_Code = @Code

if @Query is null
begin
	raiserror('Code %s not found', 16, 1, @Code)
	return
end
set @SQL = concat('exec ', @FormattingProcedure + ' @PRN_ID, @Code, ''', @Query,
							iif(@FormattingProcedure is null, '', '''')
				)

exec sp_executesql @SQL,
				N'@PRN_ID int,
				@Code varchar(100)',
				@PRN_ID = @PRN_ID,
				@Code = @Code
GO
