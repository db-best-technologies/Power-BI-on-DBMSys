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
/****** Object:  StoredProcedure [SYL].[usp_EndRun]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [SYL].[usp_EndRun]
	@RUN_ID int,
	@NumberOfErrors int,
	@ErrorMessage varchar(max) = null
as
set nocount on

update SYL.Runs
set RUN_EndDatetime = getdate(),
	RUN_NumberOfErrors = @NumberOfErrors,
	RUN_ErrorMessage = @ErrorMessage
where RUN_ID = @RUN_ID
GO
