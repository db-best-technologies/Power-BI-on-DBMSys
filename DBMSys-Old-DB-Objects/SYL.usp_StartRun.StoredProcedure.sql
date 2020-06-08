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
/****** Object:  StoredProcedure [SYL].[usp_StartRun]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [SYL].[usp_StartRun]
	@ServerList varchar(max),
	@QueryType tinyint,
	@Database nvarchar(255),
	@Command nvarchar(max),
	@ExpectsResults bit
as
set nocount on

insert into SYL.Runs(RUN_ServerList, RUN_QRT_ID, RUN_Database, RUN_Command, RUN_ExpectsResults)
select @ServerList, @QueryType, @Database , @Command, @ExpectsResults

select scope_identity() RUN_ID
GO
