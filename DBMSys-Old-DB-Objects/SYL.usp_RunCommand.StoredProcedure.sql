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
/****** Object:  StoredProcedure [SYL].[usp_RunCommand]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [SYL].[usp_RunCommand]
	@QueryType [int],
	@ServerList [nvarchar](max),
	@Command [nvarchar](max),
	@RUN_ID [int] OUTPUT,
	@Database [nvarchar](128) = N'',
	@IsResultExpected [bit] = True,
	@OutputTables [nvarchar](257) = N'',
	@ConnectionTimeout [int] = 30,
	@QueryTimeout [int] = 0,
	@MetadataColumns [nvarchar](4000) = N''
WITH EXECUTE AS CALLER
AS
EXTERNAL NAME [SYL].[SYL].[usp_RunCommand]
GO
