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
/****** Object:  StoredProcedure [EventProcessing].[usp_RemoveExpiredIncludeExcludeRules]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [EventProcessing].[usp_RemoveExpiredIncludeExcludeRules]
as
set nocount on
delete EventProcessing.EventIncludeExclude
where EIE_ValidForMinutes is not null
	and EIE_InsertDate < DATEADD(minute, -EIE_ValidForMinutes, SYSDATETIME())
GO
