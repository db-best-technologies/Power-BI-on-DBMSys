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
/****** Object:  StoredProcedure [SYL].[usp_SimpleWrapper]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [SYL].[usp_SimpleWrapper]
	@ServerList nvarchar(max),
	@Command nvarchar(max),
	@OutputTable nvarchar(257) = null,
	@IsResultExpected bit = 1
as
set nocount on
declare @l_ServerList nvarchar(max),
		@RUN_ID int = 0,
		@ErrorMessage nvarchar(2000)
set @l_ServerList = REPLACE(REPLACE(@ServerList + ';', ';', '|1;'), ';|1;', ';')
begin try
	exec SYL.usp_RunCommand
		@QueryType = 1
		, @ServerList = @l_ServerList
		, @Command = @Command
		, @RUN_ID = @RUN_ID output
		, @QueryTimeout = 0
		, @IsResultExpected = @IsResultExpected
		, @OutputTable = @OutputTable
end try
begin catch
	set @ErrorMessage = ERROR_MESSAGE()
end catch
if @ErrorMessage is null
begin
	select @ErrorMessage = RUN_ErrorMessage 
	from SYL.Runs
	where RUN_ID = @RUN_ID
	
	if @ErrorMessage is null
		select top 1 @ErrorMessage = SRR_ErrorMessage
		from SYL.ServerRunResult
		where SRR_RUN_ID = @RUN_ID
			and SRR_ErrorMessage is not null
end

if @ErrorMessage is not null
	raiserror(@ErrorMessage, 16, 1)
GO
