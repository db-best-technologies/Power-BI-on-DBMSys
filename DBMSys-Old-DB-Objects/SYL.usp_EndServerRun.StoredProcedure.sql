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
/****** Object:  StoredProcedure [SYL].[usp_EndServerRun]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [SYL].[usp_EndServerRun]
	@SRR_ID int,
	@RecordsAffected int,
	@ErrorMessage varchar(max)
as
set nocount on

update SYL.ServerRunResult
set SRR_EndDate = getdate(),
	SRR_RecordsAffected = @RecordsAffected,
	SRR_ErrorMessage = @ErrorMessage
WHERE SRR_ID = @SRR_ID
GO
