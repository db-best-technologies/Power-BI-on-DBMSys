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
/****** Object:  StoredProcedure [ManagementInterface].[usp_Settings_Update]    Script Date: 6/8/2020 1:14:33 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [ManagementInterface].[usp_Settings_Update]
	@Module varchar(100),
	@Key varchar(100),
	@Description varchar(1000),
	@Value nvarchar(4000)
as
update Management.Settings
set SET_Description = @Description,
	SET_Value = cast(@Value as sql_Variant)
where SET_Module = @Module
	and SET_Key = @Key
GO
